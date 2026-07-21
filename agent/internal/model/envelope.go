// Package model 定义 Kafka 消息 Envelope（规格 §5.2）。
package model

import "encoding/json"

// SchemaVersion 字段演进时递增，CH/后端据此兼容。
const SchemaVersion = 1

// OpCreate VOS 话单只增不删改。
const OpCreate = "c"

// Envelope 一条话单消息的外层信封。
//   - key   = flowno 字符串（同 flowno 落同分区，保序去重）
//   - value = 本结构 JSON
type Envelope struct {
	SchemaVersion int                        `json:"schema_version"`
	Op            string                     `json:"op"`
	VosID         string                     `json:"vos_id"`    // config.instance.id
	SrcTable      string                     `json:"src_table"` // e_cdr / e_cdr_20260118 / e_axb_cdr ...
	Flowno        int64                      `json:"flowno"`
	TS            int64                      `json:"ts"`   // agent 发送时间 epoch_ms
	Data          map[string]json.RawMessage `json:"data"` // 表全字段；blob→base64 String，json→原样透传
}

// Marshal 序列化为 Kafka value。
func (e *Envelope) Marshal() ([]byte, error) {
	return json.Marshal(e)
}
