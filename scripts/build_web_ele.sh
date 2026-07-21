#!/bin/bash
# 构建 web-ele 前端为静态产物（用于 release 合并包）。
# 用法： bash scripts/build_web_ele.sh
set -e

cd "$(dirname "$0")/../frontend"

# CI=true 跳过 lefthook(prepare) 等非必要步骤
export CI=true

# 使用托管 node + pnpm（corepack 已损坏，统一走 npx pnpm@11）
NODE_BIN="$(command -v node)"
echo "==> node: $NODE_BIN"
node -v

echo "==> pnpm install (web-ele monorepo)"
# 优先 frozen-lockfile，失败则普通 install
npx -y pnpm@11 install --frozen-lockfile || npx -y pnpm@11 install

echo "==> build web-ele (--mode production, 读取 .env.production)"
npx -y pnpm@11 --filter @vben/web-ele build

echo "==> 构建产物："
ls -la apps/web-ele/dist | head
echo "==> web-ele 前端构建完成"
