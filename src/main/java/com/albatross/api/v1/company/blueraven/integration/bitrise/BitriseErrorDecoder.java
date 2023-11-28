package com.albatross.api.v1.company.blueraven.integration.bitrise;

import com.fasterxml.jackson.databind.ObjectMapper;
import feign.Response;
import feign.codec.ErrorDecoder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;
import java.io.InputStream;

@Slf4j
@RequiredArgsConstructor
public class BitriseErrorDecoder implements ErrorDecoder {

  private final ObjectMapper objectMapper;

  @Override
  public Exception decode(String methodKey, Response response) {
    int status = response.status();
    String contentType = response.headers().get("Content-Type").stream().findFirst().orElse("");

    //apparently the API is not returning a json response sometimes
    if (contentType.contains("application/json")) {
      try (final InputStream inputStream = response.body().asInputStream()) {
        final BitriseApiError bitriseApiError = objectMapper.readValue(inputStream, BitriseApiError.class);
        log.debug("[Bitrise API] error; errorCode={}, errorMessage={}", bitriseApiError.getCode(), bitriseApiError.getMessage());

        return new BitriseApiException(bitriseApiError.getMessage());
      } catch (IOException e) {
        try (final InputStream errorInputStream = response.body().asInputStream()) {
          final String body = new String(errorInputStream.readAllBytes());
          log.error("[Bitrise API] Unable to parse json response; body={}", body);
        } catch (IOException ex) {
          log.error("[Bitrise API] Unable to parse json response", ex);
        }
      }
    }

    if (status == 404) {
      return new BitriseApiException("Requested resource not found");
    }

    return new BitriseApiException("Unhandled error while accessing Bitrise Api");
  }
}
