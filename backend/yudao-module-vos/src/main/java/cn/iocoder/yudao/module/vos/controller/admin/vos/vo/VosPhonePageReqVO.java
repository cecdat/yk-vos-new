package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import jakarta.validation.constraints.NotNull;

@Schema(description = "管理后台 - VOS 号码分页 Request VO")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class VosPhonePageReqVO extends PageParam {

    @Schema(description = "VOS 实例 ID", requiredMode = Schema.RequiredMode.REQUIRED, example = "1")
    @NotNull(message = "VOS 实例 ID 不能为空")
    private Long instanceId;

    @Schema(description = "电话号码（E.164）", example = "800801")
    private String e164;
}
