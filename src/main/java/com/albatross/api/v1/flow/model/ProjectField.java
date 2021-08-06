package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.sql.Timestamp;
import java.time.LocalDate;

@Data
public class ProjectField {

  private Long customFieldId, projectCustomValueId, fieldOrder;

  private String fieldName, companyDataType, textValue;

  private Boolean booleanValue;

  private LocalDate dateValue;

  private Timestamp timestampValue;
}
