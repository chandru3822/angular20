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

  private Long resourceId, processStepId, systemListTypeId, projectId, projectProcessStepId;
  private String resourceName, groupName, customerFirstName, customerLastName;
  private Boolean archived;

  private Timestamp start, end;
}

