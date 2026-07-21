# SaaS 多租户基础权限设计（yk-vos-new）

> 配套文档：`服务端历史话单回填与VOS管理设计.md`、`受控历史话单回填设计.md`（agent 侧）
> 状态：设计定稿，待实施（本文不涉及 agent 控制面，仅平台权限基座）

---

## 0. 设计原则

1. **复用 yudao 内置 RBAC + 多租户，不自研**。yudao 已提供 `system_tenant` / `system_tenant_package` / `system_menu` / `system_role` / `system_role_menu` / `system_user` 完整链路，本项目只做「菜单树定义 + 三基础角色种子 + 套餐 menuIds 配置」。
2. **权限到菜单级**：菜单（MENU）、目录（DIR）、按钮（BUTTON）三层均受权限串控制；后端 `@PreAuthorize` 拦截接口，前端路由 `meta.permissions` + `v-auth` 指令隐藏无权限按钮。
3. **三基础角色**：超级管理员（系统级）、运维人员（租户内）、财务人员（租户内）。
4. **租户数据物理隔离优先于角色**：所有业务 DO 继承 `TenantBaseDO`，由 `TenantContextHolder` + MyBatis 拦截器自动按 `tenant_id` 过滤（见 `服务端历史话单回填与VOS管理设计.md` §4.7），角色只控制「能看到哪些菜单/按钮」，不突破租户隔离。
5. **系统级跨租户可见性**：超级管理员（`tenant_id=0`）通过 ALL 范围查询全量业务数据时，由于 MyBatis 多租户拦截器默认强制附加 `tenant_id` 过滤，后端查询需通过 `TenantUtils.executeIgnore(...)` 显式挂起多租户过滤，实现安全的全局运维与状态归集。
   - **前端租户切换**：前端 UI 默认绑定登录租户（`tenant_id`），super admin 后端虽能查全量，却**无法在 UI 切到目标租户实操**。须复用 yudao 内置「租户切换 / 伪装登录」（携带特殊 header `tenant-id` 或调用 switch 接口），让前端会话切到指定租户上下文，详见 §9 第 7 步。

---

## 1. 总体架构（权限模型）

```
                ┌──────────────────────────────────────────────┐
                │              system_tenant（租户隔离根）         │
                │  TenantContextHolder + MyBatis 拦截器自动过滤   │
                └──────────────────────────────────────────────┘
                                 │ 1 租户绑定 1 套餐
                                 ▼
                ┌──────────────────────────────────────────────┐
                │     system_tenant_package（租户套餐）            │
                │  menuIds = 该租户「允许使用」的菜单白名单        │
                │  + vos_max_limit（VOS 节点额度，复用已有字段）   │
                └──────────────────────────────────────────────┘
                                 │ 套餐允许的菜单 ∩ 角色分配的菜单
                                 ▼
   system_menu（全局 @TenantIgnore）───permission 串 `${系统}:${模块}:${操作}`
                                 │ 角色→菜单映射
                                 ▼
                ┌──────────────────────────────────────────────┐
                │   system_role（租户内实体 TenantBaseDO）         │
                │   type: SYSTEM(系统级) / CUSTOM(租户自定义)      │
                │   dataScope: 数据范围（ALL/DEPT/SELF...）        │
                └──────────────────────────────────────────────┘
                                 │ 用户绑定角色
                                 ▼
                ┌──────────────────────────────────────────────┐
                │   system_user（租户内实体，role_ids）             │
                └──────────────────────────────────────────────┘
```

**双控要点**：一个菜单要真正对某个租户的用户可见，必须同时满足
① 该菜单在其租户套餐的 `menuIds` 白名单内；
② 该用户所属角色通过 `system_role_menu` 关联了该菜单。
两者取交集，缺一不可（防止套餐未购却通过角色看到菜单）。

---

## 2. 多租户模型（复用 yudao，零改造）

