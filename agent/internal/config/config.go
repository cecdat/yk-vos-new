// Package config 负责解析 config.yaml 五段配置，并按安全规范从密钥文件/环境变量注入敏感凭据。
// 对应规格文档 §3（config.yaml）与 §9（安全规范：密码不落 config，经 YK_MYSQL_PWD 注入）。
package config

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"gopkg.in/yaml.v3"
)

// Config 是 agent 的完整配置，与 docs/VOS同步Agent规格.md §3 一对应。
// 设计原则：所有可调参数均在配置文件中声明，运行时不接收任何业务命令行参数
// （内网单配置部署，见用户要求）。仅保留 -config（可选，指向本文件）与 -version（信息输出）。
type Config struct {
	Instance Instance `yaml:"instance"`
	MySQL    MySQL    `yaml:"mysql"`
	Kafka    Kafka    `yaml:"kafka"`
	Sync     Sync       `yaml:"sync"`
	Tables   []TableSync `yaml:"tables"` // 多表同步声明（§4）。留空→兼容旧 sync:，仅同步 e_cdr 滚动表。
	VosAPI   VosAPI   `yaml:"vos_api"`
	Server   Server   `yaml:"server"` // 可选入站拉取端点（§3.5 双向/测试环境）
	Log      Log      `yaml:"log"`
	State    State    `yaml:"state"`

	// ClickhouseContract 仅为归档约定，agent 不直接连 CH（§7）。保留以便文档-代码一致。
	ClickhouseContract map[string]string `yaml:"clickhouse_contract"`
}

// Instance 实例标识，写进每条消息用于区分多 VOS 来源。
type Instance struct {
	ID      string `yaml:"id"`
	Name    string `yaml:"name"`
	LocalIP string `yaml:"local_ip"`
}

// MySQL VOS 只读源。password 不在 yaml 中，运行时由 Load 从密钥注入。
type MySQL struct {
	Host            string        `yaml:"host"`
	Port            int           `yaml:"port"`
	User            string        `yaml:"user"`
	Database        string        `yaml:"database"`
	Charset         string        `yaml:"charset"`
	SocketPath      string        `yaml:"socket_path"` // 兜底：部分 VOS 仅允许 domain socket 访问
	ReadOnly        bool          `yaml:"read_only"`
	ConnMaxLifetime time.Duration `yaml:"conn_max_lifetime"`
	MaxOpenConns    int           `yaml:"max_open_conns"` // MyISAM 表锁，克制并发

	// Password 由 Load() 从 YK_MYSQL_PWD 指向的密钥文件注入，非 yaml 字段。
	Password string `yaml:"-"`
}

// Kafka 消息缓冲（替代参考实现的 RabbitMQ）。
type Kafka struct {
	Brokers       []string `yaml:"brokers"`
	CdrTopic      string   `yaml:"cdr_topic"`
	RealtimeTopic string   `yaml:"realtime_topic"`
	BackfillTopic string   `yaml:"backfill_topic"` // 回填专用隔离数据 Topic
	Compression   string   `yaml:"compression"`
	RequiredAcks  string   `yaml:"required_acks"`
	MaxRetries    int      `yaml:"max_retries"`
	SASL          SASL     `yaml:"sasl"`
}

// SASL Kafka 鉴权。Password 经 YK_KAFKA_PWD 注入。
type SASL struct {
	Mechanism string `yaml:"mechanism"`
	Username  string `yaml:"username"`
	Password  string `yaml:"-"`
}

// Sync 同步调度。
type Sync struct {
	Mode            string   `yaml:"mode"` // kafka(默认,推 Kafka) | off(不推,仅保留 serve 端点)
	IntervalSeconds int      `yaml:"interval_seconds"`
	BatchSize       int      `yaml:"batch_size"`
	Backfill        Backfill `yaml:"backfill"`
	// DimIntervalSeconds 维度/小表低频轮询间隔（§8.2）。
	DimIntervalSeconds int `yaml:"dim_interval_seconds"`
}

// Backfill 历史日表回填。
type Backfill struct {
	Enabled   bool     `yaml:"enabled"`
	DateRange []string `yaml:"date_range"` // ["2026-01-18","2026-03-09"]，空=全量发现
	Parallel  int      `yaml:"parallel"`
}

// DefaultCDRTable 是历史兼容用的默认滚动话单表名（与 source.RollingCDRTable 同值，
// 此处独立定义以避免 config↔source 的 import 环）。
const DefaultCDRTable = "e_cdr"

