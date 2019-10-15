package com.albatross.api.v1.flow.services;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.CustomFieldObjectType;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import lombok.extern.slf4j.Slf4j;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class CustomFieldGroupService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  CustomFieldService customFieldService;

  @Autowired
  CustomFieldValueService customFieldValueService;

  @Autowired
  ObjectMapper om;

  public CustomField addFieldToGroup(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("customFieldGroupId", customField.getCustomFieldGroupId());
    params.put("customFieldId", customField.getId());
    params.put("createdById", currentUser.getId());
    params.put("ancillaryCustomFieldGroupAssignmentId", customField.getAncillaryCustomFieldGroupAssignmentId());
    params.put("fieldOrder", customField.getFieldOrder());

    Long id = sqlCache.updateReturningId("customFieldGroupAssignment.addFieldToGroup", params, "id").longValue();

    return getCustomField(id);
  }

  public CustomField getCustomField(Long id){
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<CustomField> result = sqlCache.get("customFieldGroupAssignment.getCustomField", params, CustomField.class);
    return result.orElse(null);
  }

  public void deleteAllFieldsInGroup(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("customFieldGroupAssignment.deleteAllFieldsInGroup", params);
  }

  public void deleteFieldFromGroup(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("customFieldGroupAssignment.deleteFieldFromGroup", params);
  }

  public void updateFieldInGroup(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customField.getId());
    params.put("modifiedById", currentUser.getId());
    params.put("fieldOrder", customField.getFieldOrder());

    sqlCache.update("customFieldGroupAssignment.updateFieldInGroup", params);
  }

  public void updateFieldsInGroup(List<CustomField> customFields) {
    for(CustomField cf : customFields){
      updateFieldInGroup(cf);
    }
  }

  public List<CustomFieldGroup> getCustomFieldGroupsByObjectTypeId(Long objectTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", objectTypeId);

    List<CustomFieldGroup> results = sqlCache.query("customFieldGroupAssignment.getByObjectTypeId", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));
    return results;
  }

  public List<CustomField> getCustomFieldsInGroup(Long groupId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("groupId", groupId);

    List<CustomField> results = sqlCache.query("customFieldGroupAssignment.getCustomFieldsInGroup", params, CustomField.class);
    return results;
  }

  public List<CustomField> getAvailableCustomFieldsInGroup(Long objectTypeId, Long groupId, Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", objectTypeId);
    params.put("groupId", groupId);

    List<CustomField> results;

    if(null != processStepId) {
      // as of right now, judson says a field can be native to multiple process steps, but not within the same process step, i think this query does that now
      params.put("processStepId", processStepId);
      results = sqlCache.query("customFieldGroupAssignment.getAvailableNativeFieldsForProcessStep", params, CustomField.class);
    } else {
      results = sqlCache.query("customFieldGroupAssignment.getAvailableCustomFieldsInGroup", params, CustomField.class);
    }
    return results;
  }

  public CustomFieldGroup addCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("groupName", customFieldGroup.getGroupName());
    params.put("objectTypeId", customFieldGroup.getObjectTypeId());
    params.put("groupOrder", customFieldGroup.getGroupOrder());
    params.put("processStepId", customFieldGroup.getProcessStepId());

    Long id = sqlCache.updateReturningId("customFieldGroup.insertCustomFieldGroup", params, "id").longValue();
    params.put("id", id);

    Optional<CustomFieldGroup> group = sqlCache.get("customFieldGroupAssignment.getOne", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    return group.orElse(null);
  }

  public void deleteCustomFieldGroup(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    sqlCache.update("customFieldGroup.deleteCustomFieldGroup", params);
  }

  public CustomFieldGroup updateCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customFieldGroup.getId());
    params.put("groupOrder", customFieldGroup.getGroupOrder());
    params.put("groupName", customFieldGroup.getGroupName());

    sqlCache.update("customFieldGroup.updateCustomFieldGroup", params);

    Optional<CustomFieldGroup> group = sqlCache.get("customFieldGroupAssignment.getOne", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    return group.orElse(null);
  }

  public void updateCustomFieldGroups(List<CustomFieldGroup> customFieldGroups) {
    for(CustomFieldGroup cfg : customFieldGroups){
      updateCustomFieldGroup(cfg);
    }
  }

  public List<CustomFieldGroup> getInsertFieldsByType(Long objectTypeId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("objectTypeId", objectTypeId);

    List<CustomFieldGroup> results = sqlCache.query("customFieldGroup.getInsertFieldsByType", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    results.stream().filter(cfg -> !cfg.getCustomFieldValues().isEmpty()).collect(Collectors.toList());

    customFieldValueService.handleCustomListOfValue(results);

    return results;
  }

  public void updateFieldShowOnInsert(CustomFieldObjectType objectType) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", objectType.getId());
    params.put("showOnInsert", objectType.getShowOnInsert());

    sqlCache.update("customFieldGroup.updateFieldShowOnInsert", params);
  }

  public static class CustomFieldGroupMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CustomFieldGroupMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomField>> customFieldTypeRef = new TypeReference<List<CustomField>>() {};
      bw.registerCustomEditor(List.class, "customFields",
          new JsonCollectionDeserializer(customFieldTypeRef, objectMapper));

      TypeReference<List<CustomFieldValue>> customFieldValueRef = new TypeReference<List<CustomFieldValue>>() {};
      bw.registerCustomEditor(List.class, "customFieldValues",
          new JsonCollectionDeserializer(customFieldValueRef, objectMapper));
    }
  }

}
