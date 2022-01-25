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

  private Long resourceId, companyId, systemListId, processStepId, systemListTypeId, projectId, projectProcessStepId, stateId, processStepStatusTypeId, companyProcessStepStatusTypeId,
      startCustomFieldValueId, startCustomFieldGroupAssignmentId, endCustomFieldValueId, endCustomFieldGroupAssignmentId,
      resourceCustomFieldValueId, resourceCustomFieldGroupAssignmentId, contactId, eventId, projectProcessStepEventId, processStepEventId,
      companyEventStatusTypeId, eventStatusTypeId,
    //this is annoying but in order to make loading events work for multiple userPositions for the same user we need to pass back the userId. or i am dumb and cant figure it out otherwise.
    userId;
  private String resourceName, groupName, contactFirstName, contactLastName, contactFullName, projectName, processStepName,
      state, processStepStatusType, startFieldName, endFieldName, resourceFieldName,
      street1, city, stateAbbreviation, postalCode, phone, mobile, eventName, eventStatusType, companyEventStatusType;
  private Boolean archived, startFieldReadOnly, endFieldReadOnly, resourceFieldReadOnly;

  private Double latitude, longitude;

  private Timestamp start, end;

  private List<ListOfValue> resources;
  private List<Long> systemListOptionIds;
}

