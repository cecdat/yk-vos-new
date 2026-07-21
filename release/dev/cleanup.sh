#!/usr/bin/env bash
# =====================================================================
# YK-VOS 部署清理脚本
# 用途：每次更新部署之前执行，删除所有「需要更新的文件/目录」，
#       仅保留「数据映射目录」与运行时配置，避免把数据库等数据清掉。
# 用法（在解压后的 release/dev/ 目录内执行）：
#   bash cleanup.sh            # 交互确认后删除
#   bash cleanup.sh --force   # 跳过确认直接删除
#   bash cleanup.sh --dry-run # 只打印将要删除的内容，不实际删除
#
# 安全约定：
#   1) 仅当脚本所在目录存在 docker-compose.yaml 时才允许执行，防误删。
#   2) 删除前先 `docker compose down` 停止容器（不影响 ./data 持久化目录）。
#   3) 仅保留 ./data（MySQL/ClickHouse/Kafka/日志）与 ./.env（运行时配置，
#      新包不含此文件，删了需重新从 .env.example 复制填写）。
# =====================================================================
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DEPLOY_DIR"

DRY_RUN=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "未知参数: $arg" >&2; exit 2 ;;
  esac
done

# ── 安全保护：确认在正确的部署目录内 ──
if [ ! -f docker-compose.yaml ] && [ ! -f docker-compose.yml ]; then
  echo "❌ 当前目录未发现 docker-compose.yaml，疑似位置错误，已中止以防误删。" >&2
  echo "   请在解压后的 release/dev/ 目录内运行本脚本。" >&2
  exit 1
fi

# 需要保留的项（相对 DEPLOY_DIR）
KEEP=( "data" ".env" "cleanup.sh" )

# ── 停止容器（释放挂载与端口，不影响 ./data）──
if command -v docker >/dev/null 2>&1; then
  if docker compose >/dev/null 2>&1; then
    echo "==> 停止并移除容器（docker compose down，不删数据卷）..."
    docker compose down || echo "   （compose down 失败或无需停止，继续）"
  fi
else
  echo "⚠️ 未检测到 docker，跳过 compose down；请手动停止容器后再删文件。"
fi

# ── 计算待删除项（当前目录一级条目，排除保留项）──
mapfile -t ALL < <(find . -maxdepth 1 -mindepth 1 | sed 's|^\./||' | sort)

TO_DELETE=()
for item in "${ALL[@]}"; do
  keep=0
  for k in "${KEEP[@]}"; do
    [ "$item" = "$k" ] && keep=1 && break
  done
  [ "$keep" -eq 0 ] && TO_DELETE+=("$item")
done

if [ "${#TO_DELETE[@]}" -eq 0 ]; then
  echo "✅ 没有需要清理的文件（仅保留: ${KEEP[*]}）。"
  exit 0
fi

echo
echo "将保留: ${KEEP[*]}"
echo "将删除:"
for d in "${TO_DELETE[@]}"; do echo "  - $d"; done
echo

if [ "$DRY_RUN" -eq 1 ]; then
  echo "（dry-run 模式，未实际删除）"
  exit 0
fi

if [ "$FORCE" -ne 1 ]; then
  read -r -p "确认删除以上 ${#TO_DELETE[@]} 项？(yes/no) " ans
  case "$ans" in
    yes|YES|y|Y) ;;
    *) echo "已取消。"; exit 0 ;;
  esac
fi

echo "==> 删除中..."
for d in "${TO_DELETE[@]}"; do
  rm -rf "./$d"
done

echo
echo "✅ 清理完成。现在可把新的压缩包内容解压到本目录，再执行："
echo "      docker compose up -d"
echo "   保留的目录: ./data（数据库/ClickHouse/Kafka/日志）与 ./.env（运行时配置）"
