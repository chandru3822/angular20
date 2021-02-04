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

  private Long id, processStepId, companyProcessStepStatusTypeId, companyProjectStatusTypeId, projectStatusTypeId, actionTypeId, processStepStatusTypeId, displayOrder;
  private String actionName, actionType, processStepStatusType, projectStatusType;
  private List<ProcessStepLogic> processStepLogicList;
  private List<ProcessStepActionChildProcess> processStepActionChildProcesses;
  private List<ProcessStepActionChildFunction> processStepActionChildFunctions;
  private List<ProcessStepActionLink> processStepActionLinks;
  private Boolean archived, alwaysEnabled, logicListChanged, triggerAutomatically, timeBasedTrigger, hidden, multipleUses;
}

