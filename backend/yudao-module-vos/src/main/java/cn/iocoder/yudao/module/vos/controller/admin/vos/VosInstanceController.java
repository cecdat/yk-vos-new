package cn.iocoder.yudao.module.vos.controller.admin.vos;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosInstancePageReqVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosInstanceRespVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosInstanceSaveReqVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosInstanceDO;
import cn.iocoder.yudao.module.vos.service.vos.VosInstanceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import java.util.List;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

/**
 * VOS 实例 Controller：对接管理 / VOS 管理
 *
 * @author yk-vos-new
 */
@Tag(name = "管理后台 - VOS 实例")
@RestController
@RequestMapping("/vos/instances")
@Validated
public class VosInstanceController {

    @Resource
    private VosInstanceService vosInstanceService;

    @PostMapping
    @Operation(summary = "创建 VOS 实例")
    @PreAuthorize("@ss.hasPermission('vos:instance:create')")
    public CommonResult<Long> createVosInstance(@Valid @RequestBody VosInstanceSaveReqVO createReqVO) {
        return success(vosInstanceService.createVosInstance(createReqVO));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新 VOS 实例")
    @Parameter(name = "id", description = "编号", required = true, example = "1024")
    @PreAuthorize("@ss.hasPermission('vos:instance:update')")
    public CommonResult<Boolean> updateVosInstance(@PathVariable("id") Long id,
                                                  @Valid @RequestBody VosInstanceSaveReqVO updateReqVO) {
        vosInstanceService.updateVosInstance(id, updateReqVO);
        return success(true);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除 VOS 实例")
    @Parameter(name = "id", description = "编号", required = true, example = "1024")
    @PreAuthorize("@ss.hasPermission('vos:instance:delete')")
    public CommonResult<Boolean> deleteVosInstance(@PathVariable("id") Long id) {
        vosInstanceService.deleteVosInstance(id);
        return success(true);
    }

    @GetMapping("/list")
    @Operation(summary = "获得 VOS 实例列表（全量）")
    @PreAuthorize("@ss.hasPermission('vos:instance:list')")
    public CommonResult<List<VosInstanceRespVO>> getVosInstanceList() {
        return success(vosInstanceService.getVosInstanceList());
    }

    @GetMapping("/page")
    @Operation(summary = "获得 VOS 实例分页")
    @PreAuthorize("@ss.hasPermission('vos:instance:list')")
    public CommonResult<PageResult<VosInstanceRespVO>> getVosInstancePage(VosInstancePageReqVO pageReqVO) {
        return success(vosInstanceService.getVosInstancePage(pageReqVO));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获得 VOS 实例详情")
    @Parameter(name = "id", description = "编号", required = true, example = "1024")
    @PreAuthorize("@ss.hasPermission('vos:instance:list')")
    public CommonResult<VosInstanceDO> getVosInstance(@PathVariable("id") Long id) {
        return success(vosInstanceService.getVosInstance(id));
    }

}
