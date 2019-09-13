package com.albatross.api.v1.flow.controllers;

import java.util.List;

import com.albatross.api.v1.flow.model.ProcessStep;
import com.albatross.api.v1.flow.services.ProcessStepService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/processStep")
public class ProcessStepController {

  @Autowired
  private ProcessStepService processStepService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStep> getProcessStepsForCompany() {
    return processStepService.getProcessStepsForCompany();
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
  public ProcessStep insertStep(@RequestBody ProcessStep processStep) {
    return processStepService.insertStep(processStep);
  }

  @RequestMapping(value = "/getParentObjects", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStep> getParentObjects (@RequestParam(required = false) Long id) {
    return processStepService.getParentObjects(id);
  }
}
