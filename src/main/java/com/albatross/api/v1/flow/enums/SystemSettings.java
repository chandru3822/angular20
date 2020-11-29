package com.albatross.api.v1.flow.enums;

import lombok.Getter;

@Getter
public enum SystemSettings {
  CRON_USER(2417171L),
  SYSTEM_USER(2417171L),
  BR_SYSTEM_USER(99999999L);
  private final Long id;

  SystemSettings(Long id) {
    this.id = id;
  }
}
