package com.albatross.api.notification.model;

import com.fasterxml.jackson.annotation.JsonValue;

public enum NotificationTopic {
  UNKNOWN("unknown"),
  PING("ping"),
  SMS_REPLY("sms_reply");

  private final String name;

  NotificationTopic(String name) {
    this.name = name;
  }

  @JsonValue
  public String getName() {
    return name;
  }
}
