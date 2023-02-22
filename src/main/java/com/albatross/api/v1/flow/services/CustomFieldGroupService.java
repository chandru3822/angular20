package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.CustomFieldGroupController;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.queries.CustomFieldGroupAssignmentQuery;
import com.albatross.api.v1.flow.queries.CustomFieldGroupQuery;
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
  private final CustomFieldValueService customFieldValueService;
  private final ObjectMapper om;

  public CustomField addFieldToGroup(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("customFieldGroupId", customField.getCustomFieldGroupId());
    params.put("defaultFieldId", customField.getDefaultFieldId());
    params.put("customFieldId", customField.getId());
    params.put("createdById", currentUser.trueUserId());
    params.put(
        "ancillaryCustomFieldGroupAssignmentId",
        customField.getAncillaryCustomFieldGroupAssignmentId());
    params.put(
        "dataViewFieldConfigId",
        customField.getDataViewFieldConfigId());
    params.put(
      "dataViewChildFieldConfigId",
      customField.getDataViewChildFieldConfigId());
    params.put("fieldOrder", customField.getFieldOrder());

    Long id =
        sqlCache
            .updateBySqlReturningId(CustomFieldGroupAssignmentQuery.addFieldToGroup, params, "id")
            .longValue();

    return null != customField.getDefaultFieldId() ? getDefaultCustomField(id) :
             null != customField.getDataViewChildFieldConfigId() ? getDataViewChildCustomField(id) :
             null != customField.getDataViewFieldConfigId() ? getDataViewCustomField(id) : getCustomField(id);
  }

  public CustomField moveFieldToOtherGroup(CustomField customField, Long newGroupId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customField.getCustomFieldGroupAssignmentId());
    params.put("newGroupId", newGroupId);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.moveFieldToOtherGroup, params);

    return getCustomField(customField.getCustomFieldGroupAssignmentId());
  }

  public CustomField getDataViewCustomField(Long cfgaId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("cfgaId", cfgaId);
    Optional<CustomField> result = sqlCache.getBySql(CustomFieldGroupAssignmentQuery.getDataViewField, params, CustomField.class);
    return result.orElse(null);
  }

  public CustomField getDataViewChildCustomField(Long cfgaId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("cfgaId", cfgaId);
    Optional<CustomField> result = sqlCache.getBySql(CustomFieldGroupAssignmentQuery.getDataViewChildField, params, CustomField.class);
    return result.orElse(null);
  }

  public CustomField getDefaultCustomField(Long cfgaId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("cfgaId", cfgaId);
    Optional<CustomField> result = sqlCache.getBySql(CustomFieldGroupAssignmentQuery.getDefaultField, params, CustomField.class);
    return result.orElse(null);
  }

  public CustomField getCustomField(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<CustomField> result =
        sqlCache.getBySql(CustomFieldGroupAssignmentQuery.getCustomField, params, CustomField.class);
    return result.orElse(null);
  }

  public void deleteAllFieldsInGroup(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.deleteAllFieldsInGroup, params);
  }

  public void deleteFieldFromGroup(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.deleteFieldFromGroup, params);
  }

  public void deleteGroup(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(CustomFieldGroupQuery.delete, params);
  }

  public void saveUseParentData(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("useParentData", customField.getUseParentData());
    params.put("cfgaId", customField.getCustomFieldGroupAssignmentId());

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.saveUseParentData, params);
  }

  public void saveDetailView(Long cfgaId, Boolean detailView) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("detailView", detailView);
    params.put("cfgaId", cfgaId);

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.saveDetailView, params);
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
      sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.saveReadOnly, params);
    } else {
      sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.saveHidden, params);
    }

    if ((savingReadOnly && !customField.getCustomFieldGroupAssignmentReadOnly())
        || (!savingReadOnly && !customField.getCustomFieldGroupAssignmentHidden())) {
      // if field is not readonly archive any white listed positions for it
      sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.archiveWhiteListPositions, params);
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
        sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.archiveWhiteListPositionsNoLongerUsed, params);
      } else {
        // this means they removed ALL white listed positions
        sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.archiveAllWhiteListedPositions, params);
      }

      for (WhiteListedPosition wlp : positionsToUse) {
        params.put("positionId", wlp.getPositionId());
        // this insert checks if there is already a non-archived row with the same values
        sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.insertWhiteListPosition, params);
      }
    }
  }

  public void updateFieldInGroup(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customField.getCustomFieldGroupAssignmentId());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("fieldOrder", customField.getFieldOrder());

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.updateFieldInGroup, params);
  }

  public void updateFieldsInGroup(List<CustomField> customFields) {
    for (CustomField cf : customFields) {
      updateFieldInGroup(cf);
    }
  }

  public List<CustomFieldGroup> getCustomFieldGroupsByObjectTypeId(Long companyObjectTypeId) {
    Map<String, Object> params = new HashMap<>();
    params.put("companyObjectTypeId", companyObjectTypeId);

    return sqlCache.queryBySql(
      CustomFieldGroupAssignmentQuery.getByObjectTypeId,
        params,
        new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));
  }

  public List<CustomField> getCustomFieldsInGroup(Long groupId) {
    Map<String, Object> params = new HashMap<>();
    params.put("groupId", groupId);

    return sqlCache.queryBySql(
      CustomFieldGroupAssignmentQuery.getCustomFieldsInGroup, params, CustomField.class);
  }

  public List<CustomField> getEventResourceFields() {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());

    return sqlCache.queryBySql(
      CustomFieldGroupAssignmentQuery.getEventResourceFields, params, CustomField.class);
  }

  public List<CustomFieldGroup> getNonEventCustomFieldGroupsByProcessStep(Long processStepId) {
    Map<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);

    return sqlCache.queryBySql(
      CustomFieldGroupAssignmentQuery.getNonEventCustomFieldGroupsByProcessStep,
        params,
        CustomFieldGroup.class);
  }

  public List<CustomField> getAvailableCustomFieldsInGroup(Long companyObjectTypeId, Long groupId, Long processStepId, Long eventId, Long attachmentTypeId) {
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
          sqlCache.queryBySql(
            CustomFieldGroupAssignmentQuery.getAvailableNativeFieldsForProcessStep,
              params,
              CustomField.class);
    } else if (null != eventId) {
      params.put("eventId", eventId);
      results =
          sqlCache.queryBySql(
            CustomFieldGroupAssignmentQuery.getAvailableNativeFieldsForEvent,
              params,
              CustomField.class);
    } else if (null != attachmentTypeId) {
      params.put("attachmentTypeId", attachmentTypeId);
      results =
        sqlCache.queryBySql(
          CustomFieldGroupAssignmentQuery.getAvailableNativeFieldsForAttachmentType,
          params,
          CustomField.class);
    } else {
      results =
          sqlCache.queryBySql(
            CustomFieldGroupAssignmentQuery.getAvailableCustomFieldsInGroup,
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
            .updateBySqlReturningId(CustomFieldGroupQuery.insertCustomFieldGroup, params, "id")
            .longValue();
    params.put("id", id);

    Optional<CustomFieldGroup> group =
        sqlCache.getBySql(
          CustomFieldGroupAssignmentQuery.getOne,
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
        sqlCache.queryForObjectBySql(CustomFieldGroupQuery.getCompanyObjectTypeId, params, Long.class);

    CustomFieldGroup cfg = addCustomFieldGroup(customFieldGroup, companyObjectTypeId);

    return cfg;
  }

  public CustomFieldGroup addEventCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.EVENT.id);
    params.put("companyId", currentUser.getCompanyId());
    Long companyObjectTypeId =
        sqlCache.queryForObjectBySql(CustomFieldGroupQuery.getCompanyObjectTypeId, params, Long.class);

    CustomFieldGroup cfg = addCustomFieldGroup(customFieldGroup, companyObjectTypeId);

    return cfg;
  }

  public CustomFieldGroup addAttachmentCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.ATTACHMENT_TYPE.id);
    params.put("companyId", currentUser.getCompanyId());
    Long companyObjectTypeId = sqlCache.queryForObjectBySql(CustomFieldGroupQuery.getCompanyObjectTypeId, params, Long.class);

    return addCustomFieldGroup(customFieldGroup, companyObjectTypeId);
  }

  public CustomFieldGroup addProcessStepAttachmentCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.ATTACHMENT_TYPE.id);
    params.put("companyId", currentUser.getCompanyId());
    Long companyObjectTypeId =
      sqlCache.queryForObjectBySql(CustomFieldGroupQuery.getCompanyObjectTypeId, params, Long.class);

    //even though this is for a process step attachment type, the company_object_type_id is still set to the attachment object type id
    return addCustomFieldGroup(customFieldGroup, companyObjectTypeId);
  }

  public List<FieldInUse> getFieldsInUse(
      Long processStepId, Long customFieldGroupId, Long customFieldGroupAssignmentId) {
    Map<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("customFieldGroupAssignmentId", customFieldGroupAssignmentId);
    params.put("customFieldGroupId", customFieldGroupId);
    return sqlCache.queryBySql(CustomFieldGroupQuery.checkForFieldsInUse, params, FieldInUse.class);
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
      sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.deleteFieldFromGroup, params);
      return null;
    } else {
      // if the field or a field in the field group is deleted, check if used in requirement and
      // block if necessary
      // this means they are deleting a custom field group not an assignment
      params.put("id", requirementParams.getCustomFieldGroupId());
      sqlCache.updateBySql(CustomFieldGroupQuery.deleteCustomFieldGroup, params);
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

    sqlCache.updateBySql(CustomFieldGroupQuery.updateCustomFieldGroup, params);

    return sqlCache
        .getBySql(
          CustomFieldGroupAssignmentQuery.getOne,
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
        sqlCache.queryBySql(
          CustomFieldGroupQuery.getInsertFieldsByType,
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

    sqlCache.updateBySql(CustomFieldGroupQuery.updateFieldShowOrRequire, params);
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
