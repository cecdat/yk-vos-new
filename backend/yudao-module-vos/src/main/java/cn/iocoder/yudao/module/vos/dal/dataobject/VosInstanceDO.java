package cn.iocoder.yudao.module.vos.dal.dataobject;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

import java.time.LocalDateTime;

/**
 * VOS 实例注册 Entity
 *
 * @author ykxx
 */
@TableName("vos_instance")
@Data
@EqualsAndHashCode(callSuper = true)
@Accessors(chain = true)
public class VosInstanceDO extends TenantBaseDO {

    /**
     * 自增主键
     */
    @TableId
    private Long id;

    /**
     * Agent端ID(指令路由键)
     */
    private String vosId;

    /**
     * 实例名称
     */
    private String name;

    /**
     * 展示IP或地址
     */
    private String baseUrl;

    /**
     * 备注
     */
    private String description;

    /**
     * 是否启用(1启用, 0禁用)
     */
    private Boolean enabled;

    /**
     * 最近心跳上报的Agent版本
     */
    private String agentVersion;

    /**
     * 健康度(healthy, unhealthy, unknown)
     */
    private String healthStatus;

    /**
     * 最近心跳时间
     */
    private LocalDateTime healthLastCheck;

    /**
     * 最近心跳延迟(ms)或uptime
     */
    private Integer healthResponseTime;

    /**
     * 不健康详情描述
     */
    @com.baomidou.mybatisplus.annotation.TableField(updateStrategy = com.baomidou.mybatisplus.annotation.FieldStrategy.ALWAYS)
    private String healthError;
}
