package cn.iocoder.yudao.module.vos.framework.kafka;

import cn.iocoder.yudao.framework.tenant.core.util.TenantUtils;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentBackfillDO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentBackfillTaskDO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentHeartbeatDO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosInstanceDO;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosAgentBackfillMapper;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosAgentBackfillTaskMapper;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosAgentHeartbeatMapper;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosInstanceMapper;
import cn.iocoder.yudao.module.vos.framework.kafka.dto.CommandMessage;
import cn.iocoder.yudao.module.vos.framework.kafka.dto.ReportMessage;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import jakarta.annotation.Resource;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Kafka 报告消息消费者 (Topic: vos.agent.report)
 * 接收 Agent 上报的心跳、日表可用性扫描、指令执行回执和回填进度
 *
 * @author ykxx
 */
@Component
@Slf4j
public class AgentReportConsumer {

    @Resource
    private VosInstanceMapper vosInstanceMapper;

    @Resource
    private VosAgentHeartbeatMapper heartbeatMapper;

    @Resource
    private VosAgentBackfillMapper backfillMapper;

    @Resource
    private VosAgentBackfillTaskMapper taskMapper;

    @Resource
    private JdbcTemplate jdbcTemplate;

    @Resource
    private ObjectMapper objectMapper;

    @Resource
    private cn.iocoder.yudao.module.vos.service.backfill.VosBackfillService vosBackfillService;

    @Resource
    private AgentCommandProducer agentCommandProducer;

    /**
     * 已下发 start 指令的 Agent 最近一次上报的 uptime（秒），用于去重：
     * 仅在首次或 Agent 重启（uptime 回退）时重新下发 start，避免每个心跳（30s）都重复下发。
     */
    private final Map<String, Long> lastStartUptime = new ConcurrentHashMap<>();

    @KafkaListener(topics = KafkaConfig.TOPIC_REPORT, groupId = "vos-backend-group",
            containerFactory = "vosAgentReportKafkaListenerContainerFactory")
    public void onMessage(String record) {
        log.debug("[AgentReportConsumer] 收到 Agent 上报原始数据: {}", record);
        try {
            ReportMessage msg = objectMapper.readValue(record, ReportMessage.class);
            if (msg == null || msg.getVosId() == null) {
                log.warn("[AgentReportConsumer] 解析上报数据为空或缺失 vos_id: {}", record);
                return;
            }

            // 1. 根据 vos_id 路由查找所属租户 ID (通过原生 JDBC 绕过 MyBatis-Plus 多租户行拦截)
            Long tenantId = getTenantIdByVosId(msg.getVosId());
            if (tenantId == null) {
                log.warn("[AgentReportConsumer] 未找到对应 vos_id [{}] 的注册实例，丢弃消息", msg.getVosId());
                return;
            }

            // 2. 绑定租户上下文执行业务逻辑
            TenantUtils.execute(tenantId, () -> {
                handleReport(msg);
            });
        } catch (Exception e) {
            log.error("[AgentReportConsumer] 处理上报消息异常: ", e);
        }
    }

    private void handleReport(ReportMessage msg) {
        String msgType = msg.getMsgType();
        if ("heartbeat".equalsIgnoreCase(msgType)) {
            handleHeartbeat(msg);
        } else if ("availability".equalsIgnoreCase(msgType)) {
            handleAvailability(msg);
        } else if ("ack".equalsIgnoreCase(msgType)) {
            handleAck(msg);
        } else if ("progress".equalsIgnoreCase(msgType)) {
            handleProgress(msg);
        } else if ("precise_rows".equalsIgnoreCase(msgType)) {
            handlePreciseRows(msg);
        } else {
            log.warn("[AgentReportConsumer] 未知消息类型: {}, msg: {}", msgType, msg);
        }
    }

