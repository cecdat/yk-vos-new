package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * VOS Agent 心跳 / 健康快照 Response VO
 *
 * @author yk-vos-new
 */
@Schema(description = "管理后台 - VOS Agent 心跳 Response VO")
@Data
public class VosAgentHeartbeatRespVO {

    @Schema(description = "编号")
    private Long id;

    @Schema(description = "实例（agent instance.id）")
    @JsonProperty("vos_id")
    private String vosId;

    @JsonProperty("agent_version")
    private String agentVersion;

    private String hostname;

    private String os;

    @JsonProperty("cpu_load_1m")
    private BigDecimal cpuLoad1m;

    @JsonProperty("cpu_cores")
    private Integer cpuCores;

    @JsonProperty("mem_total_mb")
    private Integer memTotalMb;

    @JsonProperty("mem_used_mb")
    private Integer memUsedMb;

    @JsonProperty("disk_total_mb")
    private Integer diskTotalMb;

    @JsonProperty("disk_used_mb")
    private Integer diskUsedMb;

    @JsonProperty("uptime_seconds")
    private Long uptimeSeconds;

    @JsonProperty("db_connected")
    private Boolean dbConnected;

    @JsonProperty("db_version")
    private String dbVersion;

    @JsonProperty("db_open_conns")
    private Integer dbOpenConns;

    @JsonProperty("db_active_conns")
    private Integer dbActiveConns;

    @JsonProperty("db_max_conns")
    private Integer dbMaxConns;

    @JsonProperty("agent_pid")
    private Integer agentPid;

    @JsonProperty("delay_ms")
    private Integer delayMs;

    @JsonProperty("agent_goroutines")
    private Integer agentGoroutines;

    @JsonProperty("agent_mem_alloc_mb")
    private BigDecimal agentMemAllocMb;

    @JsonProperty("agent_uptime_seconds")
    private Long agentUptimeSeconds;

    @Schema(description = "agent 上报时间")
    @JsonProperty("generated_at")
    private LocalDateTime generatedAt;

}
