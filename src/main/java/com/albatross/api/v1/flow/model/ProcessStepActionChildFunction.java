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
public class ProcessStepActionChildFunction {

  private Long id, processStepActionId, companyFunctionId, createdById, modifiedById, displayOrder;
  private String companyFunctionName;
  private Boolean archived, edit = false;
  private List<ActionParamDynamicValue> actionParamDynamicValues;
}

