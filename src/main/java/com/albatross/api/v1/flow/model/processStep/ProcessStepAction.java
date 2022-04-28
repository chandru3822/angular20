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
public class ProcessStepAction {

  private Long id, processStepId, companyProcessStepStatusTypeId, companyProjectStatusTypeId, projectStatusTypeId, actionTypeId, processStepStatusTypeId, displayOrder;
  private String actionName, actionType, processStepStatusType, projectStatusType;
  private List<ProcessStepLogic> processStepLogicList;
  private List<ProcessStepActionChildProcess> processStepActionChildProcesses;
  private List<ProcessStepActionChildFunction> processStepActionChildFunctions;
  private List<ProcessStepActionLink> processStepActionLinks;
  private Boolean archived, alwaysEnabled, logicListChanged, triggerAutomatically, timeBasedTrigger, hideFromWeb, multipleUses, removeProcessStepOwner;

// NOTE: the "hidden" field is the same as "hideFromMobile"
// mobile was already honoring the "hidden" flag so we couldn't re-purpose it without breaking old versions of the mobile app
// newer app versions reference "hideFromMobile" though so eventually we can phase out the uninformative "hidden" flag
//humes said that this makes perfect sense so bug him about it when it doesn't
  private Boolean hidden, hideFromMobile;
}

