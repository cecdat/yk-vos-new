package cn.iocoder.yudao.module.vos.framework.kafka.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * Agent 上报的消息 DTO (Topic: vos.agent.report)
 *
 * @author ykxx
 */
@Data
public class ReportMessage {

    @JsonProperty("vos_id")
    private String vosId;

    @JsonProperty("msg_type")
    private String msgType; // availability, heartbeat, progress, ack

    @JsonProperty("generated_at")
    private String generatedAt;

    @JsonProperty("agent_version")
    private String agentVersion;

    // 1. Availability (可用表扫描) 上报专属字段
    private List<TableAvailability> tables;

    // 2. Heartbeat (健康状态) 上报专属字段
    @JsonProperty("vos_system")
    private SystemMetrics system;

    @JsonProperty("db_status")
    private DBStatus db;

    @JsonProperty("agent_status")
    private AgentMetrics agent;

    // 3. Ack (指令回执) 上报专属字段
    @JsonProperty("command_id")
    private String commandId;

    private String action;

    private String result; // ok, error

    @JsonProperty("result_msg")
    private String resultMsg;

    private String at;

    // 4. Progress (回填进度) 上报专属字段
    @JsonProperty("task_id")
    private String taskId;

    private String table;

    private Long pushed;

    private String status; // syncing, done

    // 5. PreciseCount (精确统计) 上报专属字段
    @JsonProperty("precise_rows")
    private Long preciseRows;

    @Data
    public static class TableAvailability {
        private String table;
        @JsonProperty("estimated_rows")
        private Long estimatedRows;
        @JsonProperty("already_pushed")
        private Long alreadyPushed;
    }

    @Data
    public static class SystemMetrics {
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
    }

    @Data
    public static class DBStatus {
        private Boolean connected;
        private String version;
        @JsonProperty("open_connections")
        private Integer openConnections;
        @JsonProperty("active_connections")
        private Integer activeConnections;
        @JsonProperty("max_connections")
        private Integer maxConnections;
    }

    @Data
    public static class AgentMetrics {
        private Integer pid;
        private Integer goroutines;
        @JsonProperty("mem_alloc_mb")
        private BigDecimal memAllocMb;
        @JsonProperty("uptime_seconds")
        private Long uptimeSeconds;
    }
}
