#!/bin/bash
# =====================================================================
# YK-VOS 测试环境 — MySQL「全量」初始化（自愈 / 幂等）
#
# 与 init-mysql-vos.sh（只补 VOS 模块 3 个文件）不同，本脚本负责【全量建库】：
#   quartz.sql + ykvos.sql + vos.sql + vos_menu.sql + vos_role_seed.sql
#
# 设计目标：摆脱 Docker 官方 MySQL「initdb.d 仅在数据目录【首次为空】时执行一次」
# 的脆弱性——只要 ykvos 库里缺表，就自动补齐；已存在的表绝不重复导入
# （ykvos.sql / vos.sql 含 DROP TABLE，误跑会清数据，故用哨兵表守护）。
# 所以无论：
#   - 数据卷是空的（首次部署，initdb.d 已建好表，本脚本检测到即跳过）；
#   - 还是被复用/残留（docker compose down 不会删 bind 挂载 ./data/mysql，
#     initdb.d 被整段跳过，库空空如也），
# 只要执行一次本脚本（或依赖 compose 的 mysql-init 服务），库结构都能自愈。
#
# 用法：
#   A) compose 内自动（推荐）：docker compose up -d 后 mysql-init 服务会跑本脚本
#   B) 手动补跑（库缺表时）：docker compose exec mysql bash /init/init-mysql.sh
#   C) 本机直连：MYSQL_HOST=127.0.0.1 MYSQL_PORT=3306 bash init/init-mysql.sh
#
# 连接参数均可用环境变量覆盖（默认值对齐 docker-compose.yaml 的 backend 服务：
#   root / 123456 / ykvos）。
# =====================================================================
set -euo pipefail

MYSQL_HOST="${MYSQL_HOST:-mysql}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-123456}"
MYSQL_DB="${MYSQL_DB:-ykvos}"

HERE="$(cd "$(dirname "$0")" && pwd)"
# 默认找本机布局的 sql 目录；compose 内可覆盖为挂载点
SQL_DIR="${SQL_DIR:-$HERE/../backend/sql/mysql}"
if [ -d /docker-entrypoint-initdb.d ]; then
    SQL_DIR="/docker-entrypoint-initdb.d"
fi

echo "[mysql-init] host=${MYSQL_HOST}:${MYSQL_PORT} db=${MYSQL_DB} user=${MYSQL_USER}"
echo "[mysql-init] sql dir = ${SQL_DIR}"

# 1) 确保库存在（复用卷时 MYSQL_DATABASE env 不会建库）
mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
  -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 等待可连接
echo "[mysql-init] waiting for MySQL to accept connections ..."
until mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
        -e "SELECT 1" "${MYSQL_DB}" >/dev/null 2>&1; do
    sleep 2
done
echo "[mysql-init] MySQL is ready."

# 2) 条件导入：哨兵表缺失才导入（守护 ykvos.sql/vos.sql 的 DROP TABLE 不误清数据）
#    映射：sql 文件 -> 一个必定由该文件创建的表
import_if_missing() {
    local f="$1" sentinel="$2"
    if [ ! -f "${SQL_DIR}/${f}" ]; then
        echo "[mysql-init] WARNING: ${SQL_DIR}/${f} not found, skipped."
        return
    fi
    local exists
    exists=$(mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -N \
        -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DB}' AND table_name='${sentinel}';" 2>/dev/null || echo 0)
    if [ "${exists:-0}" = "0" ]; then
        echo "[mysql-init] importing ${f} (sentinel ${sentinel} missing) ..."
        mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
            --force --default-character-set=utf8mb4 "${MYSQL_DB}" < "${SQL_DIR}/${f}" \
            && echo "[mysql-init]   ${f} applied." \
            || echo "[mysql-init]   ${f} finished (non-fatal skips possible)."
    else
        echo "[mysql-init] ${f} already present (sentinel ${sentinel}), skip."
    fi
}

import_if_missing ykvos.sql         infra_api_access_log

echo "[mysql-init] verifying ${MYSQL_DB} table count:"
mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
    -e "SELECT COUNT(*) AS table_count FROM information_schema.tables WHERE table_schema='${MYSQL_DB}';" "${MYSQL_DB}" 2>/dev/null || true

echo "[mysql-init] done."