// TableSync 单表同步声明（§4，替代写死的 e_cdr 单表）。
//   Name  表名（information_schema 发现的或固定常量；非用户输入，仍做安全校验）
//   Type  cdr      计费话单（e_cdr + 滚动历史日表），按 flowno 水位增量
//         dimension 维度表（e_customer/e_phone/...），支持 full 全量或 incremental 按 key 增量
//   Mode  （仅 dimension）full=定时整表重放（CH ReplacingMergeTree 去重，幂等）|
//                     incremental=按 Key 列增量拉取
//   Key   （仅 dimension incremental）增量键列，如 id / lastupdatetime（白名单，防注入）
//   Backfill（仅 cdr）首跑回填历史日表
// 每表 interval/batch 独立覆盖全局 sync 段；缺省按类型回退默认值。
type TableSync struct {
	Name            string `yaml:"name"`
	Type            string `yaml:"type"`       // cdr | dimension
	Mode            string `yaml:"mode"`       // (dimension) full | incremental
	Key             string `yaml:"key"`        // (dimension incremental) 增量键列
	IntervalSeconds int    `yaml:"interval_seconds"`
	BatchSize       int    `yaml:"batch_size"`
	Backfill        bool   `yaml:"backfill"`
}

// EffectiveInterval 返回该表的有效轮询间隔（秒）。
func (t TableSync) EffectiveInterval() int {
	if t.IntervalSeconds > 0 {
		return t.IntervalSeconds
	}
	if t.Type == "dimension" {
		return 300
	}
	return 5
}

// EffectiveBatch 返回该表的有效批次大小。
func (t TableSync) EffectiveBatch() int {
	if t.BatchSize > 0 {
		return t.BatchSize
	}
	return 2000
}

// EffectiveMode 返回维度表的有效同步模式（缺省 full）。
func (t TableSync) EffectiveMode() string {
	if t.Mode != "" {
		return t.Mode
	}
	return "full"
}

// VosAPI 实时并发流（默认不启用，并发优先走 DB 近似，见 §6）。
type VosAPI struct {
	Enabled             bool   `yaml:"enabled"`
	BaseURL             string `yaml:"base_url"`
	PollIntervalSeconds int    `yaml:"poll_interval_seconds"`
	TimeoutSeconds      int    `yaml:"timeout_seconds"`
}

// Log 日志配置（§10）。所有参数走配置文件，不接收命令行参数。
type Log struct {
	Level string `yaml:"level"` // debug|info|warn|error
	Path  string `yaml:"path"`  // 空=输出到 stdout（由 init.d 重定向到 /var/log/ykvos-agent.log）；非空=写该文件
}

// State 水位（断点续传）持久化配置（§4.3）。
type State struct {
	File string `yaml:"file"` // state.json 路径；空=与 config.yaml 同目录
}

// Server 可选入站拉取端点（§3.5 双向 / 测试环境）。
// 默认 listen 为空 → agent 不起任何 inbound 端口（延续 §9 安全基线）。
// 仅当 VOS 服务器有公网、而平台部署环境无公网端口时，才配置 listen 让平台主动来拉。
type Server struct {
	Listen             string `yaml:"listen"`               // 例 ":8080"；空=不起服务
	Token              string `yaml:"-"`                     // 经 YK_SERVER_TOKEN 注入；空=不鉴权（内网）
	ReadTimeoutSeconds int    `yaml:"read_timeout_seconds"`
}

const (
	envMySQLPwd = "YK_MYSQL_PWD" // 指向密钥文件路径；兼容直接放明文密码
	envKafkaPwd = "YK_KAFKA_PWD"
	envServerToken = "YK_SERVER_TOKEN" // 指向 token 文件路径；兼容直接放明文 token
)

// safeKeyColumn 是 dimension 增量键列的白名单，防 SQL 注入（键列名拼进 WHERE）。
func safeKeyColumn(c string) bool {
	switch c {
	case "id", "lastupdatetime", "starttime", "flowno":
		return true
	}
	return false
}

// Load 读取 yaml 配置文件，注入密钥，填默认值并校验。
func Load(path string) (*Config, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("读取配置文件失败: %w", err)
	}
	var c Config
	if err := yaml.Unmarshal(raw, &c); err != nil {
		return nil, fmt.Errorf("解析 yaml 失败: %w", err)
	}

	c.applyDefaults()

	// state.file 默认值：与 config.yaml 同目录的 state.json（§4.3）。
	if c.State.File == "" {
		c.State.File = filepath.Join(filepath.Dir(path), "state.json")
	}

	// 安全：密码从密钥文件/环境变量注入，绝不从 yaml 读取（§9）。
	if pwd, err := readSecret(envMySQLPwd); err != nil {
		return nil, fmt.Errorf("注入 MySQL 密码失败: %w", err)
	} else {
		c.MySQL.Password = pwd
	}
	if pwd, err := readSecret(envKafkaPwd); err == nil {
		c.Kafka.SASL.Password = pwd // Kafka 鉴权可选，缺省不报错
	}
	if tok, err := readSecret(envServerToken); err == nil {
		c.Server.Token = tok // 入站端点鉴权可选，缺省不鉴权
	}

	if err := c.validate(); err != nil {
		return nil, err
	}
	return &c, nil
}

