package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * VOS 实例创建 / 修改 Request VO
 *
 * @author yk-vos-new
 */
@Schema(description = "管理后台 - VOS 实例创建/修改 Request VO")
@Data
public class VosInstanceSaveReqVO {

    @Schema(description = "编号", example = "1024")
    private Long id;

    @Schema(description = "Agent 实例 ID（指令路由键，如 vos1）", requiredMode = Schema.RequiredMode.REQUIRED, example = "vos1")
    @NotBlank(message = "Agent ID 不能为空")
    @JsonProperty("vos_id")
    private String vosId;

    @Schema(description = "名称", requiredMode = Schema.RequiredMode.REQUIRED, example = "北京节点")
    @NotBlank(message = "名称不能为空")
    private String name;

    @Schema(description = "IP / 地址（仅展示，服务端不主动连接）", requiredMode = Schema.RequiredMode.REQUIRED, example = "http://1.2.3.4:8080")
    @NotBlank(message = "IP / 地址不能为空")
    @JsonProperty("base_url")
    private String baseUrl;

    @Schema(description = "备注", example = "生产环境")
    private String description;

    @Schema(description = "是否启用", requiredMode = Schema.RequiredMode.REQUIRED, example = "true")
    @NotNull(message = "启用状态不能为空")
    private Boolean enabled;

}
