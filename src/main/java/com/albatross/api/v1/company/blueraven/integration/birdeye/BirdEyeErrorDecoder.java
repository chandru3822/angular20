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
public class BirdEyeErrorDecoder implements ErrorDecoder {

  private final ObjectMapper objectMapper;

  @Override
  public Exception decode(String methodKey, Response response) {
    int status = response.status();
    String contentType = response.headers().get("Content-Type").stream().findFirst().orElse("");

    //apparently the API is not returning a json response sometimes
    if (contentType.contains("application/json")) {
      try (final InputStream inputStream = response.body().asInputStream()) {
        final BirdEyeApiError birdeyeApiError = objectMapper.readValue(inputStream, BirdEyeApiError.class);
        log.debug("[BirdEye API] error; errorCode={}, errorMessage={}", birdeyeApiError.getCode(), birdeyeApiError.getMessage());

        return new BirdEyeApiException(birdeyeApiError.getMessage());
      } catch (IOException e) {
        try (final InputStream errorInputStream = response.body().asInputStream()) {
          final String body = new String(errorInputStream.readAllBytes());
          log.error("[BirdEye API] Unable to parse json response; body={}", body);
        } catch (IOException ex) {
          log.error("[BirdEye API] Unable to parse json response", ex);
        }
      }
    }

    if (status == 404) {
      return new BirdEyeApiException("Requested resource not found");
    }

    return new BirdEyeApiException("Unhandled error while accessing BirdEye Api");
  }
}
