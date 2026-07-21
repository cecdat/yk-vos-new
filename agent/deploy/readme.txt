YK-VOS 话单同步 Agent 安装包
================================

1. 将本压缩包解压到 VOS 服务器任意位置
       tar -xzf ykvos-agent-1.0.4.tar.gz
       cd ykvos-agent-1.0.4

2. 以 root 执行一键安装（自动注册服务、开机自启、并启动）
       sudo bash install.sh

3. 写入 MySQL 只读账号密码（密码不进 config，见规格 §9）
       echo -n '你的只读账号密码' > /opt/ykvos-agent/secrets/mysql
       chmod 600 /opt/ykvos-agent/secrets/mysql

4. 按需编辑配置后重启使生效
       vi /opt/ykvos-agent/etc/config.yaml
       /etc/init.d/ykvos-agent restart

日常管理：
   启动：   /etc/init.d/ykvos-agent start
   停止：   /etc/init.d/ykvos-agent stop
   重启：   /etc/init.d/ykvos-agent restart
   状态：   /etc/init.d/ykvos-agent status
   日志：   tail -f /var/log/ykvos-agent.log
   看门狗： /etc/init.d/ykvos-monitor {start|stop|status}

说明：
   - 进程退出后由 ykvos-monitor 看门狗每 30 秒自动拉起。
   - 若尚未写入密码，进程会因连接失败退出，看门狗持续重试；写入密码后自动恢复。
   - 可选：使用 systemd 单元（降权运行）见 ykvos-agent.service 与 README 加固章节。

测试环境（VOS 有公网、平台无公网端口）的双向模式：
   - 编辑 /opt/ykvos-agent/etc/config.yaml：设 sync.mode: "off"、server.listen: ":5233"。
   - VOS 防火墙放行 5233；平台侧用 tools/pull_client.py 周期 GET 该端点拉话单写 CH。
   - 细节见 docs/VOS同步Agent规格.md §3.5。
