package cn.iocoder.yudao.module.vos.controller.admin.vos;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosAgentBackfillRespVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosBackfillTaskSaveReqVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosBackfillTaskRespVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentBackfillDO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentBackfillTaskDO;
import cn.iocoder.yudao.module.vos.service.backfill.VosBackfillService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.Parameters;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import java.util.List;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

/**
 * 管理后台 - VOS 历史话单回填与控制指令 Controller
 *
 * @author ykxx
 */
@Tag(name = "管理后台 - VOS 历史话单回填")
@RestController
@RequestMapping("/vos/backfill")
@Validated
public class VosBackfillController {

    @Resource
    private VosBackfillService vosBackfillService;

    @PostMapping("/start")
    @Operation(summary = "启动历史回填任务")
    @PreAuthorize("@ss.hasPermission('vos:backfill:start')")
    public CommonResult<String> startBackfill(@Valid @RequestBody VosBackfillTaskSaveReqVO reqVO) {
        String status = vosBackfillService.startBackfill(reqVO);
        return success(status); // 返回 dispatched 或 queued
    }

    @PostMapping("/dispatch")
    @Operation(summary = "手动下发（启动下发）待下发/排队中的回填任务")
    @Parameter(name = "id", description = "回填任务主键", required = true)
    @PreAuthorize("@ss.hasPermission('vos:backfill:start')")
    public CommonResult<Boolean> dispatchBackfill(@RequestParam("id") Long id) {
        vosBackfillService.dispatchBackfill(id);
        return success(true);
    }

    @PutMapping("/pause")
    @Operation(summary = "暂停回填任务")
    @Parameter(name = "commandId", description = "原指令 UUID", required = true)
    @PreAuthorize("@ss.hasPermission('vos:backfill:pause')")
    public CommonResult<Boolean> pauseBackfill(@RequestParam("commandId") String commandId) {
        vosBackfillService.pauseBackfill(commandId);
        return success(true);
    }

    @PutMapping("/resume")
    @Operation(summary = "恢复回填任务")
    @Parameter(name = "commandId", description = "原指令 UUID", required = true)
    @PreAuthorize("@ss.hasPermission('vos:backfill:resume')")
    public CommonResult<Boolean> resumeBackfill(@RequestParam("commandId") String commandId) {
        vosBackfillService.resumeBackfill(commandId);
        return success(true);
    }

    @PutMapping("/cancel")
    @Operation(summary = "取消回填任务")
    @Parameter(name = "commandId", description = "原指令 UUID", required = true)
    @PreAuthorize("@ss.hasPermission('vos:backfill:cancel')")
    public CommonResult<Boolean> cancelBackfill(@RequestParam("commandId") String commandId) {
        vosBackfillService.cancelBackfill(commandId);
        return success(true);
    }

    @PutMapping("/throttle")
    @Operation(summary = "调整同步限速")
    @Parameters({
            @Parameter(name = "commandId", description = "原指令 UUID", required = true),
            @Parameter(name = "speedLimit", description = "每秒最大流速行数", required = true)
    })
    @PreAuthorize("@ss.hasPermission('vos:backfill:throttle')")
    public CommonResult<Boolean> setThrottle(@RequestParam("commandId") String commandId,
                                             @RequestParam("speedLimit") Long speedLimit) {
        vosBackfillService.setThrottle(commandId, speedLimit);
        return success(true);
    }

    @PostMapping("/precise-count")
    @Operation(summary = "发起精确行数统计 (COUNT(*))")
    @Parameters({
            @Parameter(name = "vosId", description = "实例 ID", required = true),
            @Parameter(name = "tableName", description = "历史日表名", required = true)
    })
    @PreAuthorize("@ss.hasPermission('vos:backfill:precise-count')")
    public CommonResult<Boolean> triggerPreciseCount(@RequestParam("vosId") String vosId,
                                                     @RequestParam("tableName") String tableName) {
        vosBackfillService.triggerPreciseCount(vosId, tableName);
        return success(true);
    }

    @PostMapping("/rescan")
    @Operation(summary = "重新扫描实例可用历史日表")
    @Parameter(name = "vosId", description = "实例 ID", required = true)
    @PreAuthorize("@ss.hasPermission('vos:backfill:rescan')")
    public CommonResult<Boolean> triggerRescan(@RequestParam("vosId") String vosId) {
        vosBackfillService.triggerRescan(vosId);
        return success(true);
    }

    @GetMapping("/availabilities")
    @Operation(summary = "查询实例可用历史表列表")
    @Parameter(name = "vosId", description = "实例 ID", required = true)
    @PreAuthorize("@ss.hasPermission('vos:backfill:list')")
    public CommonResult<List<VosAgentBackfillRespVO>> getAvailabilityList(@RequestParam("vosId") String vosId) {
        List<VosAgentBackfillDO> list = vosBackfillService.getAvailabilityList(vosId);
        return success(BeanUtils.toBean(list, VosAgentBackfillRespVO.class));
    }

    @GetMapping("/tasks")
    @Operation(summary = "查询回填任务执行历史记录")
    @Parameter(name = "vosId", description = "实例 ID", required = true)
    @PreAuthorize("@ss.hasPermission('vos:backfill:list')")
    public CommonResult<List<VosBackfillTaskRespVO>> getTaskList(@RequestParam("vosId") String vosId) {
        List<VosAgentBackfillTaskDO> list = vosBackfillService.getTaskList(vosId);
        return success(BeanUtils.toBean(list, VosBackfillTaskRespVO.class));
    }
}
