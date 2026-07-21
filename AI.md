# YK-VOS 数据分析中台项目 AI 开发助手指导规范 (AI.md)

本规范是 YK-VOS 数据分析中台项目的全局技术指南，包含架构定义、研发规约、数据库设计及底层开发细节，用于引导开发人员和 AI 开发助手（如 Antigravity / Cursor / Claude Code）安全、规范地进行系统构建。

---

## 一、 项目架构与目录结构 (Project Architecture)

### 1. 架构定位
本系统旨在通过**直连 VOS 数据库同步 + ClickHouse 预聚合**的架构，对 VoIP 话务数据（日千万级）进行流式采集与极速 OLAP 聚合分析，同时通过自建业务库（PostgreSQL/MySQL）支持多角色（运维、财务、运营）的运营管理大盘。

### 2. 技术栈锁定
*   **前端**：`yudao-ui-admin-vben`（Vben 5.7 + Ant Design Vue 4 + Vite + Pinia + TS），单仓 monorepo，实际开发目录为 `apps/web-antd`，包名 `@vben/web-antd`。
*   **后端**：`ruoyi-vue-pro`（master-jdk17，Spring Boot 3.5 + MyBatis Plus + Redis + Quartz），只激活 `yudao-server`、`yudao-module-system` 和 `yudao-module-infra`，后续业务新增 `yudao-module-vos`。
*   **数据真值**：`vos3000_structure.sql`（VOS3000 MySQL 真实 MyISAM 库结构）。所有表设计与字段定义以此为唯一真值。
*   **分析库**：`ClickHouse`，用于存储话单 ODS 明细（ReplacingMergeTree 按 flowno 去重）及 DWS 预聚合统计。
*   **中台主库**：`PostgreSQL` / `MySQL`，处理 RBAC 用户权限与财务对账扣费（ACID 强一致性事务）。

### 3. 目录结构
```
yk-vos-new/
├── backend/                     # ruoyi-vue-pro (master-jdk17 后端)
│   ├── yudao-server/          # 启动入口与配置文件
│   ├── yudao-module-system/   # 内置系统权限基础 (RBAC)
│   ├── yudao-module-infra/    # 任务调度与基础设施 (Quartz)
│   └── yudao-module-vos/      # [新建] VOS 业务与数据同步挂载包
├── frontend/                   # yudao-ui-admin-vben (前端应用)
│   └── apps/web-antd/         # 开发目录 (Ant Design Vue 4)
├── agent/                      # Go 静态常驻同步 Agent (ykvos-agent)
│   ├── cmd/agent/             # 启动入口 main.go
│   ├── internal/              # 轮询采集、Kafka推送与HTTP Server端点代码
│   └── dist/                  # 打包输出目录
├── clickhouse/
│   ├── ods/01_ods_vos.sql     # ODS 表与 DWS 汇总表 DDL
│   └── test/02_kafka_ingest.sql # Kafka 引擎表与物化视图 DDL
├── tools/
│   └── mvn                    # 针对 MSYS 路径转换设计的 Maven 启动脚本
└── README.md
```

---

## 二、 数据采集与同步规约 (Data Synchronization)

### 1. 同步原理
*   由于 VOS 表为 **MyISAM 引擎**且不产出行级 binlog，**Canal / Debezium 等 Binlog 实时 CDC 方案不可用**。
*   系统必须采用 **“VOS 本地 Agent 轮询导出 + Kafka 缓冲 + ClickHouse 原生消费”** 架构：
    1. VOS 服务器本机部署 `ykvos-agent`（Go 静态服务，systemd 托管），用专用只读账号本地轮询 `e_cdr` 等表。
    2. Agent 以 5 秒为间隔，以单调递增的 `flowno` 为增量水位进行拉取，批量推送至 Kafka Topic `vos.cdr.live`。
    3. ClickHouse 使用 `Kafka` 表引擎消费，通过 `Materialized View` 流式写入 ODS 表。

### 2. 跨节点去重与分区策略
*   **去重键**：由于 `flowno` 仅在单个 VOS 节点内唯一，跨节点会重复。ClickHouse `ReplacingMergeTree` 的去重键必须是 **`(vos_id, flowno)`**。
*   **分区键**：未接通话单的接通时间 `starttime` 值为 `0`。为防止大几十万的未接通话单全部挤入 `197001` 历史分区导致性能崩溃，必须使用**呼叫发起时间 `recordstarttime`** 作为分区键：
    ```sql
    PARTITION BY toYYYYMM(toDateTime(coalesce(recordstarttime, 0)))
    ```

