package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyProcessStepStatusType;
import com.albatross.api.v1.flow.model.ProcessStepCompanyProcessStepStatusType;
import com.albatross.api.v1.flow.model.ProcessStepStatusType;
import com.albatross.api.v1.flow.services.ProcessStepStatusService;
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
@RequestMapping(value = "/api/v1/flow/processStep/status")
public class ProcessStepStatusController {

  @Autowired
  private ProcessStepStatusService processStepStatusService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepStatusType> getStatusTypes () {
    return processStepStatusService.getStatusTypes();
  }

  @GetMapping(value = "/company", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyProcessStepStatusType> getStatusTypesForCompany (@RequestParam(required = false) Long projectId,
                                                                      @RequestParam(required = false) Long projectProcessStepId) {
    return processStepStatusService.getStatusTypesForCompany(projectId, projectProcessStepId);
  }

  @GetMapping(value = "/company/availableForProcessStep/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyProcessStepStatusType> getAvailableForProcessStep (@PathVariable Long id) {
    return processStepStatusService.getAvailableForProcessStep(id);
  }

  @GetMapping(value = "/company/cancelled", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyProcessStepStatusType> getCancelledCompanyStatusTypesForCompany (@RequestParam(required = false) Long projectId,
                                                                                      @RequestParam(required = false) Long projectProcessStepId) {
    return processStepStatusService.getCancelledCompanyStatusTypesForCompany(projectId, projectProcessStepId);
  }

  @DeleteMapping(value = "/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long typeId) {
    processStepStatusService.deleteType(typeId);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateProcessStepStatusType(@RequestBody CompanyProcessStepStatusType type) {
    processStepStatusService.updateType(type);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<CompanyProcessStepStatusType> insertProcessStepStatusType(@RequestBody CompanyProcessStepStatusType type) {
    return processStepStatusService.insertType(type);
  }

  @GetMapping(value = "/company/activeAssignedToProcessStep/{processStepId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyProcessStepStatusType> getActiveAssignedToProcessStep(@PathVariable Long processStepId) {
    return processStepStatusService.getActiveAssignedToProcessStep(processStepId);
  }

  @GetMapping(value = "/company/assignedToProcessStep/{processStepId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyProcessStepStatusType> getAssignedToStep(@PathVariable Long processStepId) {
    return processStepStatusService.getAssignedToStep(processStepId);
  }

  @GetMapping(value = "/company/cancelledAssignedToProcessStep/{processStepId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyProcessStepStatusType> getCancelledAssignedToStep(@PathVariable Long processStepId) {
    return processStepStatusService.getCancelledAssignedToStep(processStepId);
  }

  @PostMapping(value = "/assignCompanyStatus/{companyStatusTypeId}/toProcessStep/{processStepId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepCompanyProcessStepStatusType> assignStatusToProcessStep(@PathVariable Long companyStatusTypeId,
                                                                           @PathVariable Long processStepId) {
    return processStepStatusService.assignStatusToProcessStep(companyStatusTypeId, processStepId);
  }

  @DeleteMapping(value = "/removeFromStep/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity deleteStatusFromProcessStep(@PathVariable Long id) {
    return processStepStatusService.deleteStatusFromProcessStep(id);
  }
}
