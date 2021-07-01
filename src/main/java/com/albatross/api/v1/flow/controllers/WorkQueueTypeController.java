package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.WorkQueueTypeService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/workQueueType")
public class WorkQueueTypeController {

  @Autowired
  private WorkQueueTypeService workQueueTypeService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueType> getWorkQueueTypes (@RequestParam(required = false) Boolean sortByName) {
    return workQueueTypeService.getWorkQueueTypes(sortByName);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<WorkQueueType> getWorkQueueType (@PathVariable Long id) {
    return workQueueTypeService.getType(id);
  }

  @DeleteMapping(value = "/type/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long typeId) {
    workQueueTypeService.deleteType(typeId);
  }

  @PutMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<WorkQueueType> updateType(@RequestBody WorkQueueType type) {
    return workQueueTypeService.updateType(type);
  }

  @PutMapping(value = "/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeDisplayOrders(@RequestBody List<WorkQueueType> types) {
    workQueueTypeService.updateTypeDisplayOrders(types);
  }

  @PostMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<WorkQueueType> insertType(@RequestBody WorkQueueType type) {
    return workQueueTypeService.insertType(type);
  }

  @GetMapping(value = "/processStep/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueType> getAvailableWorkQueueTypesForStep (@PathVariable Long id) {
    return workQueueTypeService.getAvailableWorkQueueTypesForStep(id);
  }

  @DeleteMapping(value = "/processStep/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteProcessStepWorkQueueType(@PathVariable Long id) {
    workQueueTypeService.deleteProcessStepWorkQueueType(id);
  }

  @PostMapping(value = "/processStep", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepWorkQueueType> insertProcessStepWorkQueueType(@RequestBody ProcessStepWorkQueueType workQueueType) {
    return workQueueTypeService.insertProcessStepWorkQueueType(workQueueType);
  }

  @PutMapping(value = "/saveStatusTypesToWorkQueueType", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepWorkQueueType> saveProjectStatusTypesToWorkQueueType(@RequestBody ProcessStepWorkQueueType processStepWorkQueueType) {
    workQueueTypeService.saveProjectStatusTypesToWorkQueueType(processStepWorkQueueType);
    workQueueTypeService.saveProcessStepStatusTypesToWorkQueueType(processStepWorkQueueType);

    return workQueueTypeService.getProcessStepWorkQueueType(processStepWorkQueueType.getId());
  }

}
