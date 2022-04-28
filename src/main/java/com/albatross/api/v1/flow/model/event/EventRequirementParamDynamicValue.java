package com.albatross.api.v1.flow.model.event;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class EventRequirementParamDynamicValue {

  private Long id, dbFunctionParamId, processStepEventRequirementId, dbFunctionId, dataTypeId;
  private String dynamicValue, parameterName;
  private Boolean archived;


}

