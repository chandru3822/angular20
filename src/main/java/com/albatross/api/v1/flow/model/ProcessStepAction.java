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
public class ProcessStepAction {

  private Long id, processStepId, processStepStatusTypeId, actionTypeId;
  private String actionName, actionType, processStepStatusType, logicString;
  private List<ProcessStepLogic> processStepLogicList;
  private Boolean archived;
}

