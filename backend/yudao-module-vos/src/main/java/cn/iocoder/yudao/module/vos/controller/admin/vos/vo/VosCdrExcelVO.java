package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import cn.idev.excel.annotation.ExcelProperty;
import lombok.Data;
import lombok.experimental.Accessors;

import java.math.BigDecimal;

/**
 * 原始话单明细导出对账 Excel VO
 *
 * @author ykxx
 */
@Data
@Accessors(chain = true)
public class VosCdrExcelVO {

    @ExcelProperty("话单流水号")
    private Long flowNo;

    @ExcelProperty("对账账户")
    private String account;

    @ExcelProperty("主叫号码")
    private String callerAccessE164;

    @ExcelProperty("被叫号码")
    private String calleeAccessE164;

    @ExcelProperty("落地网关")
    private String calleeGateway;

    @ExcelProperty("通话开始时间")
    private String start;

    @ExcelProperty("通话结束时间")
    private String stop;

    @ExcelProperty("计费时长 (秒)")
    private Integer feeTime;

    @ExcelProperty("结算费用 (元)")
    private BigDecimal fee;

    @ExcelProperty("落地成本 (元)")
    private BigDecimal agentFee;

    @ExcelProperty("挂断方向")
    private Integer endDirection;

    @ExcelProperty("挂断原因")
    private String endReason;
}
