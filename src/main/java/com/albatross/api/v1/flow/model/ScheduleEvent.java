package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ScheduleEvent {

  private Long resourceId, processStepId, systemListTypeId, projectId, projectProcessStepId, stateId, processStepStatusTypeId;
  private String resourceName, groupName, customerFirstName, customerLastName, projectName, processStepName, state, processStepStatusType;
  private Boolean archived;

  private Double latitude, longitude;

  private Timestamp start, end;
}

