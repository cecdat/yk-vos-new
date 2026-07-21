package cn.iocoder.yudao.module.vos.dal.mysql.vos;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentBackfillDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * VOS 话单可用性 Mapper 接口
 *
 * @author ykxx
 */
@Mapper
public interface VosAgentBackfillMapper extends BaseMapperX<VosAgentBackfillDO> {

    default VosAgentBackfillDO selectByVosIdAndTable(String vosId, String tableName) {
        return selectOne(VosAgentBackfillDO::getVosId, vosId, VosAgentBackfillDO::getTableName, tableName);
    }

    default List<VosAgentBackfillDO> selectListByVosId(String vosId) {
        return selectList(VosAgentBackfillDO::getVosId, vosId);
    }
}
