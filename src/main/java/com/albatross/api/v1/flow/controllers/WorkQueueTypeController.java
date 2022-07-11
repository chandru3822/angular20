package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.DurationType;
import com.albatross.api.v1.flow.model.FieldInUse;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEventWorkQueueType;
import com.albatross.api.v1.flow.model.processStep.ProcessStepWorkQueueType;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueType;
import com.albatross.api.v1.flow.services.WorkQueueTypeService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
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

  @GetMapping(value = "/durationTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<DurationType> getDurationTypes () {
    return workQueueTypeService.getDurationTypes();
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<WorkQueueType> getWorkQueueType (@PathVariable Long id) {
    return workQueueTypeService.getType(id);
  }

  @PutMapping(value = "/saveHiddenAndWhiteList", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveHiddenAndWhiteList(@RequestParam(required = false) Boolean savePositions,
                                     @RequestBody WorkQueueType workQueueType) {
    //will only savePositions if they changed
    workQueueTypeService.saveHiddenAndWhiteList(workQueueType, savePositions);
  }

  @PutMapping(value = "/delete/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<FieldInUse>> deleteType(@PathVariable Long typeId) {
    return workQueueTypeService.deleteType(typeId);
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

  @PutMapping(value = "/saveStatusTypesToProcessStepWorkQueueType", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepWorkQueueType> saveProjectStatusTypesToWorkQueueType(@RequestBody ProcessStepWorkQueueType processStepWorkQueueType) {
    workQueueTypeService.saveProjectStatusTypesToWorkQueueType(processStepWorkQueueType, null);
    workQueueTypeService.saveProcessStepStatusTypesToWorkQueueType(processStepWorkQueueType, null);

    workQueueTypeService.callConfigChangeFunction(processStepWorkQueueType.getId(), null);
    return workQueueTypeService.getProcessStepWorkQueueType(processStepWorkQueueType.getId());
  }

  @PutMapping(value = "/saveStatusTypesToProcessStepEventWorkQueueType", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepEventWorkQueueType> saveProjectStatusTypesToEventWorkQueueType(@RequestBody ProcessStepEventWorkQueueType processStepEventWorkQueueType) {
    workQueueTypeService.saveProjectStatusTypesToWorkQueueType(null, processStepEventWorkQueueType);
    workQueueTypeService.saveProcessStepStatusTypesToWorkQueueType(null, processStepEventWorkQueueType);
    workQueueTypeService.saveEventStatusTypesToWorkQueueType(processStepEventWorkQueueType);

    workQueueTypeService.callConfigChangeFunction(null, processStepEventWorkQueueType.getId());
    return workQueueTypeService.getEventWorkQueueType(processStepEventWorkQueueType.getId());
  }

  //event wqt
  @GetMapping(value = "/event/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueType> getAvailableWorkQueueTypesForEvent (@PathVariable Long id) {
    return workQueueTypeService.getAvailableWorkQueueTypesForEvent(id);
  }

  @DeleteMapping(value = "/event/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteEventWorkQueueType(@PathVariable Long id) {
    workQueueTypeService.deleteEventWorkQueueType(id);
  }

  @PostMapping(value = "/event", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepEventWorkQueueType> insertEventWorkQueueType(@RequestBody ProcessStepEventWorkQueueType workQueueType) {
    return workQueueTypeService.insertEventWorkQueueType(workQueueType);
  }

}
