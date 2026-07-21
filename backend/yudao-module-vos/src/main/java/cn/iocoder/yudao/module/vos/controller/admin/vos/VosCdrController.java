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
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

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

    private static final DateTimeFormatter YMD = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final DateTimeFormatter Y_M_D = DateTimeFormatter.ofPattern("yyyy-MM-dd");

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

        // 时间窗：yyyyMMdd -> yyyy-MM-dd（用于 toDate(toDateTime(coalesce(recordstarttime, 0))) 比较）
        String begin = toChDate(reqVO.getBeginTime());
        String end = toChDate(reqVO.getEndTime());
        if (begin == null || end == null) {
            return success(errorResult("begin_time / end_time 格式应为 yyyyMMdd", 0L, instanceId, instance.getName()));
        }

        int page = (reqVO.getPage() == null || reqVO.getPage() < 1) ? 1 : reqVO.getPage();
        int size = (reqVO.getPageSize() == null || reqVO.getPageSize() < 1) ? 20 : Math.min(reqVO.getPageSize(), 1000);

        // WHERE 条件拼装
        StringBuilder where = new StringBuilder(
                "WHERE vos_id = ? AND toDate(toDateTime(coalesce(recordstarttime, 0))) BETWEEN ? AND ?");
        List<Object> params = new ArrayList<>();
        params.add(vosId);
        params.add(begin);
        params.add(end);

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

    private static String toChDate(String ymd) {
        if (ymd == null || ymd.length() != 8) {
            return null;
        }
        try {
            return LocalDate.parse(ymd, YMD).format(Y_M_D);
        } catch (Exception e) {
            return null;
        }
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
}
