# 服务端（yudao 后端 + vben 前端）— 历史话单回填 & VOS 管理 设计文档

> 状态：设计定稿（未实施）
> 配套文档：
> - `受控历史话单回填设计.md`（**agent 侧**：扫描 / push_history / Kafka 控制通道 / 可暂停回填）
> - `VOS同步Agent规格.md`（agent 基础机制、topic、消息 Envelope）
> 本文档只覆盖**服务端**：yudao 后端 `module-vos` + vben 前端 `web-ele`，把 agent 经 Kafka 上报的 availability / heartbeat / progress / ack 落库，并把用户操作翻译成 `vos.agent.command` 下发给 agent。

---

## 0. 现状与边界（事实来源，已核实仓库）

| 项 | 现状 | 结论 |
|---|---|---|
| 后端 `yudao-module-vos` | **只有 `pom.xml` + `.flattened-pom.xml` + `target/`，零 Java 源码**（空脚手架） | 后端需**从零建** |
| 前端 `frontend/apps/web-ele/src/views/vos/` | 已先行存在：`index.vue`(VOS 实例列表 CRUD)、`modules/form.vue`、`api/vos.ts`、`router/routes/modules/vos.ts`(挂「对接管理 / VOS 管理」) | 页面壳已好，**缺后端即空转** |
| `/vos/instances` 后端实现 | 全仓库 grep 无对应 controller | 后端必须先实现该 CRUD |
| 框架 MQ starter | `yudao-spring-boot-starter-mq` 仅支持 **RabbitMQ / RedisMQ**，**不含 Kafka** | 需在 `module-vos` **新增 `spring-kafka`** |
| 前端 VosInstance 接口字段 | `id, vos_uuid, name, base_url, description, enabled, health_status, health_last_check, health_response_time, health_error` | `vos_uuid` 需对齐为 agent 的 `vos_id`（Kafka 分区/指令路由键） |
| yudao 约定 | Controller `@RequestMapping("/admin-api/vos/...")`；DO `extends BaseDO`；Mapper `extends BaseMapperX<DO>`；包 `cn.iocoder.yudao.module.vos.{controller.admin, service, dal.dataobject, dal.mysql.mapper, framework}` | 设计严格对齐 |
| DB | MySQL（库 `ruoyi-vue-pro`） | 建表 SQL 放 `sql/mysql/` |

---

## 1. 总体架构（服务端视角）

```
                         ┌─────────────────── VOS 本机 · agent ───────────────────┐
                         │  report(Kafka:3001)  ◀──── 控制指令 command ─────┐      │
                         └──────────────────────────────┬──────────────────────┘      │
                                                        │                            │
                                              vos.agent.report              vos.agent.command
                                                        │                            ▲
                                                        ▼                            │
   ┌──────────────────────── yudao 中台（module-vos）──────────────────────────────┘
   │  AgentReportConsumer(@KafkaListener)  ──▶  MySQL
   │     availability ─▶ vos_agent_backfill                │
   │     heartbeat   ─▶ vos_agent_heartbeat + vos_instance.health   │
   │     progress/ack─▶ vos_agent_backfill_task                       │
   │                                                                ▼
   │  REST Controller (/admin-api/vos/**)  ◀──▶  Service  ──▶  AgentCommandProducer(KafkaTemplate)
   └───────────────────────────────┬──────────────────────────────────────────────┘
                                    │  HTTP (/admin-api, vite 代理 / nginx 反代)
                                    ▼
   ┌──────────────────────── vben 前端 (web-ele) ────────────────────┐
   │  对接管理 / VOS 管理      → VOS 实例 CRUD + 心跳健康列          │
   │  对接管理 / 历史话单回填  → 可用性列表 + 任务控制 + 健康看板   │
   └────────────────────────────────────────────────────────────────────┘
```

- **服务端不直连 VOS**（架构铁律，见 agent 规格 §0.5.4）：所有数据经 agent → Kafka → 服务端。
- **控制面 Kafka**：`vos.agent.report`（agent→server）由服务端消费；`vos.agent.command`（server→agent）由服务端生产，key = `vos_id`。
- **live 永不受控**：服务端只发「历史回填 / 扫描」类指令（agent 侧保证不触碰 live），本设计不新增任何影响实时推送的能力。

