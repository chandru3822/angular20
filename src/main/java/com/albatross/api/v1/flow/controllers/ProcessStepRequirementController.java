package com.albatross.api.v1.flow.controllers;

import java.util.List;

import com.albatross.api.v1.flow.model.ProcessStepRequirement;
import com.albatross.api.v1.flow.model.ProcessStepRequirementType;
import com.albatross.api.v1.flow.services.ProcessStepRequirementService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

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

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepRequirement> getRequirementsForStep (@PathVariable Long stepId) {
    return processStepRequirementService.getRequirementsForStep(stepId);
  }

  @RequestMapping(value = "/types", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepRequirementType> getRequirementTypes () {
    return processStepRequirementService.getRequirementTypes();
  }

  @RequestMapping(value = "/{requirementId}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long requirementId) {
    processStepRequirementService.deleteRequirement(requirementId);
  }

  @RequestMapping(value = "", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepRequirement updateRequirement(@RequestBody ProcessStepRequirement requirement) {
    return processStepRequirementService.updateRequirement(requirement);
  }

  @RequestMapping(value = "", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepRequirement insertRequirement(@RequestBody ProcessStepRequirement requirement) {
    return processStepRequirementService.insertRequirement(requirement);
  }

}
