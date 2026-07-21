// Package server 实现 agent 的可选入站拉取端点（规格 §3.5 双向 / 测试环境）。
//
// 背景：生产拓扑里平台(yk-vos 中台)有公网、Kafka 可达，agent 在 VOS 本机出站推 Kafka。
// 但测试环境反过来——VOS 服务器有公网、平台部署环境没有公网端口(Kafka/CH 不可被入站连接)。
// 此时 agent 无法推到平台。解决方案：让 agent 在 VOS 本机起一个 HTTP 拉取端点，
// 由「平台侧主动出站来拉」。连接方向随谁有公网而翻转，agent 既能推(Kafka)也能被拉(HTTP)。
//
// 该端点与 Kafka 推送「同构」：返回的消息体就是 model.Envelope(JSON)，下游消费逻辑完全复用。
// 游标(after)由客户端维护，与推送水位 state.json 解耦，两条路互不干扰、都按 flowno 幂等。
package server

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"strconv"
	"time"

	"github.com/yk-vos/ykvos-agent/internal/config"
	"github.com/yk-vos/ykvos-agent/internal/model"
	"github.com/yk-vos/ykvos-agent/internal/source"
	"github.com/yk-vos/ykvos-agent/internal/status"
)

const (
	defaultLimit = 2000
	maxLimit     = 10000
	defaultTable = source.RollingCDRTable // "e_cdr"
	bearerPrefix = "Bearer "
)

// CDRReader 是拉取端点的数据依赖（由 *source.Source 满足）。
// 抽成接口便于单测用假实现验证路由/鉴权逻辑。
type CDRReader interface {
	ReadBatch(ctx context.Context, table string, watermark int64, limit int) ([]source.Row, error)
	// ReadByKey 按任意键列增量读取（维度表 on-demand 拉取用）。
	ReadByKey(ctx context.Context, table, keyCol string, after int64, limit int) ([]source.Row, error)
	// Watermark 返回表当前 MAX(flowno)，供 /v1/watermark 暴露给监控页算 lag。
	Watermark(ctx context.Context, table string) (int64, error)
	// MaxKey 返回表某键列最大值（维度表 on-demand 用）。
	MaxKey(ctx context.Context, table, keyCol string) (int64, error)
	CDRTables(ctx context.Context) ([]string, error)
}

// Server 是 agent 的 HTTP 拉取端点。
type Server struct {
	src    CDRReader
	vosID string
	token  string // 非空则需 Bearer 鉴权；空=不鉴权（内网）
	tables map[string]config.TableSync
	reg    *status.Registry // 非空则暴露 /v1/status
}

// New 创建拉取端点。tables 为本 agent 声明同步的表清单（含类型），reg 为同步状态注册表。
func New(src CDRReader, vosID, token string, tables []config.TableSync, reg *status.Registry) *Server {
	m := make(map[string]config.TableSync, len(tables))
	for _, t := range tables {
		m[t.Name] = t
	}
	return &Server{src: src, vosID: vosID, token: token, tables: m, reg: reg}
}

// Handler 返回路由：/healthz 探活、/v1/cdr 拉取话单、/v1/watermark 当前水位。
func (s *Server) Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", s.handleHealth)
	mux.HandleFunc("/v1/cdr", s.handleCDR)
	mux.HandleFunc("/v1/watermark", s.handleWatermark)
	mux.HandleFunc("/v1/tables", s.handleTables)
	mux.HandleFunc("/v1/status", s.handleStatus)
	return mux
}

// Start 启动 HTTP 服务；ctx 取消时优雅关闭。
func (s *Server) Start(ctx context.Context, listen string, readTimeoutSeconds int) error {
	srv := &http.Server{
		Addr:           listen,
		Handler:        s.Handler(),
		ReadTimeout:    time.Duration(readTimeoutSeconds) * time.Second,
		WriteTimeout:   60 * time.Second,
		MaxHeaderBytes: 1 << 16,
	}
	go func() {
		<-ctx.Done()
		qs, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := srv.Shutdown(qs); err != nil {
			slog.Default().With("module", "server").Error("HTTP 端点关闭异常", "err", err.Error())
		}
	}()

	log := slog.Default().With("module", "server")
	log.Info("HTTP 拉取端点已启动", "listen", listen, "auth", s.token != "")
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		return fmt.Errorf("HTTP 服务异常: %w", err)
	}
	return nil
}

func (s *Server) handleHealth(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{"status": "ok", "vos_id": s.vosID})
}

