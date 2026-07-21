# YK-VOS 生产环境（prod）— 待交付

本目录预留给**生产环境**交付物，架构与 `dev/` 一致，主要差异如下。到位后把对应
`*.tar.gz` / DDL / `docker-compose.yaml` 放入本目录，并补充本说明。

## 与 dev 的差异（生产须强化）
| 维度 | dev（当前） | prod（待补） |
|---|---|---|
| 同步方向 | 平台出站**拉取**（VOS 有公网、平台无端口） | agent **Kafka 直推**（生产 Kafka 有公网/专线可达） |
| agent `sync.mode` | `off` + `server.listen=:5233` | `kafka`（推 `vos.cdr.live`），`server.listen` 可留空 |
| 网络暴露 | 平台不暴露入站端口 | 平台侧 Kafka/CH 走专线/VPC，启用 TLS + SASL 鉴权 |
| 密钥管理 | `YK_MYSQL_PWD` / `YK_SERVER_TOKEN` 明文注入 | 走密钥库（Vault / KMS），不落盘 |
| 多节点 | 同 dev（按 `vos_id` 去重） | 同 dev，外加多可用区/灾备 |
| ClickHouse | 单实例容器 | 集群（含副本/分片），DDL 加 `ON CLUSTER` |
| 监控页 | 随 compose 起（FROM scratch） | 同 dev，外加告警（邮件/企微）接入 |
| 后端 | redis/postgres/backend 暂注释 | 启用 yudao 后端（见 compose 注释块） |

## 待放入本目录的交付物
- [ ] `agent/ykvos-agent-<prod版>.tar.gz`（Kafka 推送为默认模式）
- [ ] `clickhouse/01_ods_vos.sql`（生产版，含 `ON CLUSTER`）
- [ ] `clickhouse/02_kafka_ingest.sql`（生产消费者侧）
- [ ] `docker-compose.yaml`（生产编排：TLS/KMS/集群）
- [ ] `monitor/`（生产监控页 + 告警）
- [ ] `tools/`（生产拉取/回填脚本）
- [ ] `secrets/`（密钥注入说明，**不提交真实密钥**）

## 切换说明
当前激活环境为 `dev`。生产就绪后，部署时以 `prod/` 为准，并同步更新顶层
`release/README.md` 的「当前激活环境」标注。
