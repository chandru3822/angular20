package com.albatross.api.v1.flow.model;

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

  private Long id, projectProcessStepId, processStepEventId, companyEventStatusTypeId, eventId;
  private String eventName, eventStatusType;
  private List<CustomFieldGroup> customFieldGroups;
  private Boolean archived;
}

