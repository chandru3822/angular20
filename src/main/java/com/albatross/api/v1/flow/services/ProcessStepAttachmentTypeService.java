package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.processStep.ProcessStepAttachmentType;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProcessStepAttachmentTypeService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<ProcessStepAttachmentType> getStepTypes(Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    return sqlCache.query("processStepAttachmentType.getStepTypes", params, ProcessStepAttachmentType.class);
  }

  public List<ProcessStepAttachmentType> getAvailableTypesForStep(Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    return sqlCache.query("processStepAttachmentType.getAvailableTypesForStep", params, ProcessStepAttachmentType.class);
  }

  public Optional<ProcessStepAttachmentType> getProcessStepAttachmentType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<ProcessStepAttachmentType> result = sqlCache.get("processStepAttachmentType.get", params, ProcessStepAttachmentType.class);
    return result;
  }

  public Optional<ProcessStepAttachmentType> addTypeToStep(Long processStepId, ProcessStepAttachmentType processStepAttachmentType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("createdById", currentUser.trueUserId());
    params.put("attachmentTypeId", processStepAttachmentType.getAttachmentTypeId());
    Long id = sqlCache.updateReturningId("processStepAttachmentType.addTypeToStep", params, "id").longValue();
    return getProcessStepAttachmentType(id);
  }

  public void updateTypeOrder(List<ProcessStepAttachmentType> attachmentTypes) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    for (ProcessStepAttachmentType at : attachmentTypes) {
      params.put("displayOrder", at.getDisplayOrder());
      params.put("modifiedById", currentUser.trueUserId());
      params.put("id", at.getId());
      // save each display_order
      sqlCache.update("processStepAttachmentType.updateDisplayOrder", params);
    }
  }

  public void deleteTypeFromStep(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", currentUser.trueUserId());
    sqlCache.update("processStepAttachmentType.deleteTypeFromStep", params);
  }

}
