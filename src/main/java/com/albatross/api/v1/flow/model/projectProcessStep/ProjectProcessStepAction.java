package com.albatross.api.v1.flow.model.projectProcessStep;

import com.albatross.api.v1.flow.model.processStep.ProcessStepAction;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProjectProcessStepAction extends ProcessStepAction {

    private Boolean alreadyTriggered, multipleUses, canPerform;
}
