package com.albatross.api.v1.flow.model.event;

import com.albatross.api.v1.flow.model.processStep.ProcessStepEventLogic;
import lombok.Data;

import java.util.HashMap;
import java.util.List;

@Data
public class EventActionRequirement {
  private List<ProcessStepEventLogic> processStepEventLogicList;
  private HashMap<Long,Boolean> requirementIdsFulfilledStatus;
}
