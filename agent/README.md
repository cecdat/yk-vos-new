# ykvos-agent · VOS 话单同步 Agent

部署在 **VOS 服务器本机**的 Go 静态二进制常驻服务，用只读账号轮询 VOS MySQL 的 `e_cdr` 系列表，把话单增量推到 **Kafka**，由 **ClickHouse 原生 Kafka 引擎**消费入 ODS。

> 完整设计见 `../docs/VOS同步Agent规格.md`。核心前提：VOS3000 全表 **MyISAM**，无行级 binlog，Canal/Debezium 等 CDC 均不可用，故采用**轮询导出器**（对生产库零侵入、与引擎无关）。

## 目录结构

```
agent/
├── cmd/agent/main.go          # 入口：装配 + 优雅退出
├── internal/
│   ├── config/                # config.yaml 解析 + 密钥注入（§3/§9）
│   ├── logx/                  # 结构化 JSON 日志（§10）
│   ├── state/                 # per-table flowno 水位持久化（§4.3）
│   ├── source/                # VOS MySQL 只读源 + 日表发现 + 通用行读取（§4）
│   ├── sink/                  # Kafka 生产者（§5）
│   ├── model/                 # 消息 Envelope（§5.2）
│   └── puller/                # 话单轮询循环（§4/§6.2）
├── build.sh                  # 交叉编译 Linux 静态二进制 → dist/ykvos-agent/{bin,etc}
├── package.sh                # 组装 tar.gz（形态同参考 capture 安装包）
├── deploy/                    # 一键 install.sh + init.d 服务/看门狗 + 可选 systemd 单元
├── config.example.yaml        # 配置样例
└── go.mod
```

## 编译 & 打包（产出与参考 capture 一致的安装包）

```bash
cd agent
go mod tidy

# 一键：交叉编译 Linux 静态二进制 + 组装 tar.gz
bash package.sh 1.0.0
#   → 产出 dist/ykvos-agent-1.0.0.tar.gz
```

tar.gz 内部布局（与参考 capture 安装包同构）：

```
ykvos-agent-1.0.0/
├── install.sh               # 一键安装：拷运行时 → 注册 init.d + 看门狗 → 开机自启 → 装完即启动
├── readme.txt              # 使用说明
├── ykvos-agent.initd      # init.d 服务脚本（装到 /etc/init.d/ykvos-agent）
├── ykvos-monitor.initd    # 看门狗（装到 /etc/init.d/ykvos-monitor）
├── ykvos-agent.service     # 可选 systemd 单元（降权/加固用）
└── ykvos-agent/           # 运行时目录（装到 /opt/ykvos-agent/）
    ├── bin/ykvos-agent     # 编译好的 Linux 静态二进制
    └── etc/config.yaml     # 配置样例
```

Windows 本地快速自检（仅验证编译/参数解析，MySQL/Kafka 连接会失败属正常）：

```bash
go build ./...
go vet ./...
```

## 运行（手动调试）

```bash
# 所有业务参数均在 config.yaml 中；运行时不接收命令行参数（内网单配置部署）。
# 仅 -config 可选（指向配置文件，缺省按 /opt/ykvos-agent/etc/config.yaml → ./config.yaml 查找），
# 仅 -version 打印版本。
export YK_MYSQL_PWD=/opt/ykvos-agent/secrets/mysql   # 该文件内容即密码；也可直接 export YK_MYSQL_PWD='明文密码' 做本地调试
./ykvos-agent                 # 零参数：自动找 /opt/ykvos-agent/etc/config.yaml
# 或显式指定：         ./ykvos-agent -config ./config.yaml
```

日志级别、日志文件路径、水位文件路径等**全部在 config.yaml 的 `log:` / `state:` 段配置**（见样例），不再有 `-log-level` / `-state` 这类命令行参数。

## 部署（VOS 本机一键安装，形态同参考 capture）

```bash
# 1) 解压安装包
tar -xzf ykvos-agent-1.0.0.tar.gz && cd ykvos-agent-1.0.0

# 2) root 执行一键安装：自动注册服务 + 看门狗 + 开机自启 + 启动
sudo bash install.sh

# 3) 写入 MySQL 只读账号密码（密码不进 config，见 §9）
echo -n '只读账号密码' > /opt/ykvos-agent/secrets/mysql
chmod 600 /opt/ykvos-agent/secrets/mysql

# 4) 按现场改配置后重启使生效
vi /opt/ykvos-agent/etc/config.yaml
/etc/init.d/ykvos-agent restart
```

装完后进程退出会由 `ykvos-monitor` 看门狗每 30 秒自动拉起；若密码尚未写入，进程因连接失败退出、看门狗持续重试，写入密码后自动恢复。

日常管理：`/etc/init.d/ykvos-agent {start|stop|restart|status}`，日志 `tail -f /var/log/ykvos-agent.log`。

## 安全（必读，§9）

- VOS 只用**专用只读账号**：`GRANT SELECT ON vos3000.* TO 'yk_vos_ro'@'127.0.0.1';`
- 密码**不落 config**，经 `YK_MYSQL_PWD` 指向的 600 权限密钥文件注入。
- 非 root 运行、**无 inbound 端口**、`socket_path` 兜底。

## 当前实现范围（MVP）

- ✅ config 七段解析（instance/mysql/kafka/sync/vos_api/log/state）+ 密钥注入 + 校验，运行零业务命令行参数
- ✅ 只读连接（TCP/socket）+ 连接池克制
- ✅ 日表动态发现（`information_schema`，按 date_range 过滤）
- ✅ 通用行读取（`SELECT * WHERE flowno>? ORDER BY flowno LIMIT ?`，blob→base64 / json 透传）
- ✅ per-table 水位持久化（原子落盘 + done 标记）
- ✅ Kafka 生产（key=flowno / lz4 / acks=all / 退避重试）
- ✅ 滚动表 `e_cdr` 轮询循环 + 断点续传 + 优雅退出
- ⬜ 4 类话单扩展（axb/ivr/aas）· 历史日表回填直写 CH · 维度表 handler · 并发 DB 近似 · metrics 端点（按规格后续迭代）
