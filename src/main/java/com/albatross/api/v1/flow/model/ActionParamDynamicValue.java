package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ActionParamDynamicValue {

  private Long id, dbFunctionParamId, processStepActionCompanyFunctionId, dbFunctionId, dataTypeId;
  private String dynamicValue, parameterName, description;
  private Boolean archived;


}

