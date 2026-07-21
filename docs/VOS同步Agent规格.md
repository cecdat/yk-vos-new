# VOS 同步 Agent 规格说明

> 版本：v1.0 · 状态：设计稿（待评审）
> 配套文档：`技术架构基线.md` 第 10 节（参考实现分析）、`clickhouse/ods/01_ods_vos.sql`（ODS 契约）
> 事实来源：已核实 `vos3000_structure.sql`（全表 MyISAM，e_cdr PK=flowno）、参考实现 `capture-1.0.0.tar.gz` + 部署 docx、VOS3000 Web 接口说明书。

---

## 0. 一句话定位

在 **VOS 服务器本机**部署一个 **Go 静态二进制常驻服务**，用你新建的**只读账号**轮询 VOS MySQL 的 `e_cdr` 系列表，把话单增量推到 **Kafka**，由 **ClickHouse 原生 Kafka 引擎消费**入 ODS；实时并发类指标另走 **VOS Web API** 单独一条流。

> 它解决的核心问题：**VOS3000 是 MyISAM，不产行级 binlog，Canal/Debezium 这类 CDC 全不可用**。轮询导出器是与引擎无关、对生产库零侵入的唯一稳妥方案（参考实现 `capture` 已用同形态上线验证）。

---

## 0.5 同步范围原则（尽量走数据库）

> **架构铁律**：VOS 接口层不稳定，**凡 VOS 库里有的数据，一律经数据库同步，不碰 API**。经全表盘点（152 张表，全部 MyISAM），除"实时并发"外，几乎所有运营分析所需数据都能从 DB 拿到。

### 0.5.1 可同步数据源总览（按业务域）

| 业务域 | VOS 表（可 DB 同步） | 归属模块 | 同步方式 |
|--------|------------------------|---------|---------|
| **话单** | `e_cdr`+51 日表、`e_axb_cdr`、`e_ivr_cdr`、`e_aas_cdr` | 话单同步 / 统计报表 / ASR质检 | agent 实时+回填→Kafka |
| **客户** | `e_customer`、`e_customerdetail`、`e_suite`、`e_suiteorder`、`e_currentsuite` | 客户管理 / 财务 | agent 低频→Kafka/CH |
| **线路网关** | `e_gatewaymapping`(+setting)、`e_gatewaygroup`、`e_gatewayrouting`(+setting) | 线路仓库 / 路由策略 | agent 低频 |
| **费率** | `e_feerate`(+group/section/bytime/update) | 费率 / 财务 | agent 低频 |
| **号码** | `e_phone`、`e_phonecard`、`e_activephonecard`、`e_groupe164`、`e_bindede164`、`e_*phonebook`、`e_r_customer_e164ranges` | 号码管理 | agent 低频 |
| **黑名单/风控** | `e_limit_e164`(+group)、`e_system_limit_e164`、`e_terminal_black_list_policy`、`e_ip_limit`、`e_web_access_control` | 黑名单管理 / 风控 | agent 低频 |
| **财务** | `e_payhistory`(充值)、`e_consumption`(消费)、`e_report*`(28 张预聚合) | 财务管理 / 报表 | agent 低频 + CH 交叉校验 |
| **预警** | `e_alarm_current`、`e_alarm_history`、`e_alarm_setting` | 预警管理 | agent 低频 |
| **基础参考** | `e_areacode`、`e_citycode`、`e_mobilearea`、`e_calendar`(+day) | 号码归属 / 计费时段 | agent 低频 |
| **审计(可选)** | `e_user`、`e_userlogin`、`e_user_privilege`、`e_syslog` | 操作审计（不复用其登录） | 平台只读展示 |
| **实时并发** | （无表，内存态） | 实时监控 | **仅此一项走 API**（或 DB 近似，见 §6） |

### 0.5.2 关键发现（改变原方案）

1. **话单不止 `e_cdr` 一种**：`e_axb_cdr`(AXB)、`e_ivr_cdr`(IVR)、`e_aas_cdr`(含 `calleraudiotext`/`calleeaudiotext` **语音转写文本**)——4 类都带 `flowno`，均能 DB 同步。→ 连 Phase3 的 **ASR 质检文本都已在 VOS 库里**，无需另接 ASR 服务（仅新录音转写才需外部 ASR）。
2. **黑名单就是 `e_limit_e164`(+group)**（无独立 black_list 表），按 limit 类型区分黑白；另有 `e_system_limit_e164`、`e_terminal_black_list_policy`。
3. **VOS 自带 28 张 `e_report*` 预聚合表**（customerfee / gatewayfee / agentincome / clearingfee…）→ 直接同步作快速展示 + 与 CH 重算结果交叉校验，不必全在 CH 重算。
4. **并发可近似从 DB 得出**（见 §6），从而把"唯一需 API"也基本消掉。