---

## 2. 数据库设计（MySQL，4 张平台自建表）

### 2.1 `vos_instance` — VOS 实例注册（扩展前端已有字段）
对齐前端 `api/vos.ts`，并把 `vos_uuid` 收敛为 `vos_id`（= agent 的 `instance.id`，Kafka 分区键 + 指令路由键）。

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | BIGINT PK | 自增 |
| `tenant_id` | BIGINT | **多租户ID**（RuoYi/Yudao 标准隔离字段，默认 0） |
| `vos_id` | VARCHAR(64) **UNIQUE** | agent `config.instance.id`（如 `vos-180`），指令路由键 |
| `name` | VARCHAR(128) | 实例名称（前端 name） |
| `base_url` | VARCHAR(255) | 地址/IP（前端 base_url；仅展示/备注，服务端不主动连） |
| `description` | VARCHAR(512) | 备注 |
| `enabled` | TINYINT(1) | 是否启用 |
| `agent_version` | VARCHAR(32) | 最近一次心跳上报的 agent 版本 |
| `health_status` | VARCHAR(16) | `healthy` / `unhealthy` / `unknown`（**由心跳推算**，不主动探活） |
| `health_last_check` | DATETIME | 最近一次心跳 generated_at |
| `health_response_time` | INT | 预留（心跳无 RTT，可置空或填 agent uptime） |
| `health_error` | VARCHAR(512) | 不健康原因（如 db 未连接） |
| `create_time` / `update_time` | DATETIME | BaseDO 标准字段 |

> 前端 `api/vos.ts` 的 `vos_uuid` 字段改名为 `vos_id`（与 agent 一致）。其余字段（name/base_url/description/enabled/health_*）已对齐，后端实现后即通。

### 2.2 `vos_agent_backfill` — 每实例 × 历史日表 的可用性/状态
落 `availability` 报告。

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | BIGINT PK | |
| `tenant_id` | BIGINT | **多租户ID**（SaaS 隔离） |
| `vos_id` | VARCHAR(64) | 实例 |
| `table_name` | VARCHAR(64) | 历史日表（如 `e_cdr_20260101`） |
| `estimated_rows` | BIGINT | TABLE_ROWS 估算 |
| `already_pushed` | BIGINT | 已推送（agent 报） |
| `precise_rows` | BIGINT NULL | 精确 COUNT(*)（用户点开详情触发） |
| `status` | VARCHAR(16) | `pending` / `approved` / `syncing` / `done` / `rejected` |
| `mode` | VARCHAR(16) NULL | `immediate` / `scheduled` |
| `scheduled_cron` | VARCHAR(64) NULL | 定时 cron |
| `last_reported_at` | DATETIME | 最近一次 availability 上报时间 |
| `create_time` / `update_time` | DATETIME | |

唯一索引：`(vos_id, table_name)`（upsert）。

### 2.3 `vos_agent_backfill_task` — 回填任务 + 指令派发表
用户每次操作（下发/暂停/恢复/取消/rescan/precise_count/调速）落一行，**带唯一 `command_id`** 供双端幂等。

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | BIGINT PK | |
| `tenant_id` | BIGINT | **多租户ID**（SaaS 隔离） |
| `task_code` | VARCHAR(64) | 业务任务号（下发回填时生成，可空给纯指令） |
| `vos_id` | VARCHAR(64) | 实例 |
| `command_id` | VARCHAR(64) **UNIQUE** | agent 幂等键（UUID） |
| `action` | VARCHAR(24) | `backfill_start` / `pause` / `resume` / `cancel` / `rescan` / `precise_count` / `set_throttle` |
| `tables` | JSON NULL | 涉及的日表数组 |
| `mode` | VARCHAR(16) NULL | immediate / scheduled |
| `cron` | VARCHAR(64) NULL | |
| `params` | JSON NULL | 如 throttle 参数（max_batch / rows_per_minute / active_window） |
| `status` | VARCHAR(16) | `pending` → `queued` (排队中) → `dispatched` → `syncing` / `paused` / `done` / `failed` / `cancelled` |
| `progress_pushed` | BIGINT | 进度（来自 progress 报告） |
| `last_progress_at` | DATETIME NULL | |
| `result` | VARCHAR(32) NULL | ack 回执结果（ok / error） |
| `result_msg` | VARCHAR(512) NULL | ack 详情 |
| `create_time` / `update_time` | DATETIME | |

