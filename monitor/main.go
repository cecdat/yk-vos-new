// Command yk-vos-monitor —— YK-VOS 数据链路监控页（docker-compose 形式运行）。
//
// 作用：周期性探测「各 VOS 节点 agent」与「ClickHouse 落库」两端，
// 计算链路 lag，输出一个极简的 HTTP 监控页，便于判断数据底座是否正常。
//
// 设计要点：
//   - 纯标准库（net/http + embed），静态二进制，无外部依赖，可 FROM scratch 运行。
//   - 探测方向：监控页在平台侧「出站」访问各 agent 的 /healthz 与 /v1/watermark，
//     以及本机 ClickHouse HTTP 接口；平台侧无需暴露任何入站端口。
//   - 多节点：每个 VOS 节点一个 agent；NODES 以 name=url 列出，vos_id=name。
//   - 链路 lag = agent 侧 MAX(flowno) − ClickHouse 侧 MAX(flowno)；lag>0 表示落后。
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strings"
	"sync"
	"time"
	_ "embed"
)

//go:embed dashboard.html
var dashboardHTML []byte

const (
	defaultCHURL    = "http://clickhouse:8123"
	defaultCHTable = "vos_cdr_ods"
	defaultPort     = "8088"
	defaultCacheSec = 8
)

var safeNameRe = regexp.MustCompile(`[^A-Za-z0-9_\-]`)

type Node struct {
	Name string
	URL  string
}

type NodeStatus struct {
	Name     string `json:"name"`
	URL      string `json:"url"`
	Healthy  bool   `json:"healthy"`
	Error    string `json:"error,omitempty"`
	AgentWM  int64  `json:"agent_watermark"`
	CHWM     int64  `json:"ch_watermark"`
	Rows     uint64 `json:"rows"`
	LastSync string `json:"last_sync,omitempty"`
	Lag      int64  `json:"lag"` // agent_wm - ch_wm（落后量）
}

type ClickHouseStatus struct {
	OK        bool   `json:"ok"`
	Error     string `json:"error,omitempty"`
	TotalRows uint64 `json:"total_rows"`
}

// chRow 是 ClickHouse 按 vos_id 聚合的一行（用于把 CH 侧水位按节点匹配）。
type chRow struct {
	Rows     uint64 `json:"rows"`
	WM       int64  `json:"wm"`
	LastSync string `json:"last_sync"`
}

type Status struct {
	OK         bool               `json:"ok"`
	GeneratedAt string            `json:"generated_at"`
	ClickHouse  ClickHouseStatus `json:"clickhouse"`
	Nodes       []NodeStatus      `json:"nodes"`
}

var (
	nodes   []Node
	chURL   string
	chTable string
	token   string
	httpc   = &http.Client{Timeout: 6 * time.Second}
	cache   = &cacheStore{}
)

type cacheStore struct {
	mu       sync.Mutex
	status   Status
	expireAt time.Time
}

func (c *cacheStore) get() (Status, bool) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if time.Now().Before(c.expireAt) {
		return c.status, true
	}
	return Status{}, false
}

func (c *cacheStore) put(s Status, ttl int) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.status = s
	c.expireAt = time.Now().Add(time.Duration(ttl) * time.Second)
}

func sanitizeName(s string) string {
	return safeNameRe.ReplaceAllString(s, "_")
}

func parseNodes(raw string) []Node {
	out := []Node{}
	for _, part := range strings.Split(raw, ",") {
		part = strings.TrimSpace(part)
		if part == "" {
			continue
		}
		if i := strings.Index(part, "="); i >= 0 {
			out = append(out, Node{Name: strings.TrimSpace(part[:i]), URL: strings.TrimSpace(part[i+1:])})
		} else {
			u, err := url.Parse(part)
			name := part
			if err == nil && u.Host != "" {
				name = u.Host
			}
			out = append(out, Node{Name: sanitizeName(name), URL: part})
		}
	}
	return out
}

func safeTable(t string) bool {
	for _, r := range t {
		if !(r >= 'a' && r <= 'z') && !(r >= 'A' && r <= 'Z') &&
			!(r >= '0' && r <= '9') && r != '_' {
			return false
		}
	}
	return t != ""
}

func httpGetJSON(target string, v any) error {
	req, err := http.NewRequest(http.MethodGet, target, nil)
	if err != nil {
		return err
	}
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	resp, err := httpc.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 512))
		return fmt.Errorf("HTTP %d: %s", resp.StatusCode, strings.TrimSpace(string(b)))
	}
	return json.NewDecoder(resp.Body).Decode(v)
}

func chQuery(query string) ([]byte, error) {
	u := chURL + "/?query=" + url.QueryEscape(query)
	resp, err := httpc.Get(u)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 512))
		return nil, fmt.Errorf("CH HTTP %d: %s", resp.StatusCode, strings.TrimSpace(string(b)))
	}
	return io.ReadAll(resp.Body)
}

