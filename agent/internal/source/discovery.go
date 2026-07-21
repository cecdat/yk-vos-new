// 表发现（规格 §4.2）：动态发现 e_cdr_YYYYMMDD 历史日表，可选按 date_range 过滤。
package source

import (
	"context"
	"fmt"
	"sort"
	"strings"
)

// RollingCDRTable 滚动实时话单表（固定）。
const RollingCDRTable = "e_cdr"

// DiscoverCDRDailyTables 通过 information_schema 发现历史日表 e_cdr_%。
// dateRange 形如 ["2026-01-18","2026-03-09"]，非空时仅保留范围内的日表。
func (s *Source) DiscoverCDRDailyTables(ctx context.Context, dateRange []string) ([]string, error) {
	const q = `SELECT table_name FROM information_schema.tables
	           WHERE table_schema = ? AND table_name LIKE 'e\_cdr\_%'`
	rows, err := s.db.QueryContext(ctx, q, s.cfg.Database)
	if err != nil {
		return nil, fmt.Errorf("发现日表失败: %w", err)
	}
	defer rows.Close()

	var tables []string
	for rows.Next() {
		var name string
		if err := rows.Scan(&name); err != nil {
			return nil, err
		}
		tables = append(tables, name)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	var lo, hi string
	if len(dateRange) == 2 {
		lo = strings.ReplaceAll(dateRange[0], "-", "") // 20260118
		hi = strings.ReplaceAll(dateRange[1], "-", "")
	}

	var filtered []string
	for _, t := range tables {
		suffix := strings.TrimPrefix(t, "e_cdr_") // 20260118
		if lo != "" && hi != "" {
			if suffix < lo || suffix > hi {
				continue
			}
		}
		filtered = append(filtered, t)
	}
	sort.Strings(filtered)
	return filtered, nil
}

// CDRTables 返回所有可用的 CDR 同步表清单，包括滚动表和日表。
func (s *Source) CDRTables(ctx context.Context) ([]string, error) {
	daily, err := s.DiscoverCDRDailyTables(ctx, nil)
	if err != nil {
		return nil, err
	}
	res := make([]string, 0, len(daily)+1)
	res = append(res, RollingCDRTable)
	res = append(res, daily...)
	return res, nil
}
