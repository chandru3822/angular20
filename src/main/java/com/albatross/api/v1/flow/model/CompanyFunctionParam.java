package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CompanyFunctionParam {

  private Long id, companyFunctionId, customFieldGroupId, systemValueId, dbFunctionParamId, displayOrder, dataTypeId, processStepId, createdById, modifiedById, parameterTypeId;
  private String companyFunctionName, dynamicValue, systemValue, parameterName, fieldName, processStepName;
  private Boolean archived;
}

