package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 10/1/19.
 * !Describe Purpose!
 */
@Getter
@Setter
public class OwningPosition {

  private Long id, positionId, processStepProcessId, processStepProcessOwningPositionId;
  private String position;
  private Boolean archived;

}

