package cn.iocoder.yudao.module.vos.framework.kafka.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.util.List;
import java.util.Map;

/**
 * 下发给 Agent 的指令控制消息 DTO (Topic: vos.agent.command)
 *
 * @author ykxx
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
public class CommandMessage {

    /**
     * 实例 ID
     */
    @JsonProperty("vos_id")
    private String vosId;

    /**
     * 指令 UUID (用于幂等)
     */
    @JsonProperty("command_id")
    private String commandId;

    /**
     * 控制指令 action (backfill_start, pause, resume, cancel, rescan, precise_count, set_throttle)
     */
    private String action;

    /**
     * 所涉及的历史日表列表
     */
    private List<String> tables;

    /**
     * 执行模式 (immediate, scheduled)
     */
    private String mode;

    /**
     * 定时任务 Cron
     */
    private String cron;

    /**
     * 调速等指令参数
     */
    private Map<String, Object> params;
}
