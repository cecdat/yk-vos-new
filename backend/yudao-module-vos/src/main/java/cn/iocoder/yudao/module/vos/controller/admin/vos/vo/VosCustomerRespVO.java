package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class VosCustomerRespVO {

    private Long id;

    private String vosId;

    private Integer customerId;

    private String account;

    private String name;

    private BigDecimal money;

    private BigDecimal limitmoney;

    private BigDecimal todayconsumption;

    private Integer status;

    private Integer feerategroupId;

    private LocalDateTime createTime;
}
