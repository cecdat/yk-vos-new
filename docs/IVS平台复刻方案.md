# IVS 运营平台 — 完整复刻方案

> 基于 IVS 运营平台截图功能分析，结合 yk-vos-new 已确定的技术栈（ruoyi-vue-pro + yudao-ui-admin-vben + ClickHouse），输出全模块复刻实施方案。
> 数据模型唯一真值源：`vos3000_structure.sql`（VOS 服务器真实库结构）。

---

## 一、目标系统概览

### 1.1 复刻目标

将截图中 **IVS 运营平台** 的全部功能模块，用现代化技术栈（Spring Boot 3.5 + Vue3.5 + AntDV4 + ClickHouse）重新实现，同时利用**直连 VOS 数据库 + ClickHouse 预聚合**的架构优势，在数据查询能力和分析深度上超越原版。

### 1.2 技术栈锁定

| 层 | 技术 | 版本 | 说明 |
|---|------|------|------|
| 后端框架 | ruoyi-vue-pro（芋道单体） | master-jdk17 | Spring Boot 3.5 + MyBatis Plus 3.5 + Redis + Quartz |
| 前端框架 | yudao-ui-admin-vben | 2026.06 | Vben5 + Vue3.5 + Ant Design Vue4 + Vite8 + Pinia + TS |
| 业务数据库 | MySQL | 8.0+ | ruoyi 元数据 + VOS 维度表镜像 + 自建业务表 |
| 分析数据库 | ClickHouse | 24+ | ODS 原始话单镜像 + DWS 聚合汇总 |
| 数据源 | VOS MySQL（只读/从库） | — | 直连同步，替代原版 Web API 方式 |

---

## 二、功能模块全景（21 个）

### 2.1 模块总览

```
IVS 运营平台
├── 碳通管理                          ── P2: 主叫侧路由策略
├── 主叫管理                          ── P2: 主叫号码/路由规则
├── 被叫管理                          ── P2: 被叫落地路由
├── 话单同步                          ── P1: CDR 批量同步到 ClickHouse ★核心
│
├── 业务资源
│   ├── 供应商入库                    ── P1: 供应商 CRUD
│   ├── 线路仓库                      ── P1: SIP 中继线路管理
│   ├── 号码管理                      ── P2: 号码池/归属/使用率
│   └── 号码标记                      ── P3: 对接外部标记 API
│
├── 客户管理                          ── P1: 客户 CRUD / 余额 / 费率 ★VOS映射
│   ├── 财务管理                      ── P2: 充值/账单/结算
│   │   └── (子项待细化)
│   ├── 风控管理                      ── P2: 额度控制/异常检测
│   │   └── (子项待细化)
│   ├── 黑名单管理                    ── P1: 黑名单增删查
│   ├── 统计报表                      ── P2: 话务量/费用/质量报表 ★ClickHouse
│   │   └── (子项待细化)
│   ├── ASR 质检                      ── P3: 语音转文字质检
│   │   └── (子项待细化)
│   └── 预警管理                      ── P2: 规则引擎/阈值告警
│       └── (子项待细化)
│
├── 系统管理                          ── P0: ruoyi 内置 ✅ 已有
│   └── (用户/角色/菜单/字典/部门/岗位)
│
└── 对接管理
    ├── VOS 管理                      ── P1: 多 VOS 实例配置 ★当前页面
    ├── 查平台对接                    ── P2: 第三方平台 API 适配
    ├── 黑名单对接                    ── P2: 外部黑名单源适配
    ├── 号码写回对接                  ── P2: 标记数据回写适配
    └── ASR 对接                      ── P3: ASR 服务商适配
```

**优先级说明：**
- **P0** = 已有（ruoyi 内置），无需开发
- **P1** = MVP 必做（第一阶段）
- **P2** = 核心功能（第二阶段）
- **P3** = 增值/后期迭代（第三阶段）

---

## 三、分阶段实施计划

### Phase 0：基础设施验证（已完成 ✅）

| 任务 | 状态 | 说明 |
|------|------|------|
| 后端骨架搭建 | ✅ | ruoyi-vue-pro@master-jdk17 克隆完成，编译 BUILD SUCCESS |
| 前端骨架搭建 | ✅ | yudao-ui-admin-vben@2026.06 解压完成，pnpm install 进行中 |
| Maven 工具链修复 | ✅ | tools/mvn 包装脚本解决 MSYS 路径转换问题 |
| ClickHouse ODS DDL | ✅ | clickhouse/ods/01_ods_vos.sql 已编写（vos_cdr_ods 等 6 张表） |
| 回溯清单 | ✅ | scripts/cdr_backfill_manifest.json（51 日表） |

### Phase 1：MVP — 核心链路打通（建议首先执行）

**目标：** 实现截图中「VOS 管理」页面 + 话单同步链路，前后端全链路跑通。

#### 1.1 VOS 管理页面（截图当前页）— module-vos 第一个 CRUD

**功能描述：** 多 VOS 实例配置中心，对应截图中的表格（id / 名称 / IP / 创建时间 / 备注），支持新增、删除、搜索。

**后端设计：**

