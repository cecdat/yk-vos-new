package cn.iocoder.yudao.module.vos.dal.mysql.vos;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosCustomerDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * VOS 客户本地镜像缓存 Mapper
 *
 * @author ykxx
 */
@Mapper
public interface VosCustomerMapper extends BaseMapperX<VosCustomerDO> {

    default VosCustomerDO selectByVosAndCustomer(String vosId, Integer customerId) {
        return selectOne("vos_id", vosId, "customer_id", customerId);
    }

}
