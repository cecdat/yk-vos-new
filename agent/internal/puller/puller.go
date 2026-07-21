// Package puller 实现表轮询循环（规格 §4/§6.2）。
// 支持两类同步：
//   - CDR 话单（type=cdr）：按 flowno 水位增量拉取 → 发 Kafka → 推进水位落盘 → 断点续传。
//   - 维度表（type=dimension）：full=整表定时重放（CH ReplacingMergeTree 去重，幂等）；
//                              incremental=按 Key 列增量拉取。
// 两类都把「表天然去重键」写进 Envelope.Flowno（CDR=flowno，dimension=id），
// 下游按 SrcTable 映射到对应 ODS 的 ORDER BY 列，消费逻辑完全复用。
package puller

import (
	"context"
	"time"

	"github.com/yk-vos/ykvos-agent/internal/config"
	"github.com/yk-vos/ykvos-agent/internal/logx"
	"github.com/yk-vos/ykvos-agent/internal/model"
	"github.com/yk-vos/ykvos-agent/internal/source"
	"github.com/yk-vos/ykvos-agent/internal/state"
	"github.com/yk-vos/ykvos-agent/internal/status"
)

// logger 是 slog.Logger 的最小接口，便于测试替换。
type logger interface {
	Info(msg string, args ...any)
	Error(msg string, args ...any)
}

// sourceReader 是 puller 对 VOS 源的依赖（由 *source.Source 满足），便于单测。
type sourceReader interface {
	ReadBatch(ctx context.Context, table string, watermark int64, limit int) ([]source.Row, error)
	ReadByKey(ctx context.Context, table, keyCol string, after int64, limit int) ([]source.Row, error)
	Watermark(ctx context.Context, table string) (int64, error)
	MaxKey(ctx context.Context, table, keyCol string) (int64, error)
	CDRTables(ctx context.Context) ([]string, error)
}

// sinker 是 puller 对 Kafka 的写依赖（由 *sink.KafkaSink 满足）。
type sinker interface {
	WriteEnvelopes(ctx context.Context, envs []*model.Envelope) error
}

// Puller 单表话单（CDR）拉取器：按 flowno 水位增量。
type Puller struct {
	src      sourceReader
	sink     sinker
	st       *state.Store
	cfg      config.Sync
	vosID    string
	table    string
	interval time.Duration
	batch    int
	reg      *status.Registry // 可选；非空则上报同步状态
}

// New 创建 CDR 拉取器（src/snk 可为任意满足接口的实现，含 *source.Source/*sink.KafkaSink）。
func New(src sourceReader, snk sinker, st *state.Store, cfg config.Sync, vosID, table string, reg *status.Registry) *Puller {
	return &Puller{
		src:      src,
		sink:     snk,
		st:       st,
		cfg:      cfg,
		vosID:    vosID,
		table:    table,
		interval: time.Duration(cfg.IntervalSeconds) * time.Second,
		batch:    cfg.BatchSize,
		reg:      reg,
	}
}

// Run 阻塞运行轮询循环，直到 ctx 取消。
func (p *Puller) Run(ctx context.Context) {
	log := logx.Module("puller").With("table", p.table, "type", "cdr")
	log.Info("启动话单轮询", "interval", p.interval.String(), "batch", p.batch)

	ticker := time.NewTicker(p.interval)
	defer ticker.Stop()

	p.drain(ctx, log)
	for {
		select {
		case <-ctx.Done():
			log.Info("收到停止信号，轮询退出")
			return
		case <-ticker.C:
			p.drain(ctx, log)
		}
	}
}

// drain 尽量把当前落后的水位追平：连续拉满 batch 就继续，直到不足一批或出错。
func (p *Puller) drain(ctx context.Context, log logger) {
	for {
		select {
		case <-ctx.Done():
			return
		default:
		}
		n, err := p.pollOnce(ctx, log)
		if err != nil {
			log.Error("本轮拉取失败，等待下个周期重试", "err", err.Error())
			return
		}
		if n < p.batch {
			return // 已追平，等待下一个 tick
		}
	}
}

