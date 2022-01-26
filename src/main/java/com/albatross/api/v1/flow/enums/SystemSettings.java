package com.albatross.api.v1.flow.enums;

import lombok.Getter;

@Getter
public enum SystemSettings {
  CRON_USER(2417171L, null),
  SYSTEM_USER(2417172L, null),
  BR_SYSTEM_USER(99999999L, 3L);
  private final Long id;
  private final Long companyId;

  SystemSettings(Long id, Long companyId) {
  	this.id = id;
  	this.companyId = companyId;
  }
}
