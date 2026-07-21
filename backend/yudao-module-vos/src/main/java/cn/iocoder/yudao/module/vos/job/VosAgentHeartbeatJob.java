package cn.iocoder.yudao.module.vos.job;

import cn.iocoder.yudao.framework.tenant.core.job.TenantJob;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosInstanceDO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentHeartbeatDO;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosInstanceMapper;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosAgentHeartbeatMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import jakarta.annotation.Resource;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

/**
 * VOS Agent 心跳健康检查被动探活 Job
 * 每 15 秒扫描一次数据库，对超过 120 秒未上报心跳的实例判定为失联
 *
 * @author ykxx
 */
@Component
@Slf4j
public class VosAgentHeartbeatJob {

    @Resource
    private VosInstanceMapper vosInstanceMapper;

    @Resource
    private VosAgentHeartbeatMapper heartbeatMapper;

    @Scheduled(cron = "*/15 * * * * ?")
    @TenantJob // 绕过租户行过滤，遍历全表实例进行探活
    public void execute() {
        log.debug("[VosAgentHeartbeatJob] 开始被动心跳探活扫描...");
        List<VosInstanceDO> instances = vosInstanceMapper.selectList();
        if (instances == null || instances.isEmpty()) {
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        for (VosInstanceDO instance : instances) {
            VosAgentHeartbeatDO heartbeat = heartbeatMapper.selectByVosId(instance.getVosId());
            if (heartbeat == null) {
                updateHealthStatus(instance, "unknown", "未检测到Agent心跳数据上报");
                continue;
            }

            // 失联阈值 = 3 * heartbeat_interval_seconds(30s) + 30s 宽限 = 120s
            long diffSeconds = Duration.between(heartbeat.getGeneratedAt(), now).getSeconds();
            if (diffSeconds > 120) {
                updateHealthStatus(instance, "unknown", String.format("Agent心跳超时，已失联 %d 秒", diffSeconds));
            } else if (!heartbeat.getDbConnected()) {
                updateHealthStatus(instance, "unhealthy", "Agent运行正常，但报告VOS本地数据库连接断开");
            } else {
                updateHealthStatus(instance, "healthy", null);
            }
        }
    }

    private void updateHealthStatus(VosInstanceDO instance, String status, String error) {
        if (status.equals(instance.getHealthStatus())) {
            return;
        }
        
        VosInstanceDO updateObj = new VosInstanceDO()
                .setId(instance.getId())
                .setHealthStatus(status)
                .setHealthError(error)
                .setHealthLastCheck(LocalDateTime.now());
        vosInstanceMapper.updateById(updateObj);
        log.info("[VosAgentHeartbeatJob] VOS 实例 [{}] 健康状态变更: {} -> {}, 原因: {}", 
                instance.getVosId(), instance.getHealthStatus(), status, error != null ? error : "正常");
    }
}