### 2.4 `vos_agent_heartbeat` — 心跳/健康最新快照（取代 /healthz）
落 `heartbeat` 报告，取代 agent 规格里原有的 HTTP `/healthz` 探活（更适合无入站公网的测试环境）。

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | BIGINT PK | |
| `tenant_id` | BIGINT | **多租户ID**（SaaS 隔离） |
| `vos_id` | VARCHAR(64) | 实例 |
| `agent_version` | VARCHAR(32) | |
| `hostname` | VARCHAR(128) | |
| `os` | VARCHAR(64) | |
| `cpu_load_1m` | DECIMAL(5,2) | |
| `cpu_cores` | INT | |
| `mem_total_mb` / `mem_used_mb` | INT | |
| `disk_total_mb` / `disk_used_mb` | INT | |
| `uptime_seconds` | BIGINT | |
| `db_connected` | TINYINT(1) | |
| `db_version` | VARCHAR(32) | |
| `db_open_conns` / `db_active_conns` | INT | |
| `agent_goroutines` | INT | |
| `agent_mem_alloc_mb` | DECIMAL(8,2) | |
| `agent_uptime_seconds` | BIGINT | |
| `generated_at` | DATETIME | agent 上报时间（健康推算基准） |
| `create_time` | DATETIME | |

只保留每 `vos_id` 最新一条（upsert；历史可进归档表，本期不做）。

---

## 3. Kafka 集成（module-vos 新增 `spring-kafka`）

### 3.1 依赖
`yudao-module-vos/pom.xml` 引入 `spring-kafka`（版本若 yudao-dependencies BOM 未管理，则显式指定与 Spring Boot 3.x 兼容的版本，如 `3.2.x`）。

### 3.2 配置（`application.yml` / `application-prod.yaml`）
```yaml
spring:
  kafka:
    bootstrap-servers: ${YK_KAFKA_BROKERS:120.226.208.2:3001}
    producer:
      key-serializer: org.springframework.kafka.support.serializer.JsonSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
      acks: all
      compression-type: lz4
    consumer:
      group-id: ykvos-server-report
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer
      properties:
        spring.json.trusted.packages: "cn.iocoder.yudao.module.vos.framework.kafka.dto"
    properties:
      security.protocol: SASL_PLAINTEXT        # 与 agent 一致
      sasl.mechanism: SCRAM-SHA-512
      sasl.jaas.config: ${YK_KAFKA_JAAS}       # 凭据走环境变量/配置中心，不落库
```

### 3.3 路由与隔离
- **服务端消费** `vos.agent.report`：固定 group `ykvos-server-report`，至少一次语义。
- **服务端生产** `vos.agent.command`：`KafkaTemplate` 发，key = `vos_id` → 消息进入对应分区，agent 侧按 `vos_id` 过滤消费（agent 规格 §3.4 + 用户补充"command_group 必须含 vos_id"）。服务端只管生产 + 按 vos_id 精准投递。
- **契约**：topic 名、msg_type 枚举、command action 枚举、字段命名，全部对齐 `受控历史话单回填设计.md §3.4 / §3.4.2`，**不得自行增减**。

---

## 4. 后端模块设计（module-vos 包结构）

```
cn.iocoder.yudao.module.vos
 ├ controller.admin
 │   ├ VosInstanceController      # /admin-api/vos/instances       (CRUD + 健康只读)
 │   ├ VosBackfillController     # /admin-api/vos/backfill/*       (可用性/任务/指令)
 │   └ VosAgentController        # /admin-api/vos/agents/heartbeat (心跳健康看板)
 ├ service
 │   ├ VosInstanceService
 │   ├ VosBackfillService        # 落库报告 + 生产指令 + 任务状态机
 │   └ VosAgentHeartbeatService
 ├ dal.dataobject
 │   ├ VosInstanceDO / VosAgentBackfillDO / VosAgentBackfillTaskDO / VosAgentHeartbeatDO
 ├ dal.mysql.mapper              # 各 *Mapper extends BaseMapperX<DO>
 └ framework.kafka
     ├ KafkaConfig                # producer/consumer factory + topic 常量
     ├ dto/                       # ReportMessage / CommandMessage POJO（JSON 序列化契约）
     ├ AgentReportConsumer        # @KafkaListener("vos.agent.report")
     └ AgentCommandProducer      # KafkaTemplate 发 vos.agent.command
```

