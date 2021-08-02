package com.albatross.api.config;

import com.albatross.api.security.LoginSuccessHandler;
import com.albatross.api.security.jwt.JwtAuthenticationProvider;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.access.ExceptionTranslationFilter;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.authentication.preauth.AbstractPreAuthenticatedProcessingFilter;
import org.springframework.security.web.authentication.preauth.RequestHeaderAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

import static org.springframework.security.config.http.SessionCreationPolicy.STATELESS;

/**
 * Created by randanunn on 2019-05-20.
 */
@Configuration
@RequiredArgsConstructor
public class SecurityConfig extends WebSecurityConfigurerAdapter {

  private final JwtAuthenticationProvider jwtAuth;

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
    configuration.setAllowedOriginPatterns(List.of("http://localhost:[*]", "https://*.myblueraven.com"));
    configuration.setAllowedHeaders(List.of("*"));
    configuration.setAllowedMethods(List.of("*"));
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
  }

  @Override
  protected void configure(HttpSecurity http) throws Exception {
    http
      .sessionManagement()
      .sessionCreationPolicy(STATELESS)
      .and()
      .cors()
      .and()
      .authorizeRequests()
      .antMatchers("/auth/login").permitAll()
      .antMatchers("/public/**").permitAll()
      .antMatchers("/api/v1/flow/app/latest/**").permitAll()
      .antMatchers("/actuator/**").permitAll()
      .antMatchers("/api/v1/flow/user/forgotPassword/**").permitAll()
      .antMatchers("/swagger-ui/**", "/v3/api-docs/**", "/swagger-ui.html").permitAll()
      .antMatchers("/webhook/twilio/**").permitAll()
      .antMatchers("/webhook/hubspot/**").permitAll()
      .antMatchers("/webhook/ricochet/**").permitAll()
      // export the endpoint for automating s3 uploads of mobile builds from fast lane
      .antMatchers("/api/v1/flow/app/addAttachmentRecord").permitAll()
      .anyRequest().authenticated()
      .and()
      .exceptionHandling()
      .authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED))
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
  public RequestHeaderAuthenticationFilter sessionFilter() {
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
