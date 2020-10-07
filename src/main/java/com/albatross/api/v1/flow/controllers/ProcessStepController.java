package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CombinedStepAndType;
import com.albatross.api.v1.flow.model.FieldInUse;
import com.albatross.api.v1.flow.model.ProcessStep;
import com.albatross.api.v1.flow.services.ProcessStepService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStep> getProcessStepsForCompany() {
    return processStepService.getProcessStepsForCompany();
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStep getProcessStep(@PathVariable Long id) {
    return processStepService.getProcessStep(id);
  }

  @PutMapping(value = "/delete/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<FieldInUse> deleteStep(@PathVariable Long id) {
    return processStepService.deleteStep(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateStep(@RequestBody ProcessStep processStep) {
    processStepService.updateStep(processStep);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStep insertStep(@RequestBody ProcessStep processStep) {
    return processStepService.insertStep(processStep);
  }

  @GetMapping(value = "/getParentObjects", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStep> getParentObjects (@RequestParam(required = false) Long id) {
    return processStepService.getParentObjects(id);
  }

  @GetMapping(value = "/getParentObjectsWithTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CombinedStepAndType> getParentObjectsIncludingTypes (@RequestParam(required = false) Long id) {
    return processStepService.getParentObjectsIncludingTypes(id);
  }

  @GetMapping(value = "/getByCompany", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ProcessStep>> getProcessStepsByCompanyId() {
    return new ResponseEntity<>(processStepService.getByCompanyId(), HttpStatus.OK);
  }
}
