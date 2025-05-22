package com.albatross.api.v1.flow.model.filter;

import lombok.Data;

@Data
public class WorkFiltersDTO {
  private Long id;
  private Long workQueueTypeId;
  //  private Long eventId;
  private Long processStepId;
  private Long filterId;
  private String name;
  private String processStepName;
  private Long operatorId;
  private Long valueId;
  private Object customValues;
}
