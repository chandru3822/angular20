package com.albatross.api.v1.flow.model.processStep;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepEventAction {

  private Long id, companyEventStatusTypeId, companyProcessStepStatusTypeId, displayOrder, rootEventStatusTypeId, rootProcessStepStatusTypeId, createdById, actionTypeId; //rootProcessStepStatusTypeId needed to determine if action can be run, //rootEventStatusTypeId needed for mobile
  private String actionName, processStepStatusType, eventStatusType, actionRunDate, actionRunBy, color, content, actionType;
  private Boolean archived, requireStartTime, requireEndTime, requireResource,
    canPerform, logicListChanged, alwaysEnabled, alreadyTriggered, multipleUses, hideFromMobile, hideFromWeb;
  private List<ProcessStepEventActionField> customFields, requiredFields, optionalFields;
  private List<ProcessStepEventLogic> processStepEventLogicList;
  private List<ProcessStepEventActionChildFunction> childFunctions;
}

