package cn.iocoder.yudao.module.vos.dal.mysql.vos;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentBackfillTaskDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * VOS Agent 回填控制任务 Mapper 接口
 *
 * @author ykxx
 */
@Mapper
public interface VosAgentBackfillTaskMapper extends BaseMapperX<VosAgentBackfillTaskDO> {

    default VosAgentBackfillTaskDO selectByCommandId(String commandId) {
        return selectOne(VosAgentBackfillTaskDO::getCommandId, commandId);
    }
}
