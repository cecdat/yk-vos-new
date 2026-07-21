package cn.iocoder.yudao.module.vos.dal.mysql.vos;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosInstancePageReqVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosInstanceDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * VOS 实例 Mapper 接口
 *
 * @author ykxx
 */
@Mapper
public interface VosInstanceMapper extends BaseMapperX<VosInstanceDO> {

    default PageResult<VosInstanceDO> selectPage(VosInstancePageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<VosInstanceDO>()
                .likeIfPresent(VosInstanceDO::getName, reqVO.getName())
                .likeIfPresent(VosInstanceDO::getVosId, reqVO.getVosId())
                .orderByDesc(VosInstanceDO::getId));
    }

    default VosInstanceDO selectByVosId(String vosId) {
        return selectOne(VosInstanceDO::getVosId, vosId);
    }

    default VosInstanceDO selectByName(String name) {
        return selectOne(VosInstanceDO::getName, name);
    }
}
