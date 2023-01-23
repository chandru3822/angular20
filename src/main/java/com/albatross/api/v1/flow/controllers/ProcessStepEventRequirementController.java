package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.processStep.ProcessStepAction;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEventRequirement;
import com.albatross.api.v1.flow.services.ProcessStepEventRequirementService;
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
@RequestMapping(value = "/api/v1/flow/processStep/{stepId}/event/{stepEventId}/requirement")
public class ProcessStepEventRequirementController {

  @Autowired
  private ProcessStepEventRequirementService processStepEventRequirementService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepEventRequirement> getRequirementsForEvent (@PathVariable Long stepId,
                                                                    @PathVariable Long stepEventId) {
    return processStepEventRequirementService.getRequirementsForEvent(stepId, stepEventId);
  }

    @GetMapping(value = "/{requirementId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<ProcessStepAction> getActionsUsingRequirement(@PathVariable Long requirementId) {
        return processStepEventRequirementService.getActionsUsingRequirement(requirementId);
    }

  @PutMapping(value = "/{requirementId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepAction> deleteRequirement(@PathVariable Long requirementId) {
    return processStepEventRequirementService.deleteRequirement(requirementId);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepEventRequirement updateRequirement(@RequestBody ProcessStepEventRequirement requirement) {
    return processStepEventRequirementService.updateRequirement(requirement);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepEventRequirement insertRequirement(@RequestBody ProcessStepEventRequirement requirement) {
    return processStepEventRequirementService.insertRequirement(requirement);
  }

}
