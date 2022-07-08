package com.albatross.api.v1.flow.enums;

public enum ObjectType {
    PROJECT(1L, "project"),
    CONTACT(2L, "contact"),
    USER(3L, "user"),
    PROCESS_STEP(4L, "process_step"),
    ORGANIZATION(5L, "org"),
    EVENT(6L, "event"),
    ATTACHMENT_TYPE(7L, null);

  public final Long id;
  public final String tablePrefix;

  ObjectType(Long id, String tablePrefix) {
    this.id = id;
    this.tablePrefix = tablePrefix;
  }

  public static ObjectType get(String name) {
    name = name.toLowerCase();
    for (ObjectType s : values()) {
      if (s.toString().equals(name) || s.textValue().equals(name)) {
        return s;
      }
    }
    throw new IllegalArgumentException();
  }

  public String toString() {
    return name().toLowerCase().replaceAll("_", " ");
  }

  public String textValue() {
    return name().toLowerCase();
  }
}
