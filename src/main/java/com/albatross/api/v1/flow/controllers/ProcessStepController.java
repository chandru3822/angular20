package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ProcessStep;
import com.albatross.api.v1.flow.services.ProcessStepService;
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
@RequestMapping(value = "/api/v1/flow/companies/{companyId}/processStep")
public class ProcessStepController {

  @Autowired
  private ProcessStepService processStepService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStep> getProcessStepsForCompany(@PathVariable Long companyId) {
    return processStepService.getProcessStepsForCompany(companyId);
  }

  @RequestMapping(value = "/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStep getProcessStep(@PathVariable Long id) {
    return processStepService.getProcessStep(id);
  }


  @RequestMapping(value = "/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteStep(@PathVariable Long id) {
    processStepService.deleteStep(id);
  }

  @RequestMapping(value = "", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateStep(@RequestBody ProcessStep processStep) {
    processStepService.updateStep(processStep);
  }

  @RequestMapping(value = "", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStep insertStep(@PathVariable Long companyId,
                         @RequestBody ProcessStep processStep) {
    return processStepService.insertStep(companyId, processStep);
  }

  @RequestMapping(value = "/{id}/getParentObjects", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStep> getParentObjects (@PathVariable Long companyId,
                                             @PathVariable Long id) {
    return processStepService.getParentObjects(companyId, id);
  }
}
