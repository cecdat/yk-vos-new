package commander

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/segmentio/kafka-go"
	"github.com/yk-vos/ykvos-agent/internal/config"
	"github.com/yk-vos/ykvos-agent/internal/puller"
	"github.com/yk-vos/ykvos-agent/internal/scanner"
	"github.com/yk-vos/ykvos-agent/internal/sink"
)

type CommandMessage struct {
	VosID     string                 `json:"vos_id"`
	CommandID string                 `json:"command_id"`
	Action    string                 `json:"action"`
	Tables    []string               `json:"tables"`
	Mode      string                 `json:"mode"`
	Cron      string                 `json:"cron"`
	Params    map[string]interface{} `json:"params"`
}

type Commander struct {
	vosID          string
	db             *sql.DB
	cfg            config.Kafka
	reader         *kafka.Reader
	sinker         *sink.KafkaSink
	backfillWorker *puller.BackfillWorker
	scanner        *scanner.Scanner
	startCh        chan struct{} // 由服务端 start 指令关闭，通知 main 启动 puller
	startOnce      sync.Once
}

func NewCommander(
	vosID string,
	db *sql.DB,
	cfg config.Kafka,
	sinker *sink.KafkaSink,
	backfillWorker *puller.BackfillWorker,
	scanner *scanner.Scanner,
	startCh chan struct{},
) *Commander {
	// 创建消费者读取 vos.agent.command 里的指令
	reader := kafka.NewReader(kafka.ReaderConfig{
		Brokers:  cfg.Brokers,
		Topic:    "vos.agent.command",
		GroupID:  "agent-command-group-" + vosID, // 确保每个 Agent 拥有独立的消费分组以获取全量指令广播
		MinBytes: 10,
		MaxBytes: 1e6,
	})

	return &Commander{
		vosID:          vosID,
		db:             db,
		cfg:            cfg,
		reader:         reader,
		sinker:         sinker,
		backfillWorker: backfillWorker,
		scanner:        scanner,
		startCh:        startCh,
	}
}

func (c *Commander) Start(ctx context.Context) {
	log.Printf("[Commander] 监听 vos.agent.command 队列指令...")
	// 关键诊断信息：本 Agent 仅接收与自身 instance.id 完全一致的 vos_id 指令。
	// 若后端下发的 vos_id（即 vos_instance.vos_id）与此不一致，所有指令都会被静默丢弃，
	// 表现为「点击重新扫描/下发，服务端返回成功但 Agent 毫无反应」。
	log.Printf("[Commander] 本实例 vos_id=%s，仅接收匹配此 ID 的指令（topic=vos.agent.command）", c.vosID)
	defer c.reader.Close()

	for {
		select {
		case <-ctx.Done():
			log.Printf("[Commander] 停止指令监听协程")
			return
		default:
		}

		m, err := c.reader.ReadMessage(ctx)
		if err != nil {
			if ctx.Err() != nil {
				return
			}
			log.Printf("[Commander] 读取 Kafka 指令消息失败: %v", err)
			time.Sleep(1 * time.Second)
			continue
		}

		var cmd CommandMessage
		if err := json.Unmarshal(m.Value, &cmd); err != nil {
			log.Printf("[Commander] 解析指令 JSON 失败: %v, payload: %s", err, string(m.Value))
			continue
		}

		// 仅处理发给本 VOS Agent 实例的指令
		if cmd.VosID != c.vosID {
			log.Printf("[Commander] 丢弃非本实例指令: 收到 vos_id=%s, 本实例 vos_id=%s, action=%s",
				cmd.VosID, c.vosID, cmd.Action)
			continue
		}

		log.Printf("[Commander] 收到本实例专属指令: commandId=%s, action=%s", cmd.CommandID, cmd.Action)
		
		// 路由分发
		err = c.dispatch(ctx, &cmd)
		// start / rescan / precise_count 为一次性指令，服务端无对应任务行，无需 ACK（避免刷 warn 日志）
		if cmd.Action != "start" && cmd.Action != "rescan" && cmd.Action != "precise_count" {
			c.sendAck(cmd.CommandID, cmd.Action, err)
		}
	}
}

