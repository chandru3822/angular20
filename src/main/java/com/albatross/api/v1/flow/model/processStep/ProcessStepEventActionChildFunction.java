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
public class ProcessStepEventActionChildFunction extends ProcessStepActionChildFunction {

  private Long processStepEventActionId;
  private Boolean createsPps;
}

