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

  private Long resourceId, processStepId, systemListTypeId, projectId, projectProcessStepId, stateId, processStepStatusTypeId, companyProcessStepStatusTypeId,
      startCustomFieldValueId, startCustomFieldGroupAssignmentId, endCustomFieldValueId, endCustomFieldGroupAssignmentId,
      resourceCustomFieldValueId, resourceCustomFieldGroupAssignmentId;
  private String resourceName, groupName, contactFirstName, contactLastName, contactFullName, projectName, processStepName,
      state, processStepStatusType, startFieldName, endFieldName, resourceFieldName;
  private Boolean archived, startFieldReadOnly, endFieldReadOnly;

  private Double latitude, longitude;

  private Timestamp start, end;

  private List<ListOfValue> resources;
}

