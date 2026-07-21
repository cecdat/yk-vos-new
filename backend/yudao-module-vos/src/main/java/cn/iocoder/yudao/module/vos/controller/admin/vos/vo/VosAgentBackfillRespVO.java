package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 可用历史日表 Response VO
 *
 * @author ykxx
 */
@Data
public class VosAgentBackfillRespVO {

    private Long id;

    private String vosId;

    private String tableName;

    private Long estimatedRows;

    private Long alreadyPushed;

    private Long preciseRows;

    private String status;

    private String mode;

    private String scheduledCron;

    private LocalDateTime lastReportedAt;
}
