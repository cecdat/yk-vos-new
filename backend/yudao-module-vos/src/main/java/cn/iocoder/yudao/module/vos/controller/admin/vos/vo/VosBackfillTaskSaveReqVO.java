package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

/**
 * 历史回填启动 Request VO
 *
 * @author ykxx
 */
@Data
public class VosBackfillTaskSaveReqVO {

    /**
     * VOS 实例 ID
     */
    @NotBlank(message = "实例ID不能为空")
    private String vosId;

    /**
     * 所选的日表清单
     */
    @NotEmpty(message = "至少选择一个日表进行同步")
    private List<String> tables;

    /**
     * 同步模式 (immediate, scheduled)
     */
    private String mode = "immediate";

    /**
     * 定时任务 Cron 表达式
     */
    private String cron;

    /**
     * 调速上限 (行/秒)，可为空
     */
    private Long speedLimit;
}
