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

import cn.iocoder.yudao.framework.excel.core.util.ExcelUtils;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosCdrExcelVO;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

/**
 * 管理后台 - VOS 智能话单查询 Controller
 * <p>优先从 ClickHouse ODS 表 {@code vos_cdr_ods} 查询，按 vos_id + recordstarttime 时间窗过滤。</p>
 *
 * @author ykxx
 */
@Tag(name = "管理后台 - VOS 智能话单查询")
@RestController
@RequestMapping("/cdr")
@Validated
public class VosCdrController {

    @Resource
    private VosInstanceMapper vosInstanceMapper;

    @Resource
    private JdbcTemplate clickHouseJdbcTemplate;

    @PostMapping("/query-from-vos/{instanceId}")
    @Operation(summary = "智能话单查询（ClickHouse ODS）")
    @Parameter(name = "instanceId", description = "VOS 实例主键", required = true)
    @PreAuthorize("@ss.hasPermission('cdr:query:list')")
    public CommonResult<Map<String, Object>> queryFromVos(
            @PathVariable("instanceId") Long instanceId,
            @RequestBody VosCdrQueryReqVO reqVO) {
        long startMs = System.currentTimeMillis();

        VosInstanceDO instance = vosInstanceMapper.selectById(instanceId);
        if (instance == null) {
            return success(errorResult("VOS 实例不存在 (id=" + instanceId + ")", 0L, instanceId, null));
        }
        String vosId = instance.getVosId();

        // 时间窗自适应解析：毫秒时间戳比较
        Long beginMs = parseTimeToMillis(reqVO.getBeginTime(), false);
        Long endMs = parseTimeToMillis(reqVO.getEndTime(), true);
        if (beginMs == null || endMs == null) {
            return success(errorResult("begin_time / end_time 格式应为 yyyyMMdd 或 yyyy-MM-dd HH:mm:ss", 0L, instanceId, instance.getName()));
        }

        int page = (reqVO.getPage() == null || reqVO.getPage() < 1) ? 1 : reqVO.getPage();
        int size = (reqVO.getPageSize() == null || reqVO.getPageSize() < 1) ? 20 : Math.min(reqVO.getPageSize(), 1000);

        // WHERE 条件拼装：直接使用 Int64 毫秒时间戳区间比较，避免函数转换导致的报错与性能开销
        StringBuilder where = new StringBuilder(
                "WHERE vos_id = ? AND recordstarttime BETWEEN ? AND ?");
        List<Object> params = new ArrayList<>();
        params.add(vosId);
        params.add(beginMs);
        params.add(endMs);

        List<String> accounts = reqVO.getAccountList();
        if (!accounts.isEmpty()) {
            where.append(" AND customeraccount IN (").append(String.join(",", Collections.nCopies(accounts.size(), "?"))).append(")");
            params.addAll(accounts);
        }
        if (reqVO.getCallerE164() != null && !reqVO.getCallerE164().isBlank()) {
            where.append(" AND callere164 = ?");
            params.add(reqVO.getCallerE164().trim());
        }
        if (reqVO.getCalleeE164() != null && !reqVO.getCalleeE164().isBlank()) {
            where.append(" AND calleee164 = ?");
            params.add(reqVO.getCalleeE164().trim());
        }
        if (reqVO.getCalleeGateway() != null && !reqVO.getCalleeGateway().isBlank()) {
            where.append(" AND calleegatewayid = ?");
            params.add(reqVO.getCalleeGateway().trim());
        }
        if (Boolean.TRUE.equals(reqVO.getExcludeZeroFee())) {
            where.append(" AND fee > 0");
        }

        try {
            // 总数
            String countSql = "SELECT count() FROM vos_cdr_ods " + where;
            Object cntObj = clickHouseJdbcTemplate.queryForObject(countSql, Object.class, params.toArray());
            long total = (cntObj instanceof Number) ? ((Number) cntObj).longValue() : 0L;

            // 分页查询（列别名映射为前端 camelCase）
            String dataSql = "SELECT "
                    + "flowno AS flowNo, "
                    + "customeraccount AS account, "
                    + "customername AS accountName, "
                    + "calleraccesse164 AS callerAccessE164, "
                    + "calleeaccesse164 AS calleeAccessE164, "
                    + "calleegatewayid AS calleeGateway, "
                    + "starttime AS start, "
                    + "stoptime AS stop, "
                    + "holdtime AS holdTime, "
                    + "feetime AS feeTime, "
                    + "fee AS fee, "
                    + "enddirection AS endDirection, "
                    + "endreason AS endReason "
                    + "FROM vos_cdr_ods " + where
                    + " ORDER BY recordstarttime DESC LIMIT ? OFFSET ?";
            List<Object> dataParams = new ArrayList<>(params);
            dataParams.add(size);
            dataParams.add((page - 1) * size);

            List<Map<String, Object>> rows = clickHouseJdbcTemplate.queryForList(dataSql, dataParams.toArray());

            Map<String, Object> result = new LinkedHashMap<>();
            result.put("success", true);
            result.put("cdrs", rows);
            result.put("count", total);
            result.put("total", total);
            result.put("page", page);
            result.put("page_size", size);
            result.put("total_pages", (int) Math.ceil(total * 1.0 / size));
            result.put("instance_id", instanceId);
            result.put("instance_name", instance.getName());
            result.put("data_source", "clickhouse:vos_cdr_ods");
            result.put("query_time_ms", System.currentTimeMillis() - startMs);
            return success(result);
        } catch (Exception e) {
            return success(errorResult("ClickHouse 查询失败: " + e.getMessage(), 0L, instanceId, instance.getName()));
        }
    }

