package scanner

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/yk-vos/ykvos-agent/internal/sink"
	"github.com/yk-vos/ykvos-agent/internal/state"
)

// TableAvailability 话单可用性元数据
type TableAvailability struct {
	Table         string `json:"table"`
	EstimatedRows int64  `json:"estimated_rows"`
	AlreadyPushed int64  `json:"already_pushed"`
}

// ScanReportPayload 上报给后端的 Payload 契约
type ScanReportPayload struct {
	VosID        string              `json:"vos_id"`
	MsgType      string              `json:"msg_type"` // "availability"
	GeneratedAt  string              `json:"generated_at"`
	AgentVersion string              `json:"agent_version"`
	Tables       []TableAvailability `json:"tables"`
}

type Scanner struct {
	vosID  string
	db     *sql.DB
	st     *state.Store
	sinker *sink.KafkaSink
}

// NewScanner 构造可用表扫描器
func NewScanner(vosID string, db *sql.DB, st *state.Store, sinker *sink.KafkaSink) *Scanner {
	return &Scanner{
		vosID:  vosID,
		db:     db,
		st:     st,
		sinker: sinker,
	}
}

// ScanAndReport 扫描本地数据库中 e_cdr_ 开头的历史话单表并上报 Kafka
func (s *Scanner) ScanAndReport(ctx context.Context) error {
	log.Printf("[Scanner] 开始扫描本地 MySQL 可用历史话单表...")

	// 1. 从 information_schema.tables 查询日表清单及其物理估算行数 (TABLE_ROWS)
	query := `SELECT TABLE_NAME, TABLE_ROWS 
	          FROM information_schema.tables 
	          WHERE table_schema = DATABASE() 
	            AND table_name LIKE 'e_cdr_%'
	          ORDER BY table_name DESC`

	rows, err := s.db.QueryContext(ctx, query)
	if err != nil {
		return fmt.Errorf("查询 information_schema 失败: %w", err)
	}
	defer rows.Close()

	var tables []TableAvailability
	for rows.Next() {
		var tableName string
		var estimatedRows int64
		if err := rows.Scan(&tableName, &estimatedRows); err != nil {
			log.Printf("[Scanner] 读取行数据失败: %v", err)
			continue
		}

		// 2. 对比本地 state.json 判断已经同步的行数
		alreadyPushed := int64(0)
		wm, done := s.st.Watermark(tableName)
		if done {
			alreadyPushed = estimatedRows
		} else if wm > 0 {
			// 若存在断点，基于 indexed flowno 计算实际落盘行数 (极快)
			cntQuery := fmt.Sprintf("SELECT COUNT(1) FROM `%s` WHERE flowno <= ?", tableName)
			err = s.db.QueryRowContext(ctx, cntQuery, wm).Scan(&alreadyPushed)
			if err != nil {
				log.Printf("[Scanner] 查询表 %s 已同步行数失败: %v", tableName, err)
				alreadyPushed = 0
			}
		}

		tables = append(tables, TableAvailability{
			Table:         tableName,
			EstimatedRows: estimatedRows,
			AlreadyPushed: alreadyPushed,
		})
	}

	if len(tables) == 0 {
		log.Printf("[Scanner] 未发现任何可用历史话单表")
	}

	// 3. 构造上报 Payload 并发送
	payload := &ScanReportPayload{
		VosID:        s.vosID,
		MsgType:      "availability",
		GeneratedAt:  time.Now().Format(time.RFC3339),
		AgentVersion: "1.0.0",
		Tables:       tables,
	}

	bytes, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("序列化可用表报告失败: %w", err)
	}

	err = s.sinker.WriteRaw(ctx, "vos.agent.report", s.vosID, bytes)
	if err != nil {
		return fmt.Errorf("上报可用表报告至 Kafka 失败: %w", err)
	}

	log.Printf("[Scanner] 可用表扫描上报完成，共上报了 %d 张历史表", len(tables))
	return nil
}
