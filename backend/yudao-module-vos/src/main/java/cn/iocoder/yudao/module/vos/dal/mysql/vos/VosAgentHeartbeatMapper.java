package cn.iocoder.yudao.module.vos.dal.mysql.vos;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentHeartbeatDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * VOS Agent 心跳状态快照 Mapper 接口
 *
 * @author ykxx
 */
@Mapper
public interface VosAgentHeartbeatMapper extends BaseMapperX<VosAgentHeartbeatDO> {

    default VosAgentHeartbeatDO selectByVosId(String vosId) {
        return selectOne(VosAgentHeartbeatDO::getVosId, vosId);
    }

    default List<VosAgentHeartbeatDO> selectLatestList() {
        return selectList(new LambdaQueryWrapperX<VosAgentHeartbeatDO>()
                .orderByDesc(VosAgentHeartbeatDO::getGeneratedAt));
    }
}
