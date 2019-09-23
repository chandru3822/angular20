package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class ProjectProcessStepRequirement extends ProcessStepRequirement {

  private Boolean booleanValue;

  private LocalDateTime timestampValue, dateValue;

  private String textValue;

  private Double numericValue;

  private Long intValue;

  private List<Long> intArrayValue;
}
