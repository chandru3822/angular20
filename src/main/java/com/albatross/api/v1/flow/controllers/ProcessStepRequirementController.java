package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ProcessStepRequirement;
import com.albatross.api.v1.flow.model.ProcessStepRequirementType;
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
@RequestMapping(value = "/api/v1/flow/companies/{companyId}/processStep/{stepId}/requirement")
public class ProcessStepRequirementController {

  @Autowired
  private ProcessStepRequirementService processStepRequirementService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepRequirement> getRequirementsForStep (@PathVariable Long companyId,
                                                              @PathVariable Long stepId) {
    return processStepRequirementService.getRequirementsForStep(companyId, stepId);
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
  public ProcessStepRequirement updateProcess(@RequestBody ProcessStepRequirement requirement) {
    return processStepRequirementService.updateRequirement(requirement);
  }

  @RequestMapping(value = "", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepRequirement insertProcess(@RequestBody ProcessStepRequirement requirement) {
    return processStepRequirementService.insertRequirement(requirement);
  }

}
