# YK-VOS 数据分析中台（新建项目）

> 本目录 `yk-vos-new` 是**全新**项目，与旧仓库 `yk-vos`（Python/FastAPI/Next.js + VOS API 拉取）**完全独立**。
> 重建原因：数据来源从「调 VOS Web API」改为「**直连 VOS 数据库同步**」，采集层与数据模型整体不同，故重建而非重构。

## 一、技术栈（已锁定）

| 层 | 选型 | 说明 |
|----|------|------|
| 后端 | **ruoyi-vue-pro**（`master-jdk17` 分支，tag v2026.06） | Spring Boot 3.5 + MyBatis Plus + Redis + Quartz + 内置 RBAC/代码生成 |
| 前端 | **yudao-ui-admin-vben**（2026.06 发行包，已解压至 `frontend/`） | Vben Admin 5.7 + **Ant Design Vue 4** + Vite + Pinia + TypeScript（pnpm monorepo，开发目录 `apps/web-antd`，包名 `@vben/web-antd`） |
| 数据真值 | `vos3000_structure.sql` | VOS3000 服务器数据库**真实结构**，所有表设计以此为准（非设计文档里写错的 SIP 级 CDR） |
| 分析库 | ClickHouse | ODS 层 DDL 见 `clickhouse/ods/01_ods_vos.sql` |
| 业务库 | PostgreSQL / MySQL | 中台自身主库（用户/权限/配置），与 VOS 只读维度分离 |

### 后端模块取舍
根 `pom.xml` 已默认只激活 `yudao-server` + `yudao-module-system` + `yudao-module-infra`，
`mall/erp/crm/pay/bpm/mp/ai/iot` 等模块已注释排除。后续新增 `yudao-module-vos`（同步层）对齐 `cn.iocoder.yudao.module.vos` 分层。

## 二、目录结构
```
yk-vos-new/
├── backend/                     # ruoyi-vue-pro（master-jdk17）
│   ├── yudao-server/          # 启动模块（含 main）
│   ├── yudao-module-system/   # RBAC/用户/角色/菜单（中台鉴权基座）
│   ├── yudao-module-infra/    # 定时任务（Quartz）/ 数据源
│   └── yudao-framework/ ...  # 各 starter
├── frontend/                   # yudao-ui-admin-vben 2026.06（解压自 zip）
│   ├── apps/web-antd/         # ★ 开发目录（Ant Design Vue）
│   ├── packages/              # @vben/* 公共包（request/layouts/stores...）
│   ├── pnpm-workspace.yaml
│   └── package.json
├── clickhouse/ods/01_ods_vos.sql   # ODS 层 DDL（e_cdr 全字段镜像 + 维度 + DWS 汇总）
├── scripts/cdr_backfill_manifest.json # 51 个历史日表 + 滚动 e_cdr 回溯清单
├── tools/
│   ├── maven/                # 隔离的干净 Maven 3.9.9（绕过本机坏掉的全局 Maven）
│   └── mvn                   # Windows 路径包装脚本（见下方「Maven 坑」）
└── README.md
```

## 三、环境准备（本机已验证）

- **JDK 17**：`C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot`（注意：本机 `JAVA_HOME` 默认指向 JDK11，项目脚本已写死 JDK17）
- **Node 22**：`node -v` ≥ 22.18
- **pnpm 11**：本机 corepack 损坏，统一用 `npx -y pnpm@11.7.0`
- **Maven 坑（重要）**：本机 Git Bash 设了 `MSYS_NO_PATHCONV=1`，会把 `/d/...` POSIX 路径原样传给 Windows 的 `java.exe` 导致 Maven 报
  `找不到或无法加载主类 org.codehaus.plexus.classworlds.launcher.Launcher`。
  → 已用 `tools/mvn` 包装脚本（`cygpath -w` 显式转 `D:\...` 路径 + 直启 classworlds）绕过，**永远用 `tools/mvn` 而非全局 `mvn`**。

## 四、启动（后端）

```bash
cd backend
# 编译（含 -am 关联模块）
../tools/mvn -pl yudao-server -am -Dmaven.test.skip=true compile
# 运行
../tools/mvn -pl yudao-server -am spring-boot:run
# 或打包
../tools/mvn -pl yudao-server -am -Dmaven.test.skip=true package
```
> 首次需连接 MySQL（ruoyi 自带初始化 SQL）与 Redis，详见 `yudao-server/src/main/resources/application.yml`。

## 五、启动（前端）

```bash
cd frontend
# 安装依赖（必用 pnpm 11；--ignore-scripts 可跳过 lefthook/stub 的本地钩子）
npx -y pnpm@11.7.0 install --ignore-scripts
# 启动 AntDV 开发服务器
npx -y pnpm@11.7.0 -F @vben/web-antd run dev
# 类型检查（验证工具链）
npx -y pnpm@11.7.0 -F @vben/web-antd run typecheck
```
> 前端默认对接 yudao 后端契约（token/菜单/响应包装），与 `backend` 零适配。
> 需将 `apps/web-antd` 的 `@vben/request` baseURL 指向本机后端端口（默认 48080）。

## 六、数据同步（待落地）
- 数据源：`vos3000_structure.sql`（`e_cdr` + 51 个同构日表 `e_cdr_YYYYMMDD` + `e_customer`/`e_gatewaymapping`/`e_feerate`）。
- 采集机制：**批量增量优先**（MyISAM 表 Canal 无法回放历史），实时 CDC/Canal 列为二期。
- 回溯清单：`scripts/cdr_backfill_manifest.json`（`flowno` 去重）。
- ODS 落库：`clickhouse/ods/01_ods_vos.sql`。

## 七、下一步
1. 前端依赖装好后跑通 `dev` / `typecheck`。
2. 新增 `yudao-module-vos`：实体映射（e_cdr/e_customer/...）+ `BatchSource` 批量回溯骨架（接口可插拔，Canal 留二期）。
3. 打通前后端：登录/RBAC 菜单按角色渲染、话单看板首屏。
