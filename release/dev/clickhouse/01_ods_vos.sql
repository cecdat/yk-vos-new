-- =====================================================================
-- YK-VOS 数据分析中台 — ClickHouse ODS 层
-- 数据源：VOS3000 生产库 e_cdr / e_customer / e_gatewaymapping / e_feerate
-- 说明：e_cdr 与 e_cdr_YYYYMMDD 完全同构，统一入 vos_cdr_ods，
--       以 flowno 去重(ReplacingMergeTree)，分区按通话日。
--       e_customer / e_gatewaymapping / e_feerate 为维度表镜像。
-- =====================================================================

-- 1) 话单原始镜像（计费级，全字段）
-- 多节点：vos_id 标识来源 VOS 实例；flowno 在单节点内唯一、跨节点不唯一，
--   故去重键为 (vos_id, flowno)，分区按月（与节点数解耦，避免分区爆炸）。
CREATE TABLE IF NOT EXISTS vos_cdr_ods
(
    vos_id                 LowCardinality(String),
    flowno                 Int64,
    id                     Int32,
    callere164             Nullable(String),
    calleraccesse164       Nullable(String),
    calleee164             Nullable(String),
    calleeaccesse164       Nullable(String),
    callerip                Nullable(String),
    callerrtpip            Nullable(String),
    callercodec            Nullable(String),
    callergatewayid        Nullable(String),
    callerproductid        Nullable(String),
    callertogatewaye164   Nullable(String),
    callertype             Nullable(Int32),
    calleeip               Nullable(String),
    calleertpip            Nullable(String),
    calleecodec            Nullable(String),
    calleegatewayid        Nullable(String),
    calleeproductid        Nullable(String),
    calleetogatewaye164   Nullable(String),
    calleetype             Nullable(Int32),
    billingmode            Nullable(Int32),
    calllevel              Nullable(Int32),
    agentfeetime           Nullable(Int32),
    starttime              Nullable(Int64),
    stoptime               Nullable(Int64),
    callerpdd              Nullable(Int32),
    calleepdd              Nullable(Int32),
    holdtime               Nullable(Int32),
    callerareacode         Nullable(String),
    feetime                Nullable(Int32),
    fee                    Nullable(Float64),
    tax                    Nullable(Float64),
    suitefee               Nullable(Float64),
    suitefeetime           Nullable(Int32),
    incomefee              Nullable(Float64),
    incometax              Nullable(Float64),
    customeraccount        Nullable(String),
    customername           Nullable(String),
    calleeareacode         Nullable(String),
    agentfee               Nullable(Float64),
    agenttax               Nullable(Float64),
    agentsuitefee          Nullable(Float64),
    agentsuitefeetime      Nullable(Int32),
    agentaccount           Nullable(String),
    agentname              Nullable(String),
    softswitchname         Nullable(String),
    softswitchcallid        Nullable(Int64),
    callercallid           Nullable(String),
    calleroriginalcallid    Nullable(String),
    calleecallid           Nullable(String),
    calleroriginalinfo      Nullable(String),
    rtpforward             Nullable(Int32),
    enddirection           Nullable(Int32),
    endreason              Nullable(Int32),
    billingtype            Nullable(Int32),
    cdrlevel               Nullable(Int32),
    agentcdr_id            Nullable(Int32),
    sipreasonheader        Nullable(String),
    recordstarttime        Nullable(Int64),
    transactionid          Nullable(String),
    flownofirst            Nullable(Int64),
    additional             Nullable(String),
    dynamicValue           Nullable(String),
    _sync_ts               DateTime DEFAULT now(),
    _src_table             LowCardinality(String) DEFAULT 'e_cdr'
)
ENGINE = ReplacingMergeTree(_sync_ts)
PARTITION BY toYYYYMM(toDateTime(coalesce(recordstarttime, 0)))
ORDER BY (vos_id, flowno)
SETTINGS index_granularity = 8192;

