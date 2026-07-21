// Package status 维护每表同步状态（§监控/监视）：最近同步时间、本批行数、
// 源表总水位、滞后 lag、最近错误。供 agent 入站端点 GET /v1/status 暴露，
// 监控页据此画「各表同步健康 + 链路 lag」。
package status

import (
	"sync"
	"time"
)

// Entry 单表同步状态快照。
type Entry struct {
	Table      string `json:"table"`
	Type       string `json:"type"`    // cdr | dimension
	Mode       string `json:"mode"`    // (dimension) full | incremental
	LastSync   string `json:"last_sync"` // RFC3339，最近一次成功同步时刻
	LastRows   int    `json:"last_rows"` // 最近一次同步行数
	TotalRows  int64  `json:"total_rows"` // 源表当前总水位（MAX 键）
	Lag        int64  `json:"lag"`       // 源水位 - 已同步水位（仅 cdr 有意义）
	LastError  string `json:"last_error"`
	Healthy    bool   `json:"healthy"`
}

// Registry 线程安全的状态注册表。
type Registry struct {
	mu      sync.Mutex
	startAt time.Time
	entries map[string]*Entry
}

// New 创建空注册表。
func New() *Registry {
	return &Registry{
		startAt: time.Now(),
		entries: make(map[string]*Entry),
	}
}

// Record 由各表 worker 在每轮 drain 后调用，刷新该表状态。
//   total  源表当前总水位（用于算 lag）
//   synced 已同步到的水位（cdr=Max flowno，dimension=0/不追踪）
func (r *Registry) Record(table, typ, mode string, rows int, total, synced int64, err error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	e, ok := r.entries[table]
	if !ok {
		e = &Entry{Table: table, Type: typ, Mode: mode}
		r.entries[table] = e
	}
	e.LastSync = time.Now().Format(time.RFC3339)
	e.LastRows = rows
	e.TotalRows = total
	if typ == "cdr" {
		e.Lag = total - synced
		if e.Lag < 0 {
			e.Lag = 0
		}
	}
	if err != nil {
		e.LastError = err.Error()
		e.Healthy = false
	} else {
		e.LastError = ""
		e.Healthy = true
	}
}

// Snapshot 返回所有表的当前状态（深拷贝，避免调用方持锁）。
func (r *Registry) Snapshot() []Entry {
	r.mu.Lock()
	defer r.mu.Unlock()
	out := make([]Entry, 0, len(r.entries))
	for _, e := range r.entries {
		out = append(out, *e)
	}
	return out
}

// UptimeSeconds 返回 agent 已运行时长（秒）。
func (r *Registry) UptimeSeconds() int64 {
	return int64(time.Since(r.startAt).Seconds())
}
