package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.CustomFieldGroupController;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
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
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class CustomFieldGroupService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final CustomFieldService customFieldService;
  private final CustomFieldValueService customFieldValueService;
  private final ProcessStepRequirementService processStepRequirementService;
  private final ObjectMapper om;

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

  public CustomField moveFieldToOtherGroup(CustomField customField, Long newGroupId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customField.getCustomFieldGroupAssignmentId());
    params.put("newGroupId", newGroupId);
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("customFieldGroupAssignment.moveFieldToOtherGroup", params);

    return getCustomField(customField.getCustomFieldGroupAssignmentId());
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

  public void saveReadOnlyAndWhiteList(CustomField customField, Boolean savePositions) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("cfgaReadOnly", customField.getCustomFieldGroupAssignmentReadOnly());
    params.put("cfgaId", customField.getCustomFieldGroupAssignmentId());

    sqlCache.update("customFieldGroupAssignment.saveReadOnly", params);

    if(!customField.getCustomFieldGroupAssignmentReadOnly()) {
      // if field is not readonly archive any white listed positions for it
      sqlCache.update("customFieldGroupAssignment.archiveWhiteListPositions", params);
    } else if(null != savePositions && savePositions) {
      // if field IS read_only archive any white listed positions no longer in the body sent in
      List<Long> positionIdsUsed = customField.getWhiteListedPositions().stream().map(WhiteListedPosition::getPositionId).collect(Collectors.toList());
      params.put("positionIdsUsed", positionIdsUsed);
      if(positionIdsUsed.size() > 0) {
        sqlCache.update("customFieldGroupAssignment.archiveWhiteListPositionsNoLongerUsed", params);
      } else {
        //this means they removed ALL white listed positions
        sqlCache.update("customFieldGroupAssignment.archiveAllWhiteListedPositions", params);
      }

      for(WhiteListedPosition wlp : customField.getWhiteListedPositions()) {
        params.put("positionId", wlp.getPositionId());
        //this insert checks if there is already a non-archived row with the same values
        sqlCache.update("customFieldGroupAssignment.insertWhiteListPosition", params);
      }
    }

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

  public List<ScheduleFieldType> getEventTypesAndFields() {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());

    List<ScheduleFieldType> results = sqlCache.query("customFieldGroupAssignment.getEventTypesAndFields", params, new ScheduleFieldTypeMapper<>(ScheduleFieldType.class, om));
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
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("groupName", customFieldGroup.getGroupName());
    params.put("companyObjectTypeId", companyObjectTypeId);
    params.put("eventTypeId", customFieldGroup.getEventTypeId());
    params.put("processStepId", customFieldGroup.getProcessStepId());
    params.put("createdById", user.getId());

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

    if(null != customFieldGroup.getEventTypeId() && null != customFieldGroup.getSchedulingFields()) {
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

  public List<FieldInUse> getFieldsInUse(Long processStepId, Long customFieldGroupId, Long customFieldGroupAssignmentId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("customFieldGroupAssignmentId", customFieldGroupAssignmentId);
    params.put("customFieldGroupId", customFieldGroupId);
    List<FieldInUse> fields = sqlCache.query("customFieldGroup.checkForFieldsInUse", params, FieldInUse.class);
    return fields;
  }

  public List<FieldInUse> deleteWithRequirementChecks(CustomFieldGroupController.DeleteWithRequirementParams requirementParams) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.getId());

    List<FieldInUse> fields = getFieldsInUse(null, requirementParams.getCustomFieldGroupId(), requirementParams.getCustomFieldGroupAssignmentId());
    if(!fields.isEmpty()) {
      return fields;
    } else if(null != requirementParams.getCustomFieldGroupAssignmentId()) {
      //handle custom field group assignment stuff
      params.put("id", requirementParams.getCustomFieldGroupAssignmentId());
      sqlCache.update("customFieldGroupAssignment.deleteFieldFromGroup", params);
      return null;
    } else {
      //if the field or a field in the field group is deleted, check if used in requirement and block if necessary
      //this means they are deleting a custom field group not an assignment
      params.put("id", requirementParams.getCustomFieldGroupId());
      sqlCache.update("customFieldGroup.deleteCustomFieldGroup", params);
      return null;
    }

  }

  public CustomFieldGroup updateCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customFieldGroup.getId());
    params.put("groupOrder", customFieldGroup.getGroupOrder());
    params.put("groupName", customFieldGroup.getGroupName());
    params.put("companyObjectTypeTabId", customFieldGroup.getCompanyObjectTypeTabId());
    params.put("modifiedById", user.getId());

    sqlCache.update("customFieldGroup.updateCustomFieldGroup", params);

    Optional<CustomFieldGroup> group = sqlCache.get("customFieldGroupAssignment.getOne", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    return group.orElse(null);
  }

  public void updateCustomFieldGroups(List<CustomFieldGroup> customFieldGroups) {
    for(CustomFieldGroup cfg : customFieldGroups){
      updateCustomFieldGroup(cfg);
    }
  }

  public List<CustomFieldGroup> getInsertFieldsByType(Long companyId, Long objectTypeId) {
    User user = securityService.getCurrentUser();
    Long realCompanyId = null != companyId ? companyId : user.getCompanyId();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", realCompanyId);
    params.put("objectTypeId", objectTypeId);

    List<CustomFieldGroup> results = sqlCache.query("customFieldGroup.getInsertFieldsByType", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    results.stream().filter(cfg -> !cfg.getCustomFieldValues().isEmpty()).collect(Collectors.toList());

    customFieldValueService.handleCustomListOfValue(results, realCompanyId);

    return results;
  }

  public void updateFieldShowOrRequireOnInsert(CustomFieldObjectType customFieldObjectType) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customFieldObjectType.getId());
    params.put("modifiedById", user.getId());
    params.put("showOnInsert", customFieldObjectType.getShowOnInsert());
    params.put("requireOnInsert", customFieldObjectType.getRequireOnInsert());

    sqlCache.update("customFieldGroup.updateFieldShowOrRequireOnInsert", params);
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