// handleWatermark 返回源表当前 MAX(flowno)，供监控页对比 CH 落库水位算链路 lag。
func (s *Server) handleWatermark(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if s.token != "" && !validBearer(r.Header.Get("Authorization"), s.token) {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	table := r.URL.Query().Get("table")
	if table == "" {
		table = defaultTable
	}
	if !source.IsSafeTableName(table) {
		http.Error(w, "invalid table", http.StatusBadRequest)
		return
	}
	wm, err := s.src.Watermark(r.Context(), table)
	if err != nil {
		http.Error(w, "watermark failed: "+err.Error(), http.StatusInternalServerError)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"table":     table,
		"watermark": wm,
		"vos_id":    s.vosID,
	})
}

func (s *Server) handleCDR(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if s.token != "" && !validBearer(r.Header.Get("Authorization"), s.token) {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	q := r.URL.Query()
	table := q.Get("table")
	if table == "" {
		table = defaultTable
	}
	if !source.IsSafeTableName(table) {
		http.Error(w, "invalid table", http.StatusBadRequest)
		return
	}

	after := int64(0)
	if v := q.Get("after"); v != "" {
		if n, err := strconv.ParseInt(v, 10, 64); err == nil {
			after = n
		}
	}
	limit := defaultLimit
	if v := q.Get("limit"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 {
			limit = n
		}
	}
	if limit > maxLimit {
		limit = maxLimit
	}

	// 维度表 on-demand 拉取按主键 id（而非 flowno）游标；CDR 表按 flowno。
	rows, err := s.readRows(r.Context(), table, after, limit)
	if err != nil {
		http.Error(w, "read failed: "+err.Error(), http.StatusInternalServerError)
		return
	}

	now := time.Now().UnixMilli()
	envs := make([]*model.Envelope, 0, len(rows))
	var nextAfter int64 = after
	for _, row := range rows {
		envs = append(envs, &model.Envelope{
			SchemaVersion: model.SchemaVersion,
			Op:            model.OpCreate,
			VosID:         s.vosID,
			SrcTable:      table,
			Flowno:        row.Flowno,
			TS:            now,
			Data:          row.Data,
		})
		if row.Flowno > nextAfter {
			nextAfter = row.Flowno
		}
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"table":     table,
		"after":     after,
		"count":     len(envs),
		"next_after": nextAfter,
		"rows":      envs,
	})
}

// readRows 按表类型选读取方式：dimension 表用主键 id 游标（ReadByKey），
// CDR/其它用 flowno 水位（ReadBatch）。统一把天然去重键放进 Envelope.Flowno。
func (s *Server) readRows(ctx context.Context, table string, after int64, limit int) ([]source.Row, error) {
	if t, ok := s.tables[table]; ok && t.Type == "dimension" {
		return s.src.ReadByKey(ctx, table, "id", after, limit)
	}
	return s.src.ReadBatch(ctx, table, after, limit)
}

func (s *Server) handleTables(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if s.token != "" && !validBearer(r.Header.Get("Authorization"), s.token) {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	// 优先返回声明表清单（含类型/模式），便于平台 per-table 拉取。
	if len(s.tables) > 0 {
		list := make([]map[string]any, 0, len(s.tables))
		for name, t := range s.tables {
			list = append(list, map[string]any{
				"table": name,
				"type":  t.Type,
				"mode":  t.EffectiveMode(),
			})
		}
		writeJSON(w, http.StatusOK, map[string]any{
			"vos_id": s.vosID,
			"tables": list,
		})
		return
	}
	tables, err := s.src.CDRTables(r.Context())
	if err != nil {
		http.Error(w, "CDRTables failed: "+err.Error(), http.StatusInternalServerError)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"vos_id": s.vosID,
		"tables": tables,
	})
}

// handleStatus 暴露每表同步状态（§监控 / A5）：上游监控页据此画健康 + lag。
func (s *Server) handleStatus(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if s.token != "" && !validBearer(r.Header.Get("Authorization"), s.token) {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	uptime := int64(0)
	var snap []status.Entry
	if s.reg != nil {
		uptime = s.reg.UptimeSeconds()
		snap = s.reg.Snapshot()
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"vos_id":       s.vosID,
		"uptime_seconds": uptime,
		"tables":        snap,
	})
}

func validBearer(header, token string) bool {
	if len(header) <= len(bearerPrefix) || header[:len(bearerPrefix)] != bearerPrefix {
		return false
	}
	return header[len(bearerPrefix):] == token
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
