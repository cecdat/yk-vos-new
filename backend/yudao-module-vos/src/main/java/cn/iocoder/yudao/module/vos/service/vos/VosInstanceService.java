package cn.iocoder.yudao.module.vos.service.vos;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosInstancePageReqVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosInstanceRespVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosInstanceSaveReqVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosInstanceDO;

import java.util.List;

/**
 * VOS 实例 Service 接口
 *
 * @author yk-vos-new
 */
public interface VosInstanceService {

    /**
     * 创建 VOS 实例
     */
    Long createVosInstance(VosInstanceSaveReqVO createReqVO);

    /**
     * 更新 VOS 实例
     */
    void updateVosInstance(Long id, VosInstanceSaveReqVO updateReqVO);

    /**
     * 删除 VOS 实例
     */
    void deleteVosInstance(Long id);

    /**
     * 获得 VOS 实例
     */
    VosInstanceDO getVosInstance(Long id);

    /**
     * 获得 VOS 实例列表
     */
    List<VosInstanceRespVO> getVosInstanceList();

    /**
     * 获得 VOS 实例分页
     */
    PageResult<VosInstanceRespVO> getVosInstancePage(VosInstancePageReqVO pageReqVO);

}
