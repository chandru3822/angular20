package com.albatross.api.pdf;

import com.albatross.api.config.AppProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
@RequiredArgsConstructor
public class PdfWebClientConfiguration {
  private final AppProperties properties;

  @Bean
  public WebClient pdfWebClient() {
    return WebClient.builder()
      .baseUrl(properties.getHtmlToPdfApi().toString())
      .codecs(clientCodecConfigurer -> clientCodecConfigurer.defaultCodecs().maxInMemorySize(1024 * 1024 * 10)).build();
  }
}
