package com.albatross.api.v1.flow.model;

import java.sql.Timestamp;
import java.time.LocalDate;

import lombok.Data;

@Data
public class ProjectField {
  
  private Long customFieldId, projectCustomValueId, fieldOrder;

  private String fieldName, companyDataType, textValue;

  private Boolean booleanValue;

  private LocalDate dateValue;

  private Timestamp timestampValue;
}