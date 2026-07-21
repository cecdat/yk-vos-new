#!/bin/bash
# ykvos-agent 一键安装脚本（对应 docs/VOS同步Agent规格.md §2）。
#   拷贝运行时目录 → 注册 init.d 服务 + 看门狗 → 开机自启 → 装完即启动。
# 在 VOS 服务器本机以 root 执行： sudo bash install.sh

set -e

APP=ykvos-agent
APP_DIR=/opt/$APP
SVC_USER=vosreader
HERE="$(cd "$(dirname "$0")" && pwd)"
RUNTIME_SRC="$HERE/agent"   # 包内运行时目录 → 安装到 /opt/ykvos-agent

echo "==> 停止旧服务（若存在）"
/etc/init.d/$APP stop 2>/dev/null || true
/etc/init.d/${APP}-monitor stop 2>/dev/null || true

# 1. 拷贝运行时（bin + etc）
echo "==> 安装运行时到 $APP_DIR"
mkdir -p "$APP_DIR/bin" "$APP_DIR/etc"
cp -f "$RUNTIME_SRC/bin/$APP" "$APP_DIR/bin/$APP"
chmod +x "$APP_DIR/bin/$APP"

# 2. 配置：不覆盖已存在；否则生成样例并备份旧配置
if [ ! -f "$APP_DIR/etc/config.yaml" ]; then
    cp "$RUNTIME_SRC/etc/config.yaml" "$APP_DIR/etc/config.yaml"
    echo "    已生成 $APP_DIR/etc/config.yaml，请按现场修改后重启"
else
    BAK="$APP_DIR/etc/config.yaml.bak.$(date +%Y%m%d%H%M%S)"
    cp "$APP_DIR/etc/config.yaml" "$BAK"
    echo "    保留现有 config.yaml（已备份到 $BAK）"
fi

# 3. 环境变量配置文件（.env）
if [ ! -f "$APP_DIR/.env" ]; then
    cp "$HERE/.env.example" "$APP_DIR/.env"
    chmod 600 "$APP_DIR/.env"
    echo "    已生成 $APP_DIR/.env（请写入密码及密钥环境变量）"
else
    echo "    保留现有 .env 配置文件"
fi

# 4. 运行用户（降权；可选，与 init.d 的 RUN_AS 对应）
id "$SVC_USER" >/dev/null 2>&1 || useradd -r -s /sbin/nologin "$SVC_USER" 2>/dev/null || true
chown -R "$SVC_USER":"$SVC_USER" "$APP_DIR" 2>/dev/null || true

# 5. 日志
touch /var/log/$APP.log /var/log/${APP}-monitor.log
chown "$SVC_USER" /var/log/$APP.log 2>/dev/null || true

# 6. 注册 init.d 服务 + 看门狗
echo "==> 注册 init.d 服务"
cp "$HERE/$APP.initd" "/etc/init.d/$APP"
cp "$HERE/${APP}-monitor.initd" "/etc/init.d/${APP}-monitor"
chmod +x "/etc/init.d/$APP" "/etc/init.d/${APP}-monitor"

# 7. 开机自启
echo "==> 设置开机自启"
if which chkconfig >/dev/null 2>&1; then
    chkconfig --add "$APP"; chkconfig "$APP" on
    chkconfig --add "${APP}-monitor"; chkconfig "${APP}-monitor" on
    echo "    使用 chkconfig"
elif which update-rc.d >/dev/null 2>&1; then
    update-rc.d "$APP" defaults
    update-rc.d "${APP}-monitor" defaults
    echo "    使用 update-rc.d"
else
    for rl in 2 3 4 5; do
        ln -sf "/etc/init.d/$APP" "/etc/rc${rl}.d/S90$APP"
        ln -sf "/etc/init.d/${APP}-monitor" "/etc/rc${rl}.d/S50${APP}-monitor"
    done
    for rl in 0 1 6; do
        ln -sf "/etc/init.d/$APP" "/etc/rc${rl}.d/K10$APP"
        ln -sf "/etc/init.d/${APP}-monitor" "/etc/rc${rl}.d/K50${APP}-monitor"
    done
    echo "    手动创建启动链接"
fi

# 8. 启动（装完即运行；密码未写则看门狗持续重试，写入后自动拉起）
echo "==> 启动服务"
/etc/init.d/$APP start
/etc/init.d/${APP}-monitor start

cat <<EOF

安装完成！后续步骤：
  1) 编辑环境变量文件并写入 MySQL 等只读密码：
       vi $APP_DIR/.env
  2) 编辑配置（实例 id、Kafka 地址、VOS 库地址等）：
       vi $APP_DIR/etc/config.yaml
  3) 重启使配置/密码生效：
       /etc/init.d/$APP restart
  4) 查看状态与日志：
       /etc/init.d/$APP status
       tail -f /var/log/$APP.log
EOF
