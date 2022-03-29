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
public class ProcessStepEventActionChildFunction {

  private Long id, processStepEventActionId, companyFunctionId, createdById, modifiedById, displayOrder, projectId;
  private String companyFunctionName, functionName;
  private Boolean archived, edit = false, runInBackend, createsPps;
  private List<ActionParamDynamicValue> actionParamDynamicValues;
  private List<CompanyFunctionParam> companyFunctionParams;
}

