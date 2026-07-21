#!/bin/bash
# yk-vos 测试环境 — Kafka 初始化
# 由 compose 的 kafka-init 服务在 Kafka 健康后执行：
#   显式创建 topic vos.cdr.live（agent 生产推送 / 测试中继落库的目标 topic）。
# 单节点副本因子=1；--if-not-exists 保证幂等可重复执行。
set -euo pipefail

BOOTSTRAP="kafka:9092"
TOPIC="vos.cdr.live"

echo "[kafka-init] ensuring topic '${TOPIC}' exists on ${BOOTSTRAP} ..."
kafka-topics.sh --bootstrap-server "${BOOTSTRAP}" --create \
  --topic "${TOPIC}" \
  --partitions 3 \
  --replication-factor 1 \
  --if-not-exists || true

echo "[kafka-init] current topics:"
kafka-topics.sh --bootstrap-server "${BOOTSTRAP}" --list
echo "[kafka-init] done."
