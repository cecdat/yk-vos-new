package commander

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"regexp"
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
	vosAPICfg      config.VosAPI
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
	vosAPICfg config.VosAPI,
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
		vosAPICfg:      vosAPICfg,
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

	case "update_limit":
		if cmd.Params == nil {
			return errors.New("missing params for update_limit")
		}
		custIDVal, ok1 := cmd.Params["customerId"]
		limitVal, ok2 := cmd.Params["limitmoney"]
		if !ok1 || !ok2 {
			return errors.New("missing customerId or limitmoney in params")
		}
		var customerID int
		if f, ok := custIDVal.(float64); ok {
			customerID = int(f)
		} else {
			return fmt.Errorf("invalid customerId type: %T", custIDVal)
		}
		var limitmoney float64
		if f, ok := limitVal.(float64); ok {
			limitmoney = f
		} else {
			return fmt.Errorf("invalid limitmoney type: %T", limitVal)
		}
		if limitmoney < -100000.0 || limitmoney > 100000.0 {
			return fmt.Errorf("limitmoney %f out of safe bounds [-100000, 100000]", limitmoney)
		}
		_, err := c.db.ExecContext(ctx, "UPDATE e_customer SET limitmoney = ? WHERE id = ?", limitmoney, customerID)
		if err != nil {
			return fmt.Errorf("failed to update limitmoney: %w", err)
		}
		log.Printf("[Commander] 额度调整指令执行成功: customerId=%d, limitmoney=%f", customerID, limitmoney)
		return nil

	case "set_status":
		if cmd.Params == nil {
			return errors.New("missing params for set_status")
		}
		custIDVal, ok1 := cmd.Params["customerId"]
		statusVal, ok2 := cmd.Params["status"]
		if !ok1 || !ok2 {
			return errors.New("missing customerId or status in params")
		}
		var customerID int
		if f, ok := custIDVal.(float64); ok {
			customerID = int(f)
		} else {
			return fmt.Errorf("invalid customerId type: %T", custIDVal)
		}
		var status int
		if f, ok := statusVal.(float64); ok {
			status = int(f)
		} else {
			return fmt.Errorf("invalid status type: %T", statusVal)
		}
		if status != 0 && status != 1 {
			return fmt.Errorf("invalid status value: %d (only 0 or 1 allowed)", status)
		}
		_, err := c.db.ExecContext(ctx, "UPDATE e_customer SET status = ? WHERE id = ?", status, customerID)
		if err != nil {
			return fmt.Errorf("failed to update status: %w", err)
		}
		log.Printf("[Commander] 客户状态切换成功: customerId=%d, status=%d", customerID, status)
		return nil

	case "recycle_phone":
		if cmd.Params == nil {
			return errors.New("missing params for recycle_phone")
		}
		e164sVal, ok := cmd.Params["e164s"]
		if !ok {
			return errors.New("missing e164s in params")
		}
		var e164s []string
		if list, ok := e164sVal.([]interface{}); ok {
			for _, item := range list {
				if s, ok := item.(string); ok {
					e164s = append(e164s, s)
				}
			}
		} else {
			return fmt.Errorf("invalid e164s type: %T", e164sVal)
		}
		if len(e164s) == 0 {
			return errors.New("empty e164s list")
		}
		reg, err := regexp.Compile("^[0-9+]{3,20}$")
		if err != nil {
			return err
		}
		for _, e164 := range e164s {
			if !reg.MatchString(e164) {
				return fmt.Errorf("phone %q fails format validation", e164)
			}
			err := c.callDeletePhone(ctx, e164)
			if err != nil {
				return fmt.Errorf("failed to recycle phone %s: %w", e164, err)
			}
		}
		log.Printf("[Commander] 号码批量回收指令执行成功: count=%d", len(e164s))
		return nil

	default:
		return fmt.Errorf("未知指令 action: %s", cmd.Action)
	}
}

func (c *Commander) callDeletePhone(ctx context.Context, e164 string) error {
	baseURL := c.vosAPICfg.BaseURL
	if baseURL == "" {
		baseURL = "http://127.0.0.1:9090/external/server"
	}
	url := fmt.Sprintf("%s/DeletePhone", baseURL)

	params := map[string]string{
		"e164": e164,
	}
	jsonData, err := json.Marshal(params)
	if err != nil {
		return err
	}

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8")

	client := &http.Client{
		Timeout: time.Duration(c.vosAPICfg.TimeoutSeconds) * time.Second,
	}
	if client.Timeout == 0 {
		client.Timeout = 5 * time.Second
	}

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("http request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("invalid status code: %d", resp.StatusCode)
	}

	var vosResult struct {
		RetCode   int    `json:"retCode"`
		Exception string `json:"exception"`
	}
	err = json.NewDecoder(resp.Body).Decode(&vosResult)
	if err != nil {
		return fmt.Errorf("failed to decode vos response: %w", err)
	}

	if vosResult.RetCode != 0 {
		return fmt.Errorf("vos error: %s (code: %d)", vosResult.Exception, vosResult.RetCode)
	}

	return nil
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
