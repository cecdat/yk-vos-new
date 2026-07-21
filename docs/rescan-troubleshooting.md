# F 排查：点击「重新扫描可用日表」后 Agent 未收到指令

> 现象：前端点「重新扫描可用日表」→ 后端 `/admin-api/vos/backfill/rescan?vosId=vos1` 返回
> `{"code":0,"msg":"","data":true}`（成功），但 Agent 端毫无反应、未发起扫描上报。

## 指令下发全链路

```
前端 handleRescan(selectedVosId)
  → POST /admin-api/vos/backfill/rescan?vosId=vos1
  → VosBackfillService.triggerRescan(vosId)        // 不插任务行，仅下发一次性 Kafka 指令
  → AgentCommandProducer.sendCommand(rescan)        // topic = vos.agent.command
  → Kafka broker (vos.agent.command)
  → Agent commander.go 消费 vos.agent.command
       if cmd.VosID != c.vosID { 丢弃 }           // ★ 静默丢弃点
       else dispatch → c.scanner.ScanAndReport()    // 异步扫描并上报 availability
  → Kafka broker (vos.agent.report)
  → 后端 AgentReportConsumer.handleAvailability → autoCreatePendingTasks（建「待下发」任务）
```

## 已修复的两个「静默丢」点（本次改动）

### 1. 后端 fire-and-forget → 改为同步等待送达（`AgentCommandProducer.java`）
原实现 `vosAgentCommandKafkaTemplate.send(...)` 不等待结果。若 Kafka broker 不可达，
异常发生在异步 future 中，**HTTP 仍返回 `data:true`**，造成「服务端说成功、实际没投出去」的假象。

修复：改成 `future.get(10s)` 同步等待，失败抛 `RuntimeException`，使 HTTP 接口能感知并返回失败；
成功时打印 `指令已送达 Kafka: topic=... partition=... offset=...`。

### 2. Agent 指令过滤无日志 → 补诊断日志（`commander.go`）
原 `if cmd.VosID != c.vosID { continue }` 没有任何日志，ID 不匹配时指令被**静默丢弃**，
表现为「点了没反应」。

修复：
- `Start()` 启动即打印本实例 `vos_id`：`本实例 vos_id=vos1，仅接收匹配此 ID 的指令...`
- 丢弃时打印 `WARN`：`丢弃非本实例指令: 收到 vos_id=xxx, 本实例 vos_id=vos1, action=rescan`

## 现场核查清单（需你侧确认/操作）

1. **Agent `config.yaml` 的 `instance.id` 必须 == 后端 `vos_instance.vos_id`（即请求用的 `vos1`）。**
   - 这是最可能导致「所有指令都收不到」的原因：若不一致，`rescan`/`start` 等**全部**被静默丢弃，
     Agent 还会一直卡在 `等待服务端下发 start 指令`（因为 `start` 也收不到）。
   - 对齐方法：查库 `SELECT vos_id FROM vos_instance WHERE deleted=0;` 看后端存的到底是 `vos1` 还是别的；
     再比对 agent 配置文件里的 `instance.id`。
2. **Agent `sync.mode` 必须为 `kafka`。**
   - `main.go` 中只有 `sync.mode=="kafka"` 才启动 `commander`；为 `off` 时 commander 整个不启动，收不到任何指令。
3. **重启 Agent 后看日志（关键）**：
   - 应出现：`[Commander] 本实例 vos_id=vos1，仅接收匹配此 ID 的指令...`
   - 点「重新扫描」后应出现：`[Commander] 收到本实例专属指令: commandId=..., action=rescan`
   - 若出现 `丢弃非本实例指令: 收到 vos_id=???` → 直接证明是 **第 1 条 ID 不匹配**，改 agent `instance.id` 即可。
4. **看后端日志**：
   - 成功：`[AgentCommandProducer] 指令已送达 Kafka: topic=vos.agent.command ...`
   - 失败：`[AgentCommandProducer] 指令未送达 Kafka(可能 broker 不可达)` → 检查 `spring.kafka.bootstrap-servers` 与 docker 网络内 broker 连通性。
5. **Kafka 连通性**：docker-compose 内 `kafka` 服务可达；后端 `spring.kafka.bootstrap-servers` 指向正确的 broker 地址。

## 判定树（按出现顺序排查）

| 现象 | 结论 | 处理 |
|---|---|---|
| 后端日志 `指令未送达 Kafka` | broker 不可达 / 地址错 | 修 `spring.kafka.bootstrap-servers`、查 docker 网络 |
| 后端日志 `指令已送达 Kafka`，但 Agent 无 `收到本实例专属指令` | Agent 没在消费 / sync.mode≠kafka | 查 agent 启动日志是否进 kafka 分支 |
| Agent 日志 `丢弃非本实例指令: 收到 vos_id=A, 本实例 vos_id=B` | ID 不匹配 | 把 agent `instance.id` 改成与后端 `vos_instance.vos_id` 一致 |
| Agent 日志 `收到本实例专属指令 ... action=rescan` 但无后续扫描上报 | ScanAndReport 失败 | 看 Agent 日志 `Scanner` 报错（多数为 VOS 本机 MySQL 连不上） |

## 关联改动文件
- `backend/.../framework/kafka/AgentCommandProducer.java`（同步等待 + 送达日志）
- `agent/internal/commander/commander.go`（启动打印本实例 vos_id + 丢弃时 WARN）
- `backend/.../framework/kafka/KafkaConfig.java`（已存在：`vos.agent.command` 专用 StringSerializer 模板，正确）
