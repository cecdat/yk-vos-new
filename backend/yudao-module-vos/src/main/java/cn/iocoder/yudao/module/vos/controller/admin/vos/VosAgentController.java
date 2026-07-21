package cn.iocoder.yudao.module.vos.controller.admin.vos;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosAgentHeartbeatRespVO;
import cn.iocoder.yudao.module.vos.service.vos.VosAgentHeartbeatService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.Resource;
import java.util.List;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

/**
 * VOS Agent Controller：健康看板 / 监控运维
 *
 * @author yk-vos-new
 */
@Tag(name = "管理后台 - VOS Agent")
@RestController
@RequestMapping("/vos/agents")
@Validated
public class VosAgentController {

    @Resource
    private VosAgentHeartbeatService heartbeatService;

    @GetMapping("/heartbeat")
    @Operation(summary = "获得 Agent 心跳 / 健康最新快照列表")
    @PreAuthorize("@ss.hasPermission('vos:agent:health')")
    public CommonResult<List<VosAgentHeartbeatRespVO>> getHeartbeatList() {
        return success(heartbeatService.getLatestHeartbeatList());
    }

}