// pollOnce 拉取并发送一批，成功后推进水位。返回本批行数。
func (p *Puller) pollOnce(ctx context.Context, log logger) (int, error) {
	// 源表总水位（用于算 lag）。
	srcMax, werr := p.src.Watermark(ctx, p.table)
	if werr != nil {
		log.Error("读取源水位失败", "err", werr.Error())
	}

	wm, done := p.st.Watermark(p.table)
	if done {
		return 0, nil // 历史日表已回填完成
	}

	rows, err := p.src.ReadBatch(ctx, p.table, wm, p.batch)
	if err != nil {
		p.report(srcMax, wm, 0, err)
		return 0, err
	}
	if len(rows) == 0 {
		p.report(srcMax, wm, 0, nil)
		return 0, nil
	}

	now := time.Now().UnixMilli()
	envs := make([]*model.Envelope, 0, len(rows))
	var maxFlowno int64 = wm
	for _, r := range rows {
		envs = append(envs, &model.Envelope{
			SchemaVersion: model.SchemaVersion,
			Op:            model.OpCreate,
			VosID:         p.vosID,
			SrcTable:      p.table,
			Flowno:        r.Flowno,
			TS:            now,
			Data:          r.Data,
		})
		if r.Flowno > maxFlowno {
			maxFlowno = r.Flowno
		}
	}

	if err := p.sink.WriteEnvelopes(ctx, envs); err != nil {
		p.report(srcMax, wm, 0, err)
		return 0, err // 发送失败：不推进水位，下轮重来（幂等）
	}

	if err := p.st.SetWatermark(p.table, maxFlowno); err != nil {
		// 已发 Kafka 但水位落盘失败：重启会重发，靠 flowno 去重，安全但需告警。
		log.Error("水位落盘失败（数据已发送，重启将重放）", "flowno", maxFlowno, "err", err.Error())
		p.report(srcMax, maxFlowno, len(rows), err)
		return len(rows), err
	}

	log.Info("已发送一批", "count", len(rows), "watermark", maxFlowno)
	p.report(srcMax, maxFlowno, len(rows), nil)
	return len(rows), nil
}

func (p *Puller) report(srcMax, synced int64, rows int, err error) {
	if p.reg == nil {
		return
	}
	p.reg.Record(p.table, "cdr", "incremental", rows, srcMax, synced, err)
}

// ───────────────────────── 维度表拉取器 ─────────────────────────

// DimensionPuller 维度表（e_customer/e_phone/...）拉取器。
type DimensionPuller struct {
	src      sourceReader
	sink     sinker
	st       *state.Store
	cfg      config.TableSync
	vosID    string
	interval time.Duration
	batch    int
	reg      *status.Registry
}

// NewDimension 创建维度表拉取器（src/snk 可为任意满足接口的实现）。
func NewDimension(src sourceReader, snk sinker, st *state.Store, cfg config.TableSync, vosID string, reg *status.Registry) *DimensionPuller {
	return &DimensionPuller{
		src:      src,
		sink:     snk,
		st:       st,
		cfg:      cfg,
		vosID:    vosID,
		interval: time.Duration(cfg.EffectiveInterval()) * time.Second,
		batch:    cfg.EffectiveBatch(),
		reg:      reg,
	}
}

// Run 阻塞运行维度表轮询。
func (d *DimensionPuller) Run(ctx context.Context) {
	log := logx.Module("puller").With("table", d.cfg.Name, "type", "dimension", "mode", d.cfg.EffectiveMode())
	log.Info("启动维度表轮询", "interval", d.interval.String(), "batch", d.batch)

	ticker := time.NewTicker(d.interval)
	defer ticker.Stop()

	d.drain(ctx, log)
	for {
		select {
		case <-ctx.Done():
			log.Info("收到停止信号，轮询退出")
			return
		case <-ticker.C:
			d.drain(ctx, log)
		}
	}
}

