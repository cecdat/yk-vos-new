#!/bin/bash
# ykvos-agent 编译脚本（规格 §2）。
# 交叉编译为 Linux 静态二进制（CGO_ENABLED=0），零依赖、适配各 VOS 发行版。
# 用法： bash build.sh [VERSION]
set -e

cd "$(dirname "$0")"

APP=ykvos-agent
VERSION="${1:-1.0.0}"
OUT="dist/$APP"

mkdir -p "$OUT/bin" "$OUT/etc"

echo "==> 交叉编译 Linux 静态二进制 ($VERSION)"
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go build -ldflags="-s -w -X main.version=$VERSION" \
  -o "$OUT/bin/$APP" ./cmd/agent

echo "==> 复制配置样例 -> $OUT/etc/config.yaml"
cp config.example.yaml "$OUT/etc/config.yaml"

ls -lh "$OUT/bin/$APP"
echo "==> build done: $OUT/bin/$APP"