| 表 | 作用 | 关键字段 | 是否租户隔离 |
|---|---|---|---|
| `system_tenant` | 租户根，隔离边界 | id, name, status | 自身即租户定义 |
| `system_tenant_package` | 租户套餐（菜单白名单 + 额度） | `menuIds`(Set<Long>), `vos_max_limit` | `@TenantIgnore`（全局套餐模板） |
| `system_menu` | 平台菜单树（全局共享） | `permission`, `type`(DIR/MENU/BUTTON), `parentId`, `path` | **`@TenantIgnore`（全局唯一一份）** |
| `system_role` | 角色（租户内） | `type`, `dataScope`, `tenant_id`(继承 TenantBaseDO) | 是（TenantBaseDO） |
| `system_role_menu` | 角色-菜单关联 | role_id, menu_id | 随角色隔离 |
| `system_user` | 用户（租户内） | `role_ids`, `tenant_id` | 是（TenantBaseDO） |

> ⚠️ 关键事实：`system_menu` 标了 `@TenantIgnore`，**菜单本身不按租户分库**，所有租户看同一棵菜单树。租户间的菜单差异完全由「套餐 menuIds + 角色映射」决定，而非多份菜单。

---

## 3. 角色与权限模型（复用 yudao）

- **权限串格式**：`${系统}:${模块}:${操作}`，例如 `vos:instance:create`、`vos:backfill:pause`、`finance:bill:list`。
- **权限生效双层**：
  - 后端：Controller 方法 `@PreAuthorize("@ss.hasPermission('vos:instance:create')")` 拦截越权调用。
  - 前端：路由 `meta.permissions` 控制菜单/目录显隐；`<a-button v-auth="'vos:instance:create'">` 控制按钮显隐。
- **角色类型**（`RoleTypeEnum`）：
  - `SYSTEM(1)`：内置系统级角色，位于系统租户（`tenant_id=0`），可跨租户。
  - `CUSTOM(2)`：租户自定义角色，受本租户 `tenant_id` 隔离。
- **数据范围轴 vs 租户隔离轴（勿混淆）**：
  - **租户隔离轴**：由 `tenant_id` + MyBatis 拦截器物理保证；跨租户可见性取决于是否 `tenant_id=0` 且持有 `SYSTEM` 角色（此时拦截器被绕过）。超级管理员的「跨租户」能力来自这一轴，**不是 `dataScope`**。
  - **dataScope 轴**：仅管租户*内*的部门/组织维度（DEPT/SELF/ALL）。本平台无部门层级、用不上该维度，故所有租户内角色 `dataScope` 一律取「本租户全部」（等价于 SELF 租户），**切勿误以为设 `ALL` 即跨租户**。

---

## 4. 三基础角色定义

| 角色 | 角色类型 | 租户范围 | 菜单范围 | 数据范围 |
|---|---|---|---|---|
| **超级管理员** | `SYSTEM`（内置，系统租户 `tenant_id=0`） | 系统级，跨全部租户 | 全部菜单 + 租户管理/套餐管理 | `ALL`（跨租户实际由 `tenant_id=0`+SYSTEM 角色绕过拦截器实现，非 dataScope 生效，见 §3） |
| **运维人员** | `CUSTOM`（租户内） | 仅本租户 | 对接管理（VOS 管理 + 历史话单回填）+ 监控运维 + 系统管理中的**租户内自管**（角色/用户/菜单管理，不含租户/套餐管理） | 本租户内 |
| **财务人员** | `CUSTOM`（租户内） | 仅本租户 | 财务管理（账单/对账/报表） | 本租户内 |

> 超级管理员为 yudao 开箱内置角色（用户 `admin` 持有），首次建库即存在，无需自建；运维/财务为**新增的租户内角色模板**，见 §7。

---

## 5. 菜单树设计（权限到菜单级）

顶层目录「**VOS 数据中台**」，下挂 4 个二级目录。权限串统一前缀 `vos:` / `finance:` / `system:`。

