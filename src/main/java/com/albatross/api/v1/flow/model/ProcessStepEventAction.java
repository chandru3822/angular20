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
public class ProcessStepEventAction {

  private Long id, companyEventStatusTypeId, companyProcessStepStatusTypeId, displayOrder, rootProcessStepStatusTypeId; //rootProcessStepStatusTypeId needed to determine if action can be run
  private String actionName, processStepStatusType, eventStatusType;
  private Boolean archived, requireStartTime, requireEndTime, requireResource, canPerform, logicListChanged, alwaysEnabled;
  private List<ProcessStepEventActionField> customFields;
  private List<ProcessStepEventLogic> processStepEventLogicList;
}

