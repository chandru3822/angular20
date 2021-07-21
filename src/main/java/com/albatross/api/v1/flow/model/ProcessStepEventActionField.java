package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepEventActionField {

  private Long id, customFieldGroupAssignmentId, processStepEventActionId;
  private String fieldName, groupName;
  private Boolean archived, required;
}

