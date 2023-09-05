package com.albatross.api.v1.flow.model.projectProcessStep;

import lombok.Data;

import java.util.List;

@Data
public class ProjectProcessStepActionResult extends ProjectProcessStepStatus {

  private List<String> childFunctionReturnedStrings;

}
