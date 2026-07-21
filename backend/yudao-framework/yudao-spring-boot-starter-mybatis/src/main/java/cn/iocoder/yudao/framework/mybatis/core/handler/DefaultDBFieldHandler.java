package cn.iocoder.yudao.framework.mybatis.core.handler;

import cn.iocoder.yudao.framework.mybatis.core.dataobject.BaseDO;
import cn.iocoder.yudao.framework.security.core.util.SecurityFrameworkUtils;
import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import org.apache.ibatis.reflection.MetaObject;

import java.time.LocalDateTime;
import java.util.Objects;

/**
 * 通用参数填充实现类
 *
 * 如果没有显式的对通用参数进行赋值，这里会对通用参数进行填充、赋值
 *
 * @author hexiaowu
 */
public class DefaultDBFieldHandler implements MetaObjectHandler {

    /**
     * 系统内置用户编号（无登录上下文时回退使用）。
     * Kafka 消费、定时任务、异步线程等场景没有登录用户，直接写入 NULL 会触发
     * creator/updater 的 NOT NULL 约束异常，故回退为系统用户 0。
     */
    private static final Long SYSTEM_USER_ID = 0L;

    @Override
    @SuppressWarnings("PatternVariableCanBeUsed")
    public void insertFill(MetaObject metaObject) {
        if (Objects.nonNull(metaObject) && metaObject.getOriginalObject() instanceof BaseDO) {
            BaseDO baseDO = (BaseDO) metaObject.getOriginalObject();

            LocalDateTime current = LocalDateTime.now();
            // 创建时间为空，则以当前时间为插入时间
            if (Objects.isNull(baseDO.getCreateTime())) {
                baseDO.setCreateTime(current);
            }
            // 更新时间为空，则以当前时间为更新时间
            if (Objects.isNull(baseDO.getUpdateTime())) {
                baseDO.setUpdateTime(current);
            }

            Long userId = getLoginUserIdOrDefault();
            // 创建人为空，则当前用户（或系统用户）为创建人
            if (Objects.isNull(baseDO.getCreator())) {
                baseDO.setCreator(userId.toString());
            }
            // 更新人为空，则当前用户（或系统用户）为更新人
            if (Objects.isNull(baseDO.getUpdater())) {
                baseDO.setUpdater(userId.toString());
            }
        }
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        // 更新时间为空，则以当前时间为更新时间
        Object modifyTime = getFieldValByName("updateTime", metaObject);
        if (Objects.isNull(modifyTime)) {
            setFieldValByName("updateTime", LocalDateTime.now(), metaObject);
        }

        // 更新人为空，则当前用户（或系统用户）为更新人
        Object modifier = getFieldValByName("updater", metaObject);
        if (Objects.isNull(modifier)) {
            Long userId = getLoginUserIdOrDefault();
            setFieldValByName("updater", userId.toString(), metaObject);
        }
    }

    /**
     * 获取当前登录用户编号；若处于无登录上下文（Kafka 消费/定时任务/异步线程），
     * 回退为系统内置用户 {@link #SYSTEM_USER_ID}，避免 creator/updater 写入 NULL。
     */
    private Long getLoginUserIdOrDefault() {
        Long userId = SecurityFrameworkUtils.getLoginUserId();
        return Objects.nonNull(userId) ? userId : SYSTEM_USER_ID;
    }
}