### 4.1 VosInstanceController（对齐前端 api/vos.ts）
路径 `/admin-api/vos/instances`，5 个接口与前端完全一致：
- `GET /instances` 全量（前端按名称/IP 模糊过滤）
- `GET /instances/{id}` 详情
- `POST /instances` 新增
- `PUT /instances/{id}` 修改
- `DELETE /instances/{id}` 删除

健康字段 `health_status` 等**由心跳推算后随实例返回**，无需服务端主动探活（HTTP 探活已废弃，改心跳上报）。

### 4.2 VosBackfillController（历史话单回填核心）
所有对 Agent 下达控制指令的写接口必须挂载 Yudao 标准的 `@OperateLog(type = WRITE)` 审计日志和 `@PreAuthorize` 权限控制，以便出现配置变动和回填高峰期控制时追溯审计。

| 方法 & 路径 | 权限与审计限制 | 行为 |
|---|---|---|
| `GET /backfill/availability` | `@PreAuthorize` 读权限 | 返回 `vos_agent_backfill`（每实例×日表，估算/精确/状态） |
| `POST /backfill/start` | `@PreAuthorize` 写权限 + `@OperateLog` | 并发流控校验后，生成任务及指令并发往 Kafka 启动历史同步 |
| `POST /backfill/{taskId}/pause` | `@PreAuthorize` 写权限 + `@OperateLog` | 发送 `pause` 指令（与 agent §3.4.2 / 本文 §6 契约一致），Worker 在当前批次结束处挂起 |
| `POST /backfill/{taskId}/resume` | `@PreAuthorize` 写权限 + `@OperateLog` | 发送 `resume` 指令，Worker 从断点恢复历史回填 |
| `POST /backfill/{taskId}/cancel` | `@PreAuthorize` 写权限 + `@OperateLog` | 发送 `cancel` 指令，回滚任务状态，释放并发配额 |
| `POST /backfill/{vosId}/rescan` | `@PreAuthorize` 写权限 + `@OperateLog` | 发送 `rescan` 重新扫描命令，强制 Agent 发起新一轮 availability |
| `POST /backfill/precise-count` | `@PreAuthorize` 写权限 + `@OperateLog` | 对指定单日表触发精确 `COUNT(*)` 计算指令 |
| `POST /backfill/throttle` | `@PreAuthorize` 写权限 + `@OperateLog` | 动态热调速指令下发，覆盖 Agent 本地限制参数 |
| `GET /backfill/tasks` | `@PreAuthorize` 读权限 | 获取回填任务列表与任务详细进度 % 状态 |

### 4.3 VosAgentController（健康看板）
- `GET /agents/heartbeat` → 各实例最新心跳快照 + 健康（CPU/内存/磁盘/DB 状态），供「VOS 管理」健康列与服务端监控大屏。

### 4.4 AgentReportConsumer（数据面落地）
`@KafkaListener(topics="vos.agent.report", groupId="ykvos-server-report")`，按 `msg_type` 分派：
- **availability** → upsert `vos_agent_backfill`（按 vos_id+table_name）。
- **heartbeat** → upsert `vos_agent_heartbeat`（按 vos_id）；回算 `vos_instance.health_status`：
  - **失联**：当前时间距该实例最近一次心跳的 `generated_at` > `120s`（= `3 × heartbeat_interval(30s)` + 30s 宽限）→ `unknown`（agent 失联）。
  - **异常**：最近一次心跳 `db_connected = false` 且其 `generated_at` 距当前时间 ≥ `60s`（持续未恢复）→ `unhealthy`。
  - **健康**：否则 → `healthy`。
  - ⚠️ 实现要点：失联/异常判定须在**心跳接收定时巡检作业**中执行（而不仅在该实例心跳到达时），才能覆盖「长时间未收到任何心跳」的场景；巡检间隔 ≤ 心跳周期的 1/2（如 15s）。
