package com.albatross.api.config;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

@Configuration
@Slf4j
@Data
public class JedisPoolConfiguration {
    @Value("${redis.host:localhost}")
    private String host;

    @Value("${redis.port:6379}")
    private Integer port;

    @Value("${redis.password:}")
    private String password;

    @Value("${redis.database:1}")
    private Integer db;

    @Value("${redis.timeout:2000}")
    private Integer timeout;

    @Value("${redis.defaultTtl:60}")
    private Integer defaultTtl;

    private JedisPool pool;

    @Bean
    public JedisPool jedisPool() {
        if (pool == null) {
            try {
                JedisPoolConfig cfg = new JedisPoolConfig();
                if (password != null && password.isEmpty()) {
                    password = null;
                }
                pool = new JedisPool(cfg, host, port, timeout, password, db);
            } catch (Exception ex) {
                log.error("JEDIS_CONFIGURATION_ERROR", ex);
            }
        }

        return pool;
    }
}
