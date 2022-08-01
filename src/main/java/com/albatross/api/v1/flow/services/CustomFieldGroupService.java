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
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@Slf4j
@Service
@RequiredArgsConstructor
public class CustomFieldGroupService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final CustomFieldService customFieldService;
  private final CustomFieldValueService customFieldValueService;
  private final ProcessStepRequirementService processStepRequirementService;
  private final ObjectMapper om;

  public CustomField addFieldToGroup(CustomFieldWithDefault customField) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("customFieldGroupId", customField.getCustomFieldGroupId());
    params.put("defaultFieldId", customField.getDefaultFieldId());
    params.put("customFieldId", customField.getId());
    params.put("createdById", currentUser.trueUserId());
    params.put(
        "ancillaryCustomFieldGroupAssignmentId",
        customField.getAncillaryCustomFieldGroupAssignmentId());
    params.put("fieldOrder", customField.getFieldOrder());

    Long id =
        sqlCache
            .updateReturningId("customFieldGroupAssignment.addFieldToGroup", params, "id")
            .longValue();

    return null == customField.getDefaultFieldId() ? getDefaultCustomField(id) : getCustomField(id);
  }

  public CustomField moveFieldToOtherGroup(CustomField customField, Long newGroupId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customField.getCustomFieldGroupAssignmentId());
    params.put("newGroupId", newGroupId);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.update("customFieldGroupAssignment.moveFieldToOtherGroup", params);

    return getCustomField(customField.getCustomFieldGroupAssignmentId());
  }

  public CustomFieldWithDefault getDefaultCustomField(Long cfgaId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("cfgaId", cfgaId);
    Optional<CustomFieldWithDefault> result =
      sqlCache.get("customFieldGroupAssignment.getDefaultField", params, CustomFieldWithDefault.class);
    return result.orElse(null);
  }

  public CustomFieldWithDefault getCustomField(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<CustomFieldWithDefault> result =
        sqlCache.get("customFieldGroupAssignment.getCustomField", params, CustomFieldWithDefault.class);
    return result.orElse(null);
  }

  public void deleteAllFieldsInGroup(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.update("customFieldGroupAssignment.deleteAllFieldsInGroup", params);
  }

  public void deleteFieldFromGroup(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.update("customFieldGroupAssignment.deleteFieldFromGroup", params);
  }

  public void saveUseParentData(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("useParentData", customField.getUseParentData());
    params.put("cfgaId", customField.getCustomFieldGroupAssignmentId());

    sqlCache.update("customFieldGroupAssignment.saveUseParentData", params);
  }

  public void saveDetailView(Long cfgaId, Boolean detailView) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("detailView", detailView);
    params.put("cfgaId", cfgaId);

    sqlCache.update("customFieldGroupAssignment.saveDetailView", params);
  }

  public void saveCfgaAndWhiteList(
      CustomField customField,
      Boolean savingReadOnly,
      Boolean savePositions,
      Long whiteListTypeId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());
    params.put("cfgaReadOnly", customField.getCustomFieldGroupAssignmentReadOnly());
    params.put("cfgaHidden", customField.getCustomFieldGroupAssignmentHidden());
    params.put("cfgaId", customField.getCustomFieldGroupAssignmentId());
    params.put("whiteListTypeId", whiteListTypeId);

    // todo: this can totally be made better I just suck at coding and my brain is struggling
    if (savingReadOnly) {
      sqlCache.update("customFieldGroupAssignment.saveReadOnly", params);
    } else {
      sqlCache.update("customFieldGroupAssignment.saveHidden", params);
    }

    if ((savingReadOnly && !customField.getCustomFieldGroupAssignmentReadOnly())
        || (!savingReadOnly && !customField.getCustomFieldGroupAssignmentHidden())) {
      // if field is not readonly archive any white listed positions for it
      sqlCache.update("customFieldGroupAssignment.archiveWhiteListPositions", params);
    } else if (null != savePositions && savePositions) {
      // if field IS read_only archive any white listed positions no longer in the body sent in
      List<WhiteListedPosition> positionsToUse =
          savingReadOnly
              ? customField.getWhiteListedPositions()
              : customField.getHiddenWhiteListedPositions();
      List<Long> positionIdsUsed =
          customField.getWhiteListedPositions().stream()
              .map(WhiteListedPosition::getPositionId)
              .collect(Collectors.toList());
      params.put("positionIdsUsed", positionIdsUsed);
      if (positionIdsUsed.size() > 0) {
        sqlCache.update("customFieldGroupAssignment.archiveWhiteListPositionsNoLongerUsed", params);
      } else {
        // this means they removed ALL white listed positions
        sqlCache.update("customFieldGroupAssignment.archiveAllWhiteListedPositions", params);
      }

      for (WhiteListedPosition wlp : positionsToUse) {
        params.put("positionId", wlp.getPositionId());
        // this insert checks if there is already a non-archived row with the same values
        sqlCache.update("customFieldGroupAssignment.insertWhiteListPosition", params);
      }
    }
  }

  public void updateFieldInGroup(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customField.getCustomFieldGroupAssignmentId());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("fieldOrder", customField.getFieldOrder());

    sqlCache.update("customFieldGroupAssignment.updateFieldInGroup", params);
  }

  public void updateFieldsInGroup(List<CustomField> customFields) {
    for (CustomField cf : customFields) {
      updateFieldInGroup(cf);
    }
  }

  public List<CustomFieldGroup> getCustomFieldGroupsByObjectTypeId(Long companyObjectTypeId) {
    Map<String, Object> params = new HashMap<>();
    params.put("companyObjectTypeId", companyObjectTypeId);

    return sqlCache.query(
        "customFieldGroupAssignment.getByObjectTypeId",
        params,
        new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));
  }

  public List<CustomField> getCustomFieldsInGroup(Long groupId) {
    Map<String, Object> params = new HashMap<>();
    params.put("groupId", groupId);

    return sqlCache.query(
        "customFieldGroupAssignment.getCustomFieldsInGroup", params, CustomField.class);
  }

  public List<CustomField> getEventResourceFields() {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());

    return sqlCache.query(
      "customFieldGroupAssignment.getEventResourceFields", params, CustomField.class);
  }

  public List<CustomFieldGroup> getNonEventCustomFieldGroupsByProcessStep(Long processStepId) {
    Map<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);

    return sqlCache.query(
        "customFieldGroupAssignment.getNonEventCustomFieldGroupsByProcessStep",
        params,
        CustomFieldGroup.class);
  }

  public List<CustomField> getAvailableCustomFieldsInGroup(Long companyObjectTypeId, Long groupId, Long processStepId, Long eventId) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("companyObjectTypeId", companyObjectTypeId);
    params.put("groupId", groupId);

    List<CustomField> results;

    if (null != processStepId) {
      // as of right now, judson says a field can be native to multiple process steps, but not
      // within the same process step, i think this query does that now
      params.put("processStepId", processStepId);
      results =
          sqlCache.query(
              "customFieldGroupAssignment.getAvailableNativeFieldsForProcessStep",
              params,
              CustomField.class);
    } else if (null != eventId) {
      params.put("eventId", eventId);
      results =
          sqlCache.query(
              "customFieldGroupAssignment.getAvailableNativeFieldsForEvent",
              params,
              CustomField.class);
    } else {
      results =
          sqlCache.query(
              "customFieldGroupAssignment.getAvailableCustomFieldsInGroup",
              params,
              CustomField.class);
    }
    return results;
  }

  public CustomFieldGroup addCustomFieldGroup(
      CustomFieldGroup customFieldGroup, Long companyObjectTypeId) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("groupName", customFieldGroup.getGroupName());
    params.put("companyObjectTypeId", companyObjectTypeId);
    params.put("eventId", customFieldGroup.getEventId());
    params.put("attachmentTypeId", customFieldGroup.getAttachmentTypeId());
    params.put("processStepAttachmentTypeId", customFieldGroup.getProcessStepAttachmentTypeId());
    params.put("userAttachmentTypeId", customFieldGroup.getUserAttachmentTypeId());
    params.put("projectAttachmentTypeId", customFieldGroup.getProjectAttachmentTypeId());
    params.put("contactAttachmentTypeId", customFieldGroup.getContactAttachmentTypeId());
    params.put("orgAttachmentTypeId", customFieldGroup.getOrgAttachmentTypeId());
    params.put("eventAttachmentTypeId", customFieldGroup.getEventAttachmentTypeId());
    params.put("processStepId", customFieldGroup.getProcessStepId());
    params.put("createdById", user.trueUserId());

    Long id =
        sqlCache
            .updateReturningId("customFieldGroup.insertCustomFieldGroup", params, "id")
            .longValue();
    params.put("id", id);

    Optional<CustomFieldGroup> group =
        sqlCache.get(
            "customFieldGroupAssignment.getOne",
            params,
            new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    return group.orElse(null);
  }

  public CustomFieldGroup addProcessStepCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.PROCESS_STEP.id);
    params.put("companyId", currentUser.getCompanyId());
    Long companyObjectTypeId =
        sqlCache.queryForObject("customFieldGroup.getCompanyObjectTypeId", params, Long.class);

    CustomFieldGroup cfg = addCustomFieldGroup(customFieldGroup, companyObjectTypeId);

    return cfg;
  }

  public CustomFieldGroup addEventCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.EVENT.id);
    params.put("companyId", currentUser.getCompanyId());
    Long companyObjectTypeId =
        sqlCache.queryForObject("customFieldGroup.getCompanyObjectTypeId", params, Long.class);

    CustomFieldGroup cfg = addCustomFieldGroup(customFieldGroup, companyObjectTypeId);

    return cfg;
  }

  public CustomFieldGroup addAttachmentCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.ATTACHMENT_TYPE.id);
    params.put("companyId", currentUser.getCompanyId());
    Long companyObjectTypeId = sqlCache.queryForObject("customFieldGroup.getCompanyObjectTypeId", params, Long.class);

    return addCustomFieldGroup(customFieldGroup, companyObjectTypeId);
  }

  public CustomFieldGroup addProcessStepAttachmentCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.ATTACHMENT_TYPE.id);
    params.put("companyId", currentUser.getCompanyId());
    Long companyObjectTypeId =
      sqlCache.queryForObject("customFieldGroup.getCompanyObjectTypeId", params, Long.class);

    //even though this is for a process step attachment type, the company_object_type_id is still set to the attachment object type id
    return addCustomFieldGroup(customFieldGroup, companyObjectTypeId);
  }

  public List<FieldInUse> getFieldsInUse(
      Long processStepId, Long customFieldGroupId, Long customFieldGroupAssignmentId) {
    Map<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("customFieldGroupAssignmentId", customFieldGroupAssignmentId);
    params.put("customFieldGroupId", customFieldGroupId);
    return sqlCache.query("customFieldGroup.checkForFieldsInUse", params, FieldInUse.class);
  }

  public List<FieldInUse> deleteWithRequirementChecks(
      CustomFieldGroupController.DeleteWithRequirementParams requirementParams) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());

    List<FieldInUse> fields =
        getFieldsInUse(
            null,
            requirementParams.getCustomFieldGroupId(),
            requirementParams.getCustomFieldGroupAssignmentId());
    if (!fields.isEmpty()) {
      return fields;
    } else if (null != requirementParams.getCustomFieldGroupAssignmentId()) {
      // handle custom field group assignment stuff
      params.put("id", requirementParams.getCustomFieldGroupAssignmentId());
      sqlCache.update("customFieldGroupAssignment.deleteFieldFromGroup", params);
      return null;
    } else {
      // if the field or a field in the field group is deleted, check if used in requirement and
      // block if necessary
      // this means they are deleting a custom field group not an assignment
      params.put("id", requirementParams.getCustomFieldGroupId());
      sqlCache.update("customFieldGroup.deleteCustomFieldGroup", params);
      return null;
    }
  }

  public CustomFieldGroup updateCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", customFieldGroup.getId());
    params.put("groupOrder", customFieldGroup.getGroupOrder());
    params.put("groupName", customFieldGroup.getGroupName());
    params.put("companyObjectTypeTabId", customFieldGroup.getCompanyObjectTypeTabId());
    params.put("modifiedById", user.trueUserId());

    sqlCache.update("customFieldGroup.updateCustomFieldGroup", params);

    return sqlCache
        .get(
            "customFieldGroupAssignment.getOne",
            params,
            new CustomFieldGroupMapper<>(CustomFieldGroup.class, om))
        .orElse(null);
  }

  public void updateCustomFieldGroups(List<CustomFieldGroup> customFieldGroups) {
    for (CustomFieldGroup cfg : customFieldGroups) {
      updateCustomFieldGroup(cfg);
    }
  }

  public List<CustomFieldGroup> getInsertFieldsByType(Long companyId, Long objectTypeId) {
    User user = securityService.getCurrentUser();
    Long realCompanyId = null != companyId ? companyId : user.getCompanyId();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", realCompanyId);
    params.put("objectTypeId", objectTypeId);


    List<CustomFieldGroup> results =
        sqlCache.query(
            "customFieldGroup.getInsertFieldsByType",
            params,
            new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    results.stream().filter(cfg -> !cfg.getCustomFieldValues().isEmpty()).toList();

    customFieldValueService.handleCustomListOfValue(results, realCompanyId);

    return results;
  }

  public void updateFieldShowOrRequire(CustomField customField) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("customFieldGroupAssignmentId", customField.getCustomFieldGroupAssignmentId());
    params.put("modifiedById", user.trueUserId());
    params.put(
        "showOnInsert",
        null != customField.getShowOnInsert() ? customField.getShowOnInsert() : false);
    params.put(
        "showOnUserProfile",
        null != customField.getShowOnUserProfile() ? customField.getShowOnUserProfile() : false);
    params.put(
        "required",
        null != customField.getRequired() ? customField.getRequired() : false);

    sqlCache.update("customFieldGroup.updateFieldShowOrRequire", params);
  }

  public static class CustomFieldGroupMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CustomFieldGroupMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomField>> customFieldTypeRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "customFields",
          new JsonCollectionDeserializer(customFieldTypeRef, objectMapper));

      TypeReference<List<CustomFieldValue>> customFieldValueRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "customFieldValues",
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
      bw.registerCustomEditor(
          List.class,
          "availableCustomFields",
          new JsonCollectionDeserializer(availableCustomFieldTypeRef, objectMapper));
    }
  }
}
