package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProjectProcessStepAction extends ProcessStepAction {

    private Boolean alreadyTriggered, canPerform;
}
