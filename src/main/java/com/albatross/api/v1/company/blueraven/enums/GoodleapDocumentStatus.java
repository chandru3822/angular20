package com.albatross.api.v1.company.blueraven.enums;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public enum GoodleapDocumentStatus {

  UNSENT("Unsent"),
  SENT("Sent"),
  SIGNED("Signed");

  private final String description;

  @Override
  public String toString() {
    return description;
  }
}
