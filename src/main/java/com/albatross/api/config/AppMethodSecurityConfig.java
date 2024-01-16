package com.albatross.api.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;

@Configuration
@EnableMethodSecurity(proxyTargetClass = true)
@RequiredArgsConstructor
public class AppMethodSecurityConfig {

}
