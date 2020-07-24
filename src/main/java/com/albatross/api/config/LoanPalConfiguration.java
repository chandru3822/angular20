package com.albatross.api.config;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Slf4j
@Configuration
@Data
public class LoanPalConfiguration {
  @Value("${loanpal.api.host}")
  private String apiHost;

  @Value("${loanpal.api.uriPrefix}")
  private String uriPrefix;

  @Value("${loanpal.api.key}")
  private String apiKey;
}
