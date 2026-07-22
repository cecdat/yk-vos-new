package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Schema(description = "管理后台 - VOS 号码 Response VO")
@Data
public class VosPhoneRespVO {

    @Schema(description = "主键 ID", example = "1001")
    private Integer id;

    @Schema(description = "电话号码（E.164）", example = "800801")
    private String e164;

    @Schema(description = "费率组 ID", example = "1")
    private Integer feerategroupId;
}
