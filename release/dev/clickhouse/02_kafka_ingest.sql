-- =====================================================================
-- YK-VOS 测试环境 — Kafka 引擎表 + 物化视图（生产消费链路验证）
-- 用法：docker exec -i yk-clickhouse clickhouse-client -m < clickhouse/test/02_kafka_ingest.sql
-- 说明：本 DDL 与生产一致——agent 在生产是 Kafka 直推方；测试时由平台 pull_client
--       经本机 Kafka 中继（topic vos.cdr.live），ClickHouse 用原生 Kafka 引擎消费，
--       经 MV 把 Envelope.data(JSON) 解析进 vos_cdr_ods（多节点去重键 vos_id,flowno）。
--       仅测试服务器本机/容器网络可达（无公网端口），符合 §9 安全基线。
-- 依赖：clickhouse/ods/01_ods_vos.sql 已先执行（建好 vos_cdr_ods 等 ODS 表）。
-- 本文件由脚本依据 01_ods_vos.sql 自动生成，与 ODS 契约零漂移。
-- =====================================================================

-- 1) Kafka 引擎表：消费 vos.cdr.live，每行是 agent 的 model.Envelope(JSON)
DROP TABLE IF EXISTS vos_cdr_kafka;
CREATE TABLE IF NOT EXISTS vos_cdr_kafka
(
    schema_version String,
    op             String,
    vos_id         String,
    src_table      String,
    flowno         Int64,
    ts             DateTime64(3),
    data           String        -- Envelope.data：e_cdr 全字段 JSON
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'vos.cdr.live',
    kafka_group_name = 'yk_ch_consumer',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 1;

-- 2) 物化视图：解析 data JSON -> 落入 ODS（与实时推送同表，靠 (vos_id,flowno) 去重）
--    vos_id 来自 Envelope 顶层（Kafka 引擎表的顶层列），非 data JSON。
DROP TABLE IF EXISTS vos_cdr_mv;
CREATE MATERIALIZED VIEW IF NOT EXISTS vos_cdr_mv TO vos_cdr_ods AS
SELECT
    vos_id                          AS vos_id,
    JSONExtractInt(data, 'flowno')        AS flowno,
    JSONExtractInt(data, 'id')        AS id,
    JSONExtractString(data, 'callere164')     AS callere164,
    JSONExtractString(data, 'calleraccesse164')     AS calleraccesse164,
    JSONExtractString(data, 'calleee164')     AS calleee164,
    JSONExtractString(data, 'calleeaccesse164')     AS calleeaccesse164,
    JSONExtractString(data, 'callerip')     AS callerip,
    JSONExtractString(data, 'callerrtpip')     AS callerrtpip,
    JSONExtractString(data, 'callercodec')     AS callercodec,
    JSONExtractString(data, 'callergatewayid')     AS callergatewayid,
    JSONExtractString(data, 'callerproductid')     AS callerproductid,
    JSONExtractString(data, 'callertogatewaye164')     AS callertogatewaye164,
    JSONExtractInt(data, 'callertype')        AS callertype,
    JSONExtractString(data, 'calleeip')     AS calleeip,
    JSONExtractString(data, 'calleertpip')     AS calleertpip,
    JSONExtractString(data, 'calleecodec')     AS calleecodec,
    JSONExtractString(data, 'calleegatewayid')     AS calleegatewayid,
    JSONExtractString(data, 'calleeproductid')     AS calleeproductid,
    JSONExtractString(data, 'calleetogatewaye164')     AS calleetogatewaye164,
    JSONExtractInt(data, 'calleetype')        AS calleetype,
    JSONExtractInt(data, 'billingmode')        AS billingmode,
    JSONExtractInt(data, 'calllevel')        AS calllevel,
    JSONExtractInt(data, 'agentfeetime')        AS agentfeetime,
    JSONExtractInt(data, 'starttime')        AS starttime,
    JSONExtractInt(data, 'stoptime')        AS stoptime,
    JSONExtractInt(data, 'callerpdd')        AS callerpdd,
    JSONExtractInt(data, 'calleepdd')        AS calleepdd,
    JSONExtractInt(data, 'holdtime')        AS holdtime,
    JSONExtractString(data, 'callerareacode')     AS callerareacode,
    JSONExtractInt(data, 'feetime')        AS feetime,
    JSONExtractFloat(data, 'fee')      AS fee,
    JSONExtractFloat(data, 'tax')      AS tax,
    JSONExtractFloat(data, 'suitefee')      AS suitefee,
    JSONExtractInt(data, 'suitefeetime')        AS suitefeetime,
    JSONExtractFloat(data, 'incomefee')      AS incomefee,
    JSONExtractFloat(data, 'incometax')      AS incometax,
    JSONExtractString(data, 'customeraccount')     AS customeraccount,
    JSONExtractString(data, 'customername')     AS customername,
    JSONExtractString(data, 'calleeareacode')     AS calleeareacode,
    JSONExtractFloat(data, 'agentfee')      AS agentfee,
    JSONExtractFloat(data, 'agenttax')      AS agenttax,
    JSONExtractFloat(data, 'agentsuitefee')      AS agentsuitefee,
    JSONExtractInt(data, 'agentsuitefeetime')        AS agentsuitefeetime,
    JSONExtractString(data, 'agentaccount')     AS agentaccount,
    JSONExtractString(data, 'agentname')     AS agentname,
    JSONExtractString(data, 'softswitchname')     AS softswitchname,
    JSONExtractInt(data, 'softswitchcallid')        AS softswitchcallid,
    JSONExtractString(data, 'callercallid')     AS callercallid,
    JSONExtractString(data, 'calleroriginalcallid')     AS calleroriginalcallid,
    JSONExtractString(data, 'calleecallid')     AS calleecallid,
    JSONExtractString(data, 'calleroriginalinfo')     AS calleroriginalinfo,
    JSONExtractInt(data, 'rtpforward')        AS rtpforward,
    JSONExtractInt(data, 'enddirection')        AS enddirection,
    JSONExtractInt(data, 'endreason')        AS endreason,
    JSONExtractInt(data, 'billingtype')        AS billingtype,
    JSONExtractInt(data, 'cdrlevel')        AS cdrlevel,
    JSONExtractInt(data, 'agentcdr_id')        AS agentcdr_id,
    JSONExtractString(data, 'sipreasonheader')     AS sipreasonheader,
    JSONExtractInt(data, 'recordstarttime')        AS recordstarttime,
    JSONExtractString(data, 'transactionid')     AS transactionid,
    JSONExtractInt(data, 'flownofirst')        AS flownofirst,
    JSONExtractString(data, 'additional')     AS additional,
    JSONExtractString(data, 'dynamicValue')     AS dynamicValue,
    now()                              AS _sync_ts,
    src_table                          AS _src_table
