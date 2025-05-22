package com.albatross.api.v1.flow.model.filter;

import lombok.Data;

@Data
public class WorkTypeFilters {
  // Core properties
  private Long id;
  private String name;
  private String processStepName;
  private Integer dataTypeId;
  private OperatorDTO operator;
  private ValueDTO value;
  private Long filterId;
  private Long operatorId;
  private Long valueId;
  private Object customValues;

  public Long getFilterId() {
    return filterId != null ? filterId : id;
  }

  public Long getOperatorId() {
    if (operatorId != null) {
      return operatorId;
    }
    return operator != null ? operator.getId() : null;
  }

  public Long getValueId() {
    if (valueId != null) {
      return valueId;
    }
    return value != null ? value.getId() : null;
  }
}
