package cn.iocoder.yudao.module.vos.controller.admin.vos;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosInstanceDO;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosInstanceMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.*;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - VOS 网关监控看板")
@RestController
@RequestMapping("/vos/gateway")
@Validated
@Slf4j
public class VosGatewayController {

    @Resource
    private VosInstanceMapper vosInstanceMapper;

    @Resource
    private JdbcTemplate clickHouseJdbcTemplate;

    @GetMapping("/load-report/{instanceId}")
    @Operation(summary = "获得网关并发负载与 KPI 监控看板数据")
    @Parameter(name = "instanceId", description = "VOS 实例主键", required = true)
    @PreAuthorize("@ss.hasPermission('vos:gateway:query')")
    public CommonResult<List<Map<String, Object>>> getGatewayLoadReport(
            @PathVariable("instanceId") Long instanceId) {
        
        VosInstanceDO instance = vosInstanceMapper.selectById(instanceId);
        if (instance == null) {
            return success(Collections.emptyList());
        }
        String vosId = instance.getVosId();

        // 1. 查询该 VOS 实例下注册的所有落地网关
        String gatewaySql = "SELECT id, name, capacity, locktype FROM vos_gatewaymapping_ods FINAL WHERE vos_id = ?";
        List<Map<String, Object>> rawGateways = clickHouseJdbcTemplate.queryForList(gatewaySql, vosId);

        // 2. 查询活跃话单获取当前的并发数
        String activeCallsSql = "SELECT calleegatewayid AS gatewayName, count() AS activeCalls " +
                "FROM vos_cdr_ods WHERE vos_id = ? AND stoptime = 0 GROUP BY calleegatewayid";
        List<Map<String, Object>> rawActiveCalls = clickHouseJdbcTemplate.queryForList(activeCallsSql, vosId);
        Map<String, Integer> activeCallsMap = new HashMap<>();
        for (Map<String, Object> row : rawActiveCalls) {
            String gName = (String) row.get("gatewayName");
            Number val = (Number) row.get("activeCalls");
            if (gName != null && val != null) {
                activeCallsMap.put(gName, val.intValue());
            }
        }

        // 3. 查询当日 KPI (ASR, ALOC)
        long todayStartMs = LocalDate.now().atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli();
        String kpiSql = "SELECT calleegatewayid AS gatewayName, " +
                " count() AS totalCalls, " +
                " countIf(feetime > 0) AS answeredCalls, " +
                " round(countIf(feetime > 0) / count() * 100, 2) AS asr, " +
                " if(countIf(feetime > 0) > 0, round(sum(feetime) / countIf(feetime > 0), 0), 0) AS aloc " +
                "FROM vos_cdr_ods " +
                "WHERE vos_id = ? AND recordstarttime >= ? " +
                "GROUP BY calleegatewayid";
        List<Map<String, Object>> rawKpis = clickHouseJdbcTemplate.queryForList(kpiSql, vosId, todayStartMs);
        Map<String, Map<String, Object>> kpiMap = new HashMap<>();
        for (Map<String, Object> row : rawKpis) {
            String gName = (String) row.get("gatewayName");
            if (gName != null) {
                kpiMap.put(gName, row);
            }
        }

        // 4. 合并组装
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map<String, Object> gw : rawGateways) {
            String name = (String) gw.get("name");
            if (name == null || name.trim().isEmpty()) {
                continue;
            }
            Number id = (Number) gw.get("id");
            Number capacityNum = (Number) gw.get("capacity");
            Number locktype = (Number) gw.get("locktype");

            int capacity = capacityNum != null ? capacityNum.intValue() : 0;
            int activeCalls = activeCallsMap.getOrDefault(name, 0);

            // 计算负载百分比
            double loadRate = 0.0;
            if (capacity > 0) {
                loadRate = Math.round((activeCalls * 100.0 / capacity) * 100.0) / 100.0;
            }

            Map<String, Object> gwKpi = kpiMap.get(name);
            long totalCalls = 0;
            long answeredCalls = 0;
            double asr = 0.0;
            long aloc = 0;

            if (gwKpi != null) {
                Number tc = (Number) gwKpi.get("totalCalls");
                Number ac = (Number) gwKpi.get("answeredCalls");
                Number asrVal = (Number) gwKpi.get("asr");
                Number alocVal = (Number) gwKpi.get("aloc");

                totalCalls = tc != null ? tc.longValue() : 0;
                answeredCalls = ac != null ? ac.longValue() : 0;
                asr = asrVal != null ? asrVal.doubleValue() : 0.0;
                aloc = alocVal != null ? alocVal.longValue() : 0;
            }

            Map<String, Object> record = new HashMap<>();
            record.put("id", id != null ? id.intValue() : 0);
            record.put("name", name);
            record.put("capacity", capacity);
            record.put("activeCalls", activeCalls);
            record.put("loadRate", loadRate);
            record.put("locktype", locktype != null ? locktype.intValue() : 0);
            record.put("totalCalls", totalCalls);
            record.put("answeredCalls", answeredCalls);
            record.put("asr", asr);
            record.put("aloc", aloc);

            result.add(record);
        }

        return success(result);
    }
}
