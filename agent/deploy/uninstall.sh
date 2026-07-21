#!/bin/bash
# ykvos-agent 卸载脚本。停止并注销服务，删除运行时目录。
# 在 VOS 服务器本机以 root 执行： sudo bash uninstall.sh [--purge]
#   --purge  额外删除配置文件与日志（默认仅停止+删除运行时，配置备份到 /tmp）

set -e

APP=ykvos-agent
APP_DIR=/opt/$APP
SVC_USER=vosreader
PURGE=0
[ "$1" = "--purge" ] && PURGE=1

echo "==> 停止服务"
/etc/init.d/$APP stop 2>/dev/null || true
/etc/init.d/${APP}-monitor stop 2>/dev/null || true

echo "==> 注销开机自启"
if which chkconfig >/dev/null 2>&1; then
  chkconfig --del "$APP" 2>/dev/null || true
  chkconfig --del "${APP}-monitor" 2>/dev/null || true
elif which update-rc.d >/dev/null 2>&1; then
  update-rc.d -f "$APP" remove 2>/dev/null || true
  update-rc.d -f "${APP}-monitor" remove 2>/dev/null || true
else
  for rl in 0 1 2 3 4 5 6; do
    rm -f "/etc/rc${rl}.d/S90$APP" "/etc/rc${rl}.d/K10$APP"
    rm -f "/etc/rc${rl}.d/S50${APP}-monitor" "/etc/rc${rl}.d/K50${APP}-monitor"
  done
fi

echo "==> 删除服务脚本"
rm -f "/etc/init.d/$APP" "/etc/init.d/${APP}-monitor"

if [ "$PURGE" = "1" ]; then
  echo "==> 彻底删除运行时目录（含配置与日志）"
  rm -rf "$APP_DIR"
  rm -f "/var/log/$APP.log" "/var/log/${APP}-monitor.log"
else
  echo "==> 备份配置到 /tmp 后移除运行时目录"
  if [ -f "$APP_DIR/etc/config.yaml" ]; then
    cp -f "$APP_DIR/etc/config.yaml" "/tmp/${APP}-config.yaml.bak.$(date +%Y%m%d%H%M%S)" || true
  fi
  rm -rf "$APP_DIR/bin" "$APP_DIR/etc"
  rmdir "$APP_DIR" 2>/dev/null || true
fi

# 运行用户保留（可能其他服务复用），如需清理可手动 userdel vosreader
echo "==> 卸载完成。"
if [ "$PURGE" = "1" ]; then
  echo "    已彻底删除（--purge）。"
else
  echo "    配置已备份至 /tmp/${APP}-config.yaml.bak.*，运行时已移除；如需彻底清除请加 --purge。"
fi
