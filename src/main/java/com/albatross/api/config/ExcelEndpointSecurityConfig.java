package com.albatross.api.config;

import com.albatross.api.security.excel.ExcelSharedSecretBasicAuthProvider;
import com.albatross.api.security.excel.UserBasicAuthProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import static org.springframework.security.config.http.SessionCreationPolicy.STATELESS;

@Configuration
@Order(2147483640 - 1) // higher priority than SecurityConfig
@EnableWebSecurity
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ExcelEndpointSecurityConfig extends WebSecurityConfigurerAdapter {
    public static final String EXCEL_URL_PATH = "/api/v1/excel/**";

    @Autowired
    private ExcelSharedSecretBasicAuthProvider excelBasicAuth;

    @Autowired
    private UserBasicAuthProvider userBasicAuth;

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.authenticationProvider(excelBasicAuth)
            .authenticationProvider(userBasicAuth);
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .antMatcher(EXCEL_URL_PATH)
            .sessionManagement()
                .sessionCreationPolicy(STATELESS)
                .and()
            .csrf()
                .disable()
            .cors() // piggybacks off SecurityConfig#corsConfigurationSource
                .and()
            .authorizeRequests()
                .antMatchers(HttpMethod.OPTIONS).permitAll()
                .anyRequest().authenticated()
                .and()
            .httpBasic()
                .authenticationEntryPoint(new AuthErrorHandler())
            ;
    }

    private static class AuthErrorHandler implements AuthenticationEntryPoint {
        @Override
        public void commence(HttpServletRequest request, HttpServletResponse response,
                AuthenticationException authException) throws IOException, ServletException {
            response.sendError(401, "Full authentication is required to access this resource");
        }
    }
}