```sql
-- =============================================
-- yudao_module_vos: VOS 实例配置表
-- 存放所有需要同步数据的 VOS 服务器实例信息
-- =============================================
CREATE TABLE `vos_instance`
(
    `id`          bigint      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `name`        varchar(100) NOT NULL COMMENT '实例名称(如 180vos/local_test)',
    `host`        varchar(255) NOT NULL COMMENT 'VOS 服务器 IP 或域名',
    `port`        int         DEFAULT 3306 COMMENT 'MySQL 端口',
    `database`    varchar(100) DEFAULT 'edb' COMMENT '数据库名',
    `username`    varchar(100) DEFAULT 'readonly' COMMENT '只读账号',
    `password`    varchar(255)          COMMENT '加密存储密码',
    `status`      tinyint     DEFAULT 0 COMMENT '状态(0=禁用 1=启用)',
    `remark`      varchar(500)          COMMENT '备注',
    -- ruoyi 公共字段
    `creator`     varchar(64)           COMMENT '创建者',
    `create_time` datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updater`     varchar(64)           COMMENT '更新者',
    `update_time` datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint      NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='VOS 实例配置表';
```

**API 设计（RESTful）：**

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/admin-api/vos/instance/create` | 新增 VOS 实例 |
| PUT | `/admin-api/vos/instance/update` | 更新实例配置 |
| DELETE | `/admin-api/vos/instance/delete` | 删除实例（逻辑删除） |
| GET | `/admin-api/vos/instance/get?id=` | 查询单个实例详情 |
| GET | `/admin-api/vos/instance/page` | 分页查询（支持 name/host 搜索） |

**前端页面：**
- 菜单路径：`对接管理 > VOS 管理`
- 组件：AntDV `a-table` + `a-form-modal`（新增/编辑）
- 列定义：id / 名称(name) / IP(host) / 端口(port) / 状态(status) / 创建时间(create_time) / 备注(remark)
- 操作列：编辑 / 删除
- 搜索栏：名称模糊搜索 + IP 精确搜索

#### 1.2 话单同步任务（BatchSource 核心）

**功能描述：** 定时从 VOS MySQL 拉取 e_cdr 数据写入 ClickHouse vos_cdr_ods。支持历史回溯（51 日表）和增量轮询。

**后端设计：**

```
yudao-module-vos/
├── src/main/java/cn/iocoder/yudao/module/vos/
│   ├── controller/
│   │   └── admin/
│   │       ├── instance/          # VOS 实例 CRUD（§1.1）
│   │       │   └── VoSInstanceController.java
│   │       ├── sync/              # 同步管理
│   │       │   └── CdrSyncController.java    # 手动触发/查看同步状态
│   │       └── cdr/               # 话单查询
│   │           └── CdrQueryController.java   # 从 CH 查询话单
│   ├── service/
│   │   ├── instance/
│   │   │   └── VoSInstanceService.java
│   │   ├── sync/
│   │   │   ├── CdrSyncService.java            # 同步编排服务
│   │   │   ├── CdrSource.java                 # 采集源接口（可插拔）
│   │   │   ├── BatchCdrSource.java            # 批量 SELECT 实现
│   │   │   └── CanalCdrSource.java            # Canal 实现（Phase 2 可选）
│   │   └── cdr/
│   │       └── CdrQueryService.java           # ClickHouse 查询封装
│   ├── dal/
│   │   ├── dataobject/
│   │   │   ├── VoSInstanceDO.java             # VOS 实例 DO
│   │   │   └── CdrSyncLogDO.java              # 同步日志 DO
│   │   └── mysql/
│   │       ├── VoSInstanceMapper.java         # MySQL Mapper
│   │       └── CdrSyncLogMapper.java
│   └── job/                                   # Quartz 定时任务
│       └── CdrSyncJob.java                    # 定时触发批量同步
```

**同步流程：**

```
[Quartz Cron] → CdrSyncJob.execute()
    → CdrSyncService.syncAllInstances()
        → 查询 vos_instance 表中 status=1 的实例
        → 对每个实例：
            1. 读取上次同步点位（Redis/DB 记录 last_sync_time + last_table）
            2. BatchCdrSource.readRange(instance, from, to)
                → JDBC 连接 VOS MySQL（只读）
                → SELECT * FROM e_cdr WHERE starttime > {last_point} LIMIT {batch_size}
                → 或遍历历史表 e_cdr_YYYYMMDD
            3. 写入 ClickHouse: INSERT INTO vos_cdr_ods VALUES (...)
            4. 更新同步点位
            5. 记录同步日志（成功条数/失败数/耗时）
```

**同步日志表：**

