package com.albatross.api.v1.flow.enums;

import lombok.Getter;

@Getter
public enum SystemSettings {
  CRON_USER(2417171L, null, null),
  SYSTEM_USER(2417172L, null, null),
  BR_SYSTEM_USER(99999999L, 3L, "blueraven");
  private final Long id;
  private final Long companyId;
  private final String awsBucket;

  SystemSettings(Long id, Long companyId, String awsBucket) {
    this.id = id;
    this.companyId = companyId;
    this.awsBucket = awsBucket;
  }
}