    private void handleHeartbeat(ReportMessage msg) {
        log.debug("[AgentReportConsumer] 处理心跳: vosId={}", msg.getVosId());
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime generatedTime = now;
        if (msg.getGeneratedAt() != null) {
            try {
                generatedTime = LocalDateTime.parse(msg.getGeneratedAt(), DateTimeFormatter.ISO_DATE_TIME);
            } catch (Exception e) {
                // 忽略解析错误，使用当前时间
            }
        }

        // 1. 动态更新 VOS 实例的健康参数
        VosInstanceDO instance = vosInstanceMapper.selectByVosId(msg.getVosId());
        if (instance != null) {
            String targetStatus = "healthy";
            String errorMsg = null;
            if (msg.getDb() != null && !msg.getDb().getConnected()) {
                targetStatus = "unhealthy";
                errorMsg = "Agent运行正常，但报告VOS本地数据库连接断开";
            }
            int responseTime = 0;
            if (msg.getAgent() != null && msg.getAgent().getUptimeSeconds() != null) {
                responseTime = msg.getAgent().getUptimeSeconds().intValue();
            }

            VosInstanceDO updateInstance = new VosInstanceDO()
                    .setId(instance.getId())
                    .setAgentVersion(msg.getAgentVersion())
                    .setHealthStatus(targetStatus)
                    .setHealthError(errorMsg)
                    .setHealthLastCheck(now)
                    .setHealthResponseTime(responseTime);
            vosInstanceMapper.updateById(updateInstance);

            // 已注册节点 & 心跳正常：自动下发 start 指令，授权 Agent 开始推送实时话单。
            // 未注册（后端尚未添加该 VOS 节点）则不触发，从而实现「未添加节点前 Agent 不推送」。
            maybeSendStartCommand(msg.getVosId(), msg);
        }

        // 2. 插入或更新心跳硬件快照
        VosAgentHeartbeatDO heartbeat = heartbeatMapper.selectByVosId(msg.getVosId());
        boolean isNew = (heartbeat == null);
        if (isNew) {
            heartbeat = new VosAgentHeartbeatDO();
        }

        heartbeat.setVosId(msg.getVosId())
                .setAgentVersion(msg.getAgentVersion())
                .setGeneratedAt(generatedTime);

        if (msg.getSystem() != null) {
            ReportMessage.SystemMetrics sys = msg.getSystem();
            heartbeat.setHostname(sys.getHostname())
                    .setOs(sys.getOs())
                    .setCpuLoad1m(sys.getCpuLoad1m())
                    .setCpuCores(sys.getCpuCores())
                    .setMemTotalMb(sys.getMemTotalMb())
                    .setMemUsedMb(sys.getMemUsedMb())
                    .setDiskTotalMb(sys.getDiskTotalMb())
                    .setDiskUsedMb(sys.getDiskUsedMb())
                    .setUptimeSeconds(sys.getUptimeSeconds());
        }

        if (msg.getDb() != null) {
            ReportMessage.DBStatus db = msg.getDb();
            heartbeat.setDbConnected(db.getConnected())
                    .setDbVersion(db.getVersion())
                    .setDbOpenConns(db.getOpenConnections())
                    .setDbActiveConns(db.getActiveConnections());
        }

        if (msg.getAgent() != null) {
            ReportMessage.AgentMetrics ag = msg.getAgent();
            heartbeat.setAgentGoroutines(ag.getGoroutines())
                    .setAgentMemAllocMb(ag.getMemAllocMb())
                    .setAgentUptimeSeconds(ag.getUptimeSeconds());
        }

        if (isNew) {
            heartbeatMapper.insert(heartbeat);
        } else {
            heartbeatMapper.updateById(heartbeat);
        }
    }

    /**
     * 当收到「已注册 VOS 实例」（即后端已添加并授权该节点）的心跳时，
     * 自动下发 {@code start} 指令，授权 Agent 开始推送实时话单。
     * 未添加节点的 Agent 心跳不会触发，从而保证「后端未添加 VOS 节点前，Agent 不推送数据」。
     *
     * <p>去重：仅在首次或 Agent 重启（上报 uptime 回退）时重新下发，
     * 避免 Agent 每 30s 心跳都重复下发 start。下发失败则移除记录允许下次重试。</p>
     */
    private void maybeSendStartCommand(String vosId, ReportMessage msg) {
        Long uptime = (msg.getAgent() != null) ? msg.getAgent().getUptimeSeconds() : null;
        Long prev = lastStartUptime.get(vosId);
        if (prev != null && (uptime == null || uptime >= prev)) {
            return; // 非首次且 Agent 未重启，去重，不重复下发
        }
        lastStartUptime.put(vosId, uptime);

        CommandMessage startCmd = new CommandMessage()
                .setVosId(vosId)
                .setCommandId(UUID.randomUUID().toString())
                .setAction("start");
        try {
            agentCommandProducer.sendCommand(startCmd);
            log.info("[AgentReportConsumer] 已向 Agent [{}] 下发 start 指令（授权开始推送）", vosId);
        } catch (Exception e) {
            lastStartUptime.remove(vosId); // 发送失败，允许下次心跳重试
            log.error("[AgentReportConsumer] 下发 start 指令失败, vosId={}", vosId, e);
        }
    }

