package cn.iocoder.yudao.module.vos.service.backfill;

import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosBackfillTaskSaveReqVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentBackfillDO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentBackfillTaskDO;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosAgentBackfillMapper;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosAgentBackfillTaskMapper;
import cn.iocoder.yudao.module.vos.enums.ErrorCodeConstants;
import cn.iocoder.yudao.module.vos.framework.kafka.AgentCommandProducer;
import cn.iocoder.yudao.module.vos.framework.kafka.dto.CommandMessage;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.annotation.Resource;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;

/**
 * VOS 话单回填与控制指令 Service 实现类
 *
 * @author ykxx
 */
@Service
@Slf4j
public class VosBackfillServiceImpl implements VosBackfillService {

    @Resource
    private VosAgentBackfillMapper backfillMapper;

    @Resource
    private VosAgentBackfillTaskMapper taskMapper;

    @Resource
    private AgentCommandProducer agentCommandProducer;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String startBackfill(VosBackfillTaskSaveReqVO reqVO) {
        String commandId = UUID.randomUUID().toString();
        String taskCode = "BF" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) + (int)(Math.random() * 90 + 10);

        // 1. 初始化为“待下发”状态，等待用户在控制台手动“启动下发”
        String initialStatus = "pending";

        Map<String, Object> params = new HashMap<>();
        if (reqVO.getSpeedLimit() != null) {
            params.put("speed_limit", reqVO.getSpeedLimit());
        }

        // 2. 写入任务记录表
        VosAgentBackfillTaskDO task = new VosAgentBackfillTaskDO()
                .setTaskCode(taskCode)
                .setVosId(reqVO.getVosId())
                .setCommandId(commandId)
                .setAction("backfill_start")
                .setTables(reqVO.getTables())
                .setMode(reqVO.getMode())
                .setCron(reqVO.getCron())
                .setParams(params)
                .setStatus(initialStatus);
        taskMapper.insert(task);

        // 3. 更新可用日表的同步状态为待回填 (pending)
        for (String table : reqVO.getTables()) {
            VosAgentBackfillDO backfill = backfillMapper.selectByVosIdAndTable(reqVO.getVosId(), table);
            if (backfill != null) {
                backfill.setStatus("pending");
                backfillMapper.updateById(backfill);
            }
        }

        // 4. 此处仅将任务入队（状态为 pending），不主动向 Kafka 投递控制指令，由手动下发接管

