package cn.iocoder.yudao.module.vos.dal.dataobject;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.KeySequence;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

import java.math.BigDecimal;

/**
 * VOS 客户本地镜像缓存 DO
 *
 * @author ykxx
 */
@TableName("vos_customer")
@KeySequence("vos_customer_seq")
@Data
@EqualsAndHashCode(callSuper = true)
@Accessors(chain = true)
public class VosCustomerDO extends TenantBaseDO {

    /**
     * 自增主键
     */
    @TableId
    private Long id;

    /**
     * VOS 实例 ID（如 vos1）
     */
    private String vosId;

    /**
     * VOS 侧 e_customer.id
     */
    private Integer customerId;

    /**
     * 客户账号
     */
    private String account;

    /**
     * 客户名称
     */
    private String name;

    /**
     * 当前可用余额 (元)
     */
    private BigDecimal money;

    /**
     * 信用额度限额 (元)
     */
    private BigDecimal limitmoney;

    /**
     * 今日已扣除消费 (元)
     */
    private BigDecimal todayconsumption;

    /**
     * 状态：0 激活正常，1 欠费锁定/挂起
     */
    private Integer status;

    /**
     * 挂载费率组 ID
     */
    private Integer feerategroupId;

}
