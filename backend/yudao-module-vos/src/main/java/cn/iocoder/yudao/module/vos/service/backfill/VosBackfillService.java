package cn.iocoder.yudao.module.vos.service.backfill;

import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosBackfillTaskSaveReqVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentBackfillDO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentBackfillTaskDO;

import java.util.List;

/**
 * VOS 话单回填与控制指令 Service 接口
 *
 * @author ykxx
 */
public interface VosBackfillService {

    /**
     * 发起历史回填任务 (含并发队列流控)
     *
     * @param reqVO 请求参数
     * @return 任务当前状态描述 (e.g. dispatched, queued)
     */
    String startBackfill(VosBackfillTaskSaveReqVO reqVO);

    /**
     * 暂停回填任务
     *
     * @param commandId 指令 UUID
     */
    void pauseBackfill(String commandId);

    /**
     * 恢复回填任务
     *
     * @param commandId 指令 UUID
     */
    void resumeBackfill(String commandId);

    /**
     * 取消/中止回填任务
     *
     * @param commandId 指令 UUID
     */
    void cancelBackfill(String commandId);

    /**
     * 动态设置回填限速限流
     *
     * @param commandId 指令 UUID
     * @param speedLimit 最大行数/秒
     */
    void setThrottle(String commandId, Long speedLimit);

    /**
     * 手动下发「待下发/排队中」的回填任务 (启动下发)
     * <p>用于定时扫描自动创建出的 pending 任务，或手动重新下发被取消/失败的任务。
     * 受全局并发流控 (最多 3 个 backfill_start 在执行) 约束：超阈值进入 queued 排队。</p>
     *
     * @param taskId 回填任务主键
     */
    void dispatchBackfill(Long taskId);

    /**
     * 发起精确行数 COUNT(*) 统计 (建议闲时执行)
     *
     * @param vosId 实例 ID
     * @param tableName 历史表名
     */
    void triggerPreciseCount(String vosId, String tableName);

    /**
     * 重新扫描可用历史表
     *
     * @param vosId 实例 ID
     */
    void triggerRescan(String vosId);

    /**
     * 查询指定实例下的可用历史日表列表
     *
     * @param vosId 实例 ID
     * @return 可用表列表
     */
    List<VosAgentBackfillDO> getAvailabilityList(String vosId);

    /**
     * 查询指定实例下的控制/回填任务记录
     *
     * @param vosId 实例 ID
     * @return 任务列表
     */
    List<VosAgentBackfillTaskDO> getTaskList(String vosId);

    /**
     * 调度下一个排队中的任务 (被动释放排队锁)
     */
    void dispatchNextQueuedTask();
}
