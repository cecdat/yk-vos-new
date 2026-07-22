package cn.iocoder.yudao.module.vos.controller.admin.vos;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosCdrQueryReqVO;
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

        int page = (reqVO.getPage() == null || reqVO.getPage() < 1) ? 1 : reqVO.getPage();
        int size = (reqVO.getPageSize() == null || reqVO.getPageSize() < 1) ? 20 : Math.min(reqVO.getPageSize(), 1000);

        // WHERE 拼装与过滤条件
        StringBuilder where = new StringBuilder("WHERE vos_id = ? AND recordstarttime BETWEEN ? AND ?");
        List<Object> params = new ArrayList<>();
        params.add(vosId);
        params.add(beginMs);
        params.add(endMs);

        List<String> accounts = reqVO.getAccountList();
        if (!accounts.isEmpty()) {
            where.append(" AND customeraccount IN (").append(String.join(",", Collections.nCopies(accounts.size(), "?"))).append(")");
            params.addAll(accounts);
        }

        try {
            // 统计过滤后的客户账户个数（去重）
            String countSql = "SELECT count(distinct customeraccount) FROM vos_cdr_ods " + where;
            Object cntObj = clickHouseJdbcTemplate.queryForObject(countSql, Object.class, params.toArray());
            long total = (cntObj instanceof Number) ? ((Number) cntObj).longValue() : 0L;

            // 利润聚合查询（列映射为前端 camelCase 并且防零除限制）
            String dataSql = "SELECT "
                    + "customeraccount AS account, "
                    + "count() AS callCount, "
                    + "sum(feetime) / 60.0 AS billingDurationMinutes, "
                    + "sum(fee) AS revenue, "
                    + "sum(agentfee) AS cost, "
                    + "sum(fee) - sum(agentfee) AS profit, "
                    + "if(sum(fee) > 0, round((sum(fee) - sum(agentfee)) / sum(fee) * 100, 2), 0.0) AS profitRate "
                    + "FROM vos_cdr_ods " + where
                    + " GROUP BY customeraccount "
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
