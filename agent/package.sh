#!/bin/bash
# ykvos-agent 打包脚本（规格 §2）。
# 先编译，再把产物与部署脚本组装成 tar.gz：
#   <pkg>/
#     install.sh             一键安装（init.d + 看门狗 + 开机自启 + 装完即启动）
#     readme.txt             使用说明
#     ykvos-agent.initd     init.d 服务脚本（装到 /etc/init.d/ykvos-agent）
#     ykvos-monitor.initd   看门狗（装到 /etc/init.d/ykvos-monitor）
#     ykvos-agent.service   可选 systemd 单元（加固/降权用）
#     ykvos-agent/          运行时目录（装到 /opt/ykvos-agent/）
#       bin/ykvos-agent     编译好的 Linux 静态二进制
#       etc/config.yaml     配置样例
# 用法： bash package.sh [VERSION]
set -e

cd "$(dirname "$0")"

APP=ykvos-agent
VERSION="${1:-1.0.0}"
TARGET_ENV="${2:-dev}" # dev (测试) 或 prod (正式)
PKG_DIR="$APP"
PKG_FILE="$APP-$VERSION.tar.gz"
DIST=dist

# 1) Clean and recreate target directories
rm -rf "$DIST"
mkdir -p "$DIST/$PKG_DIR/agent/bin"
mkdir -p "$DIST/$PKG_DIR/agent/etc"

# 2) 编译
echo "==> 交叉编译 Linux 静态二进制 ($VERSION)"
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go build -ldflags="-s -w -X main.version=$VERSION" \
  -o "$DIST/$PKG_DIR/agent/bin/$APP" ./cmd/agent

# 3) 复制配置与部署文件
echo "==> 复制配置与部署脚本..."
cp config.example.yaml           "$DIST/$PKG_DIR/agent/etc/config.yaml"

cp deploy/install.sh              "$DIST/$PKG_DIR/install.sh"
cp deploy/uninstall.sh            "$DIST/$PKG_DIR/uninstall.sh"
cp deploy/readme.txt             "$DIST/$PKG_DIR/readme.txt"
cp deploy/.env.example           "$DIST/$PKG_DIR/.env.example"
cp deploy/ykvos-agent.initd      "$DIST/$PKG_DIR/$APP.initd"
cp deploy/ykvos-monitor.initd    "$DIST/$PKG_DIR/${APP}-monitor.initd"
cp deploy/ykvos-agent.service     "$DIST/$PKG_DIR/$APP.service"

# 4) 打包
tar -czf "$DIST/$PKG_FILE" -C "$DIST" "$PKG_DIR"

# 5) 拷贝至发布目录（先清理旧版本 tar，避免历史版本被服务端包一起打包）
RELEASE_DEST="../release/$TARGET_ENV/agent"
mkdir -p "$RELEASE_DEST"
# 删除同目录内所有历史 ykvos-agent-*.tar.gz，仅保留即将拷入的当前版本
rm -f "$RELEASE_DEST"/ykvos-agent-*.tar.gz
cp -f "$DIST/$PKG_FILE" "$RELEASE_DEST/$PKG_FILE"

echo "==> 打包完成并拷贝至: $RELEASE_DEST/$PKG_FILE"
