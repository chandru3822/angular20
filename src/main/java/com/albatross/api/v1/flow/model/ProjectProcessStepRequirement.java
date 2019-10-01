package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class ProjectProcessStepRequirement extends ProcessStepRequirement {

  private Boolean booleanValue;

  private Timestamp timestampValue, dateValue;

  private String textValue;

  private Double numericValue;

  private Long intValue, dataTypeRequirementId;

  private List<Long> intArrayValue;
}
