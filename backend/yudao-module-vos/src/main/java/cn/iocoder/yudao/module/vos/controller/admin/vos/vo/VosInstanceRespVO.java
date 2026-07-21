package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * VOS 实例 Response VO
 *
 * @author yk-vos-new
 */
@Schema(description = "管理后台 - VOS 实例 Response VO")
@Data
public class VosInstanceRespVO {

    @Schema(description = "编号", example = "1024")
    private Long id;

    @Schema(description = "Agent 实例 ID")
    @JsonProperty("vos_id")
    private String vosId;

    @Schema(description = "名称")
    private String name;

    @Schema(description = "IP / 地址")
    @JsonProperty("base_url")
    private String baseUrl;

    @Schema(description = "备注")
    private String description;

    @Schema(description = "是否启用")
    private Boolean enabled;

    @Schema(description = "最近一次心跳上报的 agent 版本")
    @JsonProperty("agent_version")
    private String agentVersion;

    @Schema(description = "健康状态：healthy / unhealthy / unknown")
    @JsonProperty("health_status")
    private String healthStatus;

    @Schema(description = "最近一次心跳时间")
    @JsonProperty("health_last_check")
    private LocalDateTime healthLastCheck;

    @Schema(description = "预留（可填 agent uptime）")
    @JsonProperty("health_response_time")
    private Integer healthResponseTime;

    @Schema(description = "不健康原因")
    @JsonProperty("health_error")
    private String healthError;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

}
