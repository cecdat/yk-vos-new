package cn.iocoder.yudao.module.vos.service.vos;

import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosAgentHeartbeatRespVO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosAgentHeartbeatDO;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosAgentHeartbeatMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import jakarta.annotation.Resource;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * VOS Agent 心跳 / 健康看板 Service 实现类
 *
 * @author yk-vos-new
 */
@Service
@Validated
@Slf4j
public class VosAgentHeartbeatServiceImpl implements VosAgentHeartbeatService {

    @Resource
    private VosAgentHeartbeatMapper heartbeatMapper;

    @Override
    public List<VosAgentHeartbeatRespVO> getLatestHeartbeatList() {
        // 已按 generated_at DESC 排序，每个 vos_id 保留首条即为最新
        List<VosAgentHeartbeatDO> all = heartbeatMapper.selectLatestList();
        Map<String, VosAgentHeartbeatRespVO> latest = new LinkedHashMap<>();
        for (VosAgentHeartbeatDO heartbeatDO : all) {
            latest.putIfAbsent(heartbeatDO.getVosId(),
                    BeanUtils.toBean(heartbeatDO, VosAgentHeartbeatRespVO.class));
        }
        return new ArrayList<>(latest.values());
    }

}
