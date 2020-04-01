package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Smartlist;
import com.albatross.api.v1.flow.model.SmartlistField;
import com.albatross.api.v1.flow.model.SmartlistFieldAssignment;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
    Map<String, Object> params = Map.of("id", smartlist.getId(), "name", smartlist.getName(), "companyObjectTypeId", smartlist.getCompanyObjectTypeId());
    sqlCache.update("smartlist.update", params);
  }

  public List<SmartlistField> getAvailableSmartlistFields() {
    User user = securityService.getCurrentUser();
    return sqlCache.query("smartlist.getAvailableFields", Map.of("companyId", user.getCompanyId()), SmartlistField.class);
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
    params.put("customFieldId", assignment.getCustomFieldId());
    params.put("displayOrder", assignment.getDisplayOrder());
    params.put("createdById", user.getId());
    Long assignmentId = sqlCache.updateReturningId("smartlist.addField", params, "id").longValue();
    return this.getAssignedFieldById(assignmentId);
  }
}
