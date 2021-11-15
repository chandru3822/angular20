package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProjectProcessStepEvent {

  private Long id, projectProcessStepId, processStepEventId, companyEventStatusTypeId,
    eventId, resourceId, uniqueBehaviorTypeId, rootProjectProcessStepStatusTypeId; //rootProjectProcessStepStatusTypeId = the current status of the pps, needed to determine if the action can be run
  private String eventName, eventStatusType, startTime, endTime, resource;
  private List<CustomFieldGroup> customFieldGroups;
  private List<Resource> availableResources;
  private List<ProcessStepEventAction> eventActions;
  private Boolean archived;

  
  @Data
  public static class Resource {
    private Long id;
    private String name;
  }
}


