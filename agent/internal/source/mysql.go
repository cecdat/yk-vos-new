// Package source 封装 VOS MySQL 只读源的连接、表发现与按水位的通用行读取（规格 §4）。
package source

import (
	"context"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/url"
	"time"

	"github.com/go-sql-driver/mysql"

	"github.com/yk-vos/ykvos-agent/internal/config"
)

// 需特殊处理的列（规格 §5.2）：blob 列 base64，json 列原样透传。
const (
	colAdditional   = "additional"   // blob → base64 String
	colDynamicValue = "dynamicValue" // json → 原样透传
)

// Source 是 VOS MySQL 只读源。
type Source struct {
	db  *sql.DB
	cfg config.MySQL
}

// Open 建立只读连接（TCP 或 domain socket）。MyISAM 表锁，连接池须克制。
func Open(cfg config.MySQL) (*Source, error) {
	dsn := buildDSN(cfg)
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, fmt.Errorf("打开 MySQL 连接失败: %w", err)
	}
	db.SetMaxOpenConns(cfg.MaxOpenConns)
	db.SetMaxIdleConns(cfg.MaxOpenConns)
	db.SetConnMaxLifetime(cfg.ConnMaxLifetime)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := db.PingContext(ctx); err != nil {
		db.Close()
		return nil, fmt.Errorf("Ping VOS MySQL 失败: %w", err)
	}
	// 会话级只读，双保险（账号本身也应仅 GRANT SELECT）。
	if cfg.ReadOnly {
		_, _ = db.ExecContext(ctx, "SET SESSION TRANSACTION READ ONLY")
	}
	return &Source{db: db, cfg: cfg}, nil
}

// buildDSN 构造 go-sql-driver DSN，优先 socket（部分 VOS 仅允许 socket 访问）。
func buildDSN(cfg config.MySQL) string {
	c := mysql.NewConfig()
	c.User = cfg.User
	c.Passwd = cfg.Password
	c.DBName = cfg.Database
	c.Params = map[string]string{"charset": cfg.Charset}
	c.Loc = time.Local
	c.ParseTime = false // 话单时间为 unix int，无需驱动解析
	c.Timeout = 10 * time.Second
	c.ReadTimeout = 60 * time.Second
	if cfg.SocketPath != "" {
		c.Net = "unix"
		c.Addr = cfg.SocketPath
	} else {
		c.Net = "tcp"
		c.Addr = fmt.Sprintf("%s:%d", cfg.Host, cfg.Port)
	}
	_ = url.Values{} // 保留 net/url 依赖占位（未来 API 流可复用）
	return c.FormatDSN()
}

// Close 关闭连接。
func (s *Source) Close() error {
	if s.db == nil {
		return nil
	}
	return s.db.Close()
}

// DB 暴露底层 *sql.DB 供表发现/并发近似查询复用。
func (s *Source) DB() *sql.DB { return s.db }

// Watermark 返回表的当前最大 flowno（规格 §监控/监视：供监控页对比
// 「agent 侧水位」与「ClickHouse 落库水位」算出链路 lag）。
// flowno 在 VOS 各话单表为主键，MAX 在 MyISAM 下代价低。
func (s *Source) Watermark(ctx context.Context, table string) (int64, error) {
	if !IsSafeTableName(table) {
		return 0, fmt.Errorf("unsafe table name: %s", table)
	}
	var wm sql.NullInt64
	q := fmt.Sprintf("SELECT MAX(flowno) FROM `%s`", table)
	if err := s.db.QueryRowContext(ctx, q).Scan(&wm); err != nil {
		return 0, err
	}
	if !wm.Valid {
		return 0, nil
	}
	return wm.Int64, nil
}

// Row 是一行的字段名→JSON 值映射（已按 §5.2 处理 blob/json）。
type Row struct {
	Flowno int64
	Data   map[string]json.RawMessage
}

// ReadBatch 按 flowno 水位读取一批（规格 §4.3）：
//
//	SELECT * FROM `table` WHERE flowno > ? ORDER BY flowno ASC LIMIT ?
//
// 返回的行按 flowno 升序；调用方发送成功后以最后一行 flowno 推进水位。
func (s *Source) ReadBatch(ctx context.Context, table string, watermark int64, limit int) ([]Row, error) {
	return s.readWhere(ctx, table, "flowno", watermark, limit)
}

