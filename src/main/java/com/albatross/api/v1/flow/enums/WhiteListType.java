package com.albatross.api.v1.flow.enums;

public enum WhiteListType {
  CFGA_READ_ONLY(1L),
  CFGA_HIDDEN(2L),
  PROJECT_STATUS_READ_ONLY(3L),
  PROJECT_OWNER_READ_ONLY(4L),
  CONTACT_OWNER_READ_ONLY(5L),
  EVENT_START_TIME_READ_ONLY(6L),
  EVENT_END_TIME_READ_ONLY(7L),
  EVENT_RESOURCE_READ_ONLY(8L),
  PROCESS_STEP_READ_ONLY(9L),
  WORK_QUEUE_TYPE_HIDDEN(10L);

  public final Long id;

  WhiteListType(Long id) {
    this.id = id;
  }

  public static WhiteListType get(String name) {
    name = name.toLowerCase();
    for (WhiteListType s : values()) {
      if (s.toString().equals(name)) {
        return s;
      }
    }
    throw new IllegalArgumentException();
  }

  public String toString() {
    return name().toLowerCase().replaceAll("_", " ");
  }
}
