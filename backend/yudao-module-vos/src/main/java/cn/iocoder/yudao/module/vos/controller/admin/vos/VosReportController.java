package cn.iocoder.yudao.module.vos.controller.admin.vos;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.excel.core.util.ExcelUtils;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosCdrQueryReqVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosProfitReportExcelVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosInstanceDO;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosInstanceMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.*;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

/**
 * 管理后台 - VOS 财务利润报表 Controller
 *
 * @author ykxx
 */
@Tag(name = "管理后台 - VOS 财务利润报表")
@RestController
@RequestMapping("/vos/report")
@Validated
public class VosReportController {

    @Resource
    private VosInstanceMapper vosInstanceMapper;

    @Resource
    private JdbcTemplate clickHouseJdbcTemplate;

    @PostMapping("/profit-report/{instanceId}")
    @Operation(summary = "获得财务利润及对账统计（三合一）")
    @Parameter(name = "instanceId", description = "VOS 实例主键", required = true)
    @PreAuthorize("@ss.hasPermission('vos:report:query')")
    public CommonResult<Map<String, Object>> getProfitReport(
            @PathVariable("instanceId") Long instanceId,
            @RequestBody VosCdrQueryReqVO reqVO) {
        long startMs = System.currentTimeMillis();

        VosInstanceDO instance = vosInstanceMapper.selectById(instanceId);
        if (instance == null) {
            return success(errorResult("VOS 实例不存在 (id=" + instanceId + ")", 0L, instanceId, null));
        }
        String vosId = instance.getVosId();

        // 统一复用时间转换，防范异常格式
        Long beginMs = VosCdrController.parseTimeToMillis(reqVO.getBeginTime(), false);
        Long endMs = VosCdrController.parseTimeToMillis(reqVO.getEndTime(), true);
        if (beginMs == null || endMs == null) {
            return success(errorResult("begin_time / end_time 格式不正确", 0L, instanceId, instance.getName()));
        }

        LocalDate beginDate = LocalDate.ofInstant(Instant.ofEpochMilli(beginMs), ZoneId.systemDefault());
        LocalDate endDate = LocalDate.ofInstant(Instant.ofEpochMilli(endMs), ZoneId.systemDefault());

        int page = (reqVO.getPage() == null || reqVO.getPage() < 1) ? 1 : reqVO.getPage();
        int size = (reqVO.getPageSize() == null || reqVO.getPageSize() < 1) ? 20 : Math.min(reqVO.getPageSize(), 1000);

        // WHERE 拼装与过滤条件：基于每日聚合汇总表查询
        StringBuilder where = new StringBuilder("WHERE vos_id = ? AND date BETWEEN toDate(?) AND toDate(?)");
        List<Object> params = new ArrayList<>();
        params.add(vosId);
        params.add(beginDate.toString());
        params.add(endDate.toString());

        List<String> accounts = reqVO.getAccountList();
        if (!accounts.isEmpty()) {
            where.append(" AND account IN (").append(String.join(",", Collections.nCopies(accounts.size(), "?"))).append(")");
            params.addAll(accounts);
        }

        try {
            // 统计过滤后的客户账户个数（去重）
            String countSql = "SELECT count(distinct account) FROM vos_profit_daily_ods " + where;
            Object cntObj = clickHouseJdbcTemplate.queryForObject(countSql, Object.class, params.toArray());
            long total = (cntObj instanceof Number) ? ((Number) cntObj).longValue() : 0L;

            // 基于预聚合汇总表的快速对账分析查询
            String dataSql = "SELECT "
                    + "account, "
                    + "sum(call_count) AS callCount, "
                    + "sum(billing_duration) / 60.0 AS billingDurationMinutes, "
                    + "sum(revenue) AS revenue, "
                    + "sum(cost) AS cost, "
                    + "sum(revenue) - sum(cost) AS profit, "
                    + "if(sum(revenue) > 0, round((sum(revenue) - sum(cost)) / sum(revenue) * 100, 2), 0.0) AS profitRate "
                    + "FROM vos_profit_daily_ods " + where
                    + " GROUP BY account "
                    + " ORDER BY profit DESC LIMIT ? OFFSET ?";

            List<Object> dataParams = new ArrayList<>(params);
            dataParams.add(size);
            dataParams.add((page - 1) * size);

            List<Map<String, Object>> rows = clickHouseJdbcTemplate.queryForList(dataSql, dataParams.toArray());

            Map<String, Object> result = new LinkedHashMap<>();
            result.put("success", true);
            result.put("list", rows);
            result.put("total", total);
            result.put("page", page);
            result.put("pageSize", size);
            result.put("totalPages", (int) Math.ceil(total * 1.0 / size));
            result.put("instanceId", instanceId);
            result.put("instanceName", instance.getName());
            result.put("queryTimeMs", System.currentTimeMillis() - startMs);
            return success(result);
        } catch (Exception e) {
            return success(errorResult("ClickHouse 对账报表查询失败: " + e.getMessage(), 0L, instanceId, instance.getName()));
        }
    }

