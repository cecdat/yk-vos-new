package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import lombok.Data;
import java.math.BigDecimal;
import jakarta.validation.constraints.NotNull;

@Data
public class VosCustomerUpdateLimitReqVO {

    @NotNull(message = "id不能为空")
    private Long id;

    @NotNull(message = "信用额度不能为空")
    private BigDecimal limitmoney;
}
