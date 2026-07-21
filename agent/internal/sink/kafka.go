// Package sink 封装 Kafka 生产者（规格 §5）：key=flowno、lz4 压缩、acks=all、重试退避。
package sink

import (
	"context"
	"crypto/tls"
	"fmt"
	"strconv"
	"time"

	"github.com/segmentio/kafka-go"
	"github.com/segmentio/kafka-go/sasl/scram"

	"github.com/yk-vos/ykvos-agent/internal/config"
	"github.com/yk-vos/ykvos-agent/internal/model"
)

// KafkaSink 封装 Kafka 生产者。
//   - w    : 固定 topic 写入器（cdr/realtime），消息本身不携带 Topic；
//   - rawW : 动态 topic 写入器（vos.agent.report 等），Topic 写在 Message 上。
// 注：kafka-go 不允许 Writer 与 Message 同时指定 Topic，故心跳/ACK 必须用无 Topic 的 rawW。
type KafkaSink struct {
	w          *kafka.Writer
	backfillW  *kafka.Writer // 固定 topic 回填写入器
	rawW       *kafka.Writer
	maxRetries int
}

// NewKafka 构造生产者。topic 由调用方指定（cdr / realtime）。
func NewKafka(cfg config.Kafka, topic string) (*KafkaSink, error) {
	transport := &kafka.Transport{}
	if cfg.SASL.Mechanism != "" {
		mech, err := scram.Mechanism(scramAlgo(cfg.SASL.Mechanism), cfg.SASL.Username, cfg.SASL.Password)
		if err != nil {
			return nil, fmt.Errorf("初始化 SASL 失败: %w", err)
		}
		transport.SASL = mech
		transport.TLS = &tls.Config{MinVersion: tls.VersionTLS12}
	}

	w := &kafka.Writer{
		Addr:         kafka.TCP(cfg.Brokers...),
		Topic:        topic,
		Balancer:     &kafka.Hash{}, // 按 key(flowno) 哈希分区，保证同 flowno 落同分区
		RequiredAcks: requiredAcks(cfg.RequiredAcks),
		Compression:  compression(cfg.Compression),
		BatchTimeout: 200 * time.Millisecond,
		Transport:    transport,
	}
	backfillW := &kafka.Writer{
		Addr:         kafka.TCP(cfg.Brokers...),
		Topic:        cfg.BackfillTopic,
		Balancer:     &kafka.Hash{}, // 同上哈希分区
		RequiredAcks: requiredAcks(cfg.RequiredAcks),
		Compression:  compression(cfg.Compression),
		BatchTimeout: 200 * time.Millisecond,
		Transport:    transport,
	}
	// 动态 topic 写入器：心跳/ACK 等写往 vos.agent.report，Topic 写在 Message 上，
	// 不能与上方固定 topic 的 Writer 共用（kafka-go 会报 Topic 双重设置）。
	rawW := &kafka.Writer{
		Addr:         kafka.TCP(cfg.Brokers...),
		Balancer:     &kafka.LeastBytes{},
		RequiredAcks: requiredAcks(cfg.RequiredAcks),
		Compression:  compression(cfg.Compression),
		BatchTimeout: 200 * time.Millisecond,
		Transport:    transport,
	}
	return &KafkaSink{w: w, backfillW: backfillW, rawW: rawW, maxRetries: cfg.MaxRetries}, nil
}

// WriteEnvelopes 批量写入信封，key=flowno。带指数退避重试，失败返回 error（调用方决定是否推进水位）。
func (k *KafkaSink) WriteEnvelopes(ctx context.Context, envs []*model.Envelope) error {
	if len(envs) == 0 {
		return nil
	}
	msgs := make([]kafka.Message, 0, len(envs))
	for _, e := range envs {
		val, err := e.Marshal()
		if err != nil {
			return fmt.Errorf("序列化 envelope 失败: %w", err)
		}
		msgs = append(msgs, kafka.Message{
			Key:   []byte(strconv.FormatInt(e.Flowno, 10)),
			Value: val,
		})
	}

	var lastErr error
	for attempt := 0; attempt <= k.maxRetries; attempt++ {
		if attempt > 0 {
			backoff := time.Duration(1<<min(attempt, 6)) * 100 * time.Millisecond
			select {
			case <-ctx.Done():
				return ctx.Err()
			case <-time.After(backoff):
			}
		}
		if err := k.w.WriteMessages(ctx, msgs...); err != nil {
			lastErr = err
			continue
		}
		return nil
	}
	return fmt.Errorf("Kafka 写入重试 %d 次仍失败: %w", k.maxRetries, lastErr)
}

