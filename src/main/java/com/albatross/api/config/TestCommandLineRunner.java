package com.albatross.api.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class TestCommandLineRunner implements CommandLineRunner {
    @Value("${spring.datasource.url}")
    String databaseURL;

    @Value("${spring.datasource.username}")
    String databaseUsername;

    @Override
    public void run(String... args) throws Exception {
        log.info("[FARGATE] Datasource URL: {}", databaseURL);
        log.info("[FARGATE] Datasource Username: {}", databaseUsername);
    }
}
