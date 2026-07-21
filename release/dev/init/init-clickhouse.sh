#!/bin/bash
# yk-vos 测试环境 — ClickHouse 初始化
# 由 compose 的 clickhouse-init 服务在 CH 健康后执行：
#   1) 建 ODS/DWS 表（含多节点 vos_id 去重键）
#   2) 建 Kafka 引擎表 + 物化视图（生产消费链路验证）
# SQL 来自挂载的 /sql（即 release/dev/clickhouse/），幂等（IF NOT EXISTS）。
set -euo pipefail

SQL_DIR="/sql"
CH_HOST="clickhouse"
CH_PORT="9000"

echo "[clickhouse-init] waiting for clickhouse to accept queries on ${CH_HOST}:${CH_PORT} ..."
until clickhouse client --host "${CH_HOST}" --port "${CH_PORT}" --query "SELECT 1" >/dev/null 2>&1; do
  sleep 2
done
echo "[clickhouse-init] clickhouse is ready."

# 1. 创建后端应用所需的数据库 ykvos_ch
echo "[clickhouse-init] creating database ykvos_ch if not exists ..."
clickhouse client --host "${CH_HOST}" --port "${CH_PORT}" --query "CREATE DATABASE IF NOT EXISTS ykvos_ch"

# 2. 依次应用 DDL 并导入到 ykvos_ch 数据库
for f in 01_ods_vos.sql 02_kafka_ingest.sql; do
  if [ -f "${SQL_DIR}/${f}" ]; then
    echo "[clickhouse-init] applying ${f} to database ykvos_ch ..."
    clickhouse client --host "${CH_HOST}" --port "${CH_PORT}" --database "ykvos_ch" --multiquery < "${SQL_DIR}/${f}"
    echo "[clickhouse-init]   ${f} applied."
  else
    echo "[clickhouse-init] WARNING: ${SQL_DIR}/${f} not found, skipped."
  fi
done

echo "[clickhouse-init] schema applied. tables:"
clickhouse client --host "${CH_HOST}" --port "${CH_PORT}" --query "SHOW TABLES FROM ykvos_ch" 2>/dev/null || true
echo "[clickhouse-init] done."
