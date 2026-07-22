package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;

@Schema(description = "管理后台 - VOS 号码回收 Request VO")
@Data
public class VosPhoneRecycleReqVO {

    @Schema(description = "VOS 实例 ID", requiredMode = Schema.RequiredMode.REQUIRED, example = "1")
    @NotNull(message = "VOS 实例 ID 不能为空")
    private Long instanceId;

    @Schema(description = "号码列表（E.164）", requiredMode = Schema.RequiredMode.REQUIRED, example = "[\"800801\"]")
    @NotEmpty(message = "号码列表不能为空")
    private List<String> e164s;
}
