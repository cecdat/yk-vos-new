// Package state 负责 per-table flowno 水位的持久化（规格 §4.3）。
// state.json 记录每张表已同步的最大 flowno；历史日表回填完成后标记 "done"。
// 断点续传：进程崩溃/重启后从 state.json 续传，配合 CH ReplacingMergeTree 天然幂等。
package state

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"time"
)

// doneMarker 历史日表回填完成标记，写入 state.json 后不再重复回填。
const doneMarker = "done"

// Store 线程安全的水位存储，映射：表名 -> flowno(int64) 或 "done"。
type Store struct {
	path string
	mu   sync.Mutex
	data map[string]json.RawMessage // 值可能是数字或 "done"
}

// Load 打开（或初始化）state.json。文件不存在时以空水位启动。
func Load(path string) (*Store, error) {
	s := &Store{path: path, data: make(map[string]json.RawMessage)}
	b, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return s, nil // 首次运行，空水位
		}
		return nil, fmt.Errorf("读取 state.json 失败: %w", err)
	}
	if len(b) == 0 {
		return s, nil
	}
	if err := json.Unmarshal(b, &s.data); err != nil {
		return nil, fmt.Errorf("解析 state.json 失败: %w", err)
	}
	return s, nil
}

// Watermark 返回指定表的水位 flowno。表未记录或已标记 done 时返回 (0, done)。
func (s *Store) Watermark(table string) (flowno int64, done bool) {
	s.mu.Lock()
	defer s.mu.Unlock()
	raw, ok := s.data[table]
	if !ok {
		return 0, false
	}
	var str string
	if err := json.Unmarshal(raw, &str); err == nil && str == doneMarker {
		return 0, true
	}
	var n int64
	if err := json.Unmarshal(raw, &n); err == nil {
		return n, false
	}
	return 0, false
}

// SetWatermark 更新指定表的水位并原子落盘。
func (s *Store) SetWatermark(table string, flowno int64) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	b, _ := json.Marshal(flowno)
	s.data[table] = b
	return s.flushLocked()
}

// MarkDone 将历史日表标记为已回填完成并落盘。
func (s *Store) MarkDone(table string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	b, _ := json.Marshal(doneMarker)
	s.data[table] = b
	return s.flushLocked()
}

// Flush 强制落盘（优雅退出时调用）。
func (s *Store) Flush() error {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.flushLocked()
}

// flushLocked 原子写：先写临时文件再 rename，避免崩溃产生半截文件。
func (s *Store) flushLocked() error {
	out := make(map[string]json.RawMessage, len(s.data)+1)
	for k, v := range s.data {
		out[k] = v
	}
	ts, _ := json.Marshal(time.Now().Format(time.RFC3339))
	out["_updated_at"] = ts

	b, err := json.MarshalIndent(out, "", "  ")
	if err != nil {
		return err
	}
	dir := filepath.Dir(s.path)
	tmp, err := os.CreateTemp(dir, ".state-*.tmp")
	if err != nil {
		return fmt.Errorf("创建临时水位文件失败: %w", err)
	}
	tmpName := tmp.Name()
	if _, err := tmp.Write(b); err != nil {
		tmp.Close()
		os.Remove(tmpName)
		return err
	}
	if err := tmp.Sync(); err != nil {
		tmp.Close()
		os.Remove(tmpName)
		return err
	}
	tmp.Close()
	if err := os.Rename(tmpName, s.path); err != nil {
		os.Remove(tmpName)
		return fmt.Errorf("原子替换 state.json 失败: %w", err)
	}
	return nil
}
