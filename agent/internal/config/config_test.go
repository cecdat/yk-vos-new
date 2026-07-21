package config

import (
	"os"
	"path/filepath"
	"testing"
)

// writeTemp 把 yaml 写入临时文件并返回路径。
func writeTemp(t *testing.T, name, content string) string {
	t.Helper()
	p := filepath.Join(t.TempDir(), name)
	if err := os.WriteFile(p, []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}
	return p
}

func TestLoad_DefaultTablesFromSync(t *testing.T) {
	t.Setenv("YK_MYSQL_PWD", "test")
	p := writeTemp(t, "legacy.yaml", `
instance:
  id: "vos1"
mysql:
  host: "127.0.0.1"
  user: "vosdev"
  database: "vos3000"
kafka:
  brokers: ["10.0.0.10:9092"]
sync:
  mode: "kafka"
  interval_seconds: 5
  batch_size: 2000
  backfill:
    enabled: true
`)
	c, err := Load(p)
	if err != nil {
		t.Fatal(err)
	}
	if len(c.Tables) != 1 {
		t.Fatalf("期望默认 1 张表(e_cdr)，得到 %d", len(c.Tables))
	}
	if c.Tables[0].Name != DefaultCDRTable || c.Tables[0].Type != "cdr" {
		t.Fatalf("默认表应为 e_cdr/cdr，得到 %+v", c.Tables[0])
	}
	if !c.Tables[0].Backfill {
		t.Fatalf("默认表应继承 sync.backfill.enabled=true")
	}
}

func TestLoad_ExplicitTables(t *testing.T) {
	t.Setenv("YK_MYSQL_PWD", "test")
	p := writeTemp(t, "multi.yaml", `
instance:
  id: "vos1"
mysql:
  host: "127.0.0.1"
  user: "vosdev"
  database: "vos3000"
kafka:
  brokers: ["10.0.0.10:9092"]
sync:
  mode: "kafka"
tables:
  - name: "e_cdr"
    type: "cdr"
    backfill: true
  - name: "e_customer"
    type: "dimension"
    mode: "full"
    interval_seconds: 300
  - name: "e_phone"
    type: "dimension"
    mode: "incremental"
    key: "id"
    interval_seconds: 60
`)
	c, err := Load(p)
	if err != nil {
		t.Fatal(err)
	}
	if len(c.Tables) != 3 {
		t.Fatalf("期望 3 张表，得到 %d", len(c.Tables))
	}
	if c.Tables[2].EffectiveMode() != "incremental" || c.Tables[2].Key != "id" {
		t.Fatalf("e_phone 增量配置解析错误: %+v", c.Tables[2])
	}
	if c.Tables[1].EffectiveInterval() != 300 {
		t.Fatalf("e_customer interval 应为 300，得到 %d", c.Tables[1].EffectiveInterval())
	}
}

func TestLoad_InvalidTableType(t *testing.T) {
	t.Setenv("YK_MYSQL_PWD", "test")
	p := writeTemp(t, "badtype.yaml", `
instance:
  id: "vos1"
mysql:
  host: "127.0.0.1"
  user: "vosdev"
  database: "vos3000"
kafka:
  brokers: ["10.0.0.10:9092"]
sync:
  mode: "kafka"
tables:
  - name: "e_customer"
    type: "wrong"
`)
	if _, err := Load(p); err == nil {
		t.Fatal("期望 type=wrong 校验失败")
	}
}

func TestLoad_DimensionIncrementalNeedsKey(t *testing.T) {
	t.Setenv("YK_MYSQL_PWD", "test")
	p := writeTemp(t, "nokey.yaml", `
instance:
  id: "vos1"
mysql:
  host: "127.0.0.1"
  user: "vosdev"
  database: "vos3000"
kafka:
  brokers: ["10.0.0.10:9092"]
sync:
  mode: "kafka"
tables:
  - name: "e_phone"
    type: "dimension"
    mode: "incremental"
    key: "notacolumn"
`)
	if _, err := Load(p); err == nil {
		t.Fatal("期望 dimension incremental 的非法 key 校验失败")
	}
}
