package com.albatross.api.v1.flow.model.filter;

import lombok.Data;

@Data
public class WorkTypeFilters {
  private Long id;
  private String name;
  private String processStepName;
  private OperatorDTO operator;
  private ValueDTO value;
}
