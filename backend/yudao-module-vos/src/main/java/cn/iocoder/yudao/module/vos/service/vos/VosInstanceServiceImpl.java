package cn.iocoder.yudao.module.vos.service.vos;

import cn.iocoder.yudao.framework.common.enums.CommonStatusEnum;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosInstancePageReqVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosInstanceRespVO;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosInstanceSaveReqVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosInstanceDO;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosInstanceMapper;
import cn.iocoder.yudao.module.vos.enums.ErrorCodeConstants;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import jakarta.annotation.Resource;
import java.util.List;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;

/**
 * VOS 实例 Service 实现类
 *
 * @author yk-vos-new
 */
@Service
@Validated
@Slf4j
public class VosInstanceServiceImpl implements VosInstanceService {

    @Resource
    private VosInstanceMapper vosInstanceMapper;

    /**
     * 单租户最大 VOS 实例数（配额）。
     * 生产环境建议接入 {@code system_tenant_package.vos_max_limit}（见服务端设计 §4.7），
     * 此处先用可配置默认值，避免改动 system 表结构。
     */
    @Value("${yk.vos.max-instance-per-tenant:999}")
    private Integer maxInstancePerTenant;

    @Override
    public Long createVosInstance(VosInstanceSaveReqVO createReqVO) {
        // 校验 vos_id 唯一
        validateVosIdUnique(null, createReqVO.getVosId());
        // 校验名称唯一
        validateNameUnique(null, createReqVO.getName());
        // 租户配额校验
        validateQuota();
        // 插入
        VosInstanceDO vosInstance = BeanUtils.toBean(createReqVO, VosInstanceDO.class);
        vosInstanceMapper.insert(vosInstance);
        return vosInstance.getId();
    }

    @Override
    public void updateVosInstance(Long id, VosInstanceSaveReqVO updateReqVO) {
        validateVosInstanceExists(id);
        validateVosIdUnique(id, updateReqVO.getVosId());
        validateNameUnique(id, updateReqVO.getName());
        VosInstanceDO updateObj = BeanUtils.toBean(updateReqVO, VosInstanceDO.class);
        updateObj.setId(id);
        vosInstanceMapper.updateById(updateObj);
    }

    @Override
    public void deleteVosInstance(Long id) {
        validateVosInstanceExists(id);
        vosInstanceMapper.deleteById(id);
    }

    @Override
    public VosInstanceDO getVosInstance(Long id) {
        return vosInstanceMapper.selectById(id);
    }

    @Override
    public List<VosInstanceRespVO> getVosInstanceList() {
        List<VosInstanceDO> list = vosInstanceMapper.selectList(new LambdaQueryWrapperX<>());
        return BeanUtils.toBean(list, VosInstanceRespVO.class);
    }

    @Override
    public PageResult<VosInstanceRespVO> getVosInstancePage(VosInstancePageReqVO pageReqVO) {
        PageResult<VosInstanceDO> pageResult = vosInstanceMapper.selectPage(pageReqVO,
                new LambdaQueryWrapperX<VosInstanceDO>()
                        .likeIfPresent(VosInstanceDO::getName, pageReqVO.getName())
                        .likeIfPresent(VosInstanceDO::getVosId, pageReqVO.getVosId())
                        .orderByDesc(VosInstanceDO::getId));
        return new PageResult<>(BeanUtils.toBean(pageResult.getList(), VosInstanceRespVO.class),
                pageResult.getTotal());
    }

    private void validateQuota() {
        Long count = vosInstanceMapper.selectCount(new LambdaQueryWrapperX<>());
        if (count >= maxInstancePerTenant) {
            throw exception(ErrorCodeConstants.VOS_INSTANCE_COUNT_EXCEEDED, maxInstancePerTenant);
        }
    }

    private void validateVosIdUnique(Long id, String vosId) {
        VosInstanceDO exist = vosInstanceMapper.selectByVosId(vosId);
        if (exist == null) {
            return;
        }
        if (id == null) {
            throw exception(ErrorCodeConstants.VOS_INSTANCE_VOS_ID_DUPLICATE);
        }
        if (!exist.getId().equals(id)) {
            throw exception(ErrorCodeConstants.VOS_INSTANCE_VOS_ID_DUPLICATE);
        }
    }

    private void validateNameUnique(Long id, String name) {
        VosInstanceDO exist = vosInstanceMapper.selectByName(name);
        if (exist == null) {
            return;
        }
        if (id == null) {
            throw exception(ErrorCodeConstants.VOS_INSTANCE_NAME_DUPLICATE);
        }
        if (!exist.getId().equals(id)) {
            throw exception(ErrorCodeConstants.VOS_INSTANCE_NAME_DUPLICATE);
        }
    }

    private void validateVosInstanceExists(Long id) {
        if (vosInstanceMapper.selectById(id) == null) {
            throw exception(ErrorCodeConstants.VOS_INSTANCE_NOT_EXISTS);
        }
    }

}
