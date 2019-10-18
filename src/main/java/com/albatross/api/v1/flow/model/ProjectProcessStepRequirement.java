package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class ProjectProcessStepRequirement extends ProcessStepRequirement {

  private Boolean booleanValue, hasListValues;

  private Timestamp timestampValue, dateValue;

  private String textValue;

  private BigDecimal numericValue;

  private Long intValue, dataTypeRequirementId, listOfValueId ;

  private List<Integer> intArrayValue;
}
