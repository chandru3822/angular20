package com.albatross.api.v1.flow.model.projectProcessStep;

import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.WhiteListedPosition;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEventAction;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProjectProcessStepEvent {

  private Long id, projectProcessStepId, processStepEventId, companyEventStatusTypeId, processStepStatusTypeId, companyProcessStepStatusTypeId,
    eventId, resourceId, uniqueBehaviorTypeId, eventStatusTypeId, rootProjectProcessStepStatusTypeId, //rootProjectProcessStepStatusTypeId = the current status of the pps, needed to determine if the action can be run
    processStepId, projectId, saveVersion;
  private String eventName, eventStatusType, resource, processStepName, lastUpdated,
    dateCreated, cancelledDate, completedDate, scheduledDate, createdBy;
  private Timestamp startTime, endTime;
  private List<CustomFieldGroup> customFieldGroups;
  private List<Resource> availableResources;
  private List<ProcessStepEventAction> eventActions;
  private Boolean archived, startTimeReadOnly, endTimeReadOnly, resourceReadOnly;
  private List<WhiteListedPosition> startTimeWhiteListedPositions, endTimeWhiteListedPositions, resourceWhiteListedPositions;


  @Data
  public static class Resource {
    private Long id;
    private String name;
  }
}


