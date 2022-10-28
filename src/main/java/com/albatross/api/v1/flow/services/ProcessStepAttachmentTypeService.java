package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.processStep.ProcessStepAttachmentType;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
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
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("companyId", currentUser.getCompanyId());
    return sqlCache.query("processStepAttachmentType.getAvailableTypesForStep", params, ProcessStepAttachmentType.class);
  }

  public Optional<ProcessStepAttachmentType> getProcessStepAttachmentType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<ProcessStepAttachmentType> result = sqlCache.get("processStepAttachmentType.get", params, new ProcessStepAttachmentTypeMapper<>(ProcessStepAttachmentType.class, om));
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

  public void updateType(ProcessStepAttachmentType attachmentType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("focused", null != attachmentType.getFocused() && attachmentType.getFocused());
    params.put("linkable", null != attachmentType.getLinkable() && attachmentType.getLinkable());
    params.put("allowUpload", null != attachmentType.getAllowUpload() && attachmentType.getAllowUpload());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", attachmentType.getId());
    String sqlKey = "processStepAttachmentType.update";
    sqlCache.update(sqlKey, params);
  }

  public void deleteTypeFromStep(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", currentUser.trueUserId());
    sqlCache.update("processStepAttachmentType.deleteTypeFromStep", params);
  }

  public static class ProcessStepAttachmentTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepAttachmentTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomFieldGroup>> customFieldGroupRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "customFieldGroups",
        new JsonCollectionDeserializer(customFieldGroupRef, objectMapper));
    }
  }
}
