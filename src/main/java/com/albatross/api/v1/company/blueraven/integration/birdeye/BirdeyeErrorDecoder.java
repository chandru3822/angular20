package com.albatross.api.v1.company.blueraven.integration.birdeye;

import com.fasterxml.jackson.databind.ObjectMapper;
import feign.Response;
import feign.codec.ErrorDecoder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;
import java.io.InputStream;

@Slf4j
@RequiredArgsConstructor
public class BirdeyeErrorDecoder implements ErrorDecoder {

  private final ObjectMapper objectMapper;

  @Override
  public Exception decode(String methodKey, Response response) {
    try (final InputStream inputStream = response.body().asInputStream()) {
      final BirdeyeApiError birdeyeApiError = objectMapper.readValue(inputStream, BirdeyeApiError.class);
      log.error("[Birdeye] API error; errorCode={}, errorMessage={}", birdeyeApiError.getCode(), birdeyeApiError.getMessage());

      return new BirdeyeApiException(birdeyeApiError.getMessage());
    } catch (IOException e) {

      try (final InputStream errorInputStream = response.body().asInputStream()) {
        final String body = new String(errorInputStream.readAllBytes());
        log.error("[Birdeye] Unable to parse json response; body={}", body);
      } catch (IOException ex) {
        throw new RuntimeException(ex);
      }
    }
    return new BirdeyeApiException("Unhandled error while accessing Birdeye Api");
  }
}