### 3. 数据出口原则 (Data Egress)
*   **Agent 作为唯一物理出口**：所有维度表（如 `e_customer`、`e_gatewaymapping`、`e_feerate` 等）统一由 Agent 在 VOS 本机低频轮询（增量/全量对比）写入 ODS / 镜像到业务库。
*   **中台后端永远不直连 VOS 数据库生产源**，确保生产数据库的稳定与安全隔离。

### 4. 双向网络与测试调试
*   若测试环境平台没有公网入站端口，Agent 可在配置中启用 `server.listen: ":5233"`，由平台侧周期性运行 `agent/tools/pull_client.py` 主动来拉，数据格式与 Kafka 消息同构，且支持断点续传。

---

## 三、 开发规范与避坑指南 (Development Guidelines)

### 1. 后端开发规则
*   **Maven 启动巨坑**：在 Windows Git Bash 等环境中由于路径格式转换问题，全局 `mvn` 无法加载 Launcher。**禁止直接使用全局 `mvn` 命令**，必须执行项目根目录下的 **`../tools/mvn`** 包装脚本。
*   **多数据源路由**：对 PostgreSQL (或 MySQL 业务库) 的事务操作在 Mapper/Service 上使用 `@DS("master")`（财务批量扣费时必须优先锁定 `account_id` 并包含 `@Transactional(rollbackFor = Exception.class)`，且执行不超过 3 秒以防死锁）。
*   对 ClickHouse 的聚合分析操作使用 `@DS("clickhouse")`。

### 2. 前端开发规则
*   **构建工具链**：前端依赖锁定使用 `pnpm@11.7.0`。如果本机 corepack 损坏，执行依赖安装和启动开发时统一使用：
    ```bash
    npx -y pnpm@11.7.0 install --ignore-scripts
    npx -y pnpm@11.7.0 -F @vben/web-antd run dev
    ```
*   **菜单鉴权**：菜单结构严禁在前端写死，统一由后端 `sys_menu` 表按角色分发，前端仅定义路由与组件映射关系。

### 3. ClickHouse 写入与查询规约
*   **防止 Too Many Parts 报错**：ClickHouse 禁止小批次高频写入。后端 Java 消费者必须实现**内存双重检查攒批写入器**（BlockingQueue 缓冲，达到 5000 条或 2 秒定时器强制刷盘）。
*   **禁止存储 Nullable 空值**：对于话单中的未接通/空字段，在 Java 写入 ClickHouse 前，禁止将这些字段设为 `null`，而应填充默认初始值（例如：未接通时间设为 `1970-01-01 00:00:00`，`sip_status` 设为 `0`），以避免 ClickHouse 的 Nullable 字段造成的 1.5 倍以上存储空间膨胀和查询降速。
*   **ASR (接通数) 判定标准**：统计接通率 (ASR) 和平均通话时长 (ACD) 时，统一使用 **`starttime > 0` 且 `feetime > 0`**（或 `holdtime > 0`）为成功接通判定，严禁使用挂断原因为正常释放（`endreason = 0`）来判定，避免数据偏高失真。

### 4. 交付与打包规范 (Packaging & Delivery Standards)
*   **交付件隔离原则**：所有打包文件必须输出至项目根目录下的 `release/` 目录中。
    *   **测试包（开发联调/部署）**：统一输出至 **`release/dev/`** 目录。
    *   **正式包（生产环境交付）**：统一输出至 **`release/prod/`** 目录。
*   **Agent 编译打包**：
    *   Agent 打包脚本（`package.ps1` 和 `package.sh`）支持传入版本号及环境参数（`dev` 或 `prod`，默认 `dev`）。
    *   编译打包的 Linux 静态二进制及配置文件将输出为 `ykvos-agent-$version.tar.gz`，并自动移动至对应的发布目录（如 `release/dev/agent/ykvos-agent-1.0.4.tar.gz`）。
    *   Windows 环境下打包运行命令：
        ```powershell
        cd agent
        powershell -ExecutionPolicy Bypass -File .\package.ps1 1.0.4 dev
        ```
*   **数据端/服务侧打包**：
    *   数据端打包脚本（`release/package_server.ps1` 和 `release/package_server.sh`）同样支持环境参数（`dev` 或 `prod`，默认 `dev`）。
    *   打包脚本会将对应环境的整个数据底座（docker-compose、DDL、monitor等）打包为 `ykvos-server-$targetEnv-$version.tar.gz`，并存放在该环境发布文件夹下。
    *   Windows 环境下打包运行命令：
        ```powershell
        cd release
        powershell -ExecutionPolicy Bypass -File .\package_server.ps1 dev 1.0.1
        ```
