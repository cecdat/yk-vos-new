package cn.iocoder.yudao.module.vos.controller.admin.vos;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosCustomerPageReqVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosCustomerRespVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosCustomerUpdateLimitReqVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosCustomerUpdateStatusReqVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosCustomerDO;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosCustomerMapper;
import cn.iocoder.yudao.module.vos.framework.kafka.AgentCommandProducer;
import cn.iocoder.yudao.module.vos.framework.kafka.dto.CommandMessage;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

/**
 * 管理后台 - VOS 客户财务管理 Controller
 *
 * @author ykxx
 */
@Tag(name = "管理后台 - VOS 客户财务管理")
@RestController
@RequestMapping("/vos/customer")
@Validated
public class VosCustomerController {

    @Resource
    private VosCustomerMapper vosCustomerMapper;

    @Resource
    private AgentCommandProducer agentCommandProducer;

    @GetMapping("/page")
    @Operation(summary = "获得客户分页列表")
    @PreAuthorize("@ss.hasPermission('vos:customer:query')")
    public CommonResult<PageResult<VosCustomerRespVO>> getCustomerPage(@Valid VosCustomerPageReqVO pageVO) {
        PageResult<VosCustomerDO> pageResult = vosCustomerMapper.selectPage(pageVO);
        return success(BeanUtils.toBean(pageResult, VosCustomerRespVO.class));
    }

    @PutMapping("/update-limit")
    @Operation(summary = "修改客户可用信用额度")
    @PreAuthorize("@ss.hasPermission('vos:customer:write')")
    public CommonResult<Boolean> updateCustomerLimit(@Valid @RequestBody VosCustomerUpdateLimitReqVO limitVO) {
        VosCustomerDO customer = vosCustomerMapper.selectById(limitVO.getId());
        if (customer == null) {
            throw new IllegalArgumentException("客户记录不存在");
        }

        // 下发控制指令
        CommandMessage command = new CommandMessage()
                .setVosId(customer.getVosId())
                .setCommandId(UUID.randomUUID().toString())
                .setAction("update_limit");

        Map<String, Object> params = new HashMap<>();
        params.put("customerId", customer.getCustomerId());
        params.put("account", customer.getAccount());
        params.put("limitmoney", limitVO.getLimitmoney().doubleValue());
        command.setParams(params);

        agentCommandProducer.sendCommand(command);

        // 同步修改本地缓存，使前端页面即时响应
        customer.setLimitmoney(limitVO.getLimitmoney());
        vosCustomerMapper.updateById(customer);

        return success(true);
    }

    @PutMapping("/update-status")
    @Operation(summary = "锁定或解冻客户账户")
    @PreAuthorize("@ss.hasPermission('vos:customer:write')")
    public CommonResult<Boolean> updateCustomerStatus(@Valid @RequestBody VosCustomerUpdateStatusReqVO statusVO) {
        if (statusVO.getStatus() != 0 && statusVO.getStatus() != 1) {
            throw new IllegalArgumentException("非法的状态值，仅允许 0 (正常) 或 1 (冻结)");
        }

        VosCustomerDO customer = vosCustomerMapper.selectById(statusVO.getId());
        if (customer == null) {
            throw new IllegalArgumentException("客户记录不存在");
        }

        // 下发控制指令
        CommandMessage command = new CommandMessage()
                .setVosId(customer.getVosId())
                .setCommandId(UUID.randomUUID().toString())
                .setAction("set_status");

        Map<String, Object> params = new HashMap<>();
        params.put("customerId", customer.getCustomerId());
        params.put("account", customer.getAccount());
        params.put("status", statusVO.getStatus());
        command.setParams(params);

        agentCommandProducer.sendCommand(command);

        // 同步修改本地缓存，使前端页面即时响应
        customer.setStatus(statusVO.getStatus());
        vosCustomerMapper.updateById(customer);

        return success(true);
    }
}
