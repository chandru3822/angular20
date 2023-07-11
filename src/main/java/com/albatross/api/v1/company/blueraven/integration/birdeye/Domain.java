package com.albatross.api.v1.company.blueraven.integration.birdeye;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public enum Domain {
  PROD("api.birdeye.com"),
  DEVO("private-anon-8e8990eaa7-birdeye.apiary-proxy.com"),
  MOCK("private-anon-8e8990eaa7-birdeye.apiary-mock.com");

  @Getter
  private final String host;
}