- **progress** → 更新对应 task 的 `progress_pushed` + `status=syncing`；**终态 `done` 必须以 agent 显式上报 `done` 消息为唯一依据**，不得用 `pushed >= estimated` 自动判定（原因：`estimated` 来自 `information_schema.TABLE_ROWS` 估算，MySQL 统计常偏低，会提前 done 导致漏推）。`pushed/estimated` 仅用于前端**进度百分比展示**，不触发终态切换。
- **ack** → 更新 task 的 `result` + 终态（`paused` / `resumed` / `cancelled` / `ok` / `failed`）。

### 4.5 AgentCommandProducer（指令生产）
`KafkaTemplate<String, CommandMessage>`，`send("vos.agent.command", vosId, command)`。每条指令：
1. 生成 UUID `command_id`；
2. 写 `vos_agent_backfill_task`（action / vos_id / command_id / params / status=pending）；
3. 按 §4.9 全局并发流控判定：
   - 并发未满（`syncing` 数 < `sync.max_global_active_backfills`）→ 置 `dispatched` 并立即发送到 Kafka；
   - 并发已满 → 置 `queued`（排队中），暂不发送；待某任务终态（`done`/`paused`/`cancelled`）释放配额后，调度器按创建时间顺序将其 `queued → dispatched` 并发送。
4. 仅 `backfill_start` 指令会触发并发占用；`pause`/`resume`/`cancel`/`rescan`/`precise_count`/`set_throttle` 为单实例控制指令，经 `dispatched` 直接发送，不占全局并发额度。

### 4.6 幂等与状态机
- **command_id 双端去重**：agent 记 `command_log_file`，服务端记 `vos_agent_backfill_task.command_id` UNIQUE。
- **前端防抖 + 后端状态校验**：如 task 已 `paused` 不再派发 `pause`；重复点击由前端 disabled + 后端校验拦截。
- **Kafka 至少一次**：progress/ack 可能重投 → 服务端用 task 状态机去重推进，避免重复置终态。

### 4.7 多租户 SaaS 隔离与 VOS 实例额度限制（新增优化）
- **租户数据物理隔离**：本设计中，`vos_instance`、`vos_agent_backfill`、`vos_agent_backfill_task`、`vos_agent_heartbeat` 实体 DO 统一继承至框架的 `TenantBaseDO` 基类，配合 Yudao 拦截器实现数据库层面的租户物理隔离。REST 接口侧由框架拦截器自动拼装 `tenant_id`；**Kafka 消费侧 tenant_id 不会自动注入，须按下方 ⚠️ 修正手动处理**。

  - ⚠️ **消费侧 tenant_id 必须手动注入（关键修正）**：Yudao 多租户靠 MyBatis 拦截器从 `TenantContextHolder` 取 `tenant_id`，**仅在 HTTP 请求线程有效**；`@KafkaListener` 消费线程不在 Web 上下文，`TenantContextHolder` 默认 `null`，拦截器**不会**自动注入、也不会自动按租户过滤。因此 Agent 上报消息本身**不带 `tenant_id`**（Agent 无租户概念），服务端消费落库前必须：
    1. 按消息中的 `vos_id` 反查 `vos_instance.tenant_id`；
    2. 显式 `TenantContextHolder.setTenantId(tenantId)` 后再执行 upsert；
    3. 方法退出前 `TenantContextHolder.clear()`（或 `try(TenantContextHolder.setTenantId(...))` 包裹），避免线程复用串租户。
  - REST 接口侧（用户操作经 `@PreAuthorize` 进入）由框架拦截器自动拼装 `tenant_id`，无需手动处理。
