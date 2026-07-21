package cn.iocoder.yudao.module.vos.dal.dataobject;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

import java.time.LocalDateTime;

/**
 * VOS 话单可用性/日表回填状态 Entity
 *
 * @author ykxx
 */
@TableName("vos_agent_backfill")
@Data
@EqualsAndHashCode(callSuper = true)
@Accessors(chain = true)
public class VosAgentBackfillDO extends TenantBaseDO {

    /**
     * 自增主键
     */
    @TableId
    private Long id;

    /**
     * 实例 ID
     */
    private String vosId;

    /**
     * 历史日表名 (e.g. e_cdr_20260202)
     */
    private String tableName;

    /**
     * TABLE_ROWS 估算行数
     */
    private Long estimatedRows;

    /**
     * Agent 侧已推行数
     */
    private Long alreadyPushed;

    /**
     * 精确 COUNT(*) 行数
     */
    private Long preciseRows;

    /**
     * 回填状态 (pending, approved, syncing, done, rejected)
     */
    private String status;

    /**
     * 执行模式 (immediate, scheduled)
     */
    private String mode;

    /**
     * 定时 Cron 表达式
     */
    private String scheduledCron;

    /**
     * 最近扫描上报时间
     */
    private LocalDateTime lastReportedAt;
}
