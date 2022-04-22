package com.albatross.api.v1.flow.model.processStep;

import com.albatross.api.v1.flow.model.ActionParamDynamicValue;
import com.albatross.api.v1.flow.model.function.CompanyFunctionParam;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepActionChildFunction {

  private Long id, processStepActionId, companyFunctionId, createdById, modifiedById, displayOrder, projectId;
  private String companyFunctionName, functionName;
  private Boolean archived, edit = false, runInBackend;
  private List<ActionParamDynamicValue> actionParamDynamicValues;
  private List<CompanyFunctionParam> companyFunctionParams;
}

