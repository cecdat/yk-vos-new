package cn.iocoder.yudao.module.vos.framework.kafka;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;

import java.util.HashMap;
import java.util.Map;

/**
 * Kafka 基础配置与 Topic 常量声明
 *
 * @author ykxx
 */
@Configuration
public class KafkaConfig {

    /**
     * Agent 上报消息通道 (heartbeat, availability, progress, ack)
     */
    public static final String TOPIC_REPORT = "vos.agent.report";

    /**
     * 平台下发控制指令通道
     */
    public static final String TOPIC_COMMAND = "vos.agent.command";

    /**
     * 历史话单回填专属物理隔离数据通道
     */
    public static final String TOPIC_BACKFILL_DATA = "vos.agent.backfill.data";

    /**
     * Agent 上报消息专用的消费者工厂。
     *
     * <p><b>关键原因：</b>Agent 端使用 Go(kafka-go) 直接发送「原始 JSON 字节」，不会带上 Spring Kafka
     * {@code JsonDeserializer} 所需的 {@code __TypeId__} 类型头，全局配置也没有指定默认目标类型。
     * 若沿用全局的 {@code JsonDeserializer}，反序列化会在「进入监听器方法之前」就抛出
     * {@code No type information in headers and no default type provided}，
     * 导致整条消费线程卡死、位点永远无法提交、每条拉取都重复报错。</p>
     *
     * <p>因此这里显式使用 {@link StringDeserializer}，把 value 原样反序列化为字符串，
     * 交由 {@code AgentReportConsumer} 内部用 {@code ObjectMapper} 手动解析为 {@code ReportMessage}。
     * 这样即便某条消息不是合法 JSON，也只会在监听器方法里被 try/catch 捕获并跳过，不会拖垮整个消费者。</p>
     */
    @Bean
    public ConsumerFactory<String, String> vosAgentReportConsumerFactory(KafkaProperties properties) {
        Map<String, Object> props = new HashMap<>(properties.buildConsumerProperties());
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        return new DefaultKafkaConsumerFactory<>(props);
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, String> vosAgentReportKafkaListenerContainerFactory(
            ConsumerFactory<String, String> vosAgentReportConsumerFactory) {
        ConcurrentKafkaListenerContainerFactory<String, String> factory =
                new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(vosAgentReportConsumerFactory);
        return factory;
    }

    /**
     * Agent 控制指令下发专用的 KafkaTemplate。
     *
     * <p><b>关键原因：</b>全局 {@code spring.kafka.producer.value-serializer} 配置为
     * {@code JsonSerializer}。当 value 类型为 {@code String} 时，{@code JsonSerializer}
     * 会把字符串整体再包一层 JSON 引号（即把 {@code {"action":"rescan"}} 变成
     * {@code "{\"action\":\"rescan\"}"}），导致 Go 端（kafka-go）用 {@code json.Unmarshal}
     * 解析时抛出 {@code cannot unmarshal string into ...CommandMessage}。</p>
     *
     * <p>这里显式用 {@link StringSerializer}，配合 {@code AgentCommandProducer} 中已用
     * {@code ObjectMapper} 手动序列化出的「原始 JSON 字符串」直接发送，value 即标准 JSON 对象，
     * Go 端可正常反序列化。该专用 Template 不影响其它模块（如 websocket）仍使用 JsonSerializer。</p>
     */
    @Bean
    public KafkaTemplate<String, String> vosAgentCommandKafkaTemplate(KafkaProperties properties) {
        Map<String, Object> props = new HashMap<>(properties.buildProducerProperties());
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        return new KafkaTemplate<>(new DefaultKafkaProducerFactory<>(props));
    }
}