func (d *DimensionPuller) drain(ctx context.Context, log logger) {
	switch d.cfg.EffectiveMode() {
	case "incremental":
		d.drainIncremental(ctx, log)
	default: // full：整表定时重放
		d.drainFull(ctx, log)
	}
}

// drainFull 每轮把整表重放一遍（按 id 分页），下游 CH 按 (vos_id,id) 去重，幂等。
func (d *DimensionPuller) drainFull(ctx context.Context, log logger) {
	total := 0
	cursor := int64(0)
	for {
		select {
		case <-ctx.Done():
			return
		default:
		}
		rows, err := d.src.ReadByKey(ctx, d.cfg.Name, "id", cursor, d.batch)
		if err != nil {
			d.report(total, err)
			log.Error("维度整表读取失败", "err", err.Error())
			return
		}
		if len(rows) == 0 {
			break
		}
		if err := d.emit(ctx, log, rows); err != nil {
			d.report(total, err)
			return
		}
		total += len(rows)
		// 推进游标到本页最大 id+1，避免重复。
		var maxID int64
		for _, r := range rows {
			if r.Flowno > maxID {
				maxID = r.Flowno
			}
		}
		cursor = maxID + 1
		if len(rows) < d.batch {
			break
		}
	}
	log.Info("维度整表重放完成", "table", d.cfg.Name, "rows", total)
	d.report(total, nil)
}

// drainIncremental 按 Key 列增量拉取（水位存于 state.json，复用 Store 的 int64 值语义）。
func (d *DimensionPuller) drainIncremental(ctx context.Context, log logger) {
	wm, done := d.st.Watermark(d.cfg.Name)
	if done {
		// 维度表不做 done 语义；若误标，清空继续。
		_ = d.st.SetWatermark(d.cfg.Name, 0)
		wm = 0
	}
	rows, err := d.src.ReadByKey(ctx, d.cfg.Name, d.cfg.Key, wm, d.batch)
	if err != nil {
		d.report(0, err)
		log.Error("维度增量读取失败", "err", err.Error())
		return
	}
	if len(rows) == 0 {
		d.report(0, nil)
		return
	}
	if err := d.emit(ctx, log, rows); err != nil {
		d.report(0, err)
		return
	}
	var maxKey int64 = wm
	for _, r := range rows {
		if r.Flowno > maxKey {
			maxKey = r.Flowno
		}
	}
	if err := d.st.SetWatermark(d.cfg.Name, maxKey); err != nil {
		log.Error("维度水位落盘失败", "err", err.Error())
		d.report(0, err)
		return
	}
	log.Info("维度增量已发送", "table", d.cfg.Name, "count", len(rows), "watermark", maxKey)
	d.report(len(rows), nil)
}

// emit 把行转为 Envelope 并写入 Kafka。Envelope.Flowno = 维度主键 id（承载天然去重键）。
func (d *DimensionPuller) emit(ctx context.Context, log logger, rows []source.Row) error {
	now := time.Now().UnixMilli()
	envs := make([]*model.Envelope, 0, len(rows))
	for _, r := range rows {
		envs = append(envs, &model.Envelope{
			SchemaVersion: model.SchemaVersion,
			Op:            model.OpCreate,
			VosID:         d.vosID,
			SrcTable:      d.cfg.Name,
			Flowno:        r.Flowno, // 维度表 = id
			TS:            now,
			Data:          r.Data,
		})
	}
	if err := d.sink.WriteEnvelopes(ctx, envs); err != nil {
		log.Error("维度消息发送失败（未推进水位）", "err", err.Error())
		return err
	}
	return nil
}

func (d *DimensionPuller) report(rows int, err error) {
	if d.reg == nil {
		return
	}
	d.reg.Record(d.cfg.Name, "dimension", d.cfg.EffectiveMode(), rows, 0, 0, err)
}
