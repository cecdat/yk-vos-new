package cn.iocoder.yudao.module.vos.framework.kafka;

import cn.iocoder.yudao.framework.tenant.core.util.TenantUtils;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosCustomerDO;
import cn.iocoder.yudao.module.vos.dal.dataobject.VosInstanceDO;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosCustomerMapper;
import cn.iocoder.yudao.module.vos.dal.mysql.vos.VosInstanceMapper;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import jakarta.annotation.Resource;
import java.math.BigDecimal;
import java.util.Map;

/**
 * 实时话单与维度数据同步消费者 (Topic: vos.cdr.live)
 * 消费来自 Agent 定时/增量上报的维度数据 (如 e_customer)，并缓存同步至中台本地 MySQL 库。
 * 话单主体仍由 ClickHouse 侧 Kafka Engine 进行高吞吐量直接接入。
 *
 * @author ykxx
 */
@Component
@Slf4j
public class VosCdrLiveConsumer {

    @Resource
    private ObjectMapper objectMapper;

    @Resource
    private VosInstanceMapper vosInstanceMapper;

    @Resource
    private VosCustomerMapper vosCustomerMapper;

    @KafkaListener(topics = KafkaConfig.TOPIC_CDR_LIVE,
            groupId = "vos-cdr-live-group",
            containerFactory = "vosAgentReportKafkaListenerContainerFactory")
    public void onMessage(String record) {
        log.debug("[VosCdrLiveConsumer] 接收到实时信封数据: {}", record);
        try {
            VosCdrEnvelope envelope = objectMapper.readValue(record, VosCdrEnvelope.class);
            if (envelope == null || envelope.getVosId() == null || envelope.getSrcTable() == null) {
                return;
            }

            // 仅对维度表 e_customer 数据做同步，其余话单数据由 ClickHouse 自动消化
            if (!"e_customer".equalsIgnoreCase(envelope.getSrcTable())) {
                return;
            }

            // 1. 查询对应 VOS 实例的注册信息，并获取其绑定的租户 ID
            Long tenantId = getTenantIdByVosId(envelope.getVosId());
            if (tenantId == null) {
                log.warn("[VosCdrLiveConsumer] 未找到对应 vos_id [{}] 的注册实例，丢弃消息", envelope.getVosId());
                return;
            }

            // 2. 以相应租户的上下文，执行本地 MySQL 缓存表的 Upsert
            TenantUtils.execute(tenantId, () -> {
                handleCustomerSync(envelope);
            });

        } catch (Exception e) {
            log.error("[VosCdrLiveConsumer] 消费实时维度消息出现异常: ", e);
        }
    }

    private void handleCustomerSync(VosCdrEnvelope envelope) {
        Map<String, Object> data = envelope.getData();
        if (data == null || !data.containsKey("id") || !data.containsKey("account")) {
            return;
        }

        try {
            Integer customerId = getInteger(data.get("id"));
            String account = getString(data.get("account"));
            if (customerId == null || account == null) {
                return;
            }

            String name = getString(data.get("name"));
            BigDecimal money = getBigDecimal(data.get("money"));
            BigDecimal limitmoney = getBigDecimal(data.get("limitmoney"));
            BigDecimal todayconsumption = getBigDecimal(data.get("todayconsumption"));
            Integer status = getInteger(data.get("status"));
            Integer feerategroupId = getInteger(data.get("feerategroup_id"));

            // 执行本地缓存表 upsert
            VosCustomerDO customer = vosCustomerMapper.selectByVosAndCustomer(envelope.getVosId(), customerId);
            if (customer == null) {
                customer = new VosCustomerDO()
                        .setVosId(envelope.getVosId())
                        .setCustomerId(customerId)
                        .setAccount(account)
                        .setName(name != null ? name : "")
                        .setMoney(money != null ? money : BigDecimal.ZERO)
                        .setLimitmoney(limitmoney != null ? limitmoney : BigDecimal.ZERO)
                        .setTodayconsumption(todayconsumption != null ? todayconsumption : BigDecimal.ZERO)
                        .setStatus(status != null ? status : 0)
                        .setFeerategroupId(feerategroupId);
                vosCustomerMapper.insert(customer);
                log.info("[VosCdrLiveConsumer] 新增 VOS 客户缓存成功: vosId={}, account={}", envelope.getVosId(), account);
            } else {
                customer.setAccount(account)
                        .setName(name != null ? name : customer.getName())
                        .setMoney(money != null ? money : customer.getMoney())
                        .setLimitmoney(limitmoney != null ? limitmoney : customer.getLimitmoney())
                        .setTodayconsumption(todayconsumption != null ? todayconsumption : customer.getTodayconsumption())
                        .setStatus(status != null ? status : customer.getStatus())
                        .setFeerategroupId(feerategroupId != null ? feerategroupId : customer.getFeerategroupId());
                vosCustomerMapper.updateById(customer);
                log.debug("[VosCdrLiveConsumer] 更新 VOS 客户缓存成功: vosId={}, account={}", envelope.getVosId(), account);
            }
        } catch (Exception e) {
            log.error("[VosCdrLiveConsumer] 解析客户维度并同步到数据库出错: ", e);
        }
    }

    private Long getTenantIdByVosId(String vosId) {
        try {
            VosInstanceDO instance = TenantUtils.executeIgnore(() ->
                    vosInstanceMapper.selectByVosId(vosId)
            );
            if (instance != null) {
                return instance.getTenantId();
            }
        } catch (Exception e) {
            log.error("[VosCdrLiveConsumer] 查询 VOS 实例所属租户失败, vosId: {}, error: {}", vosId, e.getMessage());
        }
        return null;
    }

    private Integer getInteger(Object val) {
        if (val == null) {
            return null;
        }
        if (val instanceof Number) {
            return ((Number) val).intValue();
        }
        try {
            return Integer.parseInt(val.toString());
        } catch (Exception e) {
            return null;
        }
    }

    private String getString(Object val) {
        if (val == null) {
            return null;
        }
        return val.toString();
    }

    private BigDecimal getBigDecimal(Object val) {
        if (val == null) {
            return null;
        }
        try {
            return new BigDecimal(val.toString());
        } catch (Exception e) {
            return null;
        }
    }

    @Data
    public static class VosCdrEnvelope {
        @JsonProperty("schema_version")
        private Integer schemaVersion;
        private String op;
        @JsonProperty("vos_id")
        private String vosId;
        @JsonProperty("src_table")
        private String srcTable;
        private Long flowno;
        private Long ts;
        private Map<String, Object> data;
    }
}
