package com.albatross.api.pubsub.model;

public enum EventChannel {
  NOTIFICATION("pubsub:notifications"),
  REAL_TIME_EVENT("pubsub:real-time-events");

  private final String topicName;

  EventChannel(String topicName) {
    this.topicName = topicName;
  }

  public static EventChannel findByName(String name) {
    for (EventChannel value : values()) {
      if (value.topicName.equals(name)) {
        return value;
      }
    }
    return null;
  }

  public String getName() {
    return topicName;
  }
}
