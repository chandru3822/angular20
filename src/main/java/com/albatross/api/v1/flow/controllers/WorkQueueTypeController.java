package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.DurationType;
import com.albatross.api.v1.flow.model.FieldInUse;
import com.albatross.api.v1.flow.model.filter.WorkFiltersDTO;
import com.albatross.api.v1.flow.model.filter.WorkTypeFilters;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEventWorkQueueType;
import com.albatross.api.v1.flow.model.processStep.ProcessStepWorkQueueType;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueType;
import com.albatross.api.v1.flow.services.WorkQueueTypeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
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
@RequiredArgsConstructor
public class WorkQueueTypeController {

  private final WorkQueueTypeService workQueueTypeService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueType> getWorkQueueTypes(@RequestParam(required = false) Boolean sortByName) {
    return workQueueTypeService.getWorkQueueTypes(sortByName);
  }

  @GetMapping(value = "/durationTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<DurationType> getDurationTypes() {
    return workQueueTypeService.getDurationTypes();
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<WorkQueueType> getWorkQueueType(@PathVariable Long id) {
    return workQueueTypeService.getType(id);
  }

  @GetMapping(value = "/{id}/settings", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<WorkQueueType> getWorkQueueTypeForSettings(@PathVariable Long id) {
    return workQueueTypeService.getTypeForSettings(id);
  }

  @GetMapping(value = "/{id}/inUseBy", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getItemsUsingWorkQueue(@PathVariable Long id) {
    return workQueueTypeService.getItemsUsingWorkQueueType(id);
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
  public List<WorkQueueType> getAvailableWorkQueueTypesForStep(@PathVariable Long id) {
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

  @GetMapping("/filters")
  public List<WorkFiltersDTO> getWorkQueueTypeFilters(@RequestParam Long workQueueTypeId) {
    return workQueueTypeService.getWorkQueueTypeFilters(workQueueTypeId);
  }

  @DeleteMapping("/filter/{id}")
  public ResponseEntity<Void> deleteWorkQueueTypeFilter(@PathVariable Long id) {
    try {
      workQueueTypeService.deleteWorkQueueTypeFilter(id);
      return ResponseEntity.ok().build();
    } catch (Exception e) {
      log.error("Error deleting work queue type filter: {}", e.getMessage(), e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

  @PutMapping(value = "/saveStatusTypesToProcessStepWorkQueueType", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepWorkQueueType> saveProjectStatusTypesToWorkQueueType(@RequestBody ProcessStepWorkQueueType processStepWorkQueueType) {
    workQueueTypeService.saveProjectStatusTypesToWorkQueueType(processStepWorkQueueType, null);
    workQueueTypeService.saveProcessStepStatusTypesToWorkQueueType(processStepWorkQueueType, null);

    // Add code to save filters
    if (processStepWorkQueueType.getSelectedFilters() != null) {
      workQueueTypeService.saveWorkQueueTypeFilters(processStepWorkQueueType.getWorkQueueTypeId(),
        processStepWorkQueueType.getSelectedFilters(),
        processStepWorkQueueType.getProcessStepId(),
        null);
    }

    workQueueTypeService.callConfigChangeFunction(processStepWorkQueueType.getId(), null);
    return workQueueTypeService.getProcessStepWorkQueueType(processStepWorkQueueType.getId());
  }

  @PutMapping(value = "/saveStatusTypesToProcessStepEventWorkQueueType", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepEventWorkQueueType> saveProjectStatusTypesToEventWorkQueueType(@RequestBody ProcessStepEventWorkQueueType processStepEventWorkQueueType) {
    workQueueTypeService.saveProjectStatusTypesToWorkQueueType(null, processStepEventWorkQueueType);
    workQueueTypeService.saveProcessStepStatusTypesToWorkQueueType(null, processStepEventWorkQueueType);
    workQueueTypeService.saveEventStatusTypesToWorkQueueType(processStepEventWorkQueueType);

    // Add code to save filters
    if (processStepEventWorkQueueType.getSelectedFilters() != null) {
      workQueueTypeService.saveWorkQueueTypeFilters(null,
        processStepEventWorkQueueType.getSelectedFilters(),
        null,
        processStepEventWorkQueueType.getId());
    }

    workQueueTypeService.callConfigChangeFunction(null, processStepEventWorkQueueType.getId());
    return workQueueTypeService.getEventWorkQueueType(processStepEventWorkQueueType.getId());
  }

  //event wqt
  @GetMapping(value = "/event/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueType> getAvailableWorkQueueTypesForEvent(@PathVariable Long id) {
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
