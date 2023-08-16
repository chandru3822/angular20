package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.company.blueraven.models.MarketoProject;
import com.albatross.api.v1.company.blueraven.services.MarketoService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.DensitySearch;
import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.albatross.api.v1.flow.model.project.*;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStep;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeProjectStatus;
import com.albatross.api.v1.flow.services.MessagingService;
import com.albatross.api.v1.flow.services.ProjectService;
import com.albatross.api.v1.flow.services.ProjectStatusService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/projectStatus", produces = MediaType.APPLICATION_JSON_VALUE)
public class ProjectStatusTypeController {

  private final ProjectStatusService projectStatusService;

  @PostMapping(value = "/company/{cpstId}")
  public Optional<CompanyProjectStatusFieldAssignment> saveFieldToCompanyProjectStatus(@PathVariable Long cpstId,
                                                                                       @RequestBody CompanyProjectStatusFieldAssignment field) {
    return projectStatusService.addFieldToCompanyProjectStatus(cpstId, field);
  }

  @GetMapping(value = "/company/{cpstId}")
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

}