- **基于用户套餐/等级的 VOS 数量限额**：
  - **规则配置**：在租户套餐管理表 `system_tenant_package` 中扩展 `vos_max_limit`（该等级套餐最大允许添加的 VOS 节点数）参数，或在平台独立管理表中维护“租户/用户等级 ➔ 最大 VOS 节点额度”的映射（例如：普通体验版 = 1台，企业标准版 = 3台，大客户尊享版 = 10台，旗舰定制版 = 无限制/999台）。
  - **拦截机制**：在 `VosInstanceServiceImpl.createVosInstance` 创建实例的方法中加入硬拦截：
    1. 查询当前租户内已存在的 VOS 实例数量：
       `Long currentCount = vosInstanceMapper.selectCount(new LambdaQueryWrapperX<VosInstanceDO>());`（多租户插件自动拼装当前线程中的 tenant_id 进行过滤）。
    2. 获取当前租户对应的最大 VOS 限制上限：
       `Integer maxLimit = tenantPackageService.getTenantVosLimit(tenantId);`。
    3. 如果 `currentCount >= maxLimit`，则抛出业务异常 `ServiceException(VOS_INSTANCE_COUNT_EXCEEDED, "创建失败！您的租户级别最大允许添加 %d 个 VOS 实例，请联系管理员升级租户套餐。")`。

### 4.8 心跳失联判定与健康算法优化（新增优化）
- **健康度推算宽限机制**：原设计的判定间隔由 2 倍周期放宽为 **3 倍心跳周期**（即 `3 × heartbeat_interval_seconds(30s) = 90秒`，纯周期判定），并在状态切换前增加 **30秒宽限期**（Grace Period）→ **实际失联阈值 = 90秒 + 30秒宽限 = 120秒**（与 §4.4 巡检算法、§8 风险阈值严格一致）。
- **算法实施**：当且仅当系统持续超过 **120秒（90秒 + 30秒宽限）** 没有收到对应 `vos_id` 的心跳上报，或心跳包中 `db_connected = false` 状态持续满 60 秒时，才把 VOS 实例的 `health_status` 修改为 `unknown`（失联）或 `unhealthy`（异常），并进行平台报警投递。这极大减少了因公网闪断、消息通道积压引发的误报报警。

### 4.9 全局回填任务并发流控机制（新增优化）
- **流控策略**：由于历史回填数据会巨量涌入 ClickHouse 造成 IO 负载升高，后端引入全局排队调度器：
  - 平台配置文件内置系统级参数 `sync.max_global_active_backfills`（默认 3，系统支持的最大跨实例并发回填数）。
  - 用户触发回填时，`VosBackfillService` 会校验全局处于 `syncing`（进行中）的任务数：
    - 若当前执行中的任务数 `< 3`，则将任务状态标记为 `syncing`，并在指令表中插入并向 Kafka 发送 `backfill_start`。
    - 若并发数已达上限，任务标记为 `queued`（排队中），暂时**不下发** Kafka 指令，在管理前台展示为“排队中”。
  - 当某个实例的任务变更为 `done`（完成）或 `paused`（挂起）后，系统触发调度检查，按创建时间戳顺序自动将排队中的 `queued` 任务转为 `syncing` 并向对应 Agent 发送 Kafka 指令启动回填。

---

## 5. 前端设计（vben web-ele）

### 5.1 VOS 管理页（已有，补后端 + 小改）
- 后端实现后 `views/vos/index.vue` 直接接通，零大改。
- `api/vos.ts`：`vos_uuid` → 改名为 **`vos_id`**（与 agent `instance.id` 一致，作为指令路由键）。
- 健康列（`health_status`）已存在，数据来源从「无」变为「心跳推算返回」，无需改列；可选增强：详情抽屉展示 `agent_version` + 主机信息，加「刷新心跳」按钮（触发 rescan 或仅重拉）。