### 0.5.3 暂不同步（超出 IVS 运营范围 / VOS 内部设备配置）

会议 `e_conference*`、IVR 配置 `e_ivr*`、IMS `e_ims_edge*`、呼叫中心 `e_cc_seat*`、邮箱 `e_mbx`、设备 `e_equipment`/`e_interfaceagent`/`e_dns`/`e_phoneservice`/`e_phonesetting`/`e_mo*`/`e_language`/`e_lerg`。

### 0.5.4 出口原则

**agent 作为"唯一触碰 VOS 库"的出口**：所有可 DB 同步的表都由 agent 在 VOS 本机就近读取 → 发 Kafka（话单类）或直接写 CH（维度/小表），**平台后端永远不直接连 VOS**，最大化"走 DB、最小暴露面"。MVP 先跑通 4 类话单，再逐域加维度同步 handler。

---

## 1. 总体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│  VOS 服务器（Linux，你新建的只读账号）                              │
│                                                                     │
│   ykvos-agent (Go 静态二进制, systemd/init.d 服务)                  │
│   ┌──────────────┐         ┌──────────────────┐                   │
│   │ 拉取器 Puller│──flowno─▶│  发送器 Sender   │──┐                │
│   │ (e_cdr 轮询) │         │ (Kafka Producer) │  │                │
│   └──────────────┘         └──────────────────┘  │                │
│   ┌──────────────┐         ┌──────────────────┐  │                │
│   │ API 探活器    │─并发快照─▶│  Sender(复用)    │──┤                │
│   │ (/external)   │         └──────────────────┘  │                │
│   └──────────────┘                                │                │
│   水位持久化 state.json（per-table flowno）          │                │
└───────────────────────────────────────────────────│────────────────┘
                                                     │ Kafka
                                                     ▼
                                        ┌────────────────────────┐
                                        │ topic: vos.cdr.live   │
                                        │ topic: vos.realtime    │
                                        └───────────┬────────────┘
                                                    │ 原生 Kafka 引擎
                                                    ▼
                                        ┌────────────────────────┐
                                        │ ClickHouse             │
                                        │  vos_cdr_kafka(引擎表) │
                                        │    → MV → vos_cdr_ods  │
                                        │  vos_realtime_ods      │
                                        └───────────┬────────────┘
                                                    │ 读
                                                    ▼
                                        ┌────────────────────────┐
                                        │ 后端 ruoyi module-vos  │
                                        │  /admin-api/vos/**     │
                                        │ 前端 web-antd 看板      │
                                        └────────────────────────┘
```

**关键边界**
- VOS 库**只读**，agent 不建表、不写、不加触发器、不改配置。
- 维度表（`e_customer` / `e_gatewaymapping` / `e_feerate`）**不走 Kafka**，由平台侧 `BatchSource`（Quartz 低频）直接拉，**见 §8**。
- agent 自身**默认不暴露任何入站端口**（无 inbound，§9）；**仅在测试拓扑**配置 `server.listen` 时，起一个受 Bearer 鉴权保护的 HTTP 拉取端点供平台来拉（§3.5）。

---

## 2. 部署形态

### 2.1 构建
- 语言：**Go 1.22+**，纯标准库 + 少量依赖（`go-sql-driver/mysql`、`segmentio/kafka-go` 或 `confluentinc/confluent-kafka-go`、`spf13/viper`、`kelseyhightower/envconfig`）。
- 构建命令（零依赖静态二进制）：
  ```bash
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o ykvos-agent ./cmd/agent
  ```
- `CGO_ENABLED=0` 确保不依赖 glibc 版本，适配各 VOS 发行版。

### 2.2 目录布局（安装于 VOS 本机）
```
/opt/ykvos-agent/
├── ykvos-agent          # 二进制
├── config.yaml          # 配置（密码不在此，见 §9）
├── state.json           # 水位持久化（自动生成/更新）
├── seelog.xml          # 滚动日志配置
└── logs/
    └── ykvos-agent.log # 按大小/时间切割，保留 7 份
```

### 2.3 服务注册（参考 capture 的 init.d 形态，改造为 systemd 优先）
- **推荐 systemd**（CentOS 7+/主流 VOS 镜像均支持）：
  ```ini
  # /etc/systemd/system/ykvos-agent.service
  [Unit]
  Description=YK-VOS Sync Agent
  After=network.target mysql.service

  [Service]
  Type=simple
  ExecStart=/opt/ykvos-agent/ykvos-agent -config /opt/ykvos-agent/config.yaml
  Restart=always
  RestartSec=5
  User=vosreader            # 非 root 运行（§9 安全）
  Environment=YK_MYSQL_PWD=/run/secrets/ykvos-agent/mysql
  Environment=YK_KAFKA_PWD=/run/secrets/ykvos-agent/kafka
  LimitNOFILE=65536

  [Install]
  WantedBy=multi-user.target
  ```
- 兼容 init.d（旧系统）：参考 `capture` 的 `install.sh`，提供 `/etc/init.d/ykvos-agent` 脚本 + `monitor` 看门狗，用 `chkconfig` / `update-rc.d` 开机。
- 管理命令：`systemctl start|stop|restart|status ykvos-agent`。

### 2.4 健壮性
- `Restart=always` + 看门狗，进程崩溃自动拉起。
- 滚动日志（参考 capture 的 `seelog.xml` 套路），防磁盘写爆。
- 优雅退出：收到 SIGTERM 时 flush 已拉未发批次、落盘水位后再退出。

---

## 3. 配置文件 `config.yaml`

> 对比参考实现 `capture` 的 4 段（mysql/rabbitmq/sync/vos），我们**保留其结构、替换其选型、补齐安全**：RabbitMQ→Kafka，新增 clickhouse 消费契约提示，明文密码→密钥注入，新增 `instance` 标识。

```yaml
# ── 实例标识：标识"这台 VOS"是谁，写进每条消息，供 CH/后端区分来源 ──
instance:
  id: "vos-180"            # 对应平台「VOS 管理」页的实例 id
  name: "180vos"
  local_ip: "172.16.152.108"

# ── VOS MySQL 只读源（你新建的专用账号）──
mysql:
  host: "127.0.0.1"
  port: 3306
  user: "yk_vos_ro"        # 只读账号，仅 GRANT SELECT ON vos3000.*
  # password 不在此！由环境变量 YK_MYSQL_PWD 指向的密钥文件注入（见 §9）
  database: "vos3000"
  charset: "utf8mb4"
  socket_path: "/var/run/mysqld/mysqld.sock"  # 兜底：部分 VOS 仅允许 socket 访问
  read_only: true
  conn_max_lifetime: 30m
  max_open_conns: 5         # MyISAM 表锁，并发拉取需克制

# ── Kafka（消息缓冲 + 重放，替代参考的 RabbitMQ）──
kafka:
  brokers: ["10.0.0.10:9092"]
  cdr_topic: "vos.cdr.live"
  realtime_topic: "vos.realtime"
  compression: "lz4"
  required_acks: "all"      # 计费话单：丢一天不可接受
  max_retries: 10
  # SASL/TLS（若 Kafka 集群启用）
  sasl:
    mechanism: "SCRAM-SHA-512"
    # password 经 YK_KAFKA_PWD 注入，不在此明文

# ── 同步调度 ──
sync:
  interval_seconds: 5        # 轮询间隔（参考 capture=5）
  batch_size: 2000           # 单批拉取行数（参考范围 100~2000，依 VOS 负载调）
  backfill:
    enabled: true            # 首跑做历史 51 日表回填（见 §4.2）
    date_range: ["2026-01-18", "2026-03-09"]  # 可空=全量发现
    parallel: 2              # 回填空表并行度（MyISAM 表锁，勿过大）
  # 运行时水位从 state.json 读取，无需在此写 start_date

# ── VOS Web API（实时并发流，替代参考的 vconcurrent 思路）──
vos_api:
  enabled: true
  base_url: "http://127.0.0.1:2768/external/server"
  poll_interval_seconds: 10  # 并发快照频率（轻量，不必 5s）
  timeout_seconds: 5
  # 鉴权若需，经环境变量注入，不在此明文

# ── ClickHouse 消费侧契约提示（agent 不直接连 CH；此处仅归档约定）──
clickhouse_contract:
  ods_table: "vos_cdr_ods"
  dedup_key: "flowno"
  engine: "ReplacingMergeTree(_sync_ts)"
  partition_by: "toDate(starttime)"
```

### 3.5 双向 / 测试环境：入站拉取端点（`server`）

> **背景**：生产拓扑里平台(yk-vos 中台)有公网、Kafka 可达，agent 在 VOS 本机**出站推 Kafka**（默认，延续 §9 无 inbound 基线）。但**测试环境拓扑相反**——**VOS 服务器有公网、平台部署环境没有公网端口**（Kafka/CH 不可被入站连接）。此时 agent 无法推到平台。

**解决方案（双向）**：新增可选 `server` 段。当 `server.listen` 非空，agent 在 VOS 本机起一个 **HTTP 拉取端点**，由「平台侧主动出站来拉」。连接方向随谁有公网而翻转——agent 既能**推**(Kafka)也能**被拉**(HTTP)，即"双向"。

```yaml
sync:
  mode: "kafka"   # kafka(默认,出站推 Kafka) | off(不推,仅 serve)
server:
  listen: ""        # 例 ":5233"；空=不起服务(默认,无 inbound)
  token: ""         # 经 YK_SERVER_TOKEN 注入；空=不鉴权(内网)
  read_timeout_seconds: 30
```

路由：
- `GET /healthz` —— 探活（开放，供 LB/监控）。
- `GET /v1/cdr?table=<表>&after=<游标>&limit=<N>` —— 拉取话单，返回体与 Kafka 消息**同构**（`model.Envelope` JSON）：
  ```json
  { "table":"e_cdr", "after":0, "count":2, "next_after":30,
    "rows":[ { "schema_version":1, "op":"c", "vos_id":"vos-180",
                "src_table":"e_cdr", "flowno":20, "ts":1752714000123,
                "data":{ "id":"20", ... } }, ... ] }
  ```
  - `after` 游标由**客户端**维护（返回 `next_after` 作为下次 `after`），与推送水位 `state.json` **解耦**——两条路互不干扰、都按 `flowno` 幂等。
  - `table` 默认 `e_cdr`，可指定任意已发现表；非法表名（含注入字符）返回 400。
  - `token` 非空时 `/v1/cdr` 需 `Authorization: Bearer <token>`（经 `YK_SERVER_TOKEN` 注入，与密码同理），`/healthz` 不鉴权。

**三种拓扑对照**：
| 拓扑 | `sync.mode` | `server.listen` | 行为 |
|------|-----------|---------------|------|
| 生产（平台有公网） | `kafka`（默认） | 空（默认） | agent 出站推 Kafka，**无 inbound 端口**（§9 基线） |
| 测试（VOS 有公网 / 平台无公网端口） | `off` | `:5233` | agent 仅起 HTTP 端点，平台来拉 |
| 双向（都可达） | `kafka` | `:5233` | 既推 Kafka 又起 HTTP，平台任取其一 |

**平台侧消费**：参考 `tools/pull_client.py`（Python 纯标准库）。在平台侧周期 `GET /v1/cdr` 拉取，落盘 NDJSON 或直接 `INSERT` 进 ClickHouse 原始表 `vos_cdr_raw`（DDL 见脚本头部）。游标持久化在本地文件，断点续传。

---

## 4. 表发现与拉取逻辑

### 4.1 两种表，两种处理
| 表类型 | 例子 | 处理方式 | 去向 |
|--------|------|---------|------|
| 滚动表（实时） | `e_cdr` | 持续轮询，走 Kafka | `vos.cdr.live` |
| 历史日表（回填） | `e_cdr_20260118` ... | 首跑批量，直写 CH（见 §4.3） | `vos_cdr_ods` |
| 维度表 | `e_customer` 等 | **不在此处理**，平台 BatchSource 拉 | `vos_*_ods` |

### 4.2 表发现策略
- **滚动表**：固定 `e_cdr`。
- **历史日表**：优先**动态发现**（自适应 VOS 自行建日表）：
  ```sql
  SELECT table_name FROM information_schema.tables
  WHERE table_schema = 'vos3000' AND table_name LIKE 'e\_cdr\_%';
  ```
  若 `sync.backfill.date_range` 非空，则只保留落在范围内的日表（更可控）。
- 已处理的日表在 `state.json` 标记 `done`，避免重复回填。

### 4.3 拉取 SQL（per-table 水位）
```sql
SELECT * FROM `<table>`
WHERE flowno > ?
ORDER BY flowno ASC
LIMIT ?;
```
- **水位键**：`flowno`。已核实 `e_cdr.flowno bigint NOT NULL PRIMARY KEY`，且日表同构 → 单调、唯一、有索引，轮询高效。
- **每表独立水位**：`state.json` 结构
  ```json
  {
    "e_cdr": 18450023,
    "e_cdr_20260118": 990012,
    "e_cdr_20260119": "done",
    "_updated_at": "2026-07-17T09:00:00+08:00"
  }
  ```
- **MyISAM 注意**：表级锁，故 `batch_size` 不宜过大、拉取连接数 `max_open_conns` 克制（§3 已设 5），避免长事务阻塞 VOS 自身写入。
- **断点续传**：每成功发送一批即更新水位并落盘；崩溃重启从水位继续，天然幂等（CH 按 flowno 去重）。

### 4.4 回填直写 CH（不经 Kafka）
历史 51 日表体量可能上亿行，走 Kafka 需极大 retention。**回填模式**下 agent 直接以 ClickHouse 原生协议（或 HTTP `INSERT`）批量写 `vos_cdr_ods`，绕开 Kafka。实时增量（§4.1 滚动表）才走 Kafka。这样兼顾"历史快、实时稳"。

---

## 5. Kafka 消息协议

### 5.1 Topic 划分
| Topic | 内容 | 生产者 | 消费者 |
|-------|------|--------|--------|
| `vos.cdr.live` | 实时话单增量（滚动 `e_cdr`） | agent Puller | CH Kafka 引擎表 |
| `vos.realtime` | 并发/在线状态快照（VOS API） | agent API 探活器 | CH `vos_realtime_ods` 或后端 |

### 5.2 消息 Envelope（JSON）
```
key   = flowno 字符串（保证同 flowno 落同分区，保序去重）
value = {
  "schema_version": 1,
  "op": "c",                      // create；VOS 话单只增不删改
  "vos_id": "vos-180",           // 来自 config.instance.id，区分多 VOS 来源
  "src_table": "e_cdr",
  "flowno": 18450023,
  "ts": 1752714000123,           // agent 发送时间 epoch_ms
  "data": {                      // e_cdr 全字段
     "id": 99123,
     "callere164": "13800138000",
     ...（完整 53 字段，见 ODS DDL）...
     "additional": "<base64>",    // blob 列 base64 编码
     "dynamicValue": { ... }      // json 列原样透传
  }
}
```
- **blob 处理**：`additional` 为 `blob` 类型 → base64 后放入 `data.additional`（CH 侧存 `String`，可后续解析）。
- **json 处理**：`dynamicValue` 为 `json` 类型 → 原样透传为 JSON 对象。
- **schema_version**：字段演进时递增，CH/后端据此兼容。

### 5.3 分区键
- `vos.cdr.live` 建议按 **flowno** 分区（key=flowno），保证同 call 有序、便于按 flowno 去重。分区数 = broker 数或 2×。
- 数据按 `starttime` 在 CH 侧分区（`toDate(starttime)`），与 ODS 契约一致。

---

## 6. 双流：话单流 vs 并发实时流

| 流 | 数据源 | 频率 | 协议 | 说明 |
|----|--------|------|------|------|
| 话单流 | VOS MySQL `e_cdr*`(+axb/ivr/aas) | 5s 轮询、batch 2000 | Kafka `vos.cdr.live` | 主体，计费分析主数据 |
| 并发流 | **优先 DB 近似**（见下）；API 仅作可选增强 | 实时 | Kafka `vos.realtime` | 实时并发/在线状态 |

### 6.1 并发从数据库近似（贯彻"尽量走 DB"，消掉对不稳定 API 的依赖）

活跃通话在 VOS 中通常不在 DB 落表，但**未结束的通话在 `e_cdr` 里表现为 `stoptime` 为空/0**：

```sql
-- 近似实时并发：最近 N 分钟内开始、且尚未结束的通话
SELECT COUNT(*) AS concurrent
FROM e_cdr
WHERE stoptime IS NULL OR stoptime = 0
  AND starttime > UNIX_TIMESTAMP() - 300;   -- 最近 5 分钟
```

- **优势**：完全走 DB，不依赖 VOS Web API（用户明确 API 不稳定）；精度对运营看板足够（≈"近 N 分钟未结束通话"）。
- **增强（可选）**：若需精确并发/在线话机，再经 VOS API `/external/server` 的 `getAllOnlinePhones` 等做补充，作为 `vos.realtime` 的可选来源（非必须）。
- **结论**：原"并发走 API"降级为可选项；默认并发流由 agent 在同一轮询里从 `e_cdr` 估算，与话单流共用 DB 连接，**彻底不碰 API 也能跑**。

### 6.2 4 类话单都走 DB（含 ASR 文本）

- `e_cdr` + 51 日表：计费话单（主体）。
- `e_axb_cdr`：AXB 话单（独立表，含 `flowno`）。
- `e_ivr_cdr`：IVR 话单。
- `e_aas_cdr`：含 `calleraudiotext` / `calleeaudiotext` **语音转写文本** → Phase3 ASR 质检的文本直接从这里取，**无需另接 ASR 服务**（仅新录音转写才需外部 ASR）。
- 4 类均带 `flowno`，统一按 §4 水位机制轮询，分别发往 Kafka 不同 topic 或直接写 CH。

---

## 7. ClickHouse 消费侧契约（平台侧实现，agent 仅约定）

agent 不直接连 ClickHouse。消费侧由平台 `module-vos` 落库，DDL 见 `clickhouse/ods/01_ods_vos.sql`。这里给出 **Kafka 引擎表 + MV** 约定：

```sql
-- 1) Kafka 引擎表（消费 vos.cdr.live）
CREATE TABLE vos_cdr_kafka
(
    schema_version UInt8,
    op String,
    vos_id String,
    src_table String,
    flowno Int64,
    ts DateTime64(3),
    data String            -- JSON 全文，MV 中解析
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = '10.0.0.10:9092',
    kafka_topic_list = 'vos.cdr.live',
    kafka_group_name = 'ykvos-ch',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 2;

-- 2) 物化视图：解析 data JSON → 落入 ODS（ReplacingMergeTree by flowno）
CREATE MATERIALIZED VIEW vos_cdr_mv TO vos_cdr_ods AS
SELECT
    JSONExtractInt(data, 'flowno')                    AS flowno,
    JSONExtractInt(data, 'id')                        AS id,
    JSONExtractString(data, 'callere164')             AS callere164,
    -- ... 其余 51 字段按 ODS DDL 映射 ...
    JSONExtractString(data, 'additional')              AS additional,
    JSONExtractString(data, 'dynamicValue')            AS dynamicValue,
    now()                                             AS _sync_ts,
    src_table                                         AS _src_table
FROM vos_cdr_kafka;
```

> 回填（§4.4）直写 `vos_cdr_ods`，与实时流汇入同一张表，靠 `flowno` 去重，无重复。

---

## 8. 维度/配置/小表（agent 统一出口，平台不直接连 VOS）

> 依据 §0.5.4 出口原则：**agent 是"唯一触碰 VOS 库"的出口**。维度/配置/小表量大但频次低，由 agent 在 VOS 本机就近读取后，发 Kafka（小 topic）或直接写 CH，**平台后端永远不直接连 VOS 只读源**（最小化暴露面、最小化对不稳定接口的依赖）。

### 8.1 agent 同步的维度/小表清单
| 域 | 表 | 落库目标 |
|----|----|--------|
| 客户 | `e_customer`、`e_customerdetail`、`e_suite`、`e_suiteorder`、`e_currentsuite` | `vos_customer_ods` 等 |
| 线路网关 | `e_gatewaymapping`(+setting)、`e_gatewaygroup`、`e_gatewayrouting`(+setting) | `vos_gateway*_ods` |
| 费率 | `e_feerate`(+group/section/bytime/update) | `vos_feerate_ods` |
| 号码 | `e_phone`、`e_phonecard`、`e_activephonecard`、`e_groupe164`、`e_bindede164`、`e_*phonebook`、`e_r_customer_e164ranges` | `vos_phone*_ods` |
| 黑名单/风控 | `e_limit_e164`(+group)、`e_system_limit_e164`、`e_terminal_black_list_policy`、`e_ip_limit`、`e_web_access_control` | `vos_blacklist_ods` 等 |
| 财务 | `e_payhistory`、`e_consumption`、`e_report*`（28 张预聚合） | `vos_finance_ods` / 交叉校验 |
| 预警 | `e_alarm_current`、`e_alarm_history`、`e_alarm_setting` | `vos_alarm_ods` |
| 基础参考 | `e_areacode`、`e_citycode`、`e_mobilearea`、`e_calendar`(+day) | `vos_ref_*_ods` |
| 审计(可选) | `e_user`、`e_userlogin`、`e_user_privilege`、`e_syslog` | 平台只读展示，不复用其登录 |

### 8.2 同步方式
- **低频轮询**：维度表变更慢，agent 以 `sync.dim_interval_seconds`（如 60~300s）轮询，水位可用 `lastupdatetime` / `id` / `starttime` 增量，无则全量对比。
- **`e_report*` 直写 CH**：预聚合表直接落 CH（或经 Kafka 小 topic），与 §4.4 回填同机制；同时作为我们 CH DWS 重算结果的**交叉校验源**。
- **平台侧 BatchSource 降级为可选**：仅当某 VOS 实例因网络隔离无法部署 agent 时，才退化为平台直连 VOS 只读源的应急方案。

> 旧版 §8 写"维度由平台 BatchSource 直连"——已按 §0.5.4 出口原则**废弃**，统一改为 agent 出口，平台永不直连 VOS。

---

## 9. 安全规范（必改参考实现的明文密码 + root 直连）

| 项 | 参考 capture（**不采纳**） | 我们（**强制**） |
|----|------------------------|----------------|
| 账号 | `root` 直连 | 专用只读账号 `yk_vos_ro`，仅 `GRANT SELECT ON vos3000.*` |
| 密码存放 | `config.yaml` 明文 | **密钥注入**：环境变量 `YK_MYSQL_PWD` 指向 `/run/secrets/...` 文件；config 无明文 |
| 运行身份 | 未知 | 非 root 用户 `vosreader` |
| Kafka 鉴权 | 无 | SASL/SCRAM + TLS（若集群支持） |
| 网络暴露 | 未知 | agent **默认无 inbound 端口**（仅出向连 VOS MySQL / Kafka，不连 VOS API，并发改由 DB 近似，见 §6）；**例外**：测试拓扑配置 `server.listen` 时，起一个受 Bearer 鉴权保护的 HTTP 拉取端点供平台来拉（§3.5），且仅在 VOS 有公网、平台无公网端口时启用 |
| socket 兜底 | 有 | 保留 `socket_path`，应对"仅允许 socket 访问"的 VOS |

**只读账号创建示例（在 VOS 本机执行，由你操作）：**
```sql
CREATE USER 'yk_vos_ro'@'127.0.0.1' IDENTIFIED BY '<强密码>';
GRANT SELECT ON vos3000.* TO 'yk_vos_ro'@'127.0.0.1';
-- 若走 socket：'yk_vos_ro'@'localhost'
FLUSH PRIVILEGES;
```

---

## 10. 可观测性

- **指标端点**（默认关闭，启用时 `:9101/metrics`，仅内网）：
  - `ykvos_cdr_pulled_total{table}` — 累计拉取行数
  - `ykvos_cdr_sent_total{table}` — 累计发 Kafka 成功
  - `ykvos_watermark{table}` — 当前水位 flowno
  - `ykvos_lag_seconds{table}` — 水位与 `now()` 的延迟（实时性）
  - `ykvos_errors_total{type}` — 错误计数
  - `ykvos_api_poll_total` / `ykvos_api_last_success_ts` — 并发流探活
- **结构化日志**：JSON 行，含 `level/ts/module/table/flowno/batch`。
- **心跳/状态回写（可选，后期）**：agent 可定期把自身状态（水位、lag、错误）经 Kafka `vos.agent.heartbeat` 或后端 API 上报，前端「话单同步」页展示。

---

## 11. 错误处理与重试

| 场景 | 处理 |
|------|------|
| Kafka 发送失败 | 本地重试 `max_retries=10`（指数退避）；仍失败则暂存磁盘队列，恢复后补发，**不丢** |
| VOS MySQL 断连 | 拉取器暂停，按 `interval` 重试；水位不前进 |
| 单批超长/锁等待 | `batch_size` 上限 + 语句 `max_execution_time`；超时跳过本批告警 |
| CH 消费滞后 | 由 `ykvos_lag_seconds` 暴露；Kafka retention 设足够长（>24h）防回溯丢数据 |
| 幂等保证 | `flowno` 主键 + CH `ReplacingMergeTree` → 任何重发/重放均去重 |

---

## 12. 与平台后端（ruoyi `module-vos`）的边界

| 职责 | agent（VOS 本机） | module-vos（中台后端） |
|------|-------------------|------------------------|
| 配置来源 | `config.yaml` 手工维护在 VOS 服务器 | 「VOS 管理」页配置实例元信息（id/ip/账号）→ **初期手工对齐**，后期可选下发 |
| 话单采集 | ✅ 轮询 + 发 Kafka | ❌ |
| 维度采集 | ❌ | ✅ BatchSource 直连 VOS 只读源 |
| CH 落库 | ❌（仅回填直写） | ✅ Kafka 消费 + ODS/DWS |
| 前端/API | ❌ | ✅ `/admin-api/vos/**` + 看板 |
| 账号管理 | 只读账号在 VOS 本机由你创建 | 实例元信息存 `vos_instance` 表 |

> **初期解耦原则**：agent 与平台网络可能隔离，配置**先在 VOS 本机手工维护**，`instance.id` 与平台「VOS 管理」页保持一致即可关联。平台"远程下发配置/启停 agent"留作后期（需 agent 暴露受控管理接口，那时再评估安全）。

---

## 13. MVP 验收清单（首个可运行闭环）

- [ ] Go 二进制 `ykvos-agent` 编译成功，`CGO_ENABLED=0 GOOS=linux` 静态。
- [ ] `config.yaml` 五段齐备，密码经密钥注入，无明文。
- [ ] 用你建的只读账号连 VOS MySQL，能 `SELECT * FROM e_cdr WHERE flowno>? LIMIT 1`。
- [ ] 滚动表 `e_cdr` 轮询 → 发 `vos.cdr.live` → CH `vos_cdr_ods` 出现数据，`flowno` 去重正确。
- [ ] `state.json` 水位随发送推进，进程重启后能续传。
- [ ] 并发流：调 VOS API `getAllOnlinePhones` 成功，快照进 `vos.realtime`。
- [ ] systemd 服务 `start/stop/restart/status` 正常，`Restart=always` 生效。
- [ ] 维度表经平台 BatchSource 拉取并落 ODS 镜像。
- [ ] **双向/测试拓扑**：`server.listen=:5233` + `sync.mode=off`，平台 `tools/pull_client.py` 能 `GET /v1/cdr` 拉到数据并写 CH（`vos_cdr_raw`），游标断点续传正确。
- [ ] 前端「话单同步」页能看到同步状态/水位/lag。

---

## 附录 A：参考实现 `capture` 差异对照

| 维度 | 参考 capture | 我们 ykvos-agent | 处置 |
|------|-------------|-----------------|------|
| 语言/形态 | Go 静态二进制、init.d 服务 | Go 静态二进制、systemd 优先（兼容 init.d） | 沿用形态 |
| 消息中间件 | RabbitMQ | **Kafka** | 改（CH 原生 Kafka 集成） |
| 分析存储 | Elasticsearch | **ClickHouse** | 改（聚合/报表主场） |
| 配置密码 | 明文 root | 密钥注入 + 只读账号 | 必改安全 |
| 表发现 | start_date + 硬编码 | 动态 `information_schema` + 可选 date_range | 改进（自适应） |
| 并发流 | VOS API 拉并发 | VOS API 拉并发/在线 | 沿用思路 |
| socket 兜底 | 有 | 保留 | 沿用 |
| ASR 预留 | 注释掉的 upload | 不内置（Phase3 后端处理） | 不采纳 |
| 实时性 | 5s 轮询 | 5s 轮询（相同） | 沿用 |

---

## 附录 B：e_cdr 全字段（消息 data 映射来源）

`id, callere164, calleraccesse164, calleee164, calleeaccesse164, callerip, callerrtpip, callercodec, callergatewayid, callerproductid, callertogatewaye164, callertype, calleeip, calleertpip, calleecodec, calleegatewayid, calleeproductid, calleetogatewaye164, calleetype, billingmode, calllevel, agentfeetime, starttime, stoptime, callerpdd, calleepdd, holdtime, callerareacode, feetime, fee, tax, suitefee, suitefeetime, incomefee, incometax, customeraccount, customername, calleeareacode, agentfee, agenttax, agentsuitefee, agentsuitefeetime, agentaccount, agentname, flowno(PK), softswitchname, softswitchcallid, callercallid, calleroriginalcallid, calleecallid, calleroriginalinfo, rtpforward, enddirection, endreason, billingtype, cdrlevel, agentcdr_id, sipreasonheader, recordstarttime, transactionid, flownofirst, additional(blob), dynamicValue(json)`

> 字段与 `clickhouse/ods/01_ods_vos.sql` 的 `vos_cdr_ods` 一一对应；blob/json 列按 §5.2 处理。
