package com.albatross.api.config;

import com.albatross.api.security.CustomRequestHeaderAuthenticationFilter;
import com.albatross.api.security.LoginSuccessHandler;
import com.albatross.api.security.jwt.JwtAuthenticationProvider;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.HeadersConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.ExceptionTranslationFilter;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.authentication.preauth.AbstractPreAuthenticatedProcessingFilter;
import org.springframework.security.web.authentication.preauth.RequestHeaderAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

import static org.springframework.security.config.Customizer.withDefaults;
import static org.springframework.security.config.http.SessionCreationPolicy.STATELESS;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

  private final JwtAuthenticationProvider jwtAuth;

  @Value(value = "${app.maintenanceMode:false}")
  private Boolean maintenanceMode;

  @Value("${app.local.cors:http://localhost:[*]}")
  private String appLocalCors;

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
    configuration.setAllowedOriginPatterns(
      List.of(
        appLocalCors,
        "https://*.myblueraven.com",
        "https://*blueraven-excel-data-addon.netlify.app"));
    configuration.setAllowedHeaders(List.of("*"));
    configuration.setExposedHeaders(List.of("Content-Disposition"));
    configuration.setAllowedMethods(List.of("*"));
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
  }

  @Bean
  SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

    http.sessionManagement(management -> management
        .sessionCreationPolicy(STATELESS))
      .cors(withDefaults())
      .authorizeHttpRequests((auth) ->
        auth.requestMatchers(
          "/auth/login",
          "/public/**",
          "/api/v1/flow/app/latest/**",
          "/api/v1/flow/solargraf/**",
          "/actuator/**",
          "/api/v1/flow/user/forgotPassword/**",
          "/swagger-ui/**",
          "/v3/api-docs/**",
          "/swagger-ui.html",
          "/webhook/twilio/**",
          "/webhook/verse/**",
          "/webhook/hubspot/**",
          "/webhook/genesys/**",
          "/webhook/goodleap/**",
          "/webhook/mosaic/**",
          "/webhook/enfin/**",
          "/webhook/aws/**",
//            // export the endpoint for automating s3 uploads of mobile builds from fast lane
          "/api/v1/flow/app/addAttachmentRecord",
          // export the endpoint for mobile to call to ensure the app_attachment table is present
          // in stage and flux before they do a build
          "/api/v1/flow/app/fixTable"
        ).permitAll());

    if (maintenanceMode) {
      // have to allow access to br endpoints so that ContactLeadController endpoints don't fail
      // suddenly
      http.authorizeHttpRequests((auth) -> auth.requestMatchers("/api/v1/company/blueraven/contact**").permitAll());
      http.authorizeHttpRequests((auth) -> auth.anyRequest().hasAnyAuthority("MAINTENANCE_MODE_ADMIN"));
    } else {
      http.authorizeHttpRequests((auth) -> auth.anyRequest().authenticated());
    }

    http
      .exceptionHandling(handling -> handling
        .authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED)))
      .headers(headers -> headers
        .frameOptions(HeadersConfigurer.FrameOptionsConfig::sameOrigin))
      .csrf(AbstractHttpConfigurer::disable)
      .addFilterAt(sessionFilter(authenticationManager(http.getSharedObject(AuthenticationConfiguration.class))), AbstractPreAuthenticatedProcessingFilter.class)
      .addFilterBefore(authFailureFilter(), RequestHeaderAuthenticationFilter.class)
      .authenticationProvider(jwtAuth);
    return http.build();
  }

  @SneakyThrows
  public RequestHeaderAuthenticationFilter sessionFilter(AuthenticationManager authenticationManager) {
    final var filter = new CustomRequestHeaderAuthenticationFilter();
    filter.setPrincipalRequestHeader("Authorization");
    filter.setAuthenticationManager(authenticationManager);
    filter.setExceptionIfHeaderMissing(false);
    filter.setCheckForPrincipalChanges(true);
    return filter;
  }

  @SneakyThrows
  public ExceptionTranslationFilter authFailureFilter() {
    return new ExceptionTranslationFilter(jwtAuth::logFailedAuthAttempt);
  }

  @Bean
  public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
    return authenticationConfiguration.getAuthenticationManager();
  }
}
