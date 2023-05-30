package com.albatross.api.v1.company.blueraven.services;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.ExchangeStrategies;
import org.springframework.web.reactive.function.client.WebClient;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomerPortalService {

  @Qualifier("customerPortalWebClient")
  private final WebClient webClient;

  public String getCustomerPortalLink(Long projectId) {
    return webClient.post().uri("/api/projects/encode").body(BodyInserters.fromValue(new EncodeRequest(projectId))).retrieve()
      .bodyToMono(EncodedResponse.class).map(r -> r.url).block();
  }

  public record EncodeRequest(Long projectId) {
  }

  public record EncodedResponse(String encodedId, String url) {
  }

  @Configuration
  static class CustomerPortalConfig {


    @Bean("customerPortalWebClient")
    public WebClient webClient(@Value("${app.portal.url}") String customerPortalBaseUrl) {

      return WebClient.builder()
        .baseUrl(customerPortalBaseUrl)
        .exchangeStrategies(
          ExchangeStrategies.builder()
            .codecs(codecs -> codecs.defaultCodecs().maxInMemorySize(1024 * 1024))
            .build())
        .build();
    }
  }
}