```
VOS 数据中台（DIR）
├─ 对接管理（DIR）                  ← 运维人员可见
│  ├─ VOS 管理（MENU）             perm: vos:instance:list
│  │   ├─ 新增（BUTTON）           perm: vos:instance:create
│  │   ├─ 编辑（BUTTON）           perm: vos:instance:update
│  │   └─ 删除（BUTTON）           perm: vos:instance:delete
│  └─ 历史话单回填（MENU）         perm: vos:backfill:list
│      ├─ 立即/定时接收（BUTTON）   perm: vos:backfill:start
│      ├─ 暂停（BUTTON）            perm: vos:backfill:pause
│      ├─ 恢复（BUTTON）            perm: vos:backfill:resume
│      ├─ 取消（BUTTON）            perm: vos:backfill:cancel
│      ├─ 重新扫描（BUTTON）        perm: vos:backfill:rescan
│      ├─ 精确计数（BUTTON）         perm: vos:backfill:precise-count
│      └─ 调速（BUTTON）            perm: vos:backfill:throttle
├─ 监控运维（DIR）                  ← 运维人员可见
│  ├─ Agent 健康看板（MENU）       perm: vos:agent:health
│  └─ 监控大屏（MENU）             perm: vos:monitor:screen
├─ 财务管理（DIR）                  ← 财务人员可见
│  ├─ 账单计费（MENU）             perm: finance:bill:list
│  ├─ 对账（MENU）                 perm: finance:reconcile:list
│  └─ 报表（MENU）                 perm: finance:report:list
└─ 系统管理（DIR）                  ← 超级管理员（系统级，含租户/套餐管理）；运维人员可见其中的角色/用户/菜单管理（租户内自管）
   ├─ 租户管理（MENU）             perm: system:tenant:list      （仅超级管理员 SYSTEM 范围）
   ├─ 租户套餐（MENU）             perm: system:tenant-package:list （仅超级管理员 SYSTEM 范围）
   ├─ 角色管理（MENU）             perm: system:role:list        （超级管理员 + 运维租户内自管）
   ├─ 用户管理（MENU）             perm: system:user:list        （超级管理员 + 运维租户内自管）
   └─ 菜单管理（MENU）             perm: system:menu:list        （超级管理员 + 运维租户内自管）
```

> 菜单 `path` / `component` 对齐前端 `views/vos/*`、`views/finance/*`（财务管理为预留模块，本版可先挂空路由或后续扩展）。
> 「系统管理」下的租户管理/套餐管理 `path` 带 `system` 前缀且 `dataScope` 仅 SYSTEM 角色可分配，确保普通租户用户即便误赋权也会被后端 `@PreAuthorize` + 租户拦截器拦截。
> 「监控大屏」（`vos:monitor:screen`）若需聚合**跨租户**全局状态（super admin 视角），其 Service 查询须显式走 §0.5 的 `TenantUtils.executeIgnore(...)` 跨租户查询（⚠️ 不可用 `execute(null,...)`，会引发空指针/无效拼装，见 §10）；若仅展示**本租户**数据则无需，由 `tenant_id` 物理隔离自然收敛。

---

## 6. 角色-菜单映射矩阵

| 权限串 | 超级管理员 | 运维人员 | 财务人员 |
|---|:---:|:---:|:---:|
| `vos:instance:list` | ✓ | ✓ | — |
| `vos:instance:create/update/delete` | ✓ | ✓ | — |
| `vos:backfill:list` | ✓ | ✓ | — |
| `vos:backfill:start` | ✓ | ✓ | — |
| `vos:backfill:pause/resume/cancel/rescan` | ✓ | ✓ | — |
| `vos:backfill:precise-count/throttle` | ✓ | ✓ | — |
| `vos:agent:health` | ✓ | ✓ | — |
| `vos:monitor:screen` | ✓ | ✓ | — |
| `finance:bill:list` | ✓ | — | ✓ |
| `finance:reconcile:list` | ✓ | — | ✓ |
| `finance:report:list` | ✓ | — | ✓ |
| `system:tenant:list` | ✓ | — | — |
| `system:tenant-package:list` | ✓ | — | — |
| `system:role:list / user:list / menu:list` | ✓ | （租户内自管） | — |

> 运维与财务**角色默认分离**：运维看不到财务菜单，财务看不到 VOS 运维菜单；两者都看不到系统级租户/套餐管理。⚠️ 此「分离」指**角色模板默认不互含菜单**，**并非用户层互斥**——同一用户可同时持有运维、财务两个角色（按业务需要分配），不应在代码 / UI 强制「二选一」。
> 超级管理员拥有全部权限且跨租户。

