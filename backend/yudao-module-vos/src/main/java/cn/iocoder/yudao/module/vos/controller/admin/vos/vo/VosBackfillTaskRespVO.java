package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 历史回填任务 Response VO
 *
 * @author ykxx
 */
@Data
public class VosBackfillTaskRespVO {

    private Long id;

    private String taskCode;

    private String vosId;

    private String commandId;

    private String action;

    private List<String> tables;

    private String mode;

    private String cron;

    private Map<String, Object> params;

    private String status;

    private Long progressPushed;

    private LocalDateTime lastProgressAt;

    private String result;

    private String resultMsg;

    private LocalDateTime createTime;
}
