# YK-VOS 发布目录（release）

按环境隔离的可部署交付物。当前激活环境：**`dev`**（测试环境）。

```
release/
├── README.md            # 本文件：环境总览
├── dev/                # ✅ 当前环境（测试/验证）
│   ├── docker-compose.yaml   # 数据底座编排（ClickHouse + Kafka + monitor）
│   ├── .env.example         # monitor/CH 配置样例（cp 为 .env 后填写）
│   ├── README.md            # dev 环境部署与验证 runbook
│   ├── agent/               # VOS 侧 agent 安装包 + 配置样例
│   │   ├── ykvos-agent-1.0.4.tar.gz
│   │   ├── config.example.yaml
│   │   └── config.sample.yaml
│   ├── clickhouse/          # ODS 契约 + Kafka 消费 DDL
│   │   ├── 01_ods_vos.sql       # 建 ODS/DWS 表（含 vos_id 多节点去重键）
│   │   └── 02_kafka_ingest.sql  # Kafka 引擎表 + 物化视图（生产链路验证）
│   ├── monitor/             # 数据链路监控页（FROM scratch 静态二进制）
│   │   ├── Dockerfile
│   │   ├── dist/monitor     # 预编译 linux 静态二进制
│   │   ├── dashboard.html   # 前端源码（如需改样式）
│   │   └── build.sh        # 交叉编译脚本
│   └── tools/              # 平台侧拉取客户端
│       └── pull_client.py   # 多节点出站拉取 -> ClickHouse / Kafka 中继
└── prod/               # ⏸ 生产环境（架构同 dev，差异见 prod/README.md）
    └── README.md            # 生产差异说明 + 待填清单
```

## 当前拓扑（dev）
- **VOS 服务器有公网；平台部署测试服务器无公网端口。**
- 每个 VOS 节点各跑一个 `ykvos-agent`，在 VOS 本机起 HTTP 拉取端点（`:5233`）。
- 平台侧 `pull_client.py` / `monitor` **出站**去拉，落本机 ClickHouse；可选经本机 Kafka 中继验证生产消费链路。
- 全程平台侧**不暴露入站端口**（连接方向是平台 → VOS），符合 §9 安全基线。
- 多节点：`flowno` 跨 VOS 不唯一 → 所有表以 `(vos_id, flowno)` 去重，监控页按 `vos_id` 分节点展示。

## 部署（dev）
见 `dev/README.md`。一句话：
```bash
cd release/dev
# 1) 起数据底座 + 监控页
cp .env.example .env && vi .env   # 填各 VOS 节点公网 IP
docker compose up -d clickhouse kafka monitor
docker exec -i yk-clickhouse clickhouse-client -m < clickhouse/01_ods_vos.sql
docker exec -i yk-clickhouse clickhouse-client -m < clickhouse/02_kafka_ingest.sql
# 2) 每个 VOS 节点装 agent（见 dev/agent/README 或 config.sample.yaml）
# 3) 平台侧拉取验证
python3 tools/pull_client.py --agent-url http://<VOS1公网IP>:5233 --once
# 4) 浏览器经 SSH 隧道看监控页： ssh -L 8088:127.0.0.1:8088 user@平台服务器
```

## 切换 prod
生产环境见 `prod/README.md`（架构一致，主要差异：agent 用 Kafka 直推模式而非 HTTP 拉取、启用 TLS/鉴权、密钥走密钥库、多可用区）。待 prod 交付物到位后，把对应 tar.gz / DDL / compose 放入 `prod/`。