// ReadByKey 按任意键列增量读取一批（维度表用，§4）。
// 键列来自白名单（config.safeKeyColumn），非用户输入，仍做安全校验。
// 返回的 Row.Flowno 设为该键列的值，使 Envelope.Flowno 统一承载「表的天然去重键」
// （CDR 为 flowno，dimension 为 id），下游按 SrcTable 映射到不同 ODS 的 ORDER BY 列。
func (s *Source) ReadByKey(ctx context.Context, table, keyCol string, after int64, limit int) ([]Row, error) {
	if !safeKeyColumn(keyCol) {
		return nil, fmt.Errorf("非法键列: %q", keyCol)
	}
	return s.readWhere(ctx, table, keyCol, after, limit)
}

// readWhere 是 ReadBatch / ReadByKey 的通用实现：按指定列做 `col > ? ORDER BY col ASC LIMIT ?`。
// 把该列的值解析进 Row.Flowno，作为 Envelope 的天然去重键。
func (s *Source) readWhere(ctx context.Context, table, col string, after int64, limit int) ([]Row, error) {
	if !safeTableName(table) {
		return nil, fmt.Errorf("非法表名: %q", table)
	}
	q := fmt.Sprintf("SELECT * FROM `%s` WHERE `%s` > ? ORDER BY `%s` ASC LIMIT ?", table, col, col)
	rows, err := s.db.QueryContext(ctx, q, after, limit)
	if err != nil {
		return nil, fmt.Errorf("查询 %s 失败: %w", table, err)
	}
	defer rows.Close()

	cols, err := rows.Columns()
	if err != nil {
		return nil, err
	}

	var out []Row
	for rows.Next() {
		raw := make([]sql.RawBytes, len(cols))
		ptrs := make([]any, len(cols))
		for i := range raw {
			ptrs[i] = &raw[i]
		}
		if err := rows.Scan(ptrs...); err != nil {
			return nil, fmt.Errorf("扫描 %s 行失败: %w", table, err)
		}

		data := make(map[string]json.RawMessage, len(cols))
		var key int64
		for i, name := range cols {
			data[name] = encodeCell(name, raw[i])
			if name == col && raw[i] != nil {
				fmt.Sscan(string(raw[i]), &key)
			}
		}
		out = append(out, Row{Flowno: key, Data: data})
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return out, nil
}

// MaxKey 返回指定表某键列的当前最大值（维度表全量/增量水位用，§4/§监控）。
// 键列来自白名单，非用户输入。
func (s *Source) MaxKey(ctx context.Context, table, keyCol string) (int64, error) {
	if !safeTableName(table) || !safeKeyColumn(keyCol) {
		return 0, fmt.Errorf("非法表名或键列: %s/%s", table, keyCol)
	}
	var m sql.NullInt64
	q := fmt.Sprintf("SELECT MAX(`%s`) FROM `%s`", keyCol, table)
	if err := s.db.QueryRowContext(ctx, q).Scan(&m); err != nil {
		return 0, err
	}
	if !m.Valid {
		return 0, nil
	}
	return m.Int64, nil
}

// safeKeyColumn 是维度增量键列的白名单，防 SQL 注入（键列名拼进 WHERE/SELECT）。
func safeKeyColumn(c string) bool {
	switch c {
	case "id", "lastupdatetime", "starttime", "flowno":
		return true
	}
	return false
}

// encodeCell 把一个原始单元格按列语义编码为 JSON 值：
//   - NULL          → null
//   - additional    → base64 字符串（blob）
//   - dynamicValue  → 合法 JSON 原样透传，否则退化为字符串
//   - 其它          → 字符串（数值精度交由 CH MV 侧 JSONExtract* 转换）
func encodeCell(name string, b sql.RawBytes) json.RawMessage {
	if b == nil {
		return json.RawMessage("null")
	}
	switch name {
	case colAdditional:
		enc := base64.StdEncoding.EncodeToString([]byte(b))
		v, _ := json.Marshal(enc)
		return v
	case colDynamicValue:
		if json.Valid([]byte(b)) {
			cp := make([]byte, len(b))
			copy(cp, b)
			return cp
		}
		v, _ := json.Marshal(string(b))
		return v
	default:
		v, _ := json.Marshal(string(b))
		return v
	}
}

// IsSafeTableName 仅允许字母数字下划线，防注入（供 server 等复用）。
func IsSafeTableName(t string) bool {
	return safeTableName(t)
}

// safeTableName 仅允许字母数字下划线，防注入。
func safeTableName(t string) bool {
	if t == "" {
		return false
	}
	for _, r := range t {
		if !(r == '_' || (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9')) {
			return false
		}
	}
	return true
}
