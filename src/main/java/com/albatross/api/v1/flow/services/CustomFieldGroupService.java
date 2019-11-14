package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;


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
    params.put("scheduleFieldTypeId", customField.getScheduleFieldTypeId());
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

  public List<CustomFieldGroup> getCustomFieldGroupsByObjectTypeId(Long companyObjectTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyObjectTypeId", companyObjectTypeId);

    List<CustomFieldGroup> results = sqlCache.query("customFieldGroupAssignment.getByObjectTypeId", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));
    return results;
  }

  public List<CustomField> getCustomFieldsInGroup(Long groupId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("groupId", groupId);

    List<CustomField> results = sqlCache.query("customFieldGroupAssignment.getCustomFieldsInGroup", params, CustomField.class);
    return results;
  }

  public List<ScheduleFieldType> getScheduleTypesAndFields() {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());

    List<ScheduleFieldType> results = sqlCache.query("customFieldGroupAssignment.getScheduleTypesAndFields", params, new ScheduleFieldTypeMapper<>(ScheduleFieldType.class, om));
    return results;
  }

  public List<CustomField> getAvailableCustomFieldsInGroup(Long companyObjectTypeId, Long groupId, Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyObjectTypeId", companyObjectTypeId);
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

  public CustomFieldGroup addCustomFieldGroup(CustomFieldGroup customFieldGroup, Long companyObjectTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("groupName", customFieldGroup.getGroupName());
    params.put("companyObjectTypeId", companyObjectTypeId);
    params.put("groupOrder", customFieldGroup.getGroupOrder());
    params.put("schedulable", customFieldGroup.getSchedulable());
    params.put("scheduleColor", customFieldGroup.getScheduleColor());
    params.put("processStepId", customFieldGroup.getProcessStepId());

    Long id = sqlCache.updateReturningId("customFieldGroup.insertCustomFieldGroup", params, "id").longValue();
    params.put("id", id);

    Optional<CustomFieldGroup> group = sqlCache.get("customFieldGroupAssignment.getOne", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    return group.orElse(null);
  }

  public CustomFieldGroup addProcessStepCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.PROCESS_STEP.id);
    params.put("companyId", currentUser.getCompanyId());
    Long companyObjectTypeId = sqlCache.queryForObject("customFieldGroup.getCompanyObjectTypeId", params, Long.class);

    CustomFieldGroup cfg = addCustomFieldGroup(customFieldGroup, companyObjectTypeId);

    if(customFieldGroup.getSchedulable() && null != customFieldGroup.getSchedulingFields()) {
      List<CustomField> newFieldList = new ArrayList<>();
      for(CustomField cf : customFieldGroup.getSchedulingFields()) {
        cf.setCustomFieldGroupId(cfg.getId());
        CustomField newCf = addFieldToGroup(cf);
        newFieldList.add(newCf);
      }
      cfg.setCustomFields(newFieldList);
    }

    return cfg;
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
    params.put("scheduleColor", customFieldGroup.getScheduleColor());

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

  public void updateFieldShowOnInsert(CustomFieldObjectType customFieldObjectType) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customFieldObjectType.getId());
    params.put("showOnInsert", customFieldObjectType.getShowOnInsert());

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

  public static class ScheduleFieldTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ScheduleFieldTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomField>> availableCustomFieldTypeRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "availableCustomFields",
          new JsonCollectionDeserializer(availableCustomFieldTypeRef, objectMapper));

    }
  }

}
