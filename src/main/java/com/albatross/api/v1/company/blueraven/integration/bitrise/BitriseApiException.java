package com.albatross.api.v1.company.blueraven.integration.bitrise;


import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public class BitriseApiException extends RuntimeException {
  public BitriseApiException(String message) {
    super(message);
  }
}
