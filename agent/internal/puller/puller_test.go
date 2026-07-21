package puller

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/yk-vos/ykvos-agent/internal/config"
	"github.com/yk-vos/ykvos-agent/internal/model"
	"github.com/yk-vos/ykvos-agent/internal/source"
	"github.com/yk-vos/ykvos-agent/internal/state"
	"github.com/yk-vos/ykvos-agent/internal/status"
	"log/slog"
	"path/filepath"
)

// ── 测试桩 ──

type fakeSource struct {
	batch func(table, keyCol string, after int64, limit int) []source.Row
	wm    func(table string) int64
}

func (f *fakeSource) ReadBatch(_ context.Context, t string, wm int64, lim int) ([]source.Row, error) {
	return f.batch(t, "flowno", wm, lim), nil
}
func (f *fakeSource) ReadByKey(_ context.Context, t, kc string, after int64, lim int) ([]source.Row, error) {
	return f.batch(t, kc, after, lim), nil
}
func (f *fakeSource) Watermark(_ context.Context, _ string) (int64, error) {
	return f.wm(""), nil
}
func (f *fakeSource) MaxKey(_ context.Context, _ string, _ string) (int64, error) {
	return 0, nil
}
func (f *fakeSource) CDRTables(_ context.Context) ([]string, error) {
	return []string{"e_cdr"}, nil
}

type fakeSink struct {
	envs []*model.Envelope
}

func (s *fakeSink) WriteEnvelopes(_ context.Context, envs []*model.Envelope) error {
	s.envs = append(s.envs, envs...)
	return nil
}

func dimRows(ids ...int) []source.Row {
	out := make([]source.Row, 0, len(ids))
	for _, id := range ids {
		out = append(out, source.Row{
			Flowno: int64(id),
			Data:   map[string]json.RawMessage{"id": json.RawMessage(itoa(id))},
		})
	}
	return out
}

func itoa(i int) string {
	if i == 0 {
		return "0"
	}
	neg := i < 0
	if neg {
		i = -i
	}
	var b [20]byte
	pos := len(b)
	for i > 0 {
		pos--
		b[pos] = byte('0' + i%10)
		i /= 10
	}
	if neg {
		pos--
		b[pos] = '-'
	}
	return string(b[pos:])
}

func tempState(t *testing.T) *state.Store {
	t.Helper()
	p := filepath.Join(t.TempDir(), "state.json")
	st, err := state.Load(p)
	if err != nil {
		t.Fatal(err)
	}
	return st
}

// ── 用例 ──

func TestDimension_FullSnapshot(t *testing.T) {
	// 全量模式：每轮整表重放（按 id 分页 2 条/页）。
	src := &fakeSource{batch: func(table, kc string, after int64, lim int) []source.Row {
		all := dimRows(1, 2, 3)
		var out []source.Row
		for _, r := range all {
			if r.Flowno >= after && len(out) < lim {
				out = append(out, r)
			}
		}
		return out
	}}
	snk := &fakeSink{}
	st := tempState(t)
	reg := status.New()
	cfg := config.TableSync{Name: "e_customer", Type: "dimension", Mode: "full"}

	dp := NewDimension(src, snk, st, cfg, "vos1", reg)
	dp.drainFull(context.Background(), slog.Default())

	if len(snk.envs) != 3 {
		t.Fatalf("全量应发 3 行，得到 %d", len(snk.envs))
	}
	// Envelope.Flowno 应承载维度主键 id。
	if snk.envs[0].Flowno != 1 || snk.envs[2].Flowno != 3 {
		t.Fatalf("Envelope.Flowno 应等于 id: %+v", snk.envs)
	}
	if snk.envs[0].SrcTable != "e_customer" {
		t.Fatalf("SrcTable 错误: %s", snk.envs[0].SrcTable)
	}
	if reg.Snapshot()[0].LastRows != 3 {
		t.Fatalf("状态应记录 3 行，得到 %d", reg.Snapshot()[0].LastRows)
	}
}

func TestDimension_Incremental(t *testing.T) {
	// 增量模式：水位从 0 起，拉 id>0，发完后推进到 max(id)。
	src := &fakeSource{batch: func(table, kc string, after int64, lim int) []source.Row {
		all := dimRows(1, 2, 3)
		var out []source.Row
		for _, r := range all {
			if r.Flowno > after && len(out) < lim {
				out = append(out, r)
			}
		}
		return out
	}}
	snk := &fakeSink{}
	st := tempState(t)
	reg := status.New()
	cfg := config.TableSync{Name: "e_phone", Type: "dimension", Mode: "incremental", Key: "id"}

	dp := NewDimension(src, snk, st, cfg, "vos1", reg)
	dp.drainIncremental(context.Background(), slog.Default())

	if len(snk.envs) != 3 {
		t.Fatalf("增量首轮应发 3 行，得到 %d", len(snk.envs))
	}
	wm, done := st.Watermark("e_phone")
	if done || wm != 3 {
		t.Fatalf("水位应推进到 3，得到 wm=%d done=%v", wm, done)
	}

	// 第二轮：无新数据，应不重发。
	snk2 := &fakeSink{}
	dp2 := NewDimension(src, snk2, st, cfg, "vos1", reg)
	dp2.drainIncremental(context.Background(), slog.Default())
	if len(snk2.envs) != 0 {
		t.Fatalf("水位已追平，第二轮应 0 行，得到 %d", len(snk2.envs))
	}
}
