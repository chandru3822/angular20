package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.processStep.ProcessStepAttachmentType;
import com.albatross.api.v1.flow.services.ProcessStepAttachmentTypeService;
import lombok.RequiredArgsConstructor;
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
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/processStep/{stepId}/attachmentType")
public class ProcessStepAttachmentTypeController {

  private final ProcessStepAttachmentTypeService processStepAttachmentTypeService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepAttachmentType> getStepTypes(@PathVariable Long stepId) {
    return processStepAttachmentTypeService.getStepTypes(stepId);
  }

  @GetMapping(value = "/{psAttachmentTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepAttachmentType> getProcessStepAttachmentType(@PathVariable Long psAttachmentTypeId) {
    return processStepAttachmentTypeService.getProcessStepAttachmentType(psAttachmentTypeId);
  }

  @GetMapping(value = "/available", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepAttachmentType> getAvailableTypesForStep(@PathVariable Long stepId) {
    return processStepAttachmentTypeService.getAvailableTypesForStep(stepId);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepAttachmentType> addTypeToStep(@PathVariable Long stepId,
                                                           @RequestBody ProcessStepAttachmentType processStepAttachmentType) {
    return processStepAttachmentTypeService.addTypeToStep(stepId, processStepAttachmentType);
  }

  @PutMapping(value = "/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeOrder(@RequestBody List<ProcessStepAttachmentType> types) {
    processStepAttachmentTypeService.updateTypeOrder(types);
  }

  @DeleteMapping(value = "/{processStepAttachmentTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteTypeFromStep(@PathVariable Long processStepAttachmentTypeId) {
    processStepAttachmentTypeService.deleteTypeFromStep(processStepAttachmentTypeId);
  }

}