    private void handleAvailability(ReportMessage msg) {
        log.info("[AgentReportConsumer] 收到可用表扫描数据，vosId={}, 数量={}", msg.getVosId(),
                msg.getTables() != null ? msg.getTables().size() : 0);
        if (msg.getTables() == null) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        for (ReportMessage.TableAvailability table : msg.getTables()) {
            VosAgentBackfillDO backfill = backfillMapper.selectByVosIdAndTable(msg.getVosId(), table.getTable());
            if (backfill == null) {
                // 发现新表，默认为待审批
                backfill = new VosAgentBackfillDO()
                        .setVosId(msg.getVosId())
                        .setTableName(table.getTable())
                        .setEstimatedRows(table.getEstimatedRows())
                        .setAlreadyPushed(table.getAlreadyPushed())
                        .setStatus("pending")
                        .setLastReportedAt(now);
                backfillMapper.insert(backfill);
            } else {
                // 更新表估算行数及汇报时间
                backfill.setEstimatedRows(table.getEstimatedRows())
                        .setAlreadyPushed(table.getAlreadyPushed())
                        .setLastReportedAt(now);
                backfillMapper.updateById(backfill);
            }
        }

        // 自动建任务：对每个「未同步完」的日表，若无（非 done）活跃任务则创建 pending（待下发）
        // 自动扫描 Job 与用户手动「重新扫描可用日表」都走此逻辑，扫描到未同步表即入队待下发。
        // autoCreatePendingTasks(msg.getVosId(), msg.getTables());
    }

    private void handleAck(ReportMessage msg) {
        log.info("[AgentReportConsumer] 收到指令 ACK 回执，commandId={}, action={}, result={}, msg={}",
                msg.getCommandId(), msg.getAction(), msg.getResult(), msg.getResultMsg());
        if (msg.getCommandId() == null) {
            return;
        }

        VosAgentBackfillTaskDO task = taskMapper.selectByCommandId(msg.getCommandId());
        if (task == null) {
            // 控制指令复用主任务 commandId：若主任务行尚未落库或属于一次性指令(rescan/precise_count)，忽略即可
            log.warn("[AgentReportConsumer] 未找到对应 commandId [{}] 的任务记录 (可能是指令尚未落库或一次性指令)", msg.getCommandId());
            return;
        }

        // 以 ACK 上报的 action 作为状态判定依据（控制指令复用主任务 commandId，
        // 主任务行的 action 恒为 backfill_start，必须用 msg.getAction() 区分 pause/cancel 等）
        String action = (msg.getAction() != null) ? msg.getAction() : task.getAction();
        String targetStatus = task.getStatus();
        if ("ok".equalsIgnoreCase(msg.getResult())) {
            if ("pause".equals(action)) {
                targetStatus = "paused";
            } else if ("cancel".equals(action)) {
                targetStatus = "cancelled";
            } else if ("resume".equals(action) || "backfill_start".equals(action)) {
                targetStatus = "syncing";
            }
            // set_throttle / precise_count / rescan：保持当前状态不变
        } else {
            targetStatus = "failed";
        }

        VosAgentBackfillTaskDO updateTask = new VosAgentBackfillTaskDO()
                .setId(task.getId())
                .setStatus(targetStatus)
                .setResult(msg.getResult())
                .setResultMsg(msg.getResultMsg())
                .setLastProgressAt(LocalDateTime.now());
        taskMapper.updateById(updateTask);

        // 同步更新所属日表状态（task 即主任务，直接取其 tables）
        if (task.getTables() != null) {
            for (String table : task.getTables()) {
                VosAgentBackfillDO backfill = backfillMapper.selectByVosIdAndTable(task.getVosId(), table);
                if (backfill != null && !"done".equals(backfill.getStatus())) {
                    String tblStatus = backfill.getStatus();
                    if ("paused".equals(targetStatus)) {
                        tblStatus = "paused";
                    } else if ("cancelled".equals(targetStatus) || "failed".equals(targetStatus)) {
                        tblStatus = "pending"; // 失败或取消后，重置回待同步
                    } else if ("syncing".equals(targetStatus)) {
                        tblStatus = "syncing";
                    }
                    backfill.setStatus(tblStatus);
                    backfillMapper.updateById(backfill);
                }
            }
        }

        // 若任务终结 (失败或取消) 或暂停，释放流控锁，调度下一个排队中的任务
        if ("failed".equals(targetStatus) || "cancelled".equals(targetStatus) || "paused".equals(targetStatus)) {
            vosBackfillService.dispatchNextQueuedTask();
        }
    }

