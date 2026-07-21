# VOS 历史话单回填 — 分析报告与开发计划

> 本文档基于源码核查（后端 `VosBackfillServiceImpl.java` 全文、前端 `backfill/index.vue` 全文、`docker-compose.yaml` MySQL 配置、agent `commander.go`）产出，仅做分析与计划，未改动任何代码。

---

## 一、现状核查（事实，非猜测）

### 1.1 菜单中文乱码（你看到的「乱码」）
- **现象**：`vos_menu.sql` 刷入后，VOS 菜单的中文名全是乱码。
- **根因**：`vos_menu.sql` 顶部**缺少 `SET NAMES utf8mb4;`**。
  - `docker-compose.yaml` 的 mysql 服务已设 `--character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci`（第 155–157 行），服务端默认字符集没问题。
  - 但 `docker-entrypoint-initdb.d` 导入 `.sql` 时，连接字符集依赖 SQL 文件自身声明。官方 `ruoyi-vue-pro.sql` **第 17 行就有 `SET NAMES utf8mb4;`**，所以它的中文正常；我的 `vos_menu.sql` 没有这句，导入连接字符集未显式指定 → UTF-8 字节被按错误字符集解释 → 乱码。
  - 磁盘上 `vos_menu.sql` 经 `file` 确认为合法 UTF-8，所以**不是文件本身编码坏**，是导入时连接字符集问题。
- **修复方向**：在 `vos_menu.sql` 顶部加 `SET NAMES utf8mb4;`（对齐官方文件）。测试环境已清空，重打包后首启会自动重跑 initdb.d，乱码即解决。

### 1.2 后端 backfill 接口现状（已读 `VosBackfillServiceImpl.java` 全文）
- **接口均已实现，且真正发 Kafka 指令**，不是空壳：
  - `startBackfill`：建 `backfill_start` 任务行 + 更新日表状态 + 并发<3 时发 Kafka 指令。
  - `pauseBackfill` / `resumeBackfill` / `cancelBackfill` / `setThrottle`：查到原任务 → **`INSERT` 一条新的 controlTask（action=pause/cancel/set_throttle，新 commandId，status='dispatched'）** → 发对应 Kafka 指令。
  - `triggerRescan`：建一条 `rescan` controlTask + 发 Kafka `rescan` 指令给 agent（Controller 把它包成 `success(true)` 返回）。
- **你点「暂停/取消/限速之后都是会新增一条任务」——已坐实**：因为每个控制操作都会 `taskMapper.insert(controlTask)` 插一条**新任务行**（共享同一 `taskCode`，但 action/commandId 不同）。任务队列按 `vos_id` 查全量，于是这些控制行作为独立行混入，看起来就是「点一次多一条任务」。
- **通信机制 = Kafka，不是 HTTP 轮询**：
  - 下发：服务端 `AgentCommandProducer.sendCommand` → Topic `vos.agent.command`（key=vosId）。
  - 上报：agent `commander.go` 消费 `vos.agent.command`（GroupID=`agent-command-group-`+vosID）→ `scanner.ScanAndReport` 等 → 经 `vos.agent.report` 回执。
  - **不存在** agent 定时拉取服务端的 REST 接口；指令队列就是 `vos_agent_backfill_task` 表。

### 1.3 rescan 指令 agent 端未收到（你第 2 点）
- 服务端 `triggerRescan` **逻辑正确、确实发了 Kafka 指令**（返回 `{"code":0,"data":true}` 即成功）。所以这不是「后端接口没加」。
- agent 没收到，是**运行时/连通性**问题，候选原因：
  1. agent 未在 `sync.mode=kafka` 下运行（`cmdMgr.Start` 未启动消费 `vos.agent.command`）；
  2. agent 配置 `instance.id` 不等于下发的 `vos1`（`commander.go` 按 `cmd.VosID` 过滤本实例指令，不一致会直接丢弃）；
  3. Kafka 未起 / topic 未建 / 消息已被上一次消费提交 offset；
  4. agent 侧 `dispatch()` 未处理 `rescan` action（收到但丢弃）。
- 需现场核查（见工作流 F），不一定改代码。

### 1.4 前端回填页现状（已读 `backfill/index.vue` 全文）
- **刷新闪烁**：`onMounted` 里 `setInterval(fetchData, 2000)`，每 2 秒**整体替换** `availabilities.value` / `tasks.value` 两个数组 → ElTable 全量重渲染 → 闪烁；且 `v-loading` 每次刷新都切换 → loading 闪。
- **操作列换行**：「指令操作」列 `width="180"`，最多同时渲染 4 个 `ElButton`（暂停/继续/取消/限速），空间不足 → 换行，难看。
- **日表列撑宽**：`row.tables.join(', ')` 把日表名拼成超长字符串，日表多时把列宽撑开。

