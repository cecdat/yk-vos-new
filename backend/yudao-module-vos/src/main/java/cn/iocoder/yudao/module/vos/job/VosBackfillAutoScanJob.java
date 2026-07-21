package cn.iocoder.yudao.module.vos.job;

import cn.iocoder.yudao.framework.tenant.core.job.TenantJob;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosInstanceDO;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosInstanceMapper;
import cn.iocoder.yudao.module.vos.service.backfill.VosBackfillService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import jakarta.annotation.Resource;
import java.util.List;

/**
 * VOS 历史话单回填 - 自动扫描 Job
 * <p>周期性对所有已注册 VOS 实例下发 rescan 指令，由 Agent 扫描可用日表并上报；
 * 上报后在 {@code AgentReportConsumer.handleAvailability} 中自动为「未同步完」的日表
 * 创建 pending（待下发）回填任务，落入任务队列及指令控制中心。</p>
 *
 * @author ykxx
 */
@Component
@Slf4j
public class VosBackfillAutoScanJob {

    @Resource
    private VosInstanceMapper vosInstanceMapper;

    @Resource
    private VosBackfillService vosBackfillService;

    /**
     * 每 5 分钟对所有已注册实例下发一次重扫指令。
     */
    @Scheduled(cron = "0 0/5 * * * ?")
    @TenantJob // 绕过租户行过滤，遍历全表实例进行扫描
    public void execute() {
        List<VosInstanceDO> instances = vosInstanceMapper.selectList();
        if (instances == null || instances.isEmpty()) {
            return;
        }
        int triggered = 0;
        for (VosInstanceDO instance : instances) {
            try {
                vosBackfillService.triggerRescan(instance.getVosId());
                triggered++;
            } catch (Exception e) {
                log.warn("[VosBackfillAutoScanJob] 实例 [{}] 自动扫描下发失败: {}", instance.getVosId(), e.getMessage());
            }
        }
        log.info("[VosBackfillAutoScanJob] 已对 {} / {} 个实例下发自动重扫指令", triggered, instances.size());
    }
}
