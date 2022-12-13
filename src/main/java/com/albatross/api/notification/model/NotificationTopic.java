package com.albatross.api.notification.model;

import com.fasterxml.jackson.annotation.JsonValue;

public enum NotificationTopic {
  UNKNOWN("unknown"),
  PING("ping"),
  SMS_REPLY("sms_reply"),
  SMS_OWNERSHIP("sms_ownership"),
  PROJECT_TAG("project_tag");

  private final String name;

  NotificationTopic(String name) {
    this.name = name;
  }

  public static NotificationTopic from(String topic) {
    for (NotificationTopic value : values()) {
      if (value.getName().equals(topic)) {
        return value;
      }
    }
    return UNKNOWN;
  }

  @JsonValue
  public String getName() {
    return name;
  }
}
