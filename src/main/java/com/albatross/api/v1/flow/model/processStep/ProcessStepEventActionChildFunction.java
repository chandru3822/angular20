package com.albatross.api.v1.flow.model.processStep;

import lombok.Getter;
import lombok.Setter;

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

