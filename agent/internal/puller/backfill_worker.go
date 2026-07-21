package puller

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"sync/atomic"
	"time"

	"github.com/yk-vos/ykvos-agent/internal/model"
	"github.com/yk-vos/ykvos-agent/internal/sink"
	"github.com/yk-vos/ykvos-agent/internal/source"
	"github.com/yk-vos/ykvos-agent/internal/state"
)

type BackfillWorker struct {
	vosID      string
	src        *source.Source
	db         *sql.DB
	st         *state.Store
	sinker     *sink.KafkaSink
	batchSize  int
	
	// 控制变量
	currentCommandID string
	currentTaskID    string
	currentTable     string
	
	isPaused         int32 // 0: running, 1: paused
	isCancelled      int32 // 0: active, 1: cancelled
	speedLimit       int64 // lines/second, <= 0 means unlimited
	
	mu               sync.Mutex
	cancelFunc       context.CancelFunc
}

func NewBackfillWorker(vosID string, src *source.Source, db *sql.DB, st *state.Store, sinker *sink.KafkaSink, batchSize int) *BackfillWorker {
	return &BackfillWorker{
		vosID:     vosID,
		src:       src,
		db:        db,
		st:        st,
		sinker:    sinker,
		batchSize: batchSize,
	}
}

func (w *BackfillWorker) StartBackfill(commandID string, tables []string, initialSpeedLimit int64) error {
	w.mu.Lock()
	defer w.mu.Unlock()

	// 停止当前正在运行的同步（如有）
	if w.cancelFunc != nil {
		w.cancelFunc()
	}

	w.currentCommandID = commandID
	w.currentTaskID = commandID
	atomic.StoreInt32(&w.isPaused, 0)
	atomic.StoreInt32(&w.isCancelled, 0)
	atomic.StoreInt64(&w.speedLimit, initialSpeedLimit)

	ctx, cancel := context.WithCancel(context.Background())
	w.cancelFunc = cancel

	go w.runSyncLoop(ctx, tables)
	return nil
}

func (w *BackfillWorker) Pause() {
	atomic.StoreInt32(&w.isPaused, 1)
	log.Printf("[BackfillWorker] 任务已暂停")
}

func (w *BackfillWorker) Resume() {
	atomic.StoreInt32(&w.isPaused, 0)
	log.Printf("[BackfillWorker] 任务已恢复")
}

func (w *BackfillWorker) Cancel() {
	atomic.StoreInt32(&w.isCancelled, 1)
	w.mu.Lock()
	if w.cancelFunc != nil {
		w.cancelFunc()
	}
	w.mu.Unlock()
	log.Printf("[BackfillWorker] 任务已取消中止")
}

func (w *BackfillWorker) SetThrottle(speedLimit int64) {
	atomic.StoreInt64(&w.speedLimit, speedLimit)
	log.Printf("[BackfillWorker] 调整限速为: %d 行/秒", speedLimit)
}

func (w *BackfillWorker) runSyncLoop(ctx context.Context, tables []string) {
	log.Printf("[BackfillWorker] 启动历史数据回填循环，所选日表: %v", tables)
	
	for _, tableName := range tables {
		if atomic.LoadInt32(&w.isCancelled) == 1 || ctx.Err() != nil {
			break
		}
		w.currentTable = tableName

		// 检查表是否已经标记为 done
		_, done := w.st.Watermark(tableName)
		if done {
			log.Printf("[BackfillWorker] 表 %s 已标记为 done，跳过", tableName)
			w.reportProgress(tableName, 0, "done")
			continue
		}

		err := w.syncTable(ctx, tableName)
		if err != nil {
			log.Printf("[BackfillWorker] 同步表 %s 出错: %v", tableName, err)
			break // 出错则中止整个队列
		}
	}
	log.Printf("[BackfillWorker] 回填循环退出")
}

