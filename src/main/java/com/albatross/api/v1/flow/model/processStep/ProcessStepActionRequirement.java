package com.albatross.api.v1.flow.model.processStep;

import lombok.Data;

import java.util.HashMap;
import java.util.List;

@Data
public class ProcessStepActionRequirement {
      private List<ProcessStepLogic> processStepLogicList;
  // key is requirement id and value is boolean status whether the requirement has been fulfilled or not
      private HashMap<Long,Boolean> requirementIdsFulfilledStatus;
}
