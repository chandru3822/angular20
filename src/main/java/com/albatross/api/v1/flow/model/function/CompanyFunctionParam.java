package com.albatross.api.v1.flow.model.function;

import com.albatross.api.v1.flow.model.CustomFieldValue;
import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CompanyFunctionParam extends CustomFieldValue {

  private Long id, companyFunctionId, customFieldGroupAssignmentId, systemValueId, dbFunctionParamId, displayOrder, dataTypeId, processStepId, createdById, modifiedById, parameterTypeId;
  private String companyFunctionName, dynamicValue, systemValue, parameterName, fieldName, processStepName;
  private Boolean archived;
}

