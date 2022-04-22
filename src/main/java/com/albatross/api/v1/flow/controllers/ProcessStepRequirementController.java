package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.processStep.ProcessStepAction;
import com.albatross.api.v1.flow.model.processStep.ProcessStepRequirement;
import com.albatross.api.v1.flow.model.processStep.ProcessStepRequirementType;
import com.albatross.api.v1.flow.services.ProcessStepRequirementService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/processStep/{stepId}/requirement")
public class ProcessStepRequirementController {

  @Autowired
  private ProcessStepRequirementService processStepRequirementService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepRequirement> getRequirementsForEvent (@PathVariable Long stepId) {
    return processStepRequirementService.getRequirementsForStep(stepId);
  }

  @GetMapping(value = "/types", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepRequirementType> getRequirementTypes () {
    return processStepRequirementService.getRequirementTypes();
  }

  @GetMapping(value = "/event/types", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepRequirementType> getEventRequirementTypes () {
    return processStepRequirementService.getEventRequirementTypes();
  }

  @PutMapping(value = "/{requirementId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepAction> deleteRequirement(@PathVariable Long requirementId) {
    return processStepRequirementService.deleteRequirement(requirementId);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepRequirement updateRequirement(@RequestBody ProcessStepRequirement requirement) {
    return processStepRequirementService.updateRequirement(requirement);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepRequirement insertRequirement(@RequestBody ProcessStepRequirement requirement) {
    return processStepRequirementService.insertRequirement(requirement);
  }

}
