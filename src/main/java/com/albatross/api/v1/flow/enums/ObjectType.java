package com.albatross.api.v1.flow.enums;

public enum ObjectType {
  PROJECT(1L),
  CONTACT(2L),
  USER(3L),
  PROCESS_STEP(4L),
  ORGANIZATION(5L),
  EVENT(6L);

  public final Long id;

  ObjectType(Long id) {
    this.id = id;
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
