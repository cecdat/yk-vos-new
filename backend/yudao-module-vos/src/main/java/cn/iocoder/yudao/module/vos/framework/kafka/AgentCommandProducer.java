package cn.iocoder.yudao.module.vos.framework.kafka;

import cn.iocoder.yudao.module.vos.framework.kafka.dto.CommandMessage;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.Resource;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

/**
 * Kafka 指令下发生产者 (Topic: vos.agent.command)
 * 向指定 VOS Agent 下发控制指令
 *
 * @author ykxx
 */
@Component
@Slf4j
public class AgentCommandProducer {

    // 专用 Template：value 用 StringSerializer，避免 JsonSerializer 把字符串再包一层引号导致 Go 端解析失败
    @Resource
    private KafkaTemplate<String, String> vosAgentCommandKafkaTemplate;

    @Resource
    private ObjectMapper objectMapper;

    /**
     * Spring Boot 启动类加载器（LaunchedURLClassLoader）。
     * 它能看到 BOOT-INF/lib 下的所有嵌套 jar（含 yudao 租户 Kafka 拦截器）。
     * ForkJoinPool.commonPool 等异步线程的上下文类加载器默认是系统类加载器，
     * 看不到 BOOT-INF/lib，会导致首次构造 KafkaProducer 时
     * ClassNotFoundException: TenantKafkaProducerInterceptor。
     */
    private final ClassLoader appClassLoader = getClass().getClassLoader();

    /**
     * 启动即在主线程预热 Kafka Producer。
     * 这样单例 Producer 与拦截器类在主线程（上下文类加载器正确）完成加载并缓存，
     * 后续调度线程（ForkJoinPool）复用缓存实例，不再触发类加载。
     */
    @PostConstruct
    public void warmUpProducer() {
        try {
            vosAgentCommandKafkaTemplate.getProducerFactory().createProducer();
            log.info("[AgentCommandProducer] Kafka Producer 预热完成（主线程）");
        } catch (Exception e) {
            // broker 未就绪等不影响启动；真正的发送会在首次 send 时重试
            log.warn("[AgentCommandProducer] Kafka Producer 预热失败（broker 可能未就绪，将在首次发送时重试）: {}",
                    e.getMessage());
        }
    }

    /**
     * 下发指令
     *
     * @param command 指令消息 DTO
     */
    public void sendCommand(CommandMessage command) {
        log.info("[AgentCommandProducer] 下发控制指令: commandId={}, action={}, vosId={}",
                command.getCommandId(), command.getAction(), command.getVosId());
        // 关键：在异步/调度线程（ForkJoinPool）上首次构造 KafkaProducer 时，
        // 强制使用 Spring Boot 启动类加载器，否则其看不到 BOOT-INF/lib 中的租户拦截器类。
        ClassLoader old = Thread.currentThread().getContextClassLoader();
        Thread.currentThread().setContextClassLoader(appClassLoader);
        try {
            // payload 已是标准 JSON 对象字符串；由 vosAgentCommandKafkaTemplate 的 StringSerializer 原样发送
            String payload = objectMapper.writeValueAsString(command);
            // 使用 vosId 作为分区 key，保证同一 Agent 的指令顺序投递
            CompletableFuture<SendResult<String, String>> future =
                    vosAgentCommandKafkaTemplate.send(KafkaConfig.TOPIC_COMMAND, command.getVosId(), payload);
            // 同步等待送达确认：将「broker 不可达 / 序列化失败」等静默丢失转为显式异常，
            // 使上层 HTTP 接口能感知并返回失败（而非一直返回 data:true 却实际未投递到 Kafka）。
            SendResult<String, String> result = future.get(10, TimeUnit.SECONDS);
            log.info("[AgentCommandProducer] 指令已送达 Kafka: topic={}, partition={}, offset={}, commandId={}",
                    result.getRecordMetadata().topic(),
                    result.getRecordMetadata().partition(),
                    result.getRecordMetadata().offset(),
                    command.getCommandId());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("[AgentCommandProducer] 发送指令被中断, command: {}", command, e);
            throw new RuntimeException("Kafka指令发送被中断", e);
        } catch (Exception e) {
            // 涵盖 ExecutionException（broker 不可达/超时）、TimeoutException、JsonProcessingException 等
            log.error("[AgentCommandProducer] 指令未送达 Kafka(可能 broker 不可达), command: {}", command, e);
            throw new RuntimeException("Kafka指令发送失败: " + e.getMessage(), e);
        } finally {
            Thread.currentThread().setContextClassLoader(old);
        }
    }
}
