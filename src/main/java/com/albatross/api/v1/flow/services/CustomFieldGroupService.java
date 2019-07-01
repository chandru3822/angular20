package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


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
  CustomFieldService customFieldService;

  @Autowired
  ObjectMapper om;

  public void addFieldToGroup(CustomField customField) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("customFieldGroupTypeId", customField.getCustomFieldGroupTypeId());
    params.put("customFieldId", customField.getId());
    params.put("processStepCustomFieldId", null);
    params.put("fieldOrder", customField.getFieldOrder());

    Long id = sqlCache.updateReturningId("customFieldGroup.addFieldToGroup", params, "id").longValue();

    // do i need to return anything?
  }


  public void deleteFieldFromGroup(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    sqlCache.update("customFieldGroup.deleteFieldFromGroup", params);
  }

  public void updateFieldInGroup(CustomField customField) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customField.getId());
    params.put("fieldOrder", customField.getFieldOrder());

    sqlCache.update("customFieldGroup.updateFieldInGroup", params);
  }

  public void updateFieldsInGroup(List<CustomField> customFields) {
    for(CustomField cf : customFields){
      updateFieldInGroup(cf);
    }
  }

  public List<CustomFieldGroup> getCustomFieldGroupsByObjectTypeId(Long objectTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", objectTypeId);

    List<CustomFieldGroup> results = sqlCache.query("customFieldGroup.getByObjectTypeId", params, CustomFieldGroup.class);
    return results;
  }

  public List<CustomField> getCustomFieldsInGroup(Long groupTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("groupTypeId", groupTypeId);

    List<CustomField> results = sqlCache.query("customFieldGroup.getCustomFieldsInGroup", params, CustomField.class);
    return results;
  }

  public List<CustomField> getAvailableCustomFieldsInGroup(Long objectTypeId, Long groupTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", objectTypeId);
    params.put("groupTypeId", groupTypeId);

    List<CustomField> results = sqlCache.query("customFieldGroup.getAvailableCustomFieldsInGroup", params, CustomField.class);
    return results;
  }

  public CustomFieldGroup addCustomFieldGroupType(CustomFieldGroup customFieldGroup) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("groupName", customFieldGroup.getGroupName());
    params.put("objectTypeId", customFieldGroup.getObjectTypeId());
    params.put("groupOrder", customFieldGroup.getGroupOrder());

    Long id = sqlCache.updateReturningId("customFieldGroup.insertCustomFieldGroupType", params, "id").longValue();
    params.put("id", id);

    Optional<CustomFieldGroup> group = sqlCache.get("customFieldGroup.getOne", params, CustomFieldGroup.class);

    return group.orElse(null);
  }

  public void deleteCustomFieldGroupType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    sqlCache.update("customFieldGroup.deleteCustomFieldGroupType", params);
  }

  public CustomFieldGroup updateCustomFieldGroupType(CustomFieldGroup customFieldGroup) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customFieldGroup.getId());
    params.put("groupOrder", customFieldGroup.getGroupOrder());
    params.put("groupName", customFieldGroup.getGroupName());

    sqlCache.update("customFieldGroup.updateCustomFieldGroupType", params);

    Optional<CustomFieldGroup> group = sqlCache.get("customFieldGroup.getOne", params, CustomFieldGroup.class);

    return group.orElse(null);
  }

  public void updateCustomFieldGroupTypes(List<CustomFieldGroup> customFieldGroups) {
    for(CustomFieldGroup cfg : customFieldGroups){
      updateCustomFieldGroupType(cfg);
    }
  }

}
