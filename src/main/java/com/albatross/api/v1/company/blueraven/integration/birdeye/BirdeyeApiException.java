package com.albatross.api.v1.company.blueraven.integration.birdeye;


import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public class BirdeyeApiException extends RuntimeException {
  public BirdeyeApiException(String message) {
    super(message);
  }
}
