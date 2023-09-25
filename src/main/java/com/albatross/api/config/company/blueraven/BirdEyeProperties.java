package com.albatross.api.config.company.blueraven;

import com.albatross.api.v1.company.blueraven.integration.birdeye.Domain;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import javax.validation.constraints.NotNull;

@Data
@ConfigurationProperties(prefix = "birdeye.api")
public class BirdEyeProperties {
  @NotNull
  private String key;
  @NotNull
  private String toplevelBusinessId;
  private Boolean sendInvitesForReal = false;
  private Domain serverDomain = Domain.PROD;
  private String testEmail = "support@blueravensolar.com";
  private String testPhone = "385-269-9523";
  private String fallbackBusinessId;
}