// readSecret 优先把环境变量值当作文件路径读取其内容；
// 若该路径不存在，则退化为把环境变量值本身当作密码（便于本地调试）。
func readSecret(envKey string) (string, error) {
	v := strings.TrimSpace(os.Getenv(envKey))
	if v == "" {
		return "", fmt.Errorf("环境变量 %s 未设置", envKey)
	}
	if info, err := os.Stat(v); err == nil && !info.IsDir() {
		b, err := os.ReadFile(v)
		if err != nil {
			return "", fmt.Errorf("读取密钥文件 %s 失败: %w", v, err)
		}
		return strings.TrimSpace(string(b)), nil
	}
	// 非文件路径：视为直接传入的密码值。
	return v, nil
}

func (c *Config) applyDefaults() {
	if c.MySQL.Port == 0 {
		c.MySQL.Port = 3306
	}
	if c.MySQL.Charset == "" {
		c.MySQL.Charset = "utf8mb4"
	}
	if c.MySQL.MaxOpenConns == 0 {
		c.MySQL.MaxOpenConns = 2
	}
	if c.MySQL.ConnMaxLifetime == 0 {
		c.MySQL.ConnMaxLifetime = 30 * time.Minute
	}
	if c.Sync.Mode == "" {
		c.Sync.Mode = "kafka"
	}
	if c.Sync.IntervalSeconds == 0 {
		c.Sync.IntervalSeconds = 5
	}
	if c.Sync.BatchSize == 0 {
		c.Sync.BatchSize = 2000
	}
	if c.Sync.DimIntervalSeconds == 0 {
		c.Sync.DimIntervalSeconds = 300
	}
	if c.Sync.Backfill.Parallel == 0 {
		c.Sync.Backfill.Parallel = 2
	}
	// 多表：tables 留空→兼容旧 sync:，仅同步 e_cdr 滚动表（保持已验证 CDR 行为）。
	if len(c.Tables) == 0 {
		c.Tables = []TableSync{{
			Name:            DefaultCDRTable,
			Type:            "cdr",
			Backfill:        c.Sync.Backfill.Enabled,
			IntervalSeconds: c.Sync.IntervalSeconds,
			BatchSize:       c.Sync.BatchSize,
		}}
	}
	if c.Kafka.CdrTopic == "" {
		c.Kafka.CdrTopic = "vos.cdr.live"
	}
	if c.Kafka.RealtimeTopic == "" {
		c.Kafka.RealtimeTopic = "vos.realtime"
	}
	if c.Kafka.BackfillTopic == "" {
		c.Kafka.BackfillTopic = "vos.agent.backfill.data"
	}
	if c.Kafka.Compression == "" {
		c.Kafka.Compression = "lz4"
	}
	if c.Kafka.RequiredAcks == "" {
		c.Kafka.RequiredAcks = "all"
	}
	if c.Kafka.MaxRetries == 0 {
		c.Kafka.MaxRetries = 10
	}
	if c.Log.Level == "" {
		c.Log.Level = "info"
	}
	if c.Server.ReadTimeoutSeconds == 0 {
		c.Server.ReadTimeoutSeconds = 30
	}
}

func (c *Config) validate() error {
	var errs []string
	if c.Instance.ID == "" {
		errs = append(errs, "instance.id 不能为空（用于区分多 VOS 来源）")
	}
	if c.MySQL.Host == "" && c.MySQL.SocketPath == "" {
		errs = append(errs, "mysql.host 与 mysql.socket_path 至少配置一项")
	}
	if c.MySQL.User == "" {
		errs = append(errs, "mysql.user 不能为空")
	}
	if c.MySQL.Database == "" {
		errs = append(errs, "mysql.database 不能为空")
	}
	if len(c.Kafka.Brokers) == 0 {
		errs = append(errs, "kafka.brokers 不能为空")
	}
	if c.Sync.Mode != "kafka" && c.Sync.Mode != "off" {
		errs = append(errs, "sync.mode 只能是 kafka(推 Kafka) 或 off(仅 serve)")
	}
	if c.Sync.Mode == "off" && c.Server.Listen == "" {
		errs = append(errs, "sync.mode=off 时需配置 server.listen 作为拉取端点，否则 agent 无工作")
	}
	// 多表声明校验。
	for i, t := range c.Tables {
		p := fmt.Sprintf("tables[%d](", i)
		if t.Name == "" {
			errs = append(errs, p+"name 不能为空")
		}
		switch t.Type {
		case "cdr", "dimension":
		default:
			errs = append(errs, p+"type 只能是 cdr 或 dimension，得到 "+t.Type)
		}
		if t.Type == "dimension" && t.EffectiveMode() == "incremental" && !safeKeyColumn(t.Key) {
			errs = append(errs, p+"dimension incremental 的 key 必须是白名单列（id/lastupdatetime/starttime/flowno），得到 "+t.Key)
		}
	}
	if len(errs) > 0 {
		return errors.New("配置校验失败:\n  - " + strings.Join(errs, "\n  - "))
	}
	return nil
}
