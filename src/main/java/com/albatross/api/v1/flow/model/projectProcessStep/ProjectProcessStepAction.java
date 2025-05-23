package com.albatross.api.v1.flow.model.projectProcessStep;

import java.util.HashMap;

import com.albatross.api.v1.flow.model.processStep.ProcessStepAction;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProjectProcessStepAction extends ProcessStepAction {

    private Boolean alreadyTriggered, multipleUses, canPerform;
    private String actionRunDate, actionRunBy;
    private HashMap<Long, Boolean> isPassAction;
}