```sql
CREATE TABLE `cdr_sync_log`
(
    `id`            bigint       NOT NULL AUTO_INCREMENT,
    `instance_id`   bigint       NOT NULL COMMENT 'VOS 实例 ID',
    `src_table`     varchar(50)  NOT NULL COMMENT '源表名(e_cdr/e_cdr_20260118...)',
    `sync_type`     tinyint      NOT NULL DEFAULT 1 COMMENT '同步类型(1=增量 2=全量回溯)',
    `start_time`    datetime     NOT NULL COMMENT '开始时间',
    `end_time`      datetime             COMMENT '结束时间',
    `total_count`   int          DEFAULT 0 COMMENT '读取总行数',
    `success_count` int          DEFAULT 0 COMMENT '成功写入行数',
    `fail_count`    int          DEFAULT 0 COMMENT '失败行数',
    `status`        tinyint      NOT NULL DEFAULT 0 COMMENT '状态(0=进行中 1=成功 2=失败)',
    `error_msg`     text                  COMMENT '错误信息',
    `creator`       varchar(64),
    `create_time`   datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_instance_id` (`instance_id`),
    KEY `idx_src_table` (`src_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CDR 同步日志';
```

**前端页面：**
- 菜单路径：`话单同步`
- 功能：显示各实例最近同步记录、手动触发同步、同步进度展示

#### 1.3 客户管理基础版

**功能描述：** 映射 VOS `e_customer` 表，提供客户列表/搜索/详情（余额、费率组等）。数据来源：MySQL 维度镜像（从 VOS e_customer 定期同步）。

**后端设计：**

```sql
-- VOS e_customer 维度镜像（自建业务表，定期从 VOS 全量覆盖）
CREATE TABLE `vos_customer_mirror`
(
    `id`                       int          NOT NULL AUTO_INCREMENT,
    `vos_id`                   int          NOT NULL COMMENT 'VOS 原始 ID',
    `account`                  varchar(255)         COMMENT '客户账号',
    `name`                     varchar(255)         COMMENT '客户名称',
    `type`                     int          DEFAULT NULL COMMENT '类型',
    `money`                    double       DEFAULT 0 COMMENT '余额',
    `limitmoney`               double       DEFAULT 0 COMMENT '额度上限',
    `todayconsumption`         double       DEFAULT 0 COMMENT '今日消费',
    `locktype`                 int          DEFAULT 0 COMMENT '锁定类型',
    `status`                   int          DEFAULT 0 COMMENT '状态(0=正常 1=停用)',
    `feerategroup_id`          int          DEFAULT 0 COMMENT '关联费率组 ID',
    `memo`                     varchar(255)         COMMENT '备注',
    `last_sync_time`           datetime              COMMENT '最后同步时间',
    -- ruoyi 公共字段省略...
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_vos_id` (`vos_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='VOS 客户维度镜像';
```

**API 设计：**

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/admin-api/vos/customer/page` | 分页列表（支持 account/name/status 搜索） |
| GET | `/admin-api/vos/customer/get?id=` | 客户详情含余额 |
| PUT | `/admin-api/vos/customer/update` | 编辑备注/状态等（不直接改余额） |
| POST | `/admin-api/vos/customer/sync-trigger` | 手动触发从 VOS 同步 |

**前端页面：**
- 菜单路径：`客户管理 > 客户列表`
- 列表字段：账号(account) / 名称(name) / 类型(type) / 余额(money) / 额度(limitmoney) / 今日消费(todayconsumption) / 状态(status) / 最后同步时间
- 详情弹窗：完整信息 + 关联费率组 + 最近消费趋势图

#### 1.4 供应商入库

**功能描述：** SIP 供应商（上游线路商）信息管理。纯自建业务表，无 VOS 原表依赖。

```sql
CREATE TABLE `vos_supplier`
(
    `id`            bigint   NOT NULL AUTO_INCREMENT,
    `name`          varchar(100) NOT NULL COMMENT '供应商名称',
    `contact_name`  varchar(50)  COMMENT '联系人',
    `contact_phone` varchar(20)  COMMENT '联系电话',
    `email`         varchar(100) COMMENT '邮箱',
    `status`        tinyint   DEFAULT 1 COMMENT '状态(0=停用 1=合作中)',
    `rate_type`     tinyint   DEFAULT 1 COMMENT '结算方式(1=预付费 2=后付费)',
    `balance`       decimal(12,2) DEFAULT 0 COMMENT '账户余额',
    `remark`        varchar(500) COMMENT '备注',
    -- ruoyi 公共字段省略...
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商信息';
```

#### 1.5 线路仓库（网关映射）

**功能描述：** 映射 VOS `e_gatewaymapping`，管理 SIP 中继线路。包含网关名/IP/容量/优先级/所属客户等。

**后端：** 基于 `e_gatewaymapping` 结构建镜像表 `vos_gateway_mirror`，字段对齐（name/locktype/calllevel/capacity/priority/registertype/remoteips/gatewaygroups/memo/customer_id）。

**API：** 标准 CRUD + 按 customer_id/gatewaygroup 筛选。

**前端页面：** 线路列表 + 关联客户筛选 + 在线/离线状态标识（通过定时探测 remoteips 可达性）。

#### 1.6 黑名单管理

**功能描述：** 号码黑名单增删查。支持手动录入和外部源导入。

```sql
CREATE TABLE `vos_blacklist`
(
    `id`          bigint      NOT NULL AUTO_INCREMENT,
    `number`      varchar(32)  NOT NULL COMMENT '号码',
    `type`        tinyint     NOT NULL DEFAULT 1 COMMENT '类型(1=主叫黑 2=被叫黑 3=全局)',
    `source`      tinyint     DEFAULT 1 COMMENT '来源(1=手动 2=平台对接导入)',
    `reason`      varchar(200) COMMENT '拉黑原因',
    `effect_time` datetime    NOT NULL COMMENT '生效时间',
    `expire_time` datetime            COMMENT '过期时间(NULL=永久)',
    `status`      tinyint     DEFAULT 1 COMMENT '状态(0=已解除 1=生效中)',
    -- ruoyi 公共字段省略...
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_number_type` (`number`, `type`, `effect_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='号码黑名单';
```

### Phase 2：核心业务深化

#### 2.1 统计报表（ClickHouse 分析层）

**功能概述：** 利用 ClickHouse DWS 聚合能力，输出多维度统计报表。这是相比原版 IVS 的**核心竞争力**——原版如果基于 MySQL 直接查 e_cdr，在大数据量下性能会远不如我们。

**DWS 层设计扩展（在已有 `vos_cdr_daily_customer` 基础上补充）：**

```sql
-- DWS 2: 每日每网关汇总
CREATE TABLE IF NOT EXISTS vos_cdr_daily_gateway
(
    stat_date           Date,
    gatewayid           String,
    gatewayname         Nullable(String),
    call_count          UInt64,
    connected_count     UInt64,
    total_feetime       UInt64,
    total_fee           Float64,
    asr                 Nullable(Float64),
    avg_pdd             Nullable(Float64)
)
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(stat_date)
ORDER BY (stat_date, gatewayid);

-- DWS 3: 每日全局汇总
CREATE TABLE IF NOT EXISTS vos_cdr_daily_global
(
    stat_date           Date,
    call_count          UInt64,
    connected_count     UInt64,
    total_feetime       UInt64,
    total_fee           Float64,
    total_tax           Float64,
    total_suitefee      Float64,
    total_agentfee      Float64,
    unique_callers      UInt64,
    unique_callees      UInt64
)
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(stat_date)
ORDER BY (stat_date);

-- DWS 4: 小时粒度话务分布（用于热力图/折线图）
CREATE TABLE IF NOT EXISTS vos_cdr_hourly
(
    stat_date           Date,
    stat_hour           UInt8,
    call_count          UInt64,
    connected_count     UInt64,
    total_fee           Float64,
    avg_pdd             Nullable(Float64)
)
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(stat_date)
ORDER BY (stat_date, stat_hour);
```

**前端报表页面规划：**

| 报表页面 | 数据源 | 图表类型 | 说明 |
|----------|--------|---------|------|
| 运营看板首页 | DWS global + hourly + daily_customer | KPI 卡片 + 趋势折线图 + TopN 排行 | 总通话量/费用/ASR/平均时长 |
| 客户话务报表 | DWS daily_customer | 表格 + 柱状图 | 各客户每日通话/费用明细 |
| 网关质量报表 | DWS daily_gateway | 表格 + 散点图(PDD vs ASR) | 各网关接通率/PDD/费用 |
| 话务热力图 | DWS hourly | 日历热力图 | 按小时分布的通话密度 |
| 费用趋势分析 | DWS global + daily_customer | 双轴折线图 | 收入/成本趋势对比 |
| 挂断原因分析 | ODS vos_cdr_ods | 饼图/帕累托图 | endreason 分布，定位主要失败原因 |

#### 2.2 主叫管理 / 被叫管理 / 碳通管理

**功能概述：** SIP 路由策略配置。
- **主叫管理**：主叫号码前缀路由规则（哪个主叫走哪条线路）
- **被叫管理**：被叫落地路由（被叫号码匹配规则 → 选择出口网关）
- **碳通管理**：碳路由（主叫侧特殊路由策略，如改号/前缀添加）

**数据设计：**

```sql
-- 主叫路由规则
CREATE TABLE `vos_caller_route`
(
    `id`            bigint   NOT NULL AUTO_INCREMENT,
    `name`          varchar(100) NOT NULL COMMENT '规则名称',
    `caller_prefix` varchar(32)  NOT NULL COMMENT '主叫号码前缀匹配',
    `match_mode`    tinyint   DEFAULT 1 COMMENT '匹配模式(1=精确前缀 2=正则)',
    `gateway_id`    bigint       COMMENT '指定出口网关 ID',
    `rewrite_rule`  varchar(200) COMMENT '号码改写规则',
    `priority`      int      DEFAULT 0 COMMENT '优先级(数值越小越高)',
    `enabled`       bit(1)   DEFAULT b'1' COMMENT '是否启用',
    -- ruoyi 公共字段省略...
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='主叫路由规则';

-- 被叫路由规则
CREATE TABLE `vos_callee_route`
(
    `id`            bigint   NOT NULL AUTO_INCREMENT,
    `name`          varchar(100) NOT NULL COMMENT '规则名称',
    `callee_prefix` varchar(32)  NOT NULL COMMENT '被叫号码前缀匹配',
    `match_mode`    tinyint   DEFAULT 1 COMMENT '匹配模式(1=精确前缀 2=正则 3=号段)',
    `gateway_id`    bigint       COMMENT '指定出口网关 ID',
    `rewrite_rule`  varchar(200) COMMENT '号码改写规则',
    `strip_prefix`  varchar(10)  COMMENT '剥离前缀',
    `add_prefix`    varchar(10)  COMMENT '添加前缀',
    `priority`      int      DEFAULT 0 COMMENT '优先级',
    `enabled`       bit(1)   DEFAULT b'1',
    -- ruoyi 公共字段省略...
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='被叫路由规则';
```

> **注意：** 这些路由规则是运营平台的**配置管理**功能，实际路由执行仍在 VOS3000 服务器端完成。本中台负责规则的 CRUD 和可视化展示，可选地通过 VOS API 推送配置变更到 VOS。

#### 2.3 财务管理

**功能概述：** 基于话单费用的财务操作。

| 子功能 | 说明 | 数据来源 |
|--------|------|---------|
| 充值管理 | 手动为客户余额充值 | 操作 vos_customer_mirror.money |
| 账单明细 | 按客户/时间段查询费用明细 | ClickHouse vos_cdr_ods GROUP BY customeraccount |
| 结算报表 | 代理/供应商费用结算 | DWS daily_customer.total_agentfee |
| 消费流水 | 每笔通话的费用明细 | ODS vos_cdr_ods 查询 |
| 余额预警 | 余额低于阈值自动提醒 | 定时扫描 vos_customer_mirror.money |

**关键设计：充值记录表**

```sql
CREATE TABLE `vos_recharge_record`
(
    `id`            bigint       NOT NULL AUTO_INCREMENT,
    `customer_id`   bigint       NOT NULL COMMENT '客户 ID',
    `customer_account` varchar(255) NOT NULL COMMENT '客户账号',
    `amount`        decimal(12,2) NOT NULL COMMENT '充值金额(正=充值 负=扣减)',
    `balance_before` decimal(12,2) NOT NULL COMMENT '操作前余额',
    `balance_after`  decimal(12,2) NOT NULL COMMENT '操作后余额',
    `type`          tinyint     NOT NULL COMMENT '类型(1=人工充值 2=系统调整 3=消费扣除)',
    `pay_method`    tinyint     DEFAULT NULL COMMENT '支付方式(1=现金 2=转账 3=微信 4=支付宝)',
    `trade_no`      varchar(64)         COMMENT '交易流水号',
    `operator`      varchar(64)  NOT NULL COMMENT '操作人',
    `remark`        varchar(200) COMMENT '备注',
    `create_time`   datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_customer_id` (`customer_id`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='充值/余额变动记录';
```

#### 2.4 风控管理

**功能概述：** 基于实时话单数据的风控策略。

| 子功能 | 说明 |
|--------|------|
| 风控规则 | 配置风控阈值（如：单客户每小时最大通话次数、单次最大费用、异常目的地检测） |
| 风控事件 | 触发风控规则时生成的事件记录 |
| 异常呼叫检测 | 短时高频呼叫 / 高费用目的地 / 非 ASR 时段的异常活动 |

```sql
-- 风控规则
CREATE TABLE `vos_risk_rule`
(
    `id`            bigint   NOT NULL AUTO_INCREMENT,
    `name`          varchar(100) NOT NULL COMMENT '规则名称',
    `rule_type`     tinyint  NOT NULL COMMENT '规则类型(1=频次限制 2=金额限制 3=目的地限制 4=时段限制)',
    `metric`        varchar(50)  NOT NULL COMMENT '监控指标(call_count/total_fee/avg_duration...)',
    `threshold`     decimal(12,2) NOT NULL COMMENT '阈值',
    `window_minutes` int      DEFAULT 60 COMMENT '统计窗口(分钟)',
    `action`        tinyint   DEFAULT 1 COMMENT '触发动作(1=仅告警 2=停用客户 3=加入黑名单)',
    `enabled`       bit(1)   DEFAULT b'1',
    -- ruoyi 公共字段省略...
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='风控规则';

-- 风控事件
CREATE TABLE `vos_risk_event`
(
    `id`            bigint       NOT NULL AUTO_INCREMENT,
    `rule_id`       bigint       NOT NULL COMMENT '触发的规则 ID',
    `customer_account` varchar(255) NOT NULL COMMENT '涉事客户',
    `metric_value`  decimal(12,2) NOT NULL COMMENT '实际值',
    `threshold`     decimal(12,2) NOT NULL COMMENT '阈值',
    `event_time`    datetime     NOT NULL COMMENT '发生时间',
    `status`        tinyint      DEFAULT 0 COMMENT '处理状态(0=待处理 1=已忽略 2=已处理)',
    `handler`       varchar(64)          COMMENT '处理人',
    `handle_time`   datetime            COMMENT '处理时间',
    `handle_remark` varchar(500)        COMMENT '处理备注',
    `create_time`   datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_rule_id` (`rule_id`),
    KEY `idx_customer` (`customer_account`),
    KEY `idx_event_time` (`event_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='风控事件';
```

#### 2.5 号码管理

**功能概述：** 号码池资源管理。

```sql
CREATE TABLE `vos_number_pool`
(
    `id`            bigint       NOT NULL AUTO_INCREMENT,
    `number`        varchar(32)  NOT NULL COMMENT '号码',
    `pool_group`    varchar(50)  NOT NULL COMMENT '号码池分组',
    `owner_type`    tinyint      DEFAULT 1 COMMENT '归属类型(1=自有 2=租用)',
    `owner_id`      bigint       COMMENT '归属客户/供应商 ID',
    `status`        tinyint      DEFAULT 1 COMMENT '状态(1=空闲 2=占用 3=停用 4=回收)',
    `bind_gateway`  bigint       COMMENT '绑定网关',
    `cost_monthly`  decimal(10,2) DEFAULT 0 COMMENT '月租成本',
    `activate_time` datetime            COMMENT '激活时间',
    `expire_time`   datetime            COMMENT '到期时间',
    `remark`        varchar(200),
    -- ruoyi 公共字段省略...
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_number` (`number`),
    KEY `idx_pool_group` (`pool_group`),
    KEY `idx_owner` (`owner_type`, `owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='号码池';
```

#### 2.6 预警管理

**功能概述：** 基于阈值的告警通知系统。

| 能力 | 说明 |
|------|------|
| 告警规则 | 配置监控指标 + 阈值 + 通知方式（站内信/邮件/企微/webhook） |
| 告警记录 | 所有触发过的告警历史 |
| 通知渠道 | 支持邮件 / 企业微信 webhook / 站内消息 |
| 告警升级 | 未处理告警自动升级（如 30min 无处理 → 通知上级） |

#### 2.7 对接管理子模块

**功能概述：** 与外部系统的 API 对接配置管理。

| 子模块 | 说明 | 复杂度 |
|--------|------|--------|
| 查平台对接 | 配置第三方平台（如号码标记查询平台）的 API 地址/密钥/参数模板 | 中 |
| 黑名单对接 | 配置外部黑名单数据源的拉取规则（URL/Cron/解析逻辑） | 低 |
| 号码写回对接 | 配置标记结果回写到外部系统的接口 | 低 |
| ASR 对接 | 配置 ASR 服务商（语音转文字）的连接参数 | 中（Phase 3） |

**通用对接配置表：**

```sql
CREATE TABLE `vos_api_connector`
(
    `id`            bigint       NOT NULL AUTO_INCREMENT,
    `connector_type` varchar(50) NOT NULL COMMENT '连接器类型(blacklist_check/asr/platform_query/number_writeback)',
    `name`          varchar(100) NOT NULL COMMENT '连接器名称',
    `base_url`      varchar(500) NOT NULL COMMENT 'API 基地址',
    `auth_type`     tinyint      DEFAULT 1 COMMENT '鉴权方式(1=None 2=API Key 3=OAuth2 4=Basic)',
    `auth_config`   text                 COMMENT '鉴权参数(JSON)',
    `request_template` text               COMMENT '请求模板(JSON/参数映射)',
    `response_parse`  text               COMMENT '响应解析规则',
    `cron_expr`     varchar(50)          COMMENT '定时拉取 Cron 表达式(NULL=手动)',
    `status`        tinyint      DEFAULT 1 COMMENT '状态(0=禁用 1=启用)',
    `last_exec_time` datetime            COMMENT '最后执行时间',
    `last_result`   varchar(200)         COMMENT '最后执行结果',
    -- ruoyi 公共字段省略...
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='外部 API 连接器配置';
```

### Phase 3：增值功能（后期迭代）

#### 3.1 ASR 质检

**前置条件：** 需要 ASR 服务商对接 + 录音文件访问能力。

**功能：**
- 录音文件列表与播放
- ASR 转文字结果展示
- 关键词命中检测
- 质检评分与标注
- 不合格录音工单流转

**技术要点：**
- 录音文件通常存储在 VOS 服务器或对象存储（MinIO/S3/OSS）
- ASR 服务需额外采购（阿里云 ASR / 讯飞 / 自建 Whisper）
- 此模块独立性强，不影响其他模块开发

#### 3.2 号码标记对接

**功能：** 对接外部号码标记平台（如 114 / 腾讯手机管家 / 百度号码标注），批量查询号码标记状态（骚扰/诈骗/快递/外卖等分类）。

**实现方式：** 通过 `vos_api_connector` 配置多个标记源，定时批量查询并缓存结果。

---

## 四、数据库总览

### 4.1 全量表清单

| 序号 | 表名 | 所属域 | 存储 | 来源 | 阶段 |
|------|------|--------|------|------|------|
| 0 | system_* (约 80 张) | 系统管理 | MySQL | ruoyi 内置 | P0 已有 |
| 1 | **vos_instance** | 对接管理 | MySQL | 自建 | **Phase 1** |
| 2 | **cdr_sync_log** | 话单同步 | MySQL | 自建 | **Phase 1** |
| 3 | **vos_customer_mirror** | 客户管理 | MySQL | VOS e_customer 镜像 | **Phase 1** |
| 4 | **vos_supplier** | 供应商 | MySQL | 自建 | **Phase 1** |
| 5 | **vos_gateway_mirror** | 线路仓库 | MySQL | VOS e_gatewaymapping 镜像 | **Phase 1** |
| 6 | **vos_blacklist** | 黑名单 | MySQL | 自建 | **Phase 1** |
| 7 | **vos_caller_route** | 主叫管理 | MySQL | 自建 | Phase 2 |
| 8 | **vos_callee_route** | 被叫管理 | MySQL | 自建 | Phase 2 |
| 9 | **vos_recharge_record** | 财务 | MySQL | 自建 | Phase 2 |
| 10 | **vos_risk_rule** | 风控 | MySQL | 自建 | Phase 2 |
| 11 | **vos_risk_event** | 风控 | MySQL | 自建 | Phase 2 |
| 12 | **vos_number_pool** | 号码管理 | MySQL | 自建 | Phase 2 |
| 13 | **vos_api_connector** | 对接管理 | MySQL | 自建 | Phase 2 |
| 14 | **vos_cdr_ods** | 话单 ODS | ClickHouse | VOS e_cdr 全量镜像 | **Phase 1** (已有 DDL) |
| 15 | **vos_customer_ods** | 客户 ODS | ClickHouse | VOS e_customer 镜像 | **Phase 1** (已有 DDL) |
| 16 | **vos_gatewaymapping_ods** | 网关 ODS | ClickHouse | VOS e_gatewaymapping 镜像 | **Phase 1** (已有 DDL) |
| 17 | **vos_feerate_ods** | 费率 ODS | ClickHouse | VOS e_feerate 镜像 | **Phase 1** (已有 DDL) |
| 18 | **vos_cdr_daily_customer** | 客户日报 DWS | ClickHouse | 聚合 | Phase 2 (已有 DDL) |
| 19 | **vos_cdr_daily_gateway** | 网关日报 DWS | ClickHouse | 聚合 | Phase 2 (本方案新建) |
| 20 | **vos_cdr_daily_global** | 全局日报 DWS | ClickHouse | 聚合 | Phase 2 (本方案新建) |
| 21 | **vos_cdr_hourly** | 小时粒度 DWS | ClickHouse | 聚合 | Phase 2 (本方案新建) |

### 4.2 ER 关系（核心实体）

```
vos_instance (1) ─────< (N) cdr_sync_log
     │                        │
     │  同步源                │  同步目标
     ▼                        ▼
[VOS MySQL] ──BatchSource──> [ClickHouse]
  e_cdr                         vos_cdr_ods ──聚合──> DWS(4张)
  e_customer                    vos_customer_ods ──> vos_customer_mirror(MySQL)
  e_gatewaymapping              vos_gatewaymapping_ods ──> vos_gateway_mirror(MySQL)
  e_feerate                     vos_feerate_ods

vos_customer_mirror (1) ──< (N) vos_recharge_record
vos_customer_mirror (1) ──< (N) vos_risk_event
vos_gateway_mirror  (1) ──< (N) vos_caller_route ──> gateway_id
vos_gateway_mirror  (1) ──< (N) vos_callee_route ──> gateway_id
vos_blacklist      (M:N) ──> 号码
vos_number_pool    ──> owner_id -> customer / supplier
vos_api_connector  (1) ──< (N) 外部调用日志
```

---

## 五、前端页面结构（yudao-ui-admin-vben 菜单树）

### 5.1 菜单层级设计

```
📁 工作台                              （Dashboard 首页，KPI 卡片 + 快捷入口）
📁 话务查询                            （话单明细查询，条件筛选 + 导出）
📁 VOS管理                             （多实例配置，截图页面 ★）
📁 话单同步                            （同步状态 + 手动触发 + 日志）
📁 业务资源
   📄 供应商入库                        （CRUD + 联系方式）
   📄 线路仓库                          （网关列表 + 状态 + 容量）
   📄 号码管理                          （号码池 + 占用情况）
   📄 号码标记                          （标记查询 + 来源展示）
📁 客户管理
   📄 客户列表                          （客户 CRUD + 余额 + 费率组）
   📄 财务管理
      📄 充值管理                       （充值记录 + 余额调整）
      📄 账单明细                       （按客户/日期的费用明细）
      📄 结算报表                       （代理/供应商结算汇总）
   📁 风控管理
      📄 风控规则                       （阈值配置）
      📄 风控事件                       （事件列表 + 处理）
   📄 统计报表
      📄 运营看板                       （KPI + 趋势 + 排行）
      📄 客户话务报表                   （按客户维度）
      📄 网关质量报表                   （按网关维度）
      📄 话务热力图                     （小时 x 星期）
      📄 费用趋势分析                   （收入/成本对比）
      📄 挂断原因分析                   （endreason 分布）
   📄 ASR 质检                          （Phase 3）
   📄 预警管理
      📄 告警规则                       （配置）
      📄 告警记录                       （历史）
📁 路由管理
   📄 主叫管理                          （主叫路由规则）
   📄 被叫管理                          （被叫落地路由）
   📄 碳通管理                          （碳路由策略）
📁 对接管理
   📄 VOS 管理                          （同上，快捷入口）
   📄 平台对接                          （第三方 API 连接器配置）
   📄 黑名单对接                        （外部黑名单源配置）
   📄 号码写回对接                      （回写接口配置）
   📄 ASR 对接                          （Phase 3）
📁 系统管理                            （ruoyi 内置，不改）
```

### 5.2 页面组件规范

| 场景 | 推荐组件 | 说明 |
|------|---------|------|
| 列表页 | `VbenVxeGrid` 或 `a-table` + 分页 | ruoyi 前端标准 CRUD 模板 |
| 搜索栏 | `a-form` + `a-input-search` + `a-select` + `a-date-picker` | 顶部内联搜索 |
| 新增/编辑 | `vben-modal` + `a-form` | 弹窗表单 |
| 详情 | `a-descriptions` | 只读展示 |
| KPI 卡片 | 自定义 Card + 大数字 | 运营看板 |
| 折线图/柱状图 | ECharts（Vben 内置） | 统计报表 |
| 热力图 | ECharts calendar | 话务分布 |
| 状态标签 | `a-tag` (color=success/warning/error) | 启用/停用/异常 |
| 操作列 | `TableAction`(内置) | 编辑/删除/更多 |

---

## 六、API 命名规范

所有业务 API 统一挂在 `/admin-api/vos/` 前缀下：

```
/admin-api/vos/
├── instance/          # VOS 实例管理
│   ├── POST   /create
│   ├── PUT    /update
│   ├── DELETE /delete
│   ├── GET    /get
│   └── GET    /page
├── sync/              # 话单同步
│   ├── POST   /trigger              # 手动触发同步
│   ├── GET    /status               # 当前同步状态
│   └── GET    /log/page             # 同步日志分页
├── customer/          # 客户管理
│   ├── GET    /page
│   ├── GET    /get
│   ├── PUT    /update
│   └── POST   /sync-trigger
├── supplier/          # 供应商
│   ├── POST   /create
│   ├── PUT    /update
│   ├── DELETE /delete
│   ├── GET    /get
│   └── GET    /page
├── gateway/           # 线路/网关
│   ├── GET    /page
│   ├── GET    /get
│   ├── GET    /mirror-sync          # 触发网关镜像同步
│   └── GET    /status-check         # 探测网关连通性
├── blacklist/         # 黑名单
│   ├── POST   /create
│   ├── DELETE /delete
│   ├── GET    /page
│   └── POST   /batch-import         # 批量导入
├── cdr/               # 话单查询
│   ├── GET    /page                  # 从 ClickHouse 分页查询
│   ├── GET    /detail/flowno={id}    # 单条话单详情
│   ├── GET    /export               # 导出 Excel
│   └── GET    /statistics/summary    # 汇总统计
├── report/            # 报表
│   ├── GET    /dashboard             # 看板数据
│   ├── GET    /daily-customer        # 客户日报(DWS)
│   ├── GET    /daily-gateway         # 网关日报(DWS)
│   ├── GET    /hourly                # 小时粒度(DWS)
│   └── GET    /end-reason            # 挂断原因分布
├── finance/           # 财务
│   ├── POST   /recharge              # 充值
│   ├── GET    /recharge/log/page     # 充值记录
│   ├── GET    /bill/detail/page      # 账单明细
│   └── GET    /settlement            # 结算汇总
├── risk/              # 风控
│   ├── POST   /rule/create
│   ├── PUT    /rule/update
│   ├── DELETE /rule/delete
│   ├── GET    /rule/page
│   ├── GET    /event/page
│   └── PUT    /event/handle          # 处理风控事件
├── route/             # 路由
│   ├── caller/*                           # 主叫路由 CRUD
│   └── callee/*                           # 被叫路由 CRUD
├── connector/         # 对接
│   ├── POST   /create
│   ├── PUT    /update
│   ├── DELETE /delete
│   ├── GET    /page
│   └── POST   /test-connect          # 测试连接
└── number/            # 号码
    ├── POST   /pool/create
    ├── PUT    /pool/update
    ├── GET    /pool/page
    └── GET    /mark/query             # 号码标记查询
```

---

## 七、开发工作量估算

| Phase | 内容 | 后端 | 前端 | 预计工日 |
|-------|------|------|------|---------|
| **Phase 1** | VOS 管理 + 话单同步 + 客户管理 + 供应商 + 线路 + 黑名单 | 6 个 Controller/Service/Mapper | 6 个页面 + Dashboard | **8~12 天** |
| **Phase 2** | 统计报表(6 个) + 路由(3) + 财务(4) + 风控(2) + 号码 + 预警 + 对接 | ~18 个 Controller | ~18 个页面 + ECharts 图表 | **15~25 天** |
| **Phase 3** | ASR 质检 + 号码标记对接 | ~4 个 Controller | ~4 个页面 + 音频播放器 | **8~12 天** |
| **合计** | | ~28 个 Controller | ~28 个页面 | **31~49 天** |

> 注：ruoyi-vue-pro 代码生成器可将单个 CRUD 模块（Controller+Service+Mapper+前端页面）压缩到 **0.5 天/个**，上述估算已考虑此加速因素。Phase 1 的 6 个基础 CRUD 通过代码生成器可在 **3 天内** 完成骨架，剩余时间花在话单同步逻辑和 ClickHouse 查询优化上。

---

## 八、相比原版 IVIS 的优势

| 维度 | 原 IVIS | 我们的新系统 | 提升点 |
|------|---------|-------------|--------|
| 数据采集 | VOS Web API（受限/限流） | **直连 VOS MySQL + ClickHouse** | 全字段保真 + 高吞吐 |
| 查询性能 | MySQL 单表（亿级行卡顿） | **ClickHouse 列存 + 分区** | 亿级秒级响应 |
| 分析深度 | 基础汇总 | **DWS 多维聚合 + ECharts 可视化** | 热力图/帕累托/趋势分析 |
| 架构规范 | 未知（可能手搓） | **ruoyi-vue-pro 成熟规范** | RBAC/代码生成/审计日志/多租户 |
| UI 框架 | Vue2 + Element UI（旧） | **Vue3.5 + AntDV4 + Vben5** | 更现代/更好的 TS 支持 |
| 可维护性 | 单体紧耦合 | **模块化 + 可插拔采集源** | 易扩展新 VOS 实例/新数据源 |
| 运维能力 | 基础 CRUD | **同步监控 + 风控 + 预警** | 主动发现异常 |

---

## 九、风险与缓解

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| VOS MySQL 只读权限不足 | 无法直连 | 协调 DBA 开通只读账号 / 使用 Canal 从库 |
| VOS 表结构变更 | 同步字段缺失 | _sync_ts + src_table 字段追踪来源；定期校验 schema |
| ClickHouse 单点故障 | 分析不可用 | 建议生产环境 CH 副本集（ReplicatedMergeTree） |
| 51 日表回溯耗时 | 首次同步慢 | 分批并行 + 进度可视化 + 断点续传 |
| ASR 服务成本 | Phase 3 预算超支 | 独立 Phase，按需启动，不影响 MVP |

---

## 十、下一步行动

确认本方案后，建议按以下顺序立即开工：

1. **创建 `yudao-module-vos` 模块目录结构**（参照 ruoyi-vue-pro 现有 module-system 的包约定）
2. **建表**：执行 `vos_instance` + `cdr_sync_log` + `vos_customer_mirror` + `vos_supplier` + `vos_gateway_mirror` + `vos_blacklist` 的 MySQL DDL
3. **用代码生成器**：针对以上 6 张表生成 CRUD 全套代码（Java + Vue）
4. **实现 VOS 管理页面**：作为第一个跑通的前后端功能
5. **实现 BatchSource 同步核心**：JDBC 连 VOS MySQL → 批量读 e_cdr → 写 ClickHouse
6. **前端联调验证**：VOS 管理页 CRUD + 同步日志展示 + 客户列表页
