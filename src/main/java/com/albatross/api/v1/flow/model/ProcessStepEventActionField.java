package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProcessStepEventActionField {

  private Long id, customFieldGroupAssignmentId, processStepEventActionId,
    customFieldId, customFieldGroupId, dataTypeId;
  private String fieldName, groupName;
  private Boolean archived, required, optional;

}

