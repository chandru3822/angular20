package com.albatross.api.v1.flow.enums;

import lombok.Getter;

@Getter
public enum SystemSettings {
  USER(69696969L);

  private final Long id;

  SystemSettings(Long id) {
    this.id = id;
  }
}
