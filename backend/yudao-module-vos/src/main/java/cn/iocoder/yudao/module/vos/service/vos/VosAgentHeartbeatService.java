package cn.iocoder.yudao.module.vos.service.vos;

import cn.iocoder.yudao.module.vos.controller.admin.vos.vo.VosAgentHeartbeatRespVO;

import java.util.List;

/**
 * VOS Agent 心跳 / 健康看板 Service 接口
 *
 * @author yk-vos-new
 */
public interface VosAgentHeartbeatService {

    /**
     * 获得每个实例的最新心跳快照列表
     */
    List<VosAgentHeartbeatRespVO> getLatestHeartbeatList();

}
