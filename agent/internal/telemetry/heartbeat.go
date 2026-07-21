package telemetry

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"math"
	"os"
	"runtime"
	"time"

	"github.com/yk-vos/ykvos-agent/internal/sink"
)

// AgentVersion is the current version of the agent
const AgentVersion = "1.0.0"

// HeartbeatPayload represents the message structure reported to vos.agent.report
type HeartbeatPayload struct {
	VosID        string         `json:"vos_id"`
	MsgType      string         `json:"msg_type"` // "heartbeat"
	GeneratedAt  string         `json:"generated_at"`
	AgentVersion string         `json:"agent_version"`
	System       *SystemMetrics `json:"vos_system"`
	DB           *DBStatus      `json:"db_status"`
	Agent        *AgentMetrics  `json:"agent_status"`
}

type SystemMetrics struct {
	Hostname      string  `json:"hostname"`
	OS            string  `json:"os"`
	CPULoad1m     float64 `json:"cpu_load_1m"`
	CPUCores      int     `json:"cpu_cores"`
	MemTotalMB    int     `json:"mem_total_mb"`
	MemUsedMB     int     `json:"mem_used_mb"`
	DiskTotalMB   int     `json:"disk_total_mb"`
	DiskUsedMB    int     `json:"disk_used_mb"`
	UptimeSeconds int64   `json:"uptime_seconds"`
}

type DBStatus struct {
	Connected         bool   `json:"connected"`
	Version           string `json:"version"`
	OpenConnections   int    `json:"open_connections"`
	ActiveConnections int    `json:"active_connections"`
}

type AgentMetrics struct {
	Goroutines    int     `json:"goroutines"`
	MemAllocMB    float64 `json:"mem_alloc_mb"`
	UptimeSeconds int64   `json:"uptime_seconds"`
}

type TelemetryManager struct {
	vosID    string
	db       *sql.DB
	sinker   *sink.KafkaSink
	startAt  time.Time
	interval time.Duration
}

// NewTelemetryManager constructs the telemetry coordinator
func NewTelemetryManager(vosID string, db *sql.DB, sinker *sink.KafkaSink) *TelemetryManager {
	return &TelemetryManager{
		vosID:    vosID,
		db:       db,
		sinker:   sinker,
		startAt:  time.Now(),
		interval: 30 * time.Second, // 默认 30 秒心跳上报间隔
	}
}

// Start spawns the reporting ticker loop
func (tm *TelemetryManager) Start(ctx context.Context) {
	log.Printf("[Telemetry] 启动心跳及硬件状态收集协程，上报周期: %v", tm.interval)
	ticker := time.NewTicker(tm.interval)
	defer ticker.Stop()

	// 立即上报一次
	tm.report()

	for {
		select {
		case <-ctx.Done():
			log.Printf("[Telemetry] 停止心跳上报协程")
			return
		case <-ticker.C:
			tm.report()
		}
	}
}

func (tm *TelemetryManager) report() {
	hostname, _ := os.Hostname()

	// 1. 系统指标
	memTotal, memUsed := getMemInfo()
	diskTotal, diskUsed := getDiskInfo()
	sysUptime := getSystemUptime()

	sys := &SystemMetrics{
		Hostname:      hostname,
		OS:            getPlatformOS(),
		CPULoad1m:     getCPULoad(),
		CPUCores:      runtime.NumCPU(),
		MemTotalMB:    memTotal,
		MemUsedMB:     memUsed,
		DiskTotalMB:   diskTotal,
		DiskUsedMB:    diskUsed,
		UptimeSeconds: sysUptime,
	}

	// 2. 本地 VOS MySQL 指标
	dbStatus := tm.getDBStatus()

	// 3. Agent 自身指标
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	allocMB := float64(m.Alloc) / (1024.0 * 1024.0)
	allocMB = math.Round(allocMB*100) / 100 // 保留两位小数

	agent := &AgentMetrics{
		Goroutines:    runtime.NumGoroutine(),
		MemAllocMB:    allocMB,
		UptimeSeconds: int64(time.Since(tm.startAt).Seconds()),
	}

	payload := &HeartbeatPayload{
		VosID:        tm.vosID,
		MsgType:      "heartbeat",
		GeneratedAt:  time.Now().Format(time.RFC3339),
		AgentVersion: AgentVersion,
		System:       sys,
		DB:           dbStatus,
		Agent:        agent,
	}

	bytes, err := json.Marshal(payload)
	if err != nil {
		log.Printf("[Telemetry] 心跳序列化失败: %v", err)
		return
	}

	if err := tm.sendReport(bytes); err != nil {
		log.Printf("[Telemetry] 心跳上报 Kafka 失败: %v", err)
	} else {
		memPct, diskPct := 0.0, 0.0
		if sys.MemTotalMB > 0 {
			memPct = float64(sys.MemUsedMB) / float64(sys.MemTotalMB) * 100
		}
		if sys.DiskTotalMB > 0 {
			diskPct = float64(sys.DiskUsedMB) / float64(sys.DiskTotalMB) * 100
		}
		log.Printf("[Telemetry] 心跳上报成功: vos_id=%s host=%s os=%s cpu_cores=%d load_1m=%.2f mem=%d/%dMB(%.1f%%) disk=%d/%dMB(%.1f%%) db_ok=%t db_ver=%s agent_goroutines=%d agent_uptime=%ds",
			tm.vosID, sys.Hostname, sys.OS, sys.CPUCores, sys.CPULoad1m,
			sys.MemUsedMB, sys.MemTotalMB, memPct,
			sys.DiskUsedMB, sys.DiskTotalMB, diskPct,
			dbStatus.Connected, dbStatus.Version,
			agent.Goroutines, agent.UptimeSeconds)
	}
}

