package com.albatross.api.v1.company.blueraven.integration.birdeye;

import lombok.Getter;

public enum BirdEyeCheckInType {
  REVIEW("Review"),
  SURVEY("Survey"),
  SITE_SURVEY("Site Survey");



  @Getter
  private String value;

  BirdEyeCheckInType(String value) {
    this.value = value;
  }
}