---

## 7. 角色种子与租户初始化

- **超级管理员**：yudao 内置 `SYSTEM` 角色，用户 `admin/admin123` 持有，首次执行 `ruoyi-vue-pro.sql` 即存在，**无需新建**。
- **运维人员 / 财务人员**：定义为「**内置角色模板**」，在新租户初始化时 clone 为 `CUSTOM` 角色（绑定该租户 `tenant_id`），保证每个租户开箱即有这两个角色。
  - ⚠️ **默认租户（tenant_id=1）也要 seed**：建库即存在的默认租户（其套餐已购全量菜单）**同样必须 seed 运维/财务角色**，不能只在新租户钩子里 clone。否则该默认租户初始无可用业务角色，首登即空菜单。
  - **clone 须与套餐 menuIds 取交集**：clone 时角色实际菜单 = **角色模板意图菜单 ∩ 该租户套餐允许的 `menuIds`**。若直接套用模板完整菜单，体验版租户的运维角色仍会带上套餐已剔除的回填/财务菜单，使 §7 的套餐剥离失效（防穿透见下条）。
  - 实施落点：复用 yudao 的「租户初始化」钩子（如 `TenantInfoInit` / 套餐创建时的角色模板复制逻辑），在 `system_role` 插入两条 `CUSTOM` 记录并写入 `system_role_menu`。
- **套餐 menuIds 权限限制防穿透**：给租户分配套餐时，**必须根据收费等级物理剔除未购买的模块菜单**（例如：体验版套餐对应的 `menuIds` 必须强行刨除财务管理、回填控制等高阶菜单）。不能偷懒直接给全树，否则租户管理员可以通过在后台创建自定义角色并挂载菜单来实施权限绕过和功能白嫖。
  - **API 级闭环防御**：前端不展示套餐外菜单只是障眼法——租户管理员仍可直调角色-菜单分配 API 传入套餐外的 `menu_id`。因此后端角色-菜单分配入口（yudao `RoleMenuService` / `RoleController.assignRoleMenu`）**必须校验被赋 `menu_id` ⊆ 该租户套餐 `menuIds`**，越界即拒绝，否则「不展示」形同虚设。
- **菜单升级同步逻辑**：因为 `system_menu` 是全局共享的，平台升级若新增了子菜单/按钮，已存在的租户 CUSTOM 角色对应的 `system_role_menu` 不会自动添加该绑定。必须随版本提供数据库迁移升级脚本（Migration Script），批量为历史租户的特定业务角色追加对应的新增菜单映射。
- **VOS 节点额度**：沿用 `服务端历史话单回填与VOS管理设计.md` §4.7 的 `vos_max_limit`（体验=1 / 企业=3 / 大客户=10 / 旗舰=999），与套餐绑定。

---

## 8. 与现有设计文档的衔接

- **后端权限接入**：`VosInstanceController` / `VosBackfillController` / `VosAgentController` 的 `@PreAuthorize` 权限串 = 本文 §5 的 `vos:*` 串（读接口 `:list` 类、写接口 `:create/:update/:delete/:start/:pause/...` 类），与服务端设计 §4.2 的「读权限 / 写权限 + @OperateLog」要求一致。
- **操作审计一致性**：写操作审计须覆盖**系统级**——`system:role:*`、`system:tenant:*` 的 create/update/delete 也必须加 `@OperateLog(type = ...)`，与服务端设计 §4.2 对 backfill 指令写接口的审计要求一致，避免系统级操作出现审计黑洞。
- **前端路由**：`router/routes/modules/vos.ts` 各路由 `meta.permissions` 填对应 `vos:*`；新增 `finance.ts` 路由挂 `finance:*`；按钮用 `v-auth` 包裹。
  - **菜单由后端驱动**：yudao-vue-pro 的侧边栏菜单与路由由后端 `system_menu` + 当前用户角色菜单**动态生成**，前端 `meta.permissions` 必须与后端 `system_menu.permission` 串**逐字一致**（含大小写与冒号），否则动态菜单显隐与 `v-auth` 按钮行为会对不上。前端 `router/routes/modules/*.ts` 仅负责注册 `component` + 路由守卫，**不决定权限**。
