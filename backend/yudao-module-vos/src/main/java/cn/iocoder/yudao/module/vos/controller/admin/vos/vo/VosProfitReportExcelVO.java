package cn.iocoder.yudao.module.vos.controller.admin.vos.vo;

import cn.idev.excel.annotation.ExcelProperty;
import lombok.Data;
import lombok.experimental.Accessors;

import java.math.BigDecimal;

/**
 * 客户财务对账报表导出 Excel VO
 *
 * @author ykxx
 */
@Data
@Accessors(chain = true)
public class VosProfitReportExcelVO {

    @ExcelProperty("对账账户")
    private String account;

    @ExcelProperty("通话次数 (次)")
    private Long callCount;

    @ExcelProperty("计费时长 (分钟)")
    private BigDecimal billingDurationMinutes;

    @ExcelProperty("结算收入 (元)")
    private BigDecimal revenue;

    @ExcelProperty("落地成本 (元)")
    private BigDecimal cost;

    @ExcelProperty("净利润 (元)")
    private BigDecimal profit;

    @ExcelProperty("毛利率 (%)")
    private String profitRate;
}