### 5.2 新增「历史话单回填」页（核心交付）
- 新增 `views/vos/backfill/index.vue` + `api/vos-backfill.ts` + 路由在 `router/routes/modules/vos.ts` 加 `backfill` 子路由（挂在「对接管理 / VOS 管理」下）。
- **布局**：
  - 顶部：VOS 实例选择（下拉，来自 `/vos/instances`）。
  - **表 1 可回填历史日表**：列 = 日表名 / 估算行数 / 精确行数(点开触发 `precise-count`) / 已推送 / 状态(tag) / 操作(立即接收 / 定时接收)。
    - 立即接收 = 一键 `backfill/start`(mode=immediate)；
    - 定时接收 = 弹窗选 cron → `backfill/start`(mode=scheduled)，弹窗明确提示「建议在 02:00–06:00 非高峰」。
  - **表 2 回填任务 & 控制**：列 = 任务号 / 日表 / 模式 / 状态 / 进度(pushed/estimated) / 最近进度时间 / 操作(暂停 / 恢复 / 取消 / 调速)。
    - 暂停→`/{id}/pause`；恢复→`/{id}/resume`；取消→`/{id}/cancel`；调速→弹窗 `throttle`。
  - **表 3（可选）Agent 健康**：来自 `/vos/agents/heartbeat`，展示 CPU/内存/磁盘/DB 状态，取代原 /healthz 探测。
- **刷新策略**：先用轮询（如 10s）拉 `availability` / `tasks`；后续可换 yudao WebSocket starter 推 progress/ack（本期不强制）。

---

## 6. 与 agent 设计文档的契约对齐（硬约束）

| 维度 | 约定（来源于 agent 设计文档） | 服务端落点 |
|---|---|---|
| topic | `vos.agent.report` / `vos.agent.command` | consumer / producer 严格使用 |
| 分区键 | `vos_id`（command_group 必须含 vos_id） | 生产 command 时 key=vos_id |
| msg_type | `availability` / `heartbeat` / `progress` / `ack` | AgentReportConsumer 按此分派 |
| command action | `backfill_start` / `pause` / `resume` / `cancel` / `rescan` / `precise_count` / `set_throttle` | VosBackfillController 一一对应 |
| 字段命名 | 见 agent §3.4.2 schema | DTO / DO 字段对齐，不另起名 |
| 服务端不直连 VOS | 架构铁律 §0.5.4 | 所有数据走 Kafka |
| live 永不受控 | §3.4.1 硬红线 | 服务端只发历史/扫描指令 |
| 心跳取代 /healthz | §3.5 | vos_agent_heartbeat + 健康推算 |
| 幂等 | command_id 双端去重 | task.command_id UNIQUE + agent command_log |

---

## 7. 实施分步（建议顺序）

1. **后端脚手架 + 建表 SQL**（4 表）+ DO/Mapper + `VosInstanceController` CRUD（对齐前端）。
2. **Kafka 集成**：producer/consumer config + SASL + `AgentReportConsumer`（先落 availability/heartbeat，打通数据面）。
3. **前端 VOS 管理接通**（后端好后基本零改动，`vos_uuid`→`vos_id` 改名）→ 验证心跳健康显示。
4. **`VosBackfillController` + `AgentCommandProducer` + task 状态机**（下发/暂停/恢复/取消/rescan/precise_count/throttle）。
5. **前端「历史话单回填」页**（可用性列表 + 任务控制 + 健康看板）。
6. **联调**：agent 1.0.6（控制通道）↔ 服务端，端到端验证 availability → 下发 → progress → done + 暂停/恢复。

---

## 8. 风险与注意

- **spring-kafka 版本兼容**：若 yudao-dependencies BOM 未管理 `spring-kafka`，需显式指定与 Spring Boot 3.x 匹配的版本（如 `3.2.x`），先本地 `mvn` 编译验证。
- **Kafka 至少一次语义**：ack/progress 可能重投 → 服务端 task 状态机 + command_id 去重，避免重复推进/终态覆盖。
- **心跳健康阈值**：判定失联阈值 = `3 × heartbeat_interval_seconds(30) = 90s`，外加 30s 宽限期，累计为 120s（见 §4.8 优化算法），需与 agent 配置严格对齐。
- **前端字段改名**：`vos_uuid` → `vos_id` 会影响现有 `api/vos.ts` 与 `data.ts`，需同步改并测。
- **多实例部署**：服务端 report 消费 group 固定；command 以 vos_id 为 key 精准投递，agent 侧按 vos_id 过滤消费。
- **非高峰约束**：立即接收实际由 agent 在下一窗口执行（agent §3.7），前端提示语需与 agent 窗口（02:00–06:00）一致。