func (w *BackfillWorker) syncTable(ctx context.Context, tableName string) error {
	log.Printf("[BackfillWorker] 开始同步历史日表: %s", tableName)
	
	// 1. 获取当前断点水位
	wm, _ := w.st.Watermark(tableName)
	
	// 2. 统计已同步的初始行数
	var countPushed int64
	cntQuery := fmt.Sprintf("SELECT COUNT(1) FROM `%s` WHERE flowno <= ?", tableName)
	_ = w.db.QueryRowContext(ctx, cntQuery, wm).Scan(&countPushed)

	w.reportProgress(tableName, countPushed, "syncing")

	lastReportTime := time.Now()

	for {
		// 检查是否暂停
		for atomic.LoadInt32(&w.isPaused) == 1 {
			select {
			case <-ctx.Done():
				return ctx.Err()
			case <-time.After(100 * time.Millisecond):
			}
		}

		// 检查是否取消
		if atomic.LoadInt32(&w.isCancelled) == 1 || ctx.Err() != nil {
			return ctx.Err()
		}

		startTime := time.Now()

		// 3. 读取一批数据
		rows, err := w.src.ReadBatch(ctx, tableName, wm, w.batchSize)
		if err != nil {
			return fmt.Errorf("读取数据批次失败: %w", err)
		}

		if len(rows) == 0 {
			// 表同步完成
			log.Printf("[BackfillWorker] 表 %s 同步完成 (共处理行数: %d)", tableName, countPushed)
			err = w.st.MarkDone(tableName)
			if err != nil {
				log.Printf("[BackfillWorker] 标记 done 失败: %v", err)
			}
			w.reportProgress(tableName, countPushed, "done")
			return nil
		}

		// 4. 包装为 Envelope 批量数据
		nowTime := time.Now().UnixMilli()
		envs := make([]*model.Envelope, 0, len(rows))
		var maxFlowno int64 = wm
		for _, r := range rows {
			envs = append(envs, &model.Envelope{
				SchemaVersion: model.SchemaVersion,
				Op:            model.OpCreate,
				VosID:         w.vosID,
				SrcTable:      tableName,
				Flowno:        r.Flowno,
				TS:            nowTime,
				Data:          r.Data,
			})
			if r.Flowno > maxFlowno {
				maxFlowno = r.Flowno
			}
		}

		// 5. 发送至 Kafka (lz4 压缩，Acks=all 在 sink.go 中由配置注入)
		err = w.sinker.WriteBackfillEnvelopes(ctx, envs)
		if err != nil {
			return fmt.Errorf("发送 Envelope 到 Kafka 失败: %w", err)
		}

		// 6. 更新断点落盘
		err = w.st.SetWatermark(tableName, maxFlowno)
		if err != nil {
			log.Printf("[BackfillWorker] 写入断点失败: %v", err)
		}

		wm = maxFlowno
		countPushed += int64(len(rows))

		// 7. 每 2 秒上报一次进度，减少 Kafka 交互频次
		if time.Since(lastReportTime) >= 2*time.Second {
			w.reportProgress(tableName, countPushed, "syncing")
			lastReportTime = time.Now()
		}

		// 8. 调速/限流
		elapsed := time.Since(startTime)
		speed := atomic.LoadInt64(&w.speedLimit)
		if speed > 0 {
			expectedDuration := time.Duration(float64(len(rows)) / float64(speed) * float64(time.Second))
			if elapsed < expectedDuration {
				select {
				case <-ctx.Done():
					return ctx.Err()
				case <-time.After(expectedDuration - elapsed):
				}
			}
		}
	}
}

func (w *BackfillWorker) reportProgress(tableName string, count int64, status string) {
	payload := map[string]interface{}{
		"vos_id":       w.vosID,
		"msg_type":     "progress",
		"generated_at": time.Now().Format(time.RFC3339),
		"command_id":   w.currentCommandID,
		"task_id":      w.currentTaskID,
		"table":        tableName,
		"pushed":       count,
		"status":       status,
	}
	bytes, err := json.Marshal(payload)
	if err != nil {
		log.Printf("[BackfillWorker] 序列化进度报告失败: %v", err)
		return
	}
	err = w.sinker.WriteRaw(context.Background(), "vos.agent.report", w.vosID, bytes)
	if err != nil {
		log.Printf("[BackfillWorker] 发送进度报告至 Kafka 失败: %v", err)
	}
}
