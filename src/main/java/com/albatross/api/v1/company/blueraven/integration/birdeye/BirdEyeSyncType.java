package com.albatross.api.v1.company.blueraven.integration.birdeye;

public enum BirdEyeSyncType {

  SURVEY("survey"),

  REVIEW("review");

  private final String type;

  BirdEyeSyncType(String type) {
    this.type = type;
  }

  public String getType() {
    return type;
  }
}
