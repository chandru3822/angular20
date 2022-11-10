package com.albatross.api.config.company.blueraven;

import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdeyeService;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import javax.validation.constraints.NotNull;

@Data
@ConfigurationProperties(prefix = "birdeye.api")
public class BirdeyeProperties {
  @NotNull
  private String key;
  @NotNull
  private String toplevelBusinessId;
  private Boolean sendInvitesForReal = false;
  private BirdeyeService.Domain serverDomain = BirdeyeService.Domain.PROD;
  private String testEmail = "support@blueravensolar.com";
  private String testPhone = "385-269-9523";
  private String surveyId;
  private Long surveyGroupId;
}
