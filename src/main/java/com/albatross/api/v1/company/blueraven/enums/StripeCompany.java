package com.albatross.api.v1.company.blueraven.enums;

public enum StripeCompany {
  BREEZE("breeze");

  public final String keyPrefix;

  StripeCompany(String keyPrefix) {
    this.keyPrefix = keyPrefix;
  }
}
