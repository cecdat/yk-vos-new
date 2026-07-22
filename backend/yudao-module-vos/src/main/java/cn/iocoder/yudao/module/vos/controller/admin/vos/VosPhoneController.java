package cn.iocoder.yudao.module.vos.controller.admin.vos;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosPhonePageReqVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosPhoneRespVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosPhoneRecycleReqVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosInstanceDO;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosInstanceMapper;
import cn.iocoder.yudao.module.vos.framework.kafka.AgentCommandProducer;
import cn.iocoder.yudao.module.vos.framework.kafka.dto.CommandMessage;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import java.util.*;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - VOS 号码管理")
@RestController
@RequestMapping("/vos/phone")
@Validated
@Slf4j
public class VosPhoneController {

    @Resource
    private VosInstanceMapper vosInstanceMapper;

    @Resource
    private JdbcTemplate clickHouseJdbcTemplate;

    @Resource
    private AgentCommandProducer agentCommandProducer;

    @GetMapping("/page")
    @Operation(summary = "获得号码分页列表")
    @PreAuthorize("@ss.hasPermission('vos:phone:query')")
    public CommonResult<PageResult<VosPhoneRespVO>> getPhonePage(@Valid VosPhonePageReqVO pageVO) {
        VosInstanceDO instance = vosInstanceMapper.selectById(pageVO.getInstanceId());
        if (instance == null) {
            return success(PageResult.empty());
        }
        String vosId = instance.getVosId();

        // 1. 构建 ClickHouse SQL 查询
        String baseSql = " FROM vos_phone_ods FINAL WHERE vos_id = ? ";
        List<Object> params = new ArrayList<>();
        params.add(vosId);

        if (pageVO.getE164() != null && !pageVO.getE164().trim().isEmpty()) {
            baseSql += " AND e164 LIKE ? ";
            params.add("%" + pageVO.getE164().trim() + "%");
        }

        // 2. 查询总记录数
        String countSql = "SELECT count(1) " + baseSql;
        Long total = clickHouseJdbcTemplate.queryForObject(countSql, Long.class, params.toArray());
        if (total == null || total == 0) {
            return success(PageResult.empty());
        }

        // 3. 分页查询列表
        String selectSql = "SELECT id, e164, feerategroup_id " + baseSql + " ORDER BY id DESC LIMIT ?, ?";
        int offset = (pageVO.getPageNo() - 1) * pageVO.getPageSize();
        params.add(offset);
        params.add(pageVO.getPageSize());

        List<VosPhoneRespVO> list = clickHouseJdbcTemplate.query(selectSql, (rs, rowNum) -> {
            VosPhoneRespVO resp = new VosPhoneRespVO();
            resp.setId(rs.getInt("id"));
            resp.setE164(rs.getString("e164"));
            resp.setFeerategroupId(rs.getInt("feerategroup_id"));
            return resp;
        }, params.toArray());

        return success(new PageResult<>(list, total));
    }

    @PostMapping("/recycle")
    @Operation(summary = "批量回收/删除号码")
    @PreAuthorize("@ss.hasPermission('vos:phone:delete')")
    public CommonResult<Boolean> recyclePhone(@Valid @RequestBody VosPhoneRecycleReqVO recycleVO) {
        VosInstanceDO instance = vosInstanceMapper.selectById(recycleVO.getInstanceId());
        if (instance == null) {
            throw new IllegalArgumentException("VOS 实例记录不存在");
        }
        String vosId = instance.getVosId();

        // 1. 发送 Kafka 回收指令
        CommandMessage message = new CommandMessage()
                .setVosId(vosId)
                .setCommandId(UUID.randomUUID().toString())
                .setAction("recycle_phone");

        Map<String, Object> params = new HashMap<>();
        params.put("e164s", recycleVO.getE164s());
        message.setParams(params);

        try {
            agentCommandProducer.sendCommand(message);
            log.info("[recyclePhone] 号码批量回收指令投递成功: vosId={}, size={}", vosId, recycleVO.getE164s().size());
        } catch (Exception e) {
            log.error("[recyclePhone] 号码批量回收指令投递失败: ", e);
            throw new RuntimeException("Kafka 消息发送失败，请稍后重试");
        }

        // 2. 清退 ClickHouse 本地缓存，保证 UI 界面能迅速刷新而不用等待下一次同步
        try {
            if (!recycleVO.getE164s().isEmpty()) {
                StringBuilder placeholder = new StringBuilder();
                List<Object> chParams = new ArrayList<>();
                chParams.add(vosId);
                for (int i = 0; i < recycleVO.getE164s().size(); i++) {
                    if (i > 0) placeholder.append(",");
                    placeholder.append("?");
                    chParams.add(recycleVO.getE164s().get(i));
                }
                String chDeleteSql = String.format("ALTER TABLE vos_phone_ods DELETE WHERE vos_id = ? AND e164 IN (%s)", placeholder);
                clickHouseJdbcTemplate.update(chDeleteSql, chParams.toArray());
                log.info("[recyclePhone] 发送 ClickHouse 缓存清退完成: vosId={}", vosId);
            }
        } catch (Exception e) {
            log.warn("[recyclePhone] ClickHouse 异步缓存清退未成功(非致命错误): ", e);
        }

        return success(true);
    }
}