- **多租户隔离**：所有 VOS 业务 DO（vos_instance / vos_agent_backfill / vos_agent_backfill_task / vos_agent_heartbeat）继承 `TenantBaseDO`，与本文 §2 一致；Kafka 消费侧手动注入 `tenant_id` 的要求见服务端设计 §4.7。
- **套餐 menuIds**：在 `system_tenant_package` 初始化 SQL 中配置，与本文 §7 一致。

---

## 9. 实施步骤

1. **菜单树种子 SQL**：向 `system_menu` 插入 §5 全量菜单（DIR/MENU/BUTTON 三级 + permission + parentId 层级），给定固定 menu_id 便于角色映射。插入时的 `path` / `component` 字段须与前端 `views/vos/*`、`views/finance/*` 的**实际路由定义精确对齐**（含路径大小写），否则菜单能显示但点击后白屏/不跳转。
2. **后端权限接入**：在 `VosInstanceController` / `VosBackfillController` / `VosAgentController` 方法上加 `@PreAuthorize("@ss.hasPermission('vos:xxx')")`，与 §5 权限串一一对应。
3. **前端路由 + 按钮**：`vos.ts` 路由补 `meta.permissions`；`views/vos/*` 写按钮包 `<a-button v-auth>`；新增 `finance.ts` 路由（预留）。
4. **角色模板种子**：插入运维/财务两条 `CUSTOM` 角色 + `system_role_menu` 映射（按 §6 矩阵，含系统管理下的角色/用户/菜单管理租户内自管）；接入租户初始化钩子自动 clone，**默认租户（tenant_id=1）同样 seed**（见 §7 ⚠️）。
5. **套餐 menuIds 配置**：在 `system_tenant_package` 初始化数据里填好各套餐 `menuIds` 与 `vos_max_limit`。
6. **联调验证**：分别以超级管理员 / 运维 / 财务登录，校验
   - 菜单可见性符合 §6 矩阵；
   - 无权限按钮在前端隐藏、且后端 `@PreAuthorize` 拦截越权直接调用（用 curl 带错角色 token 验证 403）；
   - 运维/财务均看不到租户管理/套餐管理；财务看不到 VOS 管理。
7. **前端租户切换接入（超级管理员专用）**：复用 yudao 内置「租户切换 / 伪装登录」，在 super admin 会话中支持切换到目标 `tenant_id`（携带特殊 header `tenant-id` 或调用 switch 接口），使运维/财务的租户内菜单与数据可在 UI 直接操作；否则即便后端 `TenantUtils.executeIgnore(...)` 能查全量，super admin 也无法在 UI 切租户实操（见 §0.5）。

---

## 10. 风险与注意

- **菜单全局共享**：因 `system_menu` 是 `@TenantIgnore`，**切勿**把租户私有数据写进菜单表；菜单只描述「结构 + 权限串」，数据隔离靠 `tenant_id`。
- **套餐 menuIds 漏配与越权**：严格按照收费阶梯在套餐级别控制 `menuIds` 白名单，它是第一道防线。
- **系统级菜单二次防御**：超级管理接口（如 `system:tenant:*` / `system:tenant-package:*`）除了后端 `@PreAuthorize` 表达式校验权限串外，其 Controller/Service 入口应强校验当前 `TenantContextHolder.getTenantId() == 0`，双重防止租户越权调用。
- **角色模板 clone 时机**：必须在新租户建库/初始化时同步 clone 运维/财务角色，否则新租户无可用业务角色。
- **存量租户菜单升级缺陷**：版本迭代新增功能权限时，必须运行全局菜单同步 SQL，防止老租户无法可见新菜单。
- **跨租户 API 名核实**：经源码审计，yudao 底层多租户工具类已明确通过 `TenantUtils.executeIgnore(...)` 来挂起租户拦截器，而 `TenantUtils.execute(null, ...)` 会引发空指针或无效拼装（其将 ignore 强制重设为 false）。因此，系统级越权及状态监控场景必须使用 `TenantUtils.executeIgnore(...)` 执行。
