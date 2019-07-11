package com.albatross.api.config;

import com.albatross.api.security.LoginSuccessHandler;
import com.albatross.api.security.jwt.JwtAuthenticationProvider;
import lombok.SneakyThrows;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.access.ExceptionTranslationFilter;
import org.springframework.security.web.authentication.preauth.AbstractPreAuthenticatedProcessingFilter;
import org.springframework.security.web.authentication.preauth.RequestHeaderAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

import static org.springframework.security.config.http.SessionCreationPolicy.STATELESS;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {

  @Autowired
  private JwtAuthenticationProvider jwtAuth;

  @Bean
  public LoginSuccessHandler loginSuccessHandler() {
    return new LoginSuccessHandler();
  }

  @Bean
  public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

  @Bean
  CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    configuration.setAllowCredentials(true);
    configuration.setAllowedHeaders(Arrays.asList("*"));
    configuration.setAllowedOrigins(Arrays.asList("*"));
    configuration.setAllowedMethods(Arrays.asList("*"));
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
  }

  @Override
  protected void configure(HttpSecurity http) throws Exception {
    http
//        .anonymous().disable()
        .sessionManagement()
        .sessionCreationPolicy(STATELESS)
        .and()
        .cors()
        .and()
        .authorizeRequests()
        .antMatchers("/auth/login").permitAll()
        // todo: don't permit all api requests
        .antMatchers("/api/v1/**").permitAll()
        .anyRequest().authenticated()
        .and()
        .exceptionHandling()
        .accessDeniedPage("/403")
        .and()
        .headers()
        .frameOptions()
        .sameOrigin()
        .and()
        .csrf().disable()
        .addFilterAt(sessionFilter(), AbstractPreAuthenticatedProcessingFilter.class)
        .addFilterBefore(authFailureFilter(), RequestHeaderAuthenticationFilter.class)
        .authenticationProvider(jwtAuth);
  }

  @SneakyThrows
  public RequestHeaderAuthenticationFilter sessionFilter(){
    RequestHeaderAuthenticationFilter filter = new RequestHeaderAuthenticationFilter();
    filter.setPrincipalRequestHeader("Authorization");
    filter.setAuthenticationManager(authenticationManager());
    filter.setExceptionIfHeaderMissing(false);
    filter.setCheckForPrincipalChanges(true);
    return filter;
  }

  @SneakyThrows
  public ExceptionTranslationFilter authFailureFilter() {
    return new ExceptionTranslationFilter(jwtAuth::logFailedAuthAttempt);
  }
}
