package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldGroupType;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
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
    params.put("ancillaryCustomFieldGroupId", customField.getAncillaryCustomFieldGroupId());
    params.put("fieldOrder", customField.getFieldOrder());

    Long id = sqlCache.updateReturningId("customFieldGroup.addFieldToGroup", params, "id").longValue();

    // do i need to return anything?
  }

  public void deleteAllFieldsInGroup(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    sqlCache.update("customFieldGroup.deleteAllFieldsInGroup", params);
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

  public List<CustomFieldGroupType> getCustomFieldGroupsByObjectTypeId(Long objectTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", objectTypeId);

    List<CustomFieldGroupType> results = sqlCache.query("customFieldGroup.getByObjectTypeId", params, CustomFieldGroupType.class);
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

  public CustomFieldGroupType addCustomFieldGroupType(CustomFieldGroupType customFieldGroupType) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("groupName", customFieldGroupType.getGroupName());
    params.put("objectTypeId", customFieldGroupType.getObjectTypeId());
    params.put("groupOrder", customFieldGroupType.getGroupOrder());
    params.put("processStepId", customFieldGroupType.getProcessStepId());

    Long id = sqlCache.updateReturningId("customFieldGroup.insertCustomFieldGroupType", params, "id").longValue();
    params.put("id", id);

    Optional<CustomFieldGroupType> group = sqlCache.get("customFieldGroup.getOne", params, new CustomFieldGroupMapper<>(CustomFieldGroupType.class, om));

    return group.orElse(null);
  }

  public void deleteCustomFieldGroupType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    sqlCache.update("customFieldGroup.deleteCustomFieldGroupType", params);
  }

  public CustomFieldGroupType updateCustomFieldGroupType(CustomFieldGroupType customFieldGroupType) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customFieldGroupType.getId());
    params.put("groupOrder", customFieldGroupType.getGroupOrder());
    params.put("groupName", customFieldGroupType.getGroupName());

    sqlCache.update("customFieldGroup.updateCustomFieldGroupType", params);

    Optional<CustomFieldGroupType> group = sqlCache.get("customFieldGroup.getOne", params, CustomFieldGroupType.class);

    return group.orElse(null);
  }

  public void updateCustomFieldGroupTypes(List<CustomFieldGroupType> customFieldGroupTypes) {
    for(CustomFieldGroupType cfg : customFieldGroupTypes){
      updateCustomFieldGroupType(cfg);
    }
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
    }
  }

}
