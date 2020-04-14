package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class SmartlistService {

  private final SecurityService securityService;

  private final SqlCache sqlCache;

  public List<Smartlist> getSmartlists() {
    return sqlCache.query("smartlist.get", null, Smartlist.class);
  }

  public Smartlist getSmartlist(Long id) {
    return sqlCache.get("smartlist.getById", Map.of("id", id), Smartlist.class).orElse(null);
  }

  public Smartlist addSmartlist(Smartlist smartlist) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("name", smartlist.getName(), "companyObjectTypeId", smartlist.getCompanyObjectTypeId(), "ownerId", user.getId(), "createdById", user.getId());
    Long smartlistId = sqlCache.updateReturningId("smartlist.add", params, "id").longValue();
    return getSmartlist(smartlistId);
  }

  public void updateSmartlist(Smartlist smartlist) {
    Map<String, Object> params = Map.of("id", smartlist.getId(), "name", smartlist.getName(), "companyObjectTypeId", smartlist.getCompanyObjectTypeId(), "shared", smartlist.isShared());
    sqlCache.update("smartlist.update", params);
  }

  public List<SmartlistFieldAssignment> getAvailableSmartlistFields(Long objectTypeId, Long processStepId) {

    if (objectTypeId == 4) {
      Assert.notNull(processStepId, "Must provide a process step ID");
    }

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", securityService.getCurrentUser().getCompanyId());
    params.put("objectTypeId", objectTypeId);
    params.put("processStepId", processStepId);
    return sqlCache.query("smartlist.getAvailableFields", params, SmartlistFieldAssignment.class);
  }

  public List<SmartlistFieldAssignment> getAssignedFields(Long smartlistId) {
    return sqlCache.query("smartlist.getAssignedFields", Map.of("id", smartlistId), SmartlistFieldAssignment.class);
  }

  public SmartlistFieldAssignment getAssignedFieldById(Long assignmentId) {
    return sqlCache.get("smartlist.getAssignedFieldById", Map.of("id", assignmentId), SmartlistFieldAssignment.class).orElse(null);
  }

  public SmartlistFieldAssignment addField(SmartlistFieldAssignment assignment) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("smartlistId", assignment.getSmartlistId());
    params.put("smartlistFieldId", assignment.getSmartlistFieldId());
    params.put("customFieldGroupAssignmentId", assignment.getCustomFieldGroupAssignmentId());
    params.put("displayOrder", assignment.getDisplayOrder());
    params.put("createdById", user.getId());
    Long assignmentId = sqlCache.updateReturningId("smartlist.addField", params, "id").longValue();
    return this.getAssignedFieldById(assignmentId);
  }

  public void deleteFieldAssignment(Long fieldId) {
    sqlCache.update("smartlist.deleteField", Map.of("id", fieldId, "userId", securityService.getCurrentUser().getId()));
  }

  public void updateDisplayOrder(List<SmartlistFieldAssignment> fields) {
    fields.forEach(field -> {
      sqlCache.update("smartlist.updateDisplayOrder", Map.of("id", field.getId(), "displayOrder", field.getDisplayOrder(), "userId", securityService.getCurrentUser().getId()));
    });
  }
}