func computeStatus() Status {
	st := Status{GeneratedAt: time.Now().Format(time.RFC3339), Nodes: []NodeStatus{}}

	// 1) ClickHouse 总览 + 各节点水位
	ch := ClickHouseStatus{}
	chRows := map[string]chRow{}
	if safeTable(chTable) {
		if b, err := chQuery(fmt.Sprintf("SELECT count() FROM %s", chTable)); err == nil {
			var n uint64
			if _, err2 := fmt.Sscanf(strings.TrimSpace(string(b)), "%d", &n); err2 == nil {
				ch.TotalRows = n
				ch.OK = true
			}
		} else {
			ch.Error = err.Error()
		}
		if b, err := chQuery(fmt.Sprintf(
			"SELECT vos_id, count() AS rows, max(flowno) AS wm, max(_sync_ts) AS last_sync FROM %s GROUP BY vos_id FORMAT JSON",
			chTable)); err == nil {
			var j struct {
				Data []struct {
					VosID    string `json:"vos_id"`
					Rows     uint64 `json:"rows"`
					WM       int64  `json:"wm"`
					LastSync string `json:"last_sync"`
				} `json:"data"`
			}
			if json.Unmarshal(b, &j) == nil {
				for _, d := range j.Data {
					chRows[d.VosID] = chRow{Rows: d.Rows, WM: d.WM, LastSync: d.LastSync}
				}
			}
		}
	} else {
		ch.Error = "invalid CH table name"
	}
	st.ClickHouse = ch

	// 2) 逐节点探测 agent（出站）
	for _, n := range nodes {
		ns := NodeStatus{Name: n.Name, URL: n.URL}
		// 健康检查
		req, _ := http.NewRequest(http.MethodGet, strings.TrimRight(n.URL, "/")+"/healthz", nil)
		if token != "" {
			req.Header.Set("Authorization", "Bearer "+token)
		}
		if resp, err := httpc.Do(req); err != nil {
			ns.Healthy = false
			ns.Error = err.Error()
		} else {
			ns.Healthy = resp.StatusCode == http.StatusOK
			resp.Body.Close()
		}
		// 水位
		var wm struct {
			Table     string `json:"table"`
			Watermark int64  `json:"watermark"`
		}
		if err := httpGetJSON(strings.TrimRight(n.URL, "/")+"/v1/watermark?table=e_cdr", &wm); err == nil {
			ns.AgentWM = wm.Watermark
		} else if ns.Error == "" {
			ns.Error = "watermark: " + err.Error()
		}
		// CH 侧匹配
		if c, ok := chRows[n.Name]; ok {
			ns.Rows = c.Rows
			ns.CHWM = c.WM
			ns.LastSync = c.LastSync
			ns.Lag = ns.AgentWM - c.WM
		} else {
			ns.Lag = ns.AgentWM // 尚无落库 → 全部落后
		}
		st.Nodes = append(st.Nodes, ns)
	}

	st.OK = ch.OK
	for _, n := range st.Nodes {
		if !n.Healthy {
			st.OK = false
		}
	}
	return st
}

func statusHandler(w http.ResponseWriter, r *http.Request) {
	if s, hit := cache.get(); hit {
		writeJSON(w, s)
		return
	}
	s := computeStatus()
	cache.put(s, cacheTTL)
	writeJSON(w, s)
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	_, _ = w.Write(dashboardHTML)
}

func writeJSON(w http.ResponseWriter, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(v)
}

var cacheTTL = defaultCacheSec

func main() {
	nodes = parseNodes(os.Getenv("NODES"))
	chURL = os.Getenv("CLICKHOUSE_URL")
	if chURL == "" {
		chURL = defaultCHURL
	}
	chTable = os.Getenv("CH_TABLE")
	if chTable == "" {
		chTable = defaultCHTable
	}
	token = os.Getenv("MONITOR_TOKEN")
	if v := os.Getenv("CACHE_SECONDS"); v != "" {
		if n, err := fmt.Sscanf(v, "%d", &cacheTTL); err == nil && n == 1 && cacheTTL > 0 {
			// ok
		}
	}
	port := os.Getenv("PORT")
	if port == "" {
		port = defaultPort
	}

	if len(nodes) == 0 {
		log.Println("[monitor] 警告：NODES 未配置，监控页将只显示 ClickHouse 状态")
	}
	for _, n := range nodes {
		log.Printf("[monitor] 监控节点: %s -> %s", n.Name, n.URL)
	}
	log.Printf("[monitor] ClickHouse=%s table=%s port=%s cache=%ds", chURL, chTable, port, cacheTTL)

	mux := http.NewServeMux()
	mux.HandleFunc("/api/status", statusHandler)
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, map[string]any{"status": "ok"})
	})
	mux.HandleFunc("/", indexHandler)

	addr := ":" + port
	log.Printf("[monitor] 监听 %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatalf("[monitor] 启动失败: %v", err)
	}
}