    @PostMapping("/export-profit-report/{instanceId}")
    @Operation(summary = "导出财务利润及对账汇总 Excel")
    @Parameter(name = "instanceId", description = "VOS 实例主键", required = true)
    @PreAuthorize("@ss.hasPermission('vos:report:export')")
    public void exportProfitReport(
            @PathVariable("instanceId") Long instanceId,
            @RequestBody VosCdrQueryReqVO reqVO,
            HttpServletResponse response) throws IOException {
        VosInstanceDO instance = vosInstanceMapper.selectById(instanceId);
        if (instance == null) {
            throw new IllegalArgumentException("VOS 实例不存在 (id=" + instanceId + ")");
        }
        String vosId = instance.getVosId();

        Long beginMs = VosCdrController.parseTimeToMillis(reqVO.getBeginTime(), false);
        Long endMs = VosCdrController.parseTimeToMillis(reqVO.getEndTime(), true);
        if (beginMs == null || endMs == null) {
            throw new IllegalArgumentException("时间格式不正确，起止时间不能为空");
        }

        LocalDate beginDate = LocalDate.ofInstant(Instant.ofEpochMilli(beginMs), ZoneId.systemDefault());
        LocalDate endDate = LocalDate.ofInstant(Instant.ofEpochMilli(endMs), ZoneId.systemDefault());

        StringBuilder where = new StringBuilder("WHERE vos_id = ? AND date BETWEEN toDate(?) AND toDate(?)");
        List<Object> params = new ArrayList<>();
        params.add(vosId);
        params.add(beginDate.toString());
        params.add(endDate.toString());

        List<String> accounts = reqVO.getAccountList();
        if (!accounts.isEmpty()) {
            where.append(" AND account IN (").append(String.join(",", Collections.nCopies(accounts.size(), "?"))).append(")");
            params.addAll(accounts);
        }

        String dataSql = "SELECT "
                + "account, "
                + "sum(call_count) AS callCount, "
                + "sum(billing_duration) / 60.0 AS billingDurationMinutes, "
                + "sum(revenue) AS revenue, "
                + "sum(cost) AS cost, "
                + "sum(revenue) - sum(cost) AS profit, "
                + "if(sum(revenue) > 0, round((sum(revenue) - sum(cost)) / sum(revenue) * 100, 2), 0.0) AS profitRate "
                + "FROM vos_profit_daily_ods " + where
                + " GROUP BY account "
                + " ORDER BY profit DESC";

        List<Map<String, Object>> rows = clickHouseJdbcTemplate.queryForList(dataSql, params.toArray());
        List<VosProfitReportExcelVO> excelList = new ArrayList<>();
        for (Map<String, Object> map : rows) {
            excelList.add(new VosProfitReportExcelVO()
                    .setAccount(getString(map.get("account")))
                    .setCallCount(getLong(map.get("callCount")))
                    .setBillingDurationMinutes(getBigDecimal(map.get("billingDurationMinutes")))
                    .setRevenue(getBigDecimal(map.get("revenue")))
                    .setCost(getBigDecimal(map.get("cost")))
                    .setProfit(getBigDecimal(map.get("profit")))
                    .setProfitRate(getString(map.get("profitRate")) + "%")
            );
        }

        ExcelUtils.write(response, "VOS对账单汇总_" + beginDate + "_至_" + endDate + ".xls", "汇总数据", VosProfitReportExcelVO.class, excelList);
    }

    private String getString(Object obj) {
        return obj == null ? "" : obj.toString();
    }

    private Long getLong(Object obj) {
        if (obj == null) return 0L;
        if (obj instanceof Number) return ((Number) obj).longValue();
        return Long.parseLong(obj.toString());
    }

    private BigDecimal getBigDecimal(Object obj) {
        if (obj == null) return BigDecimal.ZERO;
        return new BigDecimal(obj.toString()).setScale(4, java.math.RoundingMode.HALF_UP);
    }

    private static Map<String, Object> errorResult(String msg, Long total, Long instanceId, String instanceName) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", false);
        result.put("list", Collections.emptyList());
        result.put("total", total);
        result.put("page", 1);
        result.put("pageSize", 20);
        result.put("totalPages", 0);
        result.put("instanceId", instanceId);
        result.put("instanceName", instanceName);
        result.put("message", msg);
        result.put("error", msg);
        return result;
    }
}