// sendReport 将已构造的心跳 payload 上报至 vos.agent.report，返回错误（供启动门闸判断服务端连通性）。
func (tm *TelemetryManager) sendReport(bytes []byte) error {
	return tm.sinker.WriteRaw(context.Background(), "vos.agent.report", tm.vosID, bytes)
}

// ReportOnce 立即上报一次心跳；成功返回 nil。main 用它作为「已连上服务端」门闸判据。
func (tm *TelemetryManager) ReportOnce() error {
	hostname, _ := os.Hostname()

	memTotal, memUsed := getMemInfo()
	diskTotal, diskUsed := getDiskInfo()
	sysUptime := getSystemUptime()

	sys := &SystemMetrics{
		Hostname:      hostname,
		OS:            getPlatformOS(),
		CPULoad1m:     getCPULoad(),
		CPUCores:      runtime.NumCPU(),
		MemTotalMB:    memTotal,
		MemUsedMB:     memUsed,
		DiskTotalMB:   diskTotal,
		DiskUsedMB:    diskUsed,
		UptimeSeconds: sysUptime,
	}

	dbStatus := tm.getDBStatus()

	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	allocMB := float64(m.Alloc) / (1024.0 * 1024.0)
	allocMB = math.Round(allocMB*100) / 100

	agent := &AgentMetrics{
		Goroutines:    runtime.NumGoroutine(),
		MemAllocMB:    allocMB,
		UptimeSeconds: int64(time.Since(tm.startAt).Seconds()),
	}

	payload := &HeartbeatPayload{
		VosID:        tm.vosID,
		MsgType:      "heartbeat",
		GeneratedAt:  time.Now().Format(time.RFC3339),
		AgentVersion: AgentVersion,
		System:       sys,
		DB:           dbStatus,
		Agent:        agent,
	}

	bytes, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("心跳序列化失败: %w", err)
	}
	if serr := tm.sendReport(bytes); serr != nil {
		return serr
	}
	log.Printf("[Telemetry] 首次连上服务端并完成心跳上报: vos_id=%s host=%s os=%s cpu_cores=%d load_1m=%.2f mem=%d/%dMB disk=%d/%dMB db_ok=%t db_ver=%s",
		tm.vosID, sys.Hostname, sys.OS, sys.CPUCores, sys.CPULoad1m,
		sys.MemUsedMB, sys.MemTotalMB, sys.DiskUsedMB, sys.DiskTotalMB,
		dbStatus.Connected, dbStatus.Version)
	return nil
}

func (tm *TelemetryManager) getDBStatus() *DBStatus {
	status := &DBStatus{
		Connected: false,
	}
	if tm.db == nil {
		return status
	}

	// 测试连接
	err := tm.db.Ping()
	if err != nil {
		return status
	}
	status.Connected = true

	// 查询 MySQL 版本
	var version string
	err = tm.db.QueryRow("SELECT VERSION()").Scan(&version)
	if err == nil {
		status.Version = version
	}

	// 获取数据库连接池指标
	stats := tm.db.Stats()
	status.OpenConnections = stats.OpenConnections
	status.ActiveConnections = stats.InUse

	return status
}
