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
public class RequirementParamDynamicValue {

  private Long id, dbFunctionParamId, processStepRequirementId, dbFunctionId, dataTypeId, systemListId;
  private String dynamicValue, parameterName, description;
  private Boolean archived, nullable;
  private List<ListOfValue> listOfValues;


}

