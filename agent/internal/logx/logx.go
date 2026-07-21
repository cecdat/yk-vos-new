// Package logx 提供结构化 JSON 日志（规格 §10：level/ts/module/table/flowno/batch）。
// 基于标准库 log/slog，零第三方依赖，便于静态编译。
package logx

import (
	"log/slog"
	"os"
	"path/filepath"
	"strings"
)

// Init 初始化全局 slog 为 JSON handler。
// level 取自 config.yaml 的 log.level；path 取自 log.path：
// 空 → 写 stdout（由 init.d 重定向到 /var/log/ykvos-agent.log，配合 logrotate 切割）；
// 非空 → 以 append 模式写该文件（缺失自动创建）。
// 所有参数来自配置文件，不接收命令行参数。
func Init(level, path string) {
	var lv slog.Level
	switch strings.ToLower(level) {
	case "debug":
		lv = slog.LevelDebug
	case "warn":
		lv = slog.LevelWarn
	case "error":
		lv = slog.LevelError
	default:
		lv = slog.LevelInfo
	}
	w := os.Stdout
	if path != "" {
		if dir := filepath.Dir(path); dir != "" {
			_ = os.MkdirAll(dir, 0o755)
		}
		f, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
		if err == nil {
			w = f
		}
		// 打开失败则回退 stdout，避免进程因日志初始化而退出。
	}
	h := slog.NewJSONHandler(w, &slog.HandlerOptions{Level: lv})
	slog.SetDefault(slog.New(h))
}

// Module 返回带 module 字段的 logger，便于按组件过滤。
func Module(name string) *slog.Logger {
	return slog.Default().With("module", name)
}
