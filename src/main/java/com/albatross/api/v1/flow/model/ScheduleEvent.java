package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ScheduleEvent {

  private Long resourceId, processStepId, systemListTypeId, projectId, projectProcessStepId, stateId, processStepStatusTypeId,
      startCustomFieldValueId, startCustomFieldGroupAssignmentId, endCustomFieldValueId, endCustomFieldGroupAssignmentId,
      resourceCustomFieldValueId, resourceCustomFieldGroupAssignmentId;
  private String resourceName, groupName, customerFirstName, customerLastName, customerFullName, projectName, processStepName,
      state, processStepStatusType, startFieldName, endFieldName, resourceFieldName;
  private Boolean archived;

  private Double latitude, longitude;

  private Timestamp start, end;

  private List<ListOfValue> resources;
}

