package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.project.*;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeProjectStatus;
import com.albatross.api.v1.flow.services.ProjectStatusService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/projectStatus", produces = MediaType.APPLICATION_JSON_VALUE)
public class ProjectStatusTypeController {

  private final ProjectStatusService projectStatusService;

  @PostMapping(value = "/company/{cpstId}/field")
  public Optional<CompanyProjectStatusFieldAssignment> saveFieldToCompanyProjectStatus(@PathVariable Long cpstId,
                                                                                       @RequestBody CompanyProjectStatusFieldAssignment field) {
    return projectStatusService.addFieldToCompanyProjectStatus(cpstId, field);
  }

  @GetMapping(value = "/company/{cpstId}/fields")
  public List<CompanyProjectStatusFieldAssignment> getFieldsForCompanyProjectStatus(@PathVariable Long cpstId) {
    return projectStatusService.getFieldsForCompanyProjectStatus(cpstId);
  }

  @PutMapping(value = "/company/{cpstId}/fields")
  public void saveFieldsOrder(@PathVariable Long cpstId,
                                         @RequestBody List<CompanyProjectStatusFieldAssignment> fields) {
    projectStatusService.saveFieldsOrder(cpstId, fields);
  }

  @DeleteMapping(value = "/field/{fieldId}")
  public void archiveField(@PathVariable Long fieldId) {
    projectStatusService.archiveField(fieldId);
  }

  @PutMapping(value = "/company/initial/{id}")
  public void saveInitialProjectStatusType(@PathVariable Long id) {
    projectStatusService.saveInitialProjectStatusType(id);
  }

  @PutMapping(value = "/company")
  public ResponseEntity<Optional<ProjectStatusType>> saveCompanyProjectStatus(
    @RequestBody ProjectStatusType status) {
    return new ResponseEntity<>(projectStatusService.saveCompanyProjectStatus(status), HttpStatus.OK);
  }

  @PutMapping(value = "/companyStatuses")
  public ResponseEntity<List<ProjectStatusType>> saveCompanyProjectStatuses(@RequestBody List<ProjectStatusType> statuses) {
      return new ResponseEntity<>(projectStatusService.saveCompanyProjectStatuses(statuses),HttpStatus.OK);
  }

  @GetMapping(value = "/wqt")
  public ResponseEntity<List<WorkQueueTypeProjectStatus>> getStatusesForWqt() {
    return new ResponseEntity<>(projectStatusService.getStatusesForWqt(), HttpStatus.OK);
  }


  @GetMapping(value = "")
  public ResponseEntity<List<ProjectStatusType>> getProjectStatuses() {
    return new ResponseEntity<>(projectStatusService.getProjectStatuses(), HttpStatus.OK);
  }

  @DeleteMapping(value = "/companyStatus/{id}")
  public ResponseEntity<ProjectStatusTypeController.CannotDeleteProjectStatus> deleteCompanyProjectStatus(
    @PathVariable Long id) {
    return projectStatusService.deleteCompanyProjectStatus(id);
  }

  @Data
  public static class CannotDeleteProjectStatus {
    private Boolean statusInUseByProjects, statusInUseByActions,
      statusInUseByEventRequirements, statusInUseByProcessStepRequirements;
  }
}
