package cn.iocoder.yudao.module.vos.framework.clickhouse;

import com.zaxxer.hikari.HikariDataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

import jakarta.annotation.PreDestroy;

/**
 * VOS 话单查询 - ClickHouse ODS 查询数据源配置
 * <p>独立于 yudao 主库（MySQL 动态数据源），专用于话单 ODS 表 {@code vos_cdr_ods} 的查询。
 * 连接信息由 {@code ykvos.clickhouse.*} 配置项注入（docker 网络内 clickhouse:8123 直连）。</p>
 *
 * <p><b>重要约束</b>：ClickHouse 连接池<b>绝不能</b>以 {@code DataSource} 类型注册为 Spring Bean。
 * yudao 的 MyBatis {@code SqlSessionFactory} 按 {@code DataSource} 类型注入默认数据源，
 * 若存在裸的 {@code DataSource} Bean，会被误选为默认数据源，导致所有未显式 {@code @DS} 的系统表
 * （如 {@code infra_api_access_log}）写入 ClickHouse 而报错（ClickHouse 不支持 auto generated keys）。
 * 因此这里仅在方法内部 {@code new HikariDataSource()}，对外只暴露 {@code JdbcTemplate} 类型的 Bean。
 *
 * @author ykxx
 */
@Configuration
public class ClickHouseConfig {

    @Value("${ykvos.clickhouse.jdbc-url:}")
    private String jdbcUrl;

    @Value("${ykvos.clickhouse.username:default}")
    private String username;

    @Value("${ykvos.clickhouse.password:}")
    private String password;

    // 非 Spring Bean：ClickHouse 连接池仅内部持有，不暴露为 DataSource 类型（见类注释）
    private HikariDataSource chDataSource;

    /**
     * 话单 ODS 查询专用 JdbcTemplate（Bean 名 clickHouseJdbcTemplate，供 VosCdrController 按名称注入）。
     * 注意返回类型是 JdbcTemplate 而非 DataSource，避免干扰 yudao 多数据源的默认路由。
     */
    @Bean(name = "clickHouseJdbcTemplate")
    public JdbcTemplate clickHouseJdbcTemplate() {
        HikariDataSource ds = new HikariDataSource();
        ds.setDriverClassName("com.clickhouse.jdbc.ClickHouseDriver");
        ds.setJdbcUrl(jdbcUrl);
        ds.setUsername(username);
        ds.setPassword(password);
        ds.setPoolName("clickhouse-pool");
        ds.setMaximumPoolSize(5);
        ds.setMinimumIdle(1);
        ds.setConnectionTimeout(30_000);
        ds.setReadOnly(true);
        this.chDataSource = ds;
        return new JdbcTemplate(ds);
    }

    @PreDestroy
    public void destroy() {
        if (this.chDataSource != null && !this.chDataSource.isClosed()) {
            this.chDataSource.close();
        }
    }
}
