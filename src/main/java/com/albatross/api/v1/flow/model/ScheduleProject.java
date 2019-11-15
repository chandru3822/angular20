package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;


/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ScheduleProject {

  private Long processStepId, projectId, projectProcessStepId, stateId, processStepStatusTypeId;
  private String projectName, processStepName, customerFirstName, customerLastName, state,
      processStepStatusType;
  private Double latitude, longitude;
}

