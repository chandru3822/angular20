package com.albatross.api.config;

import com.amazonaws.regions.Regions;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.net.URI;

@Data
@ConfigurationProperties(prefix = "aws")
public class AwsProperties {

  @NotBlank String accessKeyId;
  @NotBlank String secretKey;
  @NotBlank String storageBucket;
  @NotNull Regions region = Regions.US_EAST_1;
  URI serviceEndpoint;

}
