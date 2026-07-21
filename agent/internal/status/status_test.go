package status

import "testing"

func TestRegistry_RecordAndSnapshot(t *testing.T) {
	r := New()
	if len(r.Snapshot()) != 0 {
		t.Fatal("初始应为空")
	}

	// CDR 表：total=1000，已同步 980 → lag=20
	r.Record("e_cdr", "cdr", "incremental", 980, 1000, 980, nil)
	// 维度表：不追踪 lag
	r.Record("e_customer", "dimension", "full", 500, 0, 0, nil)
	// 错误记录
	r.Record("e_phone", "dimension", "full", 0, 0, 0, errTest{})

	snap := r.Snapshot()
	if len(snap) != 3 {
		t.Fatalf("期望 3 条状态，得到 %d", len(snap))
	}
	byTable := map[string]Entry{}
	for _, e := range snap {
		byTable[e.Table] = e
	}

	if byTable["e_cdr"].Lag != 20 {
		t.Fatalf("e_cdr lag 应为 20，得到 %d", byTable["e_cdr"].Lag)
	}
	if !byTable["e_cdr"].Healthy {
		t.Fatal("e_cdr 应健康")
	}
	if byTable["e_customer"].Type != "dimension" || byTable["e_customer"].Mode != "full" {
		t.Fatalf("e_customer 元数据错误: %+v", byTable["e_customer"])
	}
	if byTable["e_phone"].Healthy {
		t.Fatal("e_phone 应标记不健康")
	}
	if byTable["e_phone"].LastError == "" {
		t.Fatal("e_phone 应记录错误信息")
	}
}

func TestRegistry_NegativeLagZeroed(t *testing.T) {
	r := New()
	// 已同步超过源水位（不应出现负 lag）
	r.Record("e_cdr", "cdr", "incremental", 100, 90, 100, nil)
	if r.Snapshot()[0].Lag != 0 {
		t.Fatalf("负 lag 应归零，得到 %d", r.Snapshot()[0].Lag)
	}
}

type errTest struct{}

func (errTest) Error() string { return "boom" }