-- 2) 客户镜像（多节点：加 vos_id 去重键）
CREATE TABLE IF NOT EXISTS vos_customer_ods
(
    vos_id                   LowCardinality(String),
    id                       Int32,
    account                  Nullable(String),
    name                     Nullable(String),
    type                     Nullable(Int32),
    starttime                Nullable(Int64),
    lastupdatetime           Nullable(Int64),
    money                    Nullable(Float64),
    validtime                Nullable(Int64),
    locktype                 Nullable(Int32),
    status                   Nullable(Int32),
    limitmoney               Nullable(Float64),
    todayconsumption         Nullable(Float64),
    memo                     Nullable(String),
    feerategroup_id          Nullable(Int32),
    feerategroupprivate_id   Nullable(Int32),
    customer_id              Nullable(Int32),
    timezoneid               Nullable(String),
    _sync_ts                 DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_sync_ts)
ORDER BY (vos_id, id)
SETTINGS index_granularity = 8192;

-- 3) 网关映射镜像（多节点：加 vos_id 去重键）
CREATE TABLE IF NOT EXISTS vos_gatewaymapping_ods
(
    vos_id                   LowCardinality(String),
    id                       Int32,
    name                     Nullable(String),
    locktype                 Nullable(Int32),
    calllevel                Nullable(Int32),
    capacity                 Nullable(Int32),
    priority                 Nullable(Int32),
    registertype             Nullable(Int32),
    remoteips                Nullable(String),
    rtpforwardtype           Nullable(Int32),
    gatewaygroups            Nullable(String),
    routinggatewaygroups     Nullable(String),
    memo                     Nullable(String),
    customer_id              Nullable(Int32),
    mbx_id                   Nullable(Int32),
    _sync_ts                 DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_sync_ts)
ORDER BY (vos_id, id)
SETTINGS index_granularity = 8192;

-- 4) 费率镜像（多节点：加 vos_id 去重键）
CREATE TABLE IF NOT EXISTS vos_feerate_ods
(
    vos_id         LowCardinality(String),
    id              Int32,
    feeprefix       Nullable(String),
    areacode        Nullable(String),
    locktype        Nullable(Int32),
    fee             Nullable(Float64),
    tax             Nullable(Float64),
    period          Nullable(Int32),
    ivrfee          Nullable(Float64),
    ivrperiod       Nullable(Int32),
    type            Nullable(Int32),
    feerategroup_id Nullable(Int32),
    _sync_ts        DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_sync_ts)
ORDER BY (vos_id, id)
SETTINGS index_granularity = 8192;

-- 5) DWS：每日每客户汇总（自建，比 VOS e_reportcustomerfee 更细，含接通维度）
--    ASR/接通率：以 endreason 判定（0/正常接通视为成功，具体枚举需结合 VOS 常量确认）
CREATE TABLE IF NOT EXISTS vos_cdr_daily_customer
(
    stat_date        Date,
    customeraccount  String,
    customername     Nullable(String),
    call_count       UInt64,
    connected_count  UInt64,
    total_feetime    UInt64,
    total_fee        Float64,
    total_tax        Float64,
    total_suitefee   Float64,
    total_agentfee   Float64,
    asr              Nullable(Float64),
    avg_pdd          Nullable(Float64)
)
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(stat_date)
ORDER BY (stat_date, customeraccount);

-- 6) DWS 填充示例（每日每客户）
INSERT INTO vos_cdr_daily_customer
SELECT
    toDate(toDateTime(coalesce(recordstarttime, 0)))              AS stat_date,
    customeraccount                                                AS customeraccount,
    any(customername)                                              AS customername,
    count()                                                        AS call_count,
    countIf(starttime > 0)                                         AS connected_count,
    sum(feetime)                                                  AS total_feetime,
    sum(fee)                                                       AS total_fee,
    sum(tax)                                                       AS total_tax,
    sum(suitefee)                                                  AS total_suitefee,
    sum(agentfee)                                                  AS total_agentfee,
    if(count() = 0, 0, countIf(starttime > 0) / count())          AS asr,
    avg(callerpdd)                                                 AS avg_pdd
FROM vos_cdr_ods
WHERE recordstarttime IS NOT NULL
GROUP BY stat_date, customeraccount;