    private void handleProgress(ReportMessage msg) {
        log.debug("[AgentReportConsumer] 收到回填进度上报, commandId={}, table={}, pushed={}", 
                msg.getCommandId(), msg.getTable(), msg.getPushed());
        if (msg.getCommandId() == null) {
            return;
        }

        // 1. 更新任务的已推总行数与时间
        VosAgentBackfillTaskDO task = taskMapper.selectByCommandId(msg.getCommandId());
        if (task != null) {
            VosAgentBackfillTaskDO updateTask = new VosAgentBackfillTaskDO()
                    .setId(task.getId())
                    .setProgressPushed(msg.getPushed())
                    .setLastProgressAt(LocalDateTime.now());
            if ("done".equalsIgnoreCase(msg.getStatus())) {
                updateTask.setStatus("done");
                // 任务成功完成，释放流控锁，调度下一个排队中的任务
                vosBackfillService.dispatchNextQueuedTask();
            }
            taskMapper.updateById(updateTask);
        }

        // 2. 更新日表可用性表中的单表同步行数及状态
        if (msg.getTable() != null) {
            VosAgentBackfillDO backfill = backfillMapper.selectByVosIdAndTable(msg.getVosId(), msg.getTable());
            if (backfill != null) {
                VosAgentBackfillDO updateBackfill = new VosAgentBackfillDO()
                        .setId(backfill.getId())
                        .setAlreadyPushed(msg.getPushed());
                if ("done".equalsIgnoreCase(msg.getStatus())) {
                    updateBackfill.setStatus("done");
                } else {
                    updateBackfill.setStatus("syncing");
                }
                backfillMapper.updateById(updateBackfill);
            }
        }
    }

    /**
     * 处理精确 COUNT(*) 统计结果上报 (msg_type = precise_rows)
     * 来源：Agent 收到服务端 precise_count 指令后异步执行 COUNT(*)，回写单表精确行数
     */
    private void handlePreciseRows(ReportMessage msg) {
        if (msg.getTable() == null || msg.getPreciseRows() == null) {
            log.warn("[AgentReportConsumer] precise_rows 消息缺少 table 或 precise_rows 字段: {}", msg);
            return;
        }
        VosAgentBackfillDO backfill = backfillMapper.selectByVosIdAndTable(msg.getVosId(), msg.getTable());
        if (backfill == null) {
            log.warn("[AgentReportConsumer] precise_rows 未找到对应日表: vosId={}, table={}",
                    msg.getVosId(), msg.getTable());
            return;
        }
        backfill.setPreciseRows(msg.getPreciseRows());
        backfillMapper.updateById(backfill);
        log.info("[AgentReportConsumer] 更新日表 {} 精确行数: {}", msg.getTable(), msg.getPreciseRows());
    }

    private Long getTenantIdByVosId(String vosId) {
        try {
            VosInstanceDO instance = TenantUtils.executeIgnore(() ->
                    vosInstanceMapper.selectByVosId(vosId)
            );
            if (instance != null) {
                return instance.getTenantId();
            }
        } catch (Exception e) {
            log.error("[AgentReportConsumer] 查询 VOS 实例所属租户失败, vosId: {}, error: {}", vosId, e.getMessage());
        }
        return null;
    }
}
