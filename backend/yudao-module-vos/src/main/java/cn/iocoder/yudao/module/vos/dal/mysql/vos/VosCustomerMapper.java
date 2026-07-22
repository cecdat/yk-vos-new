package cn.iocoder.yudao.module.vos.dal.mysql.vos;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosCustomerPageReqVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosCustomerDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * VOS 客户本地镜像缓存 Mapper
 *
 * @author ykxx
 */
@Mapper
@SuppressWarnings("all")
public interface VosCustomerMapper extends BaseMapperX<VosCustomerDO> {

    default PageResult<VosCustomerDO> selectPage(VosCustomerPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<VosCustomerDO>()
                .eqIfPresent(VosCustomerDO::getVosId, reqVO.getVosId())
                .likeIfPresent(VosCustomerDO::getAccount, reqVO.getAccount())
                .eqIfPresent(VosCustomerDO::getStatus, reqVO.getStatus())
                .orderByDesc(VosCustomerDO::getId));
    }

    default VosCustomerDO selectByVosAndCustomer(String vosId, Integer customerId) {
        return selectOne("vos_id", vosId, "customer_id", customerId);
    }

}
