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

  private Long id, companyFunctionId, customFieldGroupId, systemValueId, dbFunctionParamId, displayOrder, parameterDataTypeId;
  private String companyFunctionName, defaultValue, systemValue, parameterName;
  private Boolean archived, isSystemValue, isDefaultValue;
}