        return initialStatus;
    }

    /**
     * 控制指令统一发送：复用主任务的 commandId，不新增任务行。
     * <p>原因：任务队列按 vos_id 全量查出，若每次控制都 insert 新行，
     * 会导致「点击暂停/取消/限速就新增一条任务」的体验问题。
     * 改复用主 backfill_start 任务的 commandId 下发 Kafka，由 Agent ACK 回执
     * （handleAck 按 msg.getAction() 判定）更新同一行状态。</p>
     */
    private void sendControlCommand(VosAgentBackfillTaskDO task, String action, Map<String, Object> params) {
        CommandMessage command = new CommandMessage()
                .setVosId(task.getVosId())
                .setCommandId(task.getCommandId()) // 复用主任务 commandId，确保 ACK 关联同一行
                .setAction(action)
                .setTables(task.getTables())
                .setParams(params);
        agentCommandProducer.sendCommand(command);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void pauseBackfill(String commandId) {
        VosAgentBackfillTaskDO task = taskMapper.selectByCommandId(commandId);
        if (task == null) {
            throw exception(ErrorCodeConstants.VOS_BACKFILL_TASK_NOT_EXISTS);
        }
        // 不再新增行：直接复用主任务 commandId 下发控制指令，状态由 ACK 回执更新
        sendControlCommand(task, "pause", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void resumeBackfill(String commandId) {
        VosAgentBackfillTaskDO task = taskMapper.selectByCommandId(commandId);
        if (task == null) {
            throw exception(ErrorCodeConstants.VOS_BACKFILL_TASK_NOT_EXISTS);
        }
        sendControlCommand(task, "resume", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancelBackfill(String commandId) {
        VosAgentBackfillTaskDO task = taskMapper.selectByCommandId(commandId);
        if (task == null) {
            throw exception(ErrorCodeConstants.VOS_BACKFILL_TASK_NOT_EXISTS);
        }
        sendControlCommand(task, "cancel", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void setThrottle(String commandId, Long speedLimit) {
        VosAgentBackfillTaskDO task = taskMapper.selectByCommandId(commandId);
        if (task == null) {
            throw exception(ErrorCodeConstants.VOS_BACKFILL_TASK_NOT_EXISTS);
        }
        Map<String, Object> params = new HashMap<>();
        params.put("speed_limit", speedLimit);
        // 同步写入主任务 params，便于前端回显当前限速
        task.setParams(params);
        taskMapper.updateById(task);
        sendControlCommand(task, "set_throttle", params);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void triggerPreciseCount(String vosId, String tableName) {
        // 不新增任务行：精确统计结果由 Agent 异步 COUNT(*) 后经 precise_rows 上报，
        // 按 table 关联回写，无需任务行；仅下发一次性 Kafka 指令。
        CommandMessage command = new CommandMessage()
                .setVosId(vosId)
                .setCommandId(UUID.randomUUID().toString())
                .setAction("precise_count")
                .setTables(Collections.singletonList(tableName));
        agentCommandProducer.sendCommand(command);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void triggerRescan(String vosId) {
        // 不新增任务行：扫描结果由 Agent 经 availability 上报，按 vos_id+table 同步，
        // 无需任务行；仅下发一次性 Kafka 指令。
        CommandMessage command = new CommandMessage()
                .setVosId(vosId)
                .setCommandId(UUID.randomUUID().toString())
                .setAction("rescan");
        agentCommandProducer.sendCommand(command);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void dispatchBackfill(Long taskId) {
        VosAgentBackfillTaskDO task = taskMapper.selectById(taskId);
        if (task == null) {
            throw exception(ErrorCodeConstants.VOS_BACKFILL_TASK_NOT_EXISTS);
        }
        // 仅允许对「待下发 / 排队中 / 已取消 / 失败」的任务做手动下发
        if (!Arrays.asList("pending", "queued", "cancelled", "failed").contains(task.getStatus())) {
            throw exception(ErrorCodeConstants.VOS_BACKFILL_TASK_STATUS_ERROR);
        }

        // 1. 并发流控：仅 backfill_start 在执行中 (dispatched/syncing) 占额度
        Long activeCount = taskMapper.selectCount(new LambdaQueryWrapper<VosAgentBackfillTaskDO>()
                .eq(VosAgentBackfillTaskDO::getAction, "backfill_start")
                .in(VosAgentBackfillTaskDO::getStatus, Arrays.asList("dispatched", "syncing")));
        String status = (activeCount >= 3) ? "queued" : "dispatched";

        // 2. 更新任务状态
        task.setStatus(status);
        taskMapper.updateById(task);

        // 3. 更新所属日表同步状态
        if (task.getTables() != null) {
            for (String table : task.getTables()) {
                VosAgentBackfillDO backfill = backfillMapper.selectByVosIdAndTable(task.getVosId(), table);
                if (backfill != null) {
                    backfill.setStatus("syncing");
                    backfillMapper.updateById(backfill);
                }
            }
        }

        // 4. 若未被限流，下发 Kafka backfill_start 指令（复用任务自身 commandId）
        if ("dispatched".equals(status)) {
            CommandMessage command = new CommandMessage()
                    .setVosId(task.getVosId())
                    .setCommandId(task.getCommandId())
                    .setAction("backfill_start")
                    .setTables(task.getTables())
                    .setMode(task.getMode())
                    .setCron(task.getCron())
                    .setParams(task.getParams());
            agentCommandProducer.sendCommand(command);
        }
    }

    @Override
    public List<VosAgentBackfillDO> getAvailabilityList(String vosId) {
        return backfillMapper.selectList(new LambdaQueryWrapper<VosAgentBackfillDO>()
                .eq(VosAgentBackfillDO::getVosId, vosId)
                .orderByDesc(VosAgentBackfillDO::getTableName));
    }

    @Override
    public List<VosAgentBackfillTaskDO> getTaskList(String vosId) {
        return taskMapper.selectList(new LambdaQueryWrapper<VosAgentBackfillTaskDO>()
                .eq(VosAgentBackfillTaskDO::getVosId, vosId)
                .orderByDesc(VosAgentBackfillTaskDO::getId));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void dispatchNextQueuedTask() {
        // 1. 确认当前运行中的任务数未达到阈值 (仅 backfill_start 占额度，处于 dispatched / syncing 状态)
        Long activeCount = taskMapper.selectCount(new LambdaQueryWrapper<VosAgentBackfillTaskDO>()
                .eq(VosAgentBackfillTaskDO::getAction, "backfill_start")
                .in(VosAgentBackfillTaskDO::getStatus, Arrays.asList("dispatched", "syncing")));
        if (activeCount >= 3) {
            return;
        }

        // 2. 获取最早处于 queued 状态的任务
        VosAgentBackfillTaskDO nextTask = taskMapper.selectOne(new LambdaQueryWrapper<VosAgentBackfillTaskDO>()
                .eq(VosAgentBackfillTaskDO::getStatus, "queued")
                .orderByAsc(VosAgentBackfillTaskDO::getId)
                .last("LIMIT 1"));
        if (nextTask == null) {
            return;
        }

        // 3. 标记为下发中并执行
        nextTask.setStatus("dispatched");
        taskMapper.updateById(nextTask);

        if (nextTask.getTables() != null) {
            for (String table : nextTask.getTables()) {
                VosAgentBackfillDO backfill = backfillMapper.selectByVosIdAndTable(nextTask.getVosId(), table);
                if (backfill != null) {
                    backfill.setStatus("syncing");
                    backfillMapper.updateById(backfill);
                }
            }
        }

        CommandMessage command = new CommandMessage()
                .setVosId(nextTask.getVosId())
                .setCommandId(nextTask.getCommandId())
                .setAction(nextTask.getAction())
                .setTables(nextTask.getTables())
                .setMode(nextTask.getMode())
                .setCron(nextTask.getCron())
                .setParams(nextTask.getParams());
        agentCommandProducer.sendCommand(command);

        log.info("[QueueFlowControl] 锁释放，自动调度排队中任务 commandId={}", nextTask.getCommandId());
    }
}
