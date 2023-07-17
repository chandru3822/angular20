package com.albatross.api.v1.company.blueraven.integration.birdeye;


import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public class BirdEyeApiException extends RuntimeException {
  public BirdEyeApiException(String message) {
    super(message);
  }
}
