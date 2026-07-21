package cn.iocoder.yudao.module.vos.enums;

import cn.iocoder.yudao.framework.common.exception.ErrorCode;

/**
 * VOS 模块错误码枚举类
 *
 * vos 模块，使用 1-020-000-000 段
 */
public interface ErrorCodeConstants {

    // ========== VOS 实例 1-020-000-000 ==========
    ErrorCode VOS_INSTANCE_NOT_EXISTS = new ErrorCode(1_020_000_001, "VOS 实例不存在");
    ErrorCode VOS_INSTANCE_NAME_DUPLICATE = new ErrorCode(1_020_000_002, "已经存在该名字的 VOS 实例");
    ErrorCode VOS_INSTANCE_VOS_ID_DUPLICATE = new ErrorCode(1_020_000_003, "已经存在该 Agent ID(vos_id) 的 VOS 实例");
    ErrorCode VOS_INSTANCE_COUNT_EXCEEDED = new ErrorCode(1_020_000_004,
            "创建失败！您的租户级别最大允许添加 {} 个 VOS 实例，请联系管理员升级租户套餐。");

    // ========== VOS Agent 心跳 / 回填任务 1-020-001-000 ==========
    ErrorCode VOS_BACKFILL_TASK_NOT_EXISTS = new ErrorCode(1_020_001_001, "回填任务不存在");
    ErrorCode VOS_BACKFILL_TASK_STATUS_ERROR = new ErrorCode(1_020_001_002, "回填任务状态异常，无法执行该操作");

}
