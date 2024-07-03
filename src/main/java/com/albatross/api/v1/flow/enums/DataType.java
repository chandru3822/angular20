package com.albatross.api.v1.flow.enums;

import lombok.Getter;

@Getter
public enum DataType {
  DATE(1L, "date"),
  TIMESTAMP(2L, "timestamp"),
  BOOLEAN(3L, "boolean"),
  NUMERIC(4L, "numeric"),
  TEXT(5L, "text"),
  INTEGER(6L, "integer"),
  INTEGER_ARRAY(7L, "integer array"),
  SYSTEM(8L, "system");
  private final Long id;
  private final String dataType;

  DataType(Long id, String dataType) {
    this.id = id;
    this.dataType = dataType;
  }
}
