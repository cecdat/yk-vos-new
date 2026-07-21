package server

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/yk-vos/ykvos-agent/internal/source"
)

// fakeReader 是一个内存假实现，用于验证路由/鉴权/游标逻辑。
type fakeReader struct {
	rows []source.Row
}

func (f *fakeReader) ReadBatch(_ context.Context, _ string, watermark int64, _ int) ([]source.Row, error) {
	out := make([]source.Row, 0, len(f.rows))
	for _, r := range f.rows {
		if r.Flowno > watermark {
			out = append(out, r)
		}
	}
	return out, nil
}

func (f *fakeReader) Watermark(_ context.Context, _ string) (int64, error) {
	var max int64
	for _, r := range f.rows {
		if r.Flowno > max {
			max = r.Flowno
		}
	}
	return max, nil
}

func (f *fakeReader) CDRTables(_ context.Context) ([]string, error) {
	return []string{"e_cdr"}, nil
}

func (f *fakeReader) ReadByKey(_ context.Context, _ string, keyCol string, after int64, _ int) ([]source.Row, error) {
	if keyCol != "id" {
		return nil, fmt.Errorf("unsupported key col: %s", keyCol)
	}
	out := make([]source.Row, 0, len(f.rows))
	for _, r := range f.rows {
		if r.Flowno > after {
			out = append(out, r)
		}
	}
	return out, nil
}

func (f *fakeReader) MaxKey(_ context.Context, _ string, _ string) (int64, error) {
	var max int64
	for _, r := range f.rows {
		if r.Flowno > max {
			max = r.Flowno
		}
	}
	return max, nil
}

func sampleRows() []source.Row {
	return []source.Row{
		{Flowno: 10, Data: map[string]json.RawMessage{"id": json.RawMessage("10")}},
		{Flowno: 20, Data: map[string]json.RawMessage{"id": json.RawMessage("20")}},
		{Flowno: 30, Data: map[string]json.RawMessage{"id": json.RawMessage("30")}},
	}
}

func TestHealthz(t *testing.T) {
	srv := New(&fakeReader{}, "vos-1", "", nil, nil)
	ts := httptest.NewServer(srv.Handler())
	defer ts.Close()

	resp, err := http.Get(ts.URL + "/healthz")
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("healthz status = %d", resp.StatusCode)
	}
	var body map[string]any
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		t.Fatal(err)
	}
	if body["status"] != "ok" || body["vos_id"] != "vos-1" {
		t.Fatalf("unexpected healthz body: %v", body)
	}
}

func TestCDR_Auth(t *testing.T) {
	srv := New(&fakeReader{rows: sampleRows()}, "vos-1", "secret", nil, nil)
	ts := httptest.NewServer(srv.Handler())
	defer ts.Close()

	// 无 token → 401
	resp, _ := http.Get(ts.URL + "/v1/cdr")
	if resp.StatusCode != http.StatusUnauthorized {
		t.Fatalf("expected 401 without token, got %d", resp.StatusCode)
	}
	resp.Body.Close()

	// 正确 token → 200
	req, _ := http.NewRequest(http.MethodGet, ts.URL+"/v1/cdr?after=15&limit=10", nil)
	req.Header.Set("Authorization", "Bearer secret")
	resp2, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer resp2.Body.Close()
	if resp2.StatusCode != http.StatusOK {
		t.Fatalf("expected 200 with token, got %d", resp2.StatusCode)
	}
	var body struct {
		After     int64           `json:"after"`
		NextAfter int64           `json:"next_after"`
		Count     int             `json:"count"`
		Rows      []map[string]any `json:"rows"`
	}
	if err := json.NewDecoder(resp2.Body).Decode(&body); err != nil {
		t.Fatal(err)
	}
	if body.After != 15 || body.Count != 2 || body.NextAfter != 30 {
		t.Fatalf("cursor wrong: after=%d count=%d next_after=%d", body.After, body.Count, body.NextAfter)
	}
	if len(body.Rows) != 2 {
		t.Fatalf("expected 2 rows (flowno 20,30), got %d", len(body.Rows))
	}
	// 校验 Envelope 同构：含 vos_id / src_table / flowno / data
	if body.Rows[0]["vos_id"] != "vos-1" {
		t.Fatalf("vos_id missing in envelope")
	}
	if body.Rows[0]["src_table"] != "e_cdr" {
		t.Fatalf("src_table wrong: %v", body.Rows[0]["src_table"])
	}
}

func TestCDR_InvalidTable(t *testing.T) {
	srv := New(&fakeReader{}, "vos-1", "", nil, nil)
	ts := httptest.NewServer(srv.Handler())
	defer ts.Close()

	resp, _ := http.Get(ts.URL + "/v1/cdr?table=e_cdr'DROP")
	if resp.StatusCode != http.StatusBadRequest {
		t.Fatalf("expected 400 for invalid table, got %d", resp.StatusCode)
	}
	resp.Body.Close()
}

func TestWatermark(t *testing.T) {
	srv := New(&fakeReader{rows: sampleRows()}, "vos-1", "", nil, nil)
	ts := httptest.NewServer(srv.Handler())
	defer ts.Close()

	resp, err := http.Get(ts.URL + "/v1/watermark?table=e_cdr")
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("watermark status = %d", resp.StatusCode)
	}
	var body struct {
		Table     string `json:"table"`
		Watermark int64  `json:"watermark"`
		VosID     string `json:"vos_id"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		t.Fatal(err)
	}
	if body.Table != "e_cdr" || body.Watermark != 30 || body.VosID != "vos-1" {
		t.Fatalf("unexpected watermark body: %+v", body)
	}
}
