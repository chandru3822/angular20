package com.albatross.api.config.company.blueraven;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import jakarta.validation.constraints.NotNull;

@Data
@ConfigurationProperties(prefix = "bitrise.api")
public class BitriseProperties {
  @NotNull
  private String key;
  @NotNull
  private String slug;
}
