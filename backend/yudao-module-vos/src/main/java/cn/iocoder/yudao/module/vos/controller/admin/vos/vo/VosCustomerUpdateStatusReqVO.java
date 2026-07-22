package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import lombok.Data;
import jakarta.validation.constraints.NotNull;

@Data
public class VosCustomerUpdateStatusReqVO {

    @NotNull(message = "id不能为空")
    private Long id;

    @NotNull(message = "状态不能为空")
    private Integer status;
}