// WriteBackfillEnvelopes 批量写入回填信封至专属回填队列，key=flowno。
func (k *KafkaSink) WriteBackfillEnvelopes(ctx context.Context, envs []*model.Envelope) error {
	if len(envs) == 0 {
		return nil
	}
	msgs := make([]kafka.Message, 0, len(envs))
	for _, e := range envs {
		val, err := e.Marshal()
		if err != nil {
			return fmt.Errorf("序列化 envelope 失败: %w", err)
		}
		msgs = append(msgs, kafka.Message{
			Key:   []byte(strconv.FormatInt(e.Flowno, 10)),
			Value: val,
		})
	}

	var lastErr error
	for attempt := 0; attempt <= k.maxRetries; attempt++ {
		if attempt > 0 {
			backoff := time.Duration(1<<min(attempt, 6)) * 100 * time.Millisecond
			select {
			case <-ctx.Done():
				return ctx.Err()
			case <-time.After(backoff):
			}
		}
		if err := k.backfillW.WriteMessages(ctx, msgs...); err != nil {
			lastErr = err
			continue
		}
		return nil
	}
	return fmt.Errorf("Kafka 写入回填重试 %d 次仍失败: %w", k.maxRetries, lastErr)
}

// WriteRaw 写入单条原始字节消息（支持动态指定 topic）。带重试退避。
func (k *KafkaSink) WriteRaw(ctx context.Context, topic, key string, val []byte) error {
	msg := kafka.Message{
		Topic: topic,
		Key:   []byte(key),
		Value: val,
	}

	var lastErr error
	for attempt := 0; attempt <= k.maxRetries; attempt++ {
		if attempt > 0 {
			backoff := time.Duration(1<<min(attempt, 6)) * 100 * time.Millisecond
			select {
			case <-ctx.Done():
				return ctx.Err()
			case <-time.After(backoff):
			}
		}
		if err := k.rawW.WriteMessages(ctx, msg); err != nil {
			lastErr = err
			continue
		}
		return nil
	}
	return fmt.Errorf("Kafka WriteRaw 重试 %d 次仍失败: %w", k.maxRetries, lastErr)
}

// Close 刷新并关闭生产者（两个 Writer 都关闭）。
func (k *KafkaSink) Close() error {
	if k.w == nil && k.backfillW == nil && k.rawW == nil {
		return nil
	}
	var firstErr error
	if k.w != nil {
		if err := k.w.Close(); err != nil {
			firstErr = err
		}
	}
	if k.backfillW != nil {
		if err := k.backfillW.Close(); err != nil && firstErr == nil {
			firstErr = err
		}
	}
	if k.rawW != nil {
		if err := k.rawW.Close(); err != nil && firstErr == nil {
			firstErr = err
		}
	}
	return firstErr
}

func requiredAcks(s string) kafka.RequiredAcks {
	switch s {
	case "none", "0":
		return kafka.RequireNone
	case "one", "1", "leader":
		return kafka.RequireOne
	default:
		return kafka.RequireAll // 计费话单：丢一天不可接受
	}
}

func compression(s string) kafka.Compression {
	switch s {
	case "gzip":
		return kafka.Gzip
	case "snappy":
		return kafka.Snappy
	case "zstd":
		return kafka.Zstd
	case "none", "":
		return 0
	default:
		return kafka.Lz4
	}
}

func scramAlgo(mech string) scram.Algorithm {
	switch mech {
	case "SCRAM-SHA-256":
		return scram.SHA256
	default:
		return scram.SHA512
	}
}
