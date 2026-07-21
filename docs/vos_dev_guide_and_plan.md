# VOS3000 数据中台开发指导手册与项目排期计划 (Developer Guide & Roadmap)

本文件作为 YK-VOS 数据中台二期核心功能开发的技术指引与项目管理基准。所有前后端开发必须严格遵守本规范，特别是前端界面的图标渲染标准与后端的 CQRS 数据隔离规则。

---

# 第一部分：前端开发指导手册 (Frontend Dev Guide)

## 1. UI 视觉与图标规范 (UI & Icon Specifications)
为了保持企业级管理后台的整洁与专业度，前端项目有以下强制性规范：
1. **禁用任何 Emoji 表情图标**：在 HTML/Vue 模板、表格、按钮、标签或卡片文字中，**严禁**直接嵌入 Emoji（如 `🔴`, `🟢`, `📋`, `📊`, `⚙️` 等）。
2. **统一使用内置图标库**：项目集成了 Iconify / Lucide 图标集，所有图标需求一律通过 `<IconifyIcon icon="lucide:图标名" />` 进行声明渲染。
3. **高频常用图标对照表**：

| 页面/按钮元素 | 推荐 Iconify/Lucide 图标 | 示例代码 |
| :--- | :--- | :--- |
| **仪表盘/监控** | `lucide:layout-dashboard` | `<IconifyIcon icon="lucide:layout-dashboard" />` |
| **客户管理** | `lucide:users` | `<IconifyIcon icon="lucide:users" />` |
| **网关/通路** | `lucide:network` | `<IconifyIcon icon="lucide:network" />` |
| **号码资产** | `lucide:phone-call` | `<IconifyIcon icon="lucide:phone-call" />` |
| **话单/账单** | `lucide:receipt` | `<IconifyIcon icon="lucide:receipt" />` |
| **正常/已接通** | `lucide:check-circle-2` (绿色) | `<IconifyIcon icon="lucide:check-circle-2" class="text-green-500" />` |
| **冻结/异常** | `lucide:alert-circle` (红色) | `<IconifyIcon icon="lucide:alert-circle" class="text-red-500" />` |
| **调整/修改** | `lucide:edit-3` | `<IconifyIcon icon="lucide:edit-3" />` |
| **回收/删除** | `lucide:trash-2` | `<IconifyIcon icon="lucide:trash-2" />` |
| **手动刷新** | `lucide:refresh-cw` | `<IconifyIcon icon="lucide:refresh-cw" />` |

---

## 2. 前端文件结构与目录导引
二期功能的全部前端视图均存放在 `apps/web-ele` 子应用下：

* **页面视图目录**：`frontend/apps/web-ele/src/views/vos/`
  * 客户管理面：`vos/customer/index.vue` (新建)
  * 网关监控面：`vos/gateway/index.vue` (新建)
  * 号码管理面：`vos/phone/index.vue` (新建)
  * 话单对账面：`vos/report/index.vue` (新建)
* **API 请求层**：`frontend/apps/web-ele/src/api/vos.ts` (统一存放对接后端的 Axios 方法)

---

# 第二部分：后端开发指导手册 (Backend Dev Guide)

## 1. 数据隔离原则与数据库访问规范
中后台采用只读/只写分离架构：
1. **只读数据 (MySQL / ClickHouse)**：
   * 所有读请求统一注入命名为 `@Resource private JdbcTemplate clickHouseJdbcTemplate;` 的 Bean 进行 ClickHouse 原生查询。
   * 不得将 ClickHouse 表映射为 MyBatis-Plus `BaseMapper`，所有的聚合统计（ASR、毛利、并发数）直接写 SQL 并通过 `queryForList` 或 `queryForObject` 返回 DTO。
2. **新增/修改数据 (VOS API 代理)**：
   * 严禁直接更新远端 VOS 本地 MySQL 表中涉及路由和号码的字段（如 `e_phone`）。
   * 必须将更新包装成 Kafka 事件发送给 Agent，由 Agent 在 VOS 本地发起基于 HTTP 的 VOS 接口调用（保证 VOS 内存路由同步生效）。

---