// signalStart 通知 main 协程：服务端已授权推送，可以启动 puller。
// 用 sync.Once 保证即使收到重复 start 也不会重复 close channel。
func (c *Commander) signalStart() {
	c.startOnce.Do(func() {
		log.Printf("[Commander] 收到服务端 start 指令，解除数据推送门闸")
		close(c.startCh)
	})
}

func (c *Commander) dispatch(ctx context.Context, cmd *CommandMessage) error {
	switch cmd.Action {
	case "start":
		// 服务端已确认 VOS 节点并授权推送：打开启动门闸（main 在等待此信号）。
		// 收到 start 不代表要做什么具体工作，真正的同步由 backfill_start / 各业务指令驱动。
		c.signalStart()
		return nil

	case "backfill_start":
		speedLimit := int64(0)
		if cmd.Params != nil {
			if limitVal, ok := cmd.Params["speed_limit"]; ok {
				if num, ok := limitVal.(float64); ok {
					speedLimit = int64(num)
				}
			}
		}
		return c.backfillWorker.StartBackfill(cmd.CommandID, cmd.Tables, speedLimit)

	case "pause":
		c.backfillWorker.Pause()
		return nil

	case "resume":
		c.backfillWorker.Resume()
		return nil

	case "cancel":
		c.backfillWorker.Cancel()
		return nil

	case "set_throttle":
		speedLimit := int64(0)
		if cmd.Params != nil {
			if limitVal, ok := cmd.Params["speed_limit"]; ok {
				if num, ok := limitVal.(float64); ok {
					speedLimit = int64(num)
				}
			}
		}
		c.backfillWorker.SetThrottle(speedLimit)
		return nil

	case "rescan":
		// 在后台异步扫描，不阻塞主指令循环
		go func() {
			err := c.scanner.ScanAndReport(context.Background())
			if err != nil {
				log.Printf("[Commander] 执行 rescan 上报失败: %v", err)
			}
		}()
		return nil

	case "precise_count":
		// 精确行数统计 COUNT(*)，异步慢查询
		if len(cmd.Tables) > 0 {
			tableName := cmd.Tables[0]
			go c.runPreciseCount(tableName)
		}
		return nil

	default:
		return fmt.Errorf("未知指令 action: %s", cmd.Action)
	}
}

func (c *Commander) runPreciseCount(tableName string) {
	log.Printf("[Commander] 异步发起日表 %s 的精确 COUNT(*) 统计...", tableName)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Minute)
	defer cancel()

	var count int64
	q := fmt.Sprintf("SELECT COUNT(1) FROM `%s`", tableName)
	err := c.db.QueryRowContext(ctx, q).Scan(&count)
	if err != nil {
		log.Printf("[Commander] 精确统计表 %s 行数出错: %v", tableName, err)
		return
	}

	log.Printf("[Commander] 表 %s 精确行数: %d，上报至平台", tableName, count)
	payload := map[string]interface{}{
		"vos_id":       c.vosID,
		"msg_type":     "precise_rows",
		"generated_at": time.Now().Format(time.RFC3339),
		"table":        tableName,
		"precise_rows": count,
	}

	bytes, _ := json.Marshal(payload)
	// 上报至 vos.agent.report topic
	_ = c.sinker.WriteRaw(context.Background(), "vos.agent.report", c.vosID, bytes)
}

func (c *Commander) sendAck(commandID, action string, err error) {
	result := "ok"
	errMsg := ""
	if err != nil {
		result = "error"
		errMsg = err.Error()
	}

	payload := map[string]interface{}{
		"vos_id":       c.vosID,
		"msg_type":     "ack",
		"generated_at": time.Now().Format(time.RFC3339),
		"command_id":   commandID,
		"action":       action,
		"result":       result,
		"result_msg":   errMsg,
		"at":           time.Now().Format(time.RFC3339),
	}

	bytes, _ := json.Marshal(payload)
	// 上报至 vos.agent.report topic
	sendErr := c.sinker.WriteRaw(context.Background(), "vos.agent.report", c.vosID, bytes)
	if sendErr != nil {
		log.Printf("[Commander] 指令 ACK 上报 Kafka 失败: %v", sendErr)
	} else {
		log.Printf("[Commander] 指令 ACK 上报成功: commandId=%s, result=%s", commandID, result)
	}
}