### 1.5 历史话单查询接口（你第 1 点真正缺失的部分）
- 前端 `api/cdr.ts` 已有契约：`queryCdrsFromVos(instanceId, params)` → `POST /cdr/query-from-vos/${instanceId}`，入参 `CdrQueryParams`、出参 `CdrQueryResult`。
- **后端完全没有** `VosCdrController` / `/cdr` 映射（全仓搜索 `query-from-vos` / `CdrController` 无任何匹配）。这是**真正缺失的后端接口**。
- 后端目前**只有 Kafka 写入侧**，**没有 ClickHouse 查询数据源**，所以补这个接口的主要工作量是：新增 CH 查询 JdbcTemplate/数据源 + 按时间路由到日表/滚动表的查询逻辑。

### 1.6 自动扫描 / 自动建任务（你第 5 点）
- 现状：agent 仅在**启动时**扫描一次（`main.go` 启动 2s 后 `ScanAndReport`）；服务端**无定时扫描任务**（仅有一个 `VosAgentHeartbeatJob` 做心跳探活，15s 一次）。
- `AgentReportConsumer#handleAvailability` 收到 agent 上报的日表后，只 `upsert` 到 `vos_agent_backfill`（新表 `status='pending'`），**不会自动建回填任务**。
- 因此：无论定时还是手动 rescan，扫描结果只更新「可用日表」，**不会自动进入任务队列**。

---

## 二、需求 → 工作流映射

| 你的要求 | 对应工作流 | 性质 |
|---|---|---|
| 菜单中文乱码 | **A** | 快速修复（1 行 SQL） |
| 后端接口加上（rescan 已存在；真正缺的是 cdr 查询） | **E**（cdr 接口）+ **F**（rescan 排查） | 功能新增 / 排查 |
| 点暂停/取消/限速「新增一条任务」、功能没实现 | **B** | Bug 修复（控制操作改更新而非插入） |
| 刷新一直闪 | **D1** | 前端 Bug 修复 |
| 操作按钮换行、日表列撑宽 | **D2 / D3** | 前端 UX 修复 |
| 定时自动扫描 + 扫描后自动建任务（待下发）；手动重扫也自动建 | **C** | 功能新增 |
| 指令操作支持 启动下发/暂停/取消/限速；菜单不换行；日表悬浮 | **B4（启动下发）+ D2 + D3** | 功能/UX |

---

## 三、开发计划

### 工作流 A — 菜单乱码修复（最高优先级，阻断体验）
1. `backend/sql/mysql/vos_menu.sql` 顶部加：
   ```sql
   SET NAMES utf8mb4;
   SET FOREIGN_KEY_CHECKS = 0;
   ```
2. 同步在 `release/dev/init/fix-vos-menu-routes.sql` 头部也加 `SET NAMES utf8mb4;`（避免增量脚本同样乱码）。
3. 重打包；因测试环境已清空，首启自动重跑 initdb.d 即生效。
4. 验证：`SELECT name FROM system_menu WHERE id IN (5000,5011,5015,5031,5050,5051,5055,5020);` 中文正常。

### 工作流 B — 控制操作不再新增任务行
1. 重构 `pauseBackfill` / `cancelBackfill` / `resumeBackfill` / `setThrottle`：
   - **不再 `INSERT` 新 controlTask**，改为 **`UPDATE` 已有回填任务行**——设置 `status`（paused / cancelled / syncing）、`last_action`、`params.speed_limit`；
   - 复用该回填任务的 `command_id` 作为 Kafka 指令幂等键发送（agent 回执按 `command_id` 更新同一行）；
   - 这样任务队列只显示真实回填任务，点一次控制不再多一行。
2. 新增「**启动下发**」操作 `dispatchTask(commandId)`：对 `pending`/`queued` 任务手动发送 `backfill_start` Kafka 指令（供用户在待下发状态手动触发，而非只能等 `dispatchNextQueuedTask` 自动调度）。
3. `getTaskList` 保持不变（按 vos_id 查），因控制操作不再产生独立行，队列自然只含真实任务。
4. 待确认：agent `commander.go#dispatch()` 是否已处理 `pause`/`cancel`/`set_throttle`/`resume` 并回执——需核对（若未处理，需补 agent 侧逻辑）。