    static Long parseTimeToMillis(String timeStr, boolean endIfDateOnly) {
        if (timeStr == null || timeStr.isBlank()) {
            return null;
        }
        String clean = timeStr.trim();
        try {
            // Case 1: yyyyMMdd (8 chars)
            if (clean.length() == 8 && clean.matches("\\d{8}")) {
                int y = Integer.parseInt(clean.substring(0, 4));
                int m = Integer.parseInt(clean.substring(4, 6));
                int d = Integer.parseInt(clean.substring(6, 8));
                return getMillis(y, m, d, endIfDateOnly);
            }
            // Case 2: yyyy-MM-dd (10 chars)
            if (clean.length() == 10 && clean.matches("\\d{4}-\\d{2}-\\d{2}")) {
                int y = Integer.parseInt(clean.substring(0, 4));
                int m = Integer.parseInt(clean.substring(5, 7));
                int d = Integer.parseInt(clean.substring(8, 10));
                return getMillis(y, m, d, endIfDateOnly);
            }
            // Case 3: yyyyMMddHHmmss (14 chars)
            if (clean.length() == 14 && clean.matches("\\d{14}")) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyyMMddHHmmss");
                return sdf.parse(clean).getTime();
            }
            // Case 4: yyyy-MM-dd HH:mm:ss
            if (clean.contains("-") && clean.contains(":") && clean.length() >= 19) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                return sdf.parse(clean.substring(0, 19)).getTime();
            }
            // Case 6: yyyyMMdd HH:mm:ss (17 chars)
            if (clean.length() == 17 && clean.contains(" ")) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyyMMdd HH:mm:ss");
                return sdf.parse(clean).getTime();
            }
            // Case 5: numeric timestamp
            if (clean.matches("\\d+")) {
                long val = Long.parseLong(clean);
                // If it's in seconds (10 digits), convert to millis
                if (clean.length() == 10) {
                    return val * 1000L;
                }
                return val;
            }
        } catch (Exception e) {
            // Ignore
        }
        return null;
    }

    private static Long getMillis(int y, int m, int d, boolean endOfDay) {
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.clear();
        cal.set(y, m - 1, d);
        if (endOfDay) {
            cal.set(java.util.Calendar.HOUR_OF_DAY, 23);
            cal.set(java.util.Calendar.MINUTE, 59);
            cal.set(java.util.Calendar.SECOND, 59);
            cal.set(java.util.Calendar.MILLISECOND, 999);
        } else {
            cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
            cal.set(java.util.Calendar.MINUTE, 0);
            cal.set(java.util.Calendar.SECOND, 0);
            cal.set(java.util.Calendar.MILLISECOND, 0);
        }
        return cal.getTimeInMillis();
    }

    private static Map<String, Object> errorResult(String msg, Long total, Long instanceId, String instanceName) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", false);
        result.put("cdrs", Collections.emptyList());
        result.put("count", total);
        result.put("total", total);
        result.put("page", 1);
        result.put("page_size", 20);
        result.put("total_pages", 0);
        result.put("instance_id", instanceId);
        result.put("instance_name", instanceName);
        result.put("data_source", "clickhouse:vos_cdr_ods");
        result.put("query_time_ms", 0);
        result.put("message", msg);
        result.put("error", msg);
        return result;
    }

    @PostMapping("/export-from-vos/{instanceId}")
    @Operation(summary = "导出原始话单明细 Excel")
    @Parameter(name = "instanceId", description = "VOS 实例主键", required = true)
    @PreAuthorize("@ss.hasPermission('cdr:query:export')")
    public void exportCdr(
            @PathVariable("instanceId") Long instanceId,
            @RequestBody VosCdrQueryReqVO reqVO,
            HttpServletResponse response) throws IOException {
        VosInstanceDO instance = vosInstanceMapper.selectById(instanceId);
        if (instance == null) {
            throw new IllegalArgumentException("VOS 实例不存在 (id=" + instanceId + ")");
        }
        String vosId = instance.getVosId();

        Long beginMs = parseTimeToMillis(reqVO.getBeginTime(), false);
        Long endMs = parseTimeToMillis(reqVO.getEndTime(), true);
        if (beginMs == null || endMs == null) {
            throw new IllegalArgumentException("时间格式不正确，起止时间不能为空");
        }

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
        if (reqVO.getCallerE164() != null && !reqVO.getCallerE164().isBlank()) {
            where.append(" AND callere164 = ?");
            params.add(reqVO.getCallerE164().trim());
        }
        if (reqVO.getCalleeE164() != null && !reqVO.getCalleeE164().isBlank()) {
            where.append(" AND calleee164 = ?");
            params.add(reqVO.getCalleeE164().trim());
        }
        if (reqVO.getCalleeGateway() != null && !reqVO.getCalleeGateway().isBlank()) {
            where.append(" AND calleegatewayid = ?");
            params.add(reqVO.getCalleeGateway().trim());
        }
        if (Boolean.TRUE.equals(reqVO.getExcludeZeroFee())) {
            where.append(" AND fee > 0");
        }

        // 限制最大导出明细条数，防止内存泄漏（最多 50000 行）
        String dataSql = "SELECT "
                + "flowno AS flowNo, "
                + "customeraccount AS account, "
                + "calleraccesse164 AS callerAccessE164, "
                + "calleeaccesse164 AS calleeAccessE164, "
                + "calleegatewayid AS calleeGateway, "
                + "starttime AS start, "
                + "stoptime AS stop, "
                + "feetime AS feeTime, "
                + "fee AS fee, "
                + "agentfee AS agentFee, "
                + "enddirection AS endDirection, "
                + "endreason AS endReason "
                + "FROM vos_cdr_ods " + where
                + " ORDER BY recordstarttime DESC LIMIT 50000";

        List<Map<String, Object>> rows = clickHouseJdbcTemplate.queryForList(dataSql, params.toArray());
        List<VosCdrExcelVO> excelList = new ArrayList<>();
        for (Map<String, Object> map : rows) {
            excelList.add(new VosCdrExcelVO()
                    .setFlowNo(getLong(map.get("flowNo")))
                    .setAccount(getString(map.get("account")))
                    .setCallerAccessE164(getString(map.get("callerAccessE164")))
                    .setCalleeAccessE164(getString(map.get("calleeAccessE164")))
                    .setCalleeGateway(getString(map.get("calleeGateway")))
                    .setStart(formatDateTimeStr(map.get("start")))
                    .setStop(formatDateTimeStr(map.get("stop")))
                    .setFeeTime(getInteger(map.get("feeTime")))
                    .setFee(getBigDecimal(map.get("fee")))
                    .setAgentFee(getBigDecimal(map.get("agentFee")))
                    .setEndDirection(getInteger(map.get("endDirection")))
                    .setEndReason(getString(map.get("endReason")))
            );
        }

        ExcelUtils.write(response, "VOS原始话单明细_" + reqVO.getBeginTime() + "_至_" + reqVO.getEndTime() + ".xls", "明细数据", VosCdrExcelVO.class, excelList);
    }

    private String getString(Object obj) {
        return obj == null ? "" : obj.toString();
    }

    private Long getLong(Object obj) {
        if (obj == null) return 0L;
        if (obj instanceof Number) return ((Number) obj).longValue();
        return Long.parseLong(obj.toString());
    }

    private Integer getInteger(Object obj) {
        if (obj == null) return 0;
        if (obj instanceof Number) return ((Number) obj).intValue();
        return Integer.parseInt(obj.toString());
    }

    private BigDecimal getBigDecimal(Object obj) {
        if (obj == null) return BigDecimal.ZERO;
        return new BigDecimal(obj.toString()).setScale(4, java.math.RoundingMode.HALF_UP);
    }

    private String formatDateTimeStr(Object val) {
        if (val == null) return "-";
        return val.toString();
    }
}
