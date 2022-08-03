package com.albatross.api.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;
import java.net.URI;

@Data
@ConfigurationProperties(prefix = "app")
public class AppProperties {

  @NotNull URI htmlToPdfApi;
  @NotNull URI host;

  @Valid ImageProxyProperties imageProxy;

  @Data
  public static class ImageProxyProperties {
    @NotNull Boolean enabled;
    URI url;

    /**
     * (Optional) hex-encoded key
     */
    String key;

    /**
     * (Optional) hex-encoded salt
     */
    String salt;

    public boolean isImageProxyEnabled() {
      return enabled;
    }

    public boolean isURLSignatureCheckingEnabled(){
      return key != null && key.trim().length() != 0 && salt != null && salt.trim().length() != 0;
    }
  }
}
