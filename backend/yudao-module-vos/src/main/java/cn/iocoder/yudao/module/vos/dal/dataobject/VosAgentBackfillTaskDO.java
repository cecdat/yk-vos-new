package cn.iocoder.yudao.module.vos.dal.dataobject;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * VOS Agent 回填控制任务与指令记录 Entity
 *
 * @author ykxx
 */
@TableName(value = "vos_agent_backfill_task", autoResultMap = true)
@Data
@EqualsAndHashCode(callSuper = true)
@Accessors(chain = true)
public class VosAgentBackfillTaskDO extends TenantBaseDO {

    /**
     * 自增主键
     */
    @TableId
    private Long id;

    /**
     * 回填任务编号 (业务识别)
     */
    private String taskCode;

    /**
     * 实例 ID
     */
    private String vosId;

    /**
     * 指令 UUID (用于幂等)
     */
    private String commandId;

    /**
     * 控制指令 (backfill_start, pause, resume, cancel, rescan, precise_count, set_throttle)
     */
    private String action;

    /**
     * 所选日表清单
     */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> tables;

    /**
     * 回填模式 (immediate, scheduled)
     */
    private String mode;

    /**
     * 定时回填 cron
     */
    private String cron;

    /**
     * 限速调速等附加参数 (Map JSON)
     */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> params;

    /**
     * 任务状态 (pending, queued, dispatched, syncing, paused, done, failed, cancelled)
     */
    private String status;

    /**
     * 当前已回填行数
     */
    private Long progressPushed;

    /**
     * 最近一次进度上报时间
     */
    private LocalDateTime lastProgressAt;

    /**
     * Agent 侧响应回执 (ok, error)
     */
    private String result;

    /**
     * 异常回执报错详情
     */
    private String resultMsg;
}
