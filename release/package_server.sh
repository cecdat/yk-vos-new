#!/bin/bash
# YK-VOS 合并发布打包脚本（数据底座 + 应用层前后端）
# 用法： bash package_server.sh [dev|prod] [VERSION]
#   - 若 backend/yudao-server/target/yudao-server.jar 缺失 -> Maven 构建
#   - 若 frontend/apps/web-ele/dist 缺失或为空 -> pnpm 构建
#   - 把 jar / dist / MySQL 初始化 SQL 拷入 release/<env>/
#   - tar 整个 release/<env>/ 为 ykvos-server-<env>-<ver>.tar.gz
set -e

cd "$(dirname "$0")"
HERE="$(pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
TARGET_ENV="${1:-dev}"
VERSION="${2:-1.0.1}"
APP="ykvos-server-$TARGET_ENV"
PKG="$APP-$VERSION.tar.gz"
SRC_DIR="$HERE/$TARGET_ENV"

echo "==> 目标环境：$TARGET_ENV  版本：$VERSION"
echo "==> 根目录：$ROOT"

# ── 1) 后端 jar ──
JAR_SRC="$ROOT/backend/yudao-server/target/yudao-server.jar"
JAR_DST="$SRC_DIR/backend/yudao-server/target/yudao-server.jar"
if [ ! -f "$JAR_SRC" ]; then
  echo "==> [后端] jar 未构建，开始 Maven 构建（可能耗时较长）..."
  ( cd "$ROOT/backend" && bash "$ROOT/tools/mvn" -pl yudao-server -am package -DskipTests )
fi
mkdir -p "$(dirname "$JAR_DST")"
cp -f "$JAR_SRC" "$JAR_DST"
echo "==> [后端] jar 已就位：$(du -h "$JAR_DST" | cut -f1)"

# ── 2) 前端 dist ──
DIST_SRC="$ROOT/frontend/apps/web-ele/dist"
DIST_DST="$SRC_DIR/frontend/dist"
if [ ! -d "$DIST_SRC" ] || [ -z "$(ls -A "$DIST_SRC" 2>/dev/null)" ]; then
  echo "==> [前端] dist 未构建，开始 pnpm 构建..."
  bash "$ROOT/scripts/build_web_ele.sh"
fi
rm -rf "$DIST_DST"
cp -r "$DIST_SRC" "$DIST_DST"
echo "==> [前端] dist 已就位：$(du -sh "$DIST_DST" | cut -f1)"

# ── 3) MySQL 初始化 SQL（首次启动自动建库）──
SQL_SRC="$ROOT/backend/sql/mysql"
SQL_DST="$SRC_DIR/backend/sql/mysql"
if [ -d "$SQL_SRC" ]; then
  mkdir -p "$SQL_DST"
  cp -f "$SQL_SRC"/*.sql "$SQL_DST/" 2>/dev/null || true
  echo "==> [MySQL] 初始化 SQL 已就位：$(ls "$SQL_DST" 2>/dev/null | tr '\n' ' ')"
fi

# ── 4) 打包 ──
# 排除「服务端自己的历史版本 tar.gz」：避免把 ykvos-server-dev-1.0.1.tar.gz 等旧包打进新包。
# ⚠️ 注意：只排除 ykvos-server-* 自身包，【不要】排除 agent/ykvos-agent-*.tar.gz ——
#    那是当前组件，必须随服务端包一起分发（VOS 本机部署用）。
echo "==> 清理旧包并打包 $SRC_DIR/ -> $PKG（仅排除服务端历史包）"
rm -f "$PKG" "$SRC_DIR/$PKG"
tar -czf "$PKG" --exclude='ykvos-server-*.tar.gz' -C "$SRC_DIR" .
mv "$PKG" "$SRC_DIR/$PKG"

echo
echo "==> ✅ 发布包已生成：$SRC_DIR/$PKG"
echo "    部署：传到目标机后解压，cd release/$TARGET_ENV，"
echo "    cp .env.example .env && vi .env   # 填 VOS 节点 IP"
echo "    docker compose up -d mysql redis backend frontend clickhouse kafka monitor"
echo "    浏览器开 http://<目标机IP>:3000  （管理后台；后端 API 在 :48080 /admin-api）"
