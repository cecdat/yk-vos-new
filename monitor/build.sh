#!/usr/bin/env bash
# 交叉编译 monitor 静态二进制到 dist/monitor（linux/amd64），供 Dockerfile 使用。
set -euo pipefail
cd "$(dirname "$0")"
echo "==> build monitor (CGO_ENABLED=0 GOOS=linux GOARCH=amd64)"
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o dist/monitor .
ls -lh dist/monitor
echo "done."
