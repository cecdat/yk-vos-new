package cn.iocoder.yudao.module.vos.framework.kafka;

import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.stereotype.Component;

/**
 * 专属历史回填数据消费者 (Topic: vos.agent.backfill.data)
 * 物理隔离大吞吐量 ODS 回填信封，防止阻塞控制信号
 *
 * @author ykxx
 */
@Component
@Slf4j
public class BackfillDataConsumer {

    @KafkaListener(topics = KafkaConfig.TOPIC_BACKFILL_DATA,
            groupId = "vos-backfill-data-group",
            containerFactory = "vosAgentReportKafkaListenerContainerFactory")
    public void onMessage(String msg, @Header(KafkaHeaders.RECEIVED_KEY) String key) {
        if (log.isDebugEnabled()) {
            log.debug("[BackfillDataConsumer] 接收到 ODS 回填信封, key={}, length={}", key, msg.length());
        }
        // 目前主要由 ClickHouse 侧 Kafka Engine 表直接接入消费，此 Listener 作为服务端消费接口审计。
    }
}