### 工作流 C — 自动扫描 + 自动建任务（待下发）
1. **定时自动扫描**：新增 `@Scheduled` 任务（仿 `VosAgentHeartbeatJob`，加 `@TenantJob`），cron 可配（默认如每小时），遍历 `vos_instance` 调 `triggerRescan(vosId)` → agent 周期扫描可用日表。
2. **扫描后自动建任务**：在 `AgentReportConsumer#handleAvailability`（或 `vos_agent_backfill` upsert 之后）增加逻辑——若 `estimatedRows > alreadyPushed`（有未同步），自动 `INSERT` 一条 `backfill_start` 任务，`status='pending'`（待下发），`tables` 关联这些日表；随后由 `dispatchNextQueuedTask` 在并发<3 时自动下发。
3. 手动「重新扫描可用日表」(`triggerRescan`) 走同一链路 → 上报 → 自动建任务（待下发），**前端无需改动**。
4. **幂等**：自动建任务前按 `vos_id + table_name + status IN (pending,queued,dispatched,syncing)` 去重，避免重复建任务。

### 工作流 D — 前端回填页修复
- **D1 刷新闪烁**：
  - 轮询改为**原地更新**：按 `id`/`commandId` 复用并合并行对象（更新字段而非整体替换数组）；
  - ElTable 加 `:row-key="row => row.id"` + `reserve-selection`，减少重渲染、保留勾选；
  - 定时器刷新时**不**挂 `v-loading`（仅首次加载 / 手动操作显示 loading）；进度条绑定稳定 row 对象；
  - 可将可用性（10s）与任务（2s）刷新频率分开。
- **D2 操作列不换行**：把 暂停/继续/取消/限速/启动下发 改为 **`ElDropdown` 下拉菜单**（单一「操作」按钮触发，按任务状态动态显隐可用项），彻底避免换行。
- **D3 日表列悬浮**：开启 `show-overflow-tooltip`，或表内显示「N 张」+ `ElTooltip` 悬浮展示完整日表列表（日表多时不撑宽列）。

### 工作流 E — 历史话单查询后端接口（真正缺失的接口）
1. 新增 `VosCdrController` `@RequestMapping("/cdr")`，`POST /query-from-vos/{instanceId}`；入参/出参对齐前端 `cdr.ts` 的 `CdrQueryParams` / `CdrQueryResult`。
2. Service 实现智能查询：优先查 **ClickHouse ODS**（按 `begin_time/end_time` 路由到对应日表 + 滚动表 `e_cdr`），必要时回退 VOS API（agent 的 `VosAPI` 配置段）。
3. **新增 ClickHouse 查询数据源/JdbcTemplate**（后端当前只有 Kafka 写入侧，无 CH 查询侧）——在 yudao 动态数据源注册 CH，或独立配置一个 `JdbcTemplate`。
4. 联调前端「历史话单」页（`views/cdr/index.vue`）调用是否正常。

### 工作流 F — rescan 指令 agent 未收到的排查（运行时，非缺接口）
1. 确认 agent 进程在 `sync.mode=kafka` 下运行且 `cmdMgr.Start(ctx)` 已起（消费 `vos.agent.command`）。
2. 确认 agent 配置 `instance.id` 恰为 `vos1`（与下发 vosId 一致，否则 commander 按 `cmd.VosID` 过滤丢弃）。
3. Kafka 侧确认 `vos.agent.command` topic 里有该消息（kafka-console-consumer 或后端 `AgentCommandProducer` 日志）。
4. 检查 agent 日志是否收到/丢弃 `rescan`，及 `scanner.ScanAndReport` 是否执行并回 `availability`。
5. 说明：后端 `triggerRescan` 逻辑正确（已发 Kafka），此问题属部署/配置/连通性，需现场核查，不一定改代码。

---

## 四、风险与待确认
- **agent 侧是否处理 pause/cancel/set_throttle/resume**：需核对 `commander.go#dispatch()`，若未实现需补 agent 逻辑（工作流 B 的依赖）。
- **ClickHouse 查询数据源**（工作流 E）是本次主要新增工作量。
- **自动建任务幂等**（工作流 C4）需仔细处理，避免与手动「启动批量回填」重叠建重复任务。
- rescan「agent 未收到」未必是代码问题，可能仅是 agent 未起 / instance.id 不符 / Kafka 未通。

## 五、建议执行顺序
**A（乱码）→ B（控制不新增任务）→ D（前端闪烁/换行/悬浮）→ C（自动扫描建任务）→ E（cdr 接口）→ F（rescan 排查）**

A 是 1 行 SQL 的快速修复；B/D 是体验类 Bug；C 补齐自动化的核心逻辑；E 是独立的新接口；F 需现场核查后再决定是否改代码。