## 2. 后端代码布局与包结构
* **控制器包 (Controller)**：`cn.iocoder.yudao.module.vos.controller.admin.vos` (处理前端 API 请求)
* **业务服务包 (Service)**：`cn.iocoder.yudao.module.vos.service` (处理业务校验及控制面指令下发)
* **控制指令传输层 (Kafka)**：
  * 主控端：`yudao-module-vos` 下的 `AgentControlProducer.java` (用于向 Kafka `vos.control` 队列发布指令)
  * Agent接收端：`agent/internal/consumer/control_consumer.go` (接收控制指令并请求本地 VOS WebExternal 接口)

---

# 第三部分：开发排期与发布版本管理 (Roadmap & Releases)

## 1. 严格版本升级管理规范
在每次编译并执行全量打包生成部署包时，**严禁使用重复的版本号**。每次打包必须递增 Patch（修订号）或 Minor（次版本号），以确保线上升级时环境自愈不冲突。

* **当前版本基线**：`1.0.4`
* **未来各里程碑打包版本号规划**：
  * 里程碑一发布包：`ykvos-server-dev-1.0.5.tar.gz`
  * 里程碑二发布包：`ykvos-server-dev-1.0.6.tar.gz`
  * 里程碑三发布包：`ykvos-server-dev-1.0.7.tar.gz`
  * 里程碑四发布包：`ykvos-server-dev-1.0.8.tar.gz`

---

## 2. 里程碑与详细开发排期进度

### 里程碑一：Go Agent 增量采集、中台模型扩展与初始化菜单 SQL（目标版本：`1.0.5`）
* **周期**：2026-07-22 ~ 2026-07-24
* **核心任务**：
  1. 升级 Go Agent 的维度抓取逻辑，增加对本地 `e_customer`、`e_gatewaymapping`、`e_gatewayrouting` 以及 `e_phone` 表的定时抓取 and 上报。
  2. 中台 MySQL 扩展 `vos_customer` 缓存结构，定义对应 DO 类。
  3. **初始化菜单 SQL 更新**：将“客户管理”、“网关监控”、“号码管理”等子菜单，以及将“财务管理”等父级菜单显式可见的指令直接写入 `backend/sql/mysql/ykvos.sql` 初始化文件与 `fix-vos-menu-upsert.sql` 修复文件中，完成数据库层面的结构预注册。

### 里程碑二：反向控制 Kafka 通道与 Agent 本地 API 联调（目标版本：`1.0.6`）
* **周期**：2026-07-25 ~ 2026-07-31
* **核心任务**：
  1. 后端实现 `AgentControlProducer`，定义 `RECYCLE_PHONE` 与 `UPDATE_LIMIT` Kafka 消息结构。
  2. 升级 Go Agent，集成本地 HTTP Client。在接收到消息后，自动发起本地 `POST http://localhost:9090/external/server/DeletePhone` 或 `AddPhone` 请求并获取 `retCode` 返回值。
  3. 执行 `mvn clean package` 打包为 `1.0.6` 发布包，实机联调控制面通信。

### 里程碑三：多节点客户管理与财务控制中心上线（目标版本：`1.0.7`）
* **周期**：2026-08-01 ~ 2026-08-06
* **核心任务**：
  1. 编写后端 `VosCustomerController` 分页 and 控制接口。
  2. 前端构建 `views/vos/customer/index.vue` 列表与操作弹窗。
  3. **UI 规范检查**：彻底去除所有 Emoji 字符，采用 `lucide:users`、`lucide:edit-3` 等内置图标，并使用红色文字作为欠费账户的高亮警示。

### 里程碑四：毛利分析报表与网关并发监控完工（目标版本：`1.0.8`）
* **周期**：2026-08-07 ~ 2026-08-16
* **核心任务**：
  1. 编写 ClickHouse 侧的分组利润聚合 SQL 与对账报表接口。
  2. 实现网关当前并发查询（ClickHouse 活动话单计数）与 `capacity` 对比，得到实时装载率。
  3. 前端完成“话单对账”与“通道负载监控”两块页面，进度条使用框架内置 element 组件，杜绝字符块模拟。
  4. 打包最终交付包 `1.0.8`，完成系统性闭环上线。
