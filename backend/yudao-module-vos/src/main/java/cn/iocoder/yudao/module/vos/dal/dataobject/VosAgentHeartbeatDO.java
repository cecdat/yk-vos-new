package cn.iocoder.yudao.module.vos.dal.dataobject;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * VOS Agent 心跳状态快照 Entity
 *
 * @author ykxx
 */
@TableName("vos_agent_heartbeat")
@Data
@EqualsAndHashCode(callSuper = true)
@Accessors(chain = true)
public class VosAgentHeartbeatDO extends TenantBaseDO {

    /**
     * 自增主键
     */
    @TableId
    private Long id;

    /**
     * 实例ID
     */
    private String vosId;

    /**
     * Agent版本
     */
    private String agentVersion;

    /**
     * 系统主机名
     */
    private String hostname;

    /**
     * 操作系统发行版
     */
    private String os;

    /**
     * CPU系统一分钟负载
     */
    private BigDecimal cpuLoad1m;

    /**
     * 物理CPU核数
     */
    private Integer cpuCores;

    /**
     * 总内存(MB)
     */
    private Integer memTotalMb;

    /**
     * 已用内存(MB)
     */
    private Integer memUsedMb;

    /**
     * 总磁盘空间(MB)
     */
    private Integer diskTotalMb;

    /**
     * 已用磁盘空间(MB)
     */
    private Integer diskUsedMb;

    /**
     * 系统运行秒数
     */
    private Long uptimeSeconds;

    /**
     * 数据库连接正常(1是, 0否)
     */
    private Boolean dbConnected;

    /**
     * 本地数据库版本
     */
    private String dbVersion;

    /**
     * 连接池当前打开数
     */
    private Integer dbOpenConns;

    /**
     * 连接池活跃使用数
     */
    private Integer dbActiveConns;

    /**
     * 数据库配置的最大连接数
     */
    private Integer dbMaxConns;

    /**
     * Agent 进程 ID
     */
    private Integer agentPid;

    /**
     * Go协程数
     */
    private Integer agentGoroutines;

    /**
     * Agent自身内存分配(MB)
     */
    private BigDecimal agentMemAllocMb;

    /**
     * Agent运行时长
     */
    private Long agentUptimeSeconds;

    /**
     * 心跳生成时间(时区对齐)
     */
    private LocalDateTime generatedAt;
}