FROM vos_cdr_kafka
WHERE startsWith(src_table, 'e_cdr');


-- 3) 维度表物化视图：客户维度镜像
DROP TABLE IF EXISTS vos_customer_mv;
CREATE MATERIALIZED VIEW IF NOT EXISTS vos_customer_mv TO vos_customer_ods AS
SELECT
    vos_id                          AS vos_id,
    JSONExtractInt(data, 'id')             AS id,
    JSONExtractString(data, 'account')     AS account,
    JSONExtractString(data, 'name')        AS name,
    JSONExtractInt(data, 'type')           AS type,
    JSONExtractInt(data, 'starttime')      AS starttime,
    JSONExtractInt(data, 'lastupdatetime') AS lastupdatetime,
    JSONExtractFloat(data, 'money')        AS money,
    JSONExtractInt(data, 'validtime')      AS validtime,
    JSONExtractInt(data, 'locktype')       AS locktype,
    JSONExtractInt(data, 'status')         AS status,
    JSONExtractFloat(data, 'limitmoney')   AS limitmoney,
    JSONExtractFloat(data, 'todayconsumption') AS todayconsumption,
    JSONExtractString(data, 'memo')        AS memo,
    JSONExtractInt(data, 'feerategroup_id') AS feerategroup_id,
    JSONExtractInt(data, 'feerategroupprivate_id') AS feerategroupprivate_id,
    JSONExtractInt(data, 'customer_id')    AS customer_id,
    JSONExtractString(data, 'timezoneid')  AS timezoneid,
    now()                              AS _sync_ts
FROM vos_cdr_kafka
WHERE src_table = 'e_customer';


-- 4) 维度表物化视图：网关映射镜像
DROP TABLE IF EXISTS vos_gatewaymapping_mv;
CREATE MATERIALIZED VIEW IF NOT EXISTS vos_gatewaymapping_mv TO vos_gatewaymapping_ods AS
SELECT
    vos_id                          AS vos_id,
    JSONExtractInt(data, 'id')             AS id,
    JSONExtractString(data, 'name')        AS name,
    JSONExtractInt(data, 'locktype')       AS locktype,
    JSONExtractInt(data, 'calllevel')      AS calllevel,
    JSONExtractInt(data, 'capacity')       AS capacity,
    JSONExtractInt(data, 'priority')       AS priority,
    JSONExtractInt(data, 'registertype')   AS registertype,
    JSONExtractString(data, 'remoteips')   AS remoteips,
    JSONExtractInt(data, 'rtpforwardtype') AS rtpforwardtype,
    JSONExtractString(data, 'gatewaygroups') AS gatewaygroups,
    JSONExtractString(data, 'routinggatewaygroups') AS routinggatewaygroups,
    JSONExtractString(data, 'memo')        AS memo,
    JSONExtractInt(data, 'customer_id')    AS customer_id,
    JSONExtractInt(data, 'mbx_id')         AS mbx_id,
    now()                              AS _sync_ts
FROM vos_cdr_kafka
WHERE src_table = 'e_gatewaymapping';


-- 5) 维度表物化视图：费率组镜像
DROP TABLE IF EXISTS vos_feerate_mv;
CREATE MATERIALIZED VIEW IF NOT EXISTS vos_feerate_mv TO vos_feerate_ods AS
SELECT
    vos_id                          AS vos_id,
    JSONExtractInt(data, 'id')             AS id,
    JSONExtractString(data, 'feeprefix')   AS feeprefix,
    JSONExtractString(data, 'areacode')    AS areacode,
    JSONExtractInt(data, 'locktype')       AS locktype,
    JSONExtractFloat(data, 'fee')          AS fee,
    JSONExtractFloat(data, 'tax')          AS tax,
    JSONExtractInt(data, 'period')         AS period,
    JSONExtractFloat(data, 'ivrfee')       AS ivrfee,
    JSONExtractInt(data, 'ivrperiod')      AS ivrperiod,
    JSONExtractInt(data, 'type')           AS type,
    JSONExtractInt(data, 'feerategroup_id') AS feerategroup_id,
    now()                              AS _sync_ts
FROM vos_cdr_kafka
WHERE src_table = 'e_feerate';

-- 3) 校验：查看消费进度 / 落库行数（按节点）
-- SELECT vos_id, count() FROM vos_cdr_ods GROUP BY vos_id;
-- SELECT * FROM vos_cdr_ods ORDER BY vos_id, flowno DESC LIMIT 10;
