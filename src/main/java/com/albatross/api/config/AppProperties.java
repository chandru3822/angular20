package com.albatross.api.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import javax.validation.constraints.NotNull;
import java.net.URI;

@Data
@ConfigurationProperties(prefix = "app")
public class AppProperties {

  @NotNull URI htmlToPdfApi;
}
