package com.albatross.api.v1.flow.model.project;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@NoArgsConstructor
public class ProjectWorkQueueHistory {

  private Long workQueueTypeId;
  private int daysInQueue;
  private String dateEnteredQueue, dateExitedQueue, eventName, status,
    processStepName, workQueueType, workQueueCategory;
}
