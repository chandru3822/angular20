package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.convert.JsonObjectDeserializer;
import com.albatross.api.exception.ApiException;
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

import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomFieldGroupService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final CustomFieldValueService customFieldValueService;
  private final SqlArrayService sqlArrayService;
  private final ObjectMapper om;

  public CustomField addFieldToGroup(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
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

    Map<String, Object> params = new HashMap<>();
    params.put("id", customField.getCustomFieldGroupAssignmentId());
    params.put("newGroupId", newGroupId);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.moveFieldToOtherGroup, params);

    return getCustomField(customField.getCustomFieldGroupAssignmentId());
  }

  public CustomField getDataViewCustomField(Long cfgaId) {
    Map<String, Object> params = new HashMap<>();
    params.put("cfgaId", cfgaId);
    Optional<CustomField> result = sqlCache.getBySql(CustomFieldGroupAssignmentQuery.getDataViewField, params, CustomField.class);
    return result.orElse(null);
  }

  public CustomField getDataViewChildCustomField(Long cfgaId) {
    Map<String, Object> params = new HashMap<>();
    params.put("cfgaId", cfgaId);
    Optional<CustomField> result = sqlCache.getBySql(CustomFieldGroupAssignmentQuery.getDataViewChildField, params, CustomField.class);
    return result.orElse(null);
  }

  public CustomField getDefaultCustomField(Long cfgaId) {
    Map<String, Object> params = new HashMap<>();
    params.put("cfgaId", cfgaId);
    Optional<CustomField> result = sqlCache.getBySql(CustomFieldGroupAssignmentQuery.getDefaultField, params, CustomField.class);
    return result.orElse(null);
  }

  public CustomField getCustomField(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<CustomField> result =
      sqlCache.getBySql(CustomFieldGroupAssignmentQuery.getCustomField, params, CustomField.class);
    return result.orElse(null);
  }

  public void deleteAllFieldsInGroup(Long id) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.deleteAllFieldsInGroup, params);
  }

  public void deleteFieldFromGroup(Long id) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.deleteFieldFromGroup, params);
  }

  public void deleteGroup(Long id) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(CustomFieldGroupQuery.delete, params);
  }

  public void saveUseParentData(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("useParentData", customField.getUseParentData());
    params.put("cfgaId", customField.getCustomFieldGroupAssignmentId());

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.saveUseParentData, params);
  }

  public void saveDetailView(Long cfgaId, Boolean detailView) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("detailView", detailView);
    params.put("cfgaId", cfgaId);

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.saveDetailView, params);
  }

  public void saveDisplayOnSnippet(Long cfgaId) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("cfgaId", cfgaId);

    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.clearDisplayOnSnippet, params);
    sqlCache.updateBySql(CustomFieldGroupAssignmentQuery.saveDisplayOnSnippet, params);
  }

  public void saveCfgaAndWhiteList(
    CustomField customField,
    Boolean savingReadOnly,
    Boolean savePositions,
    Long whiteListTypeId) {
    User currentUser = securityService.getCurrentUser();

    if (customField.getCustomFieldGroupAssignmentId() == null) {
      String msg = "Custom Field Group Assignment ID is null, it is required for Custom Field White Listing";
      log.error(msg);
      throw new RuntimeException(msg);
    }

    Map<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());
    params.put("cfgaReadOnly", customField.getCustomFieldGroupAssignmentReadOnly());
    params.put("cfgaReadOnlyAllow", null != customField.getCustomFieldGroupAssignmentReadOnlyAllow() ? customField.getCustomFieldGroupAssignmentReadOnlyAllow() : true);
    params.put("cfgaHidden", customField.getCustomFieldGroupAssignmentHidden());
    //this is pissing me off. setting to true if a value is not passed in since that should be the default
    params.put("cfgaHiddenAllow", null != customField.getCustomFieldGroupAssignmentHiddenAllow() ? customField.getCustomFieldGroupAssignmentHiddenAllow() : true);
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
          ? (customField.getWhiteListedPositions() == null ? new ArrayList<>() : customField.getWhiteListedPositions())
          : (customField.getHiddenWhiteListedPositions() == null ? new ArrayList<>() : customField.getHiddenWhiteListedPositions());
      List<Long> positionIdsUsed =
        positionsToUse.stream()
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

    Map<String, Object> params = new HashMap<>();
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

  public List<CustomField> getEventResourceFields(Long eventId) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("eventId", eventId);

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

    String sqlQuery = CustomFieldGroupQuery.insertCustomFieldGroup;
    Map<String, Object> params = new HashMap<>();

    try {
      if (customFieldGroup.getObjectCategoryIds() == null || customFieldGroup.getObjectCategoryIds().isEmpty()) {
        if(customFieldGroup.getCompanyObjectTypeId() != null) {
          validateCategoryIdRequirements(customFieldGroup.getCompanyObjectTypeId(), null);
        }
      } else {
        params.put("objectCategoryIds", sqlArrayService.createSqlArrayOfType("int", customFieldGroup.getObjectCategoryIds()));
        sqlQuery = CustomFieldGroupQuery.insertCustomFieldGroupWithCategories;
      }


      User user = securityService.getCurrentUser();

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
          .queryForObjectBySql(sqlQuery, params, Long.class);

      Optional<CustomFieldGroup> group =
        sqlCache.getBySql(
          CustomFieldGroupAssignmentQuery.getOne,
          Map.of("id", id),
          new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

      return group.orElse(null);
    } catch (SQLException ex) {
      throw new ApiException(ex);
    }
  }

  public CustomFieldGroup addProcessStepCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.PROCESS_STEP.id);
    params.put("companyId", currentUser.getCompanyId());
    Long companyObjectTypeId =
      sqlCache.queryForObjectBySql(CustomFieldGroupQuery.getCompanyObjectTypeId, params, Long.class);

    return addCustomFieldGroup(customFieldGroup, companyObjectTypeId);
  }

  public CustomFieldGroup addEventCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.EVENT.id);
    params.put("companyId", currentUser.getCompanyId());
    Long companyObjectTypeId =
      sqlCache.queryForObjectBySql(CustomFieldGroupQuery.getCompanyObjectTypeId, params, Long.class);

    return addCustomFieldGroup(customFieldGroup, companyObjectTypeId);
  }

  public CustomFieldGroup addAttachmentCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.ATTACHMENT_TYPE.id);
    params.put("companyId", currentUser.getCompanyId());
    Long companyObjectTypeId = sqlCache.queryForObjectBySql(CustomFieldGroupQuery.getCompanyObjectTypeId, params, Long.class);

    return addCustomFieldGroup(customFieldGroup, companyObjectTypeId);
  }

  public CustomFieldGroup addProcessStepAttachmentCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
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

  public void validateCategoryIdRequirements(Long companyObjectTypeId, Long cfgId) {

    Long objectTypeId;
    Map<String, Object> params = new HashMap<>();
    params.put("companyObjectTypeId", companyObjectTypeId);
    params.put("cfgId", cfgId);

    if(companyObjectTypeId != null) {
      objectTypeId = sqlCache.queryForObjectBySql(CustomFieldGroupQuery.getObjectTypeByCompanyObjectId, params, Long.class);
    } else if (cfgId != null) {
      objectTypeId = sqlCache.queryForObjectBySql(CustomFieldGroupQuery.getObjectTypeIdForCfg, params, Long.class);
    } else {
      objectTypeId = null;
    }

    long[] array = {ObjectType.PROJECT.id, ObjectType.CONTACT.id};
    if (objectTypeId != null && Arrays.stream(array).anyMatch(x -> x == objectTypeId)) {
      throw new ApiException("At least one object category is required");
    }

  }
  public CustomFieldGroup updateCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User user = securityService.getCurrentUser();

    try {

    Map<String, Object> params = new HashMap<>();
    params.put("id", customFieldGroup.getId());
    params.put("groupOrder", customFieldGroup.getGroupOrder());
    params.put("groupName", customFieldGroup.getGroupName());
    params.put("companyObjectTypeTabId", customFieldGroup.getCompanyObjectTypeTabId());
    params.put("modifiedById", user.trueUserId());
    params.put("companyProcessStepStatusTypeIds", (customFieldGroup.getCompanyProcessStepStatusTypeIds() == null || customFieldGroup.getCompanyProcessStepStatusTypeIds().isEmpty()) ?
      List.of() :
      customFieldGroup.getCompanyProcessStepStatusTypeIds()
    );

    params.put("companyEventStatusTypeIds", (customFieldGroup.getCompanyEventStatusTypeIds() == null || customFieldGroup.getCompanyEventStatusTypeIds().isEmpty()) ?
      List.of() :
      customFieldGroup.getCompanyEventStatusTypeIds()
    );

    params.put("processStepStatusTypeIds", (customFieldGroup.getProcessStepStatusTypeIds() == null || customFieldGroup.getProcessStepStatusTypeIds().isEmpty()) ?
      List.of() :
      customFieldGroup.getProcessStepStatusTypeIds()
    );

    params.put("eventStatusTypeIds", (customFieldGroup.getEventStatusTypeIds() == null || customFieldGroup.getEventStatusTypeIds().isEmpty()) ?
      List.of() :
      customFieldGroup.getEventStatusTypeIds()
    );
    params.put("psCollapseByDefault", customFieldGroup.getPsCollapseByDefault());
    params.put("eventCollapseByDefault", customFieldGroup.getEventCollapseByDefault());
    params.put("objectCategoryIds", sqlArrayService.createSqlArrayOfType("int", customFieldGroup.getObjectCategoryIds()));

    String sqlQuery = CustomFieldGroupQuery.updateCustomFieldGroup;

    if (customFieldGroup.getObjectCategoryIds() == null || customFieldGroup.getObjectCategoryIds().isEmpty()) {
      validateCategoryIdRequirements(null, customFieldGroup.getId());
    } else {
      params.put("objectCategoryIds", sqlArrayService.createSqlArrayOfType("int", customFieldGroup.getObjectCategoryIds()));
      sqlQuery = CustomFieldGroupQuery.updateCustomFieldGroupWithCategories;
    }

    sqlCache.updateBySql(sqlQuery, params);

    return sqlCache
      .getBySql(
        CustomFieldGroupAssignmentQuery.getOne,
        params,
        new CustomFieldGroupMapper<>(CustomFieldGroup.class, om))
      .orElse(null);
    } catch (SQLException ex) {
      throw new ApiException(ex);
    }
  }

  public void updateCustomFieldGroups(List<CustomFieldGroup> customFieldGroups) {
    for (CustomFieldGroup cfg : customFieldGroups) {
      updateCustomFieldGroup(cfg);
    }
  }

  public List<CustomFieldGroup> getInsertFieldsByType(Long companyId, Long objectTypeId) {
    return getInsertFieldsByType(companyId, objectTypeId, null);
  }

  public List<CustomFieldGroup> getInsertFieldsByType(Long companyId, Long objectTypeId, Long objectCategoryId) {
    User user = securityService.getCurrentUser();
    Long realCompanyId = null != companyId ? companyId : user.getCompanyId();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", realCompanyId);
    params.put("objectTypeId", objectTypeId);
    params.put("objectCategoryId", objectCategoryId);

  //i modified this to only return insert fields if that cfg is assigned to the object category id
    List<CustomFieldGroup> results =
      sqlCache.queryBySql(
        CustomFieldGroupQuery.getInsertFieldsByType,
        params,
        new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    results.stream().filter(cfg -> !cfg.getCustomFieldValues().isEmpty()).toList();

    customFieldValueService.handleCustomListOfValue(results, realCompanyId);

    return results;
  }

  public List<CustomFieldValue> getCustomFieldsByCfgaIds(List<Long> cfgaIds) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("cfgaIds", cfgaIds);

    List<CustomFieldValue> results =
      sqlCache.queryBySql(
        CustomFieldGroupQuery.getCustomFieldsByCfgaIds,
        params,
        new CustomFieldValueService.CustomFieldValueMapper<>(CustomFieldValue.class, om));

    for (CustomFieldValue field : results) {
      customFieldValueService.handleCustomListValueForCfv(field, null, null, null, null);
    }

    return results;
  }

  public void updateFieldShowOrRequire(CustomField customField) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
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
      TypeReference<List<CustomField>> customFieldTypeRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "customFields",
        new JsonCollectionDeserializer(customFieldTypeRef, objectMapper));

      TypeReference<List<CustomFieldValue>> customFieldValueRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "customFieldValues",
        new JsonCollectionDeserializer(customFieldValueRef, objectMapper));

      TypeReference<List<Long>> companyProcessStepStatusTypeIdsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "companyProcessStepStatusTypeIds",
        new JsonCollectionDeserializer(companyProcessStepStatusTypeIdsRef, objectMapper)
      );

      TypeReference<List<Long>> companyEventStatusTypeIdsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "companyEventStatusTypeIds",
        new JsonCollectionDeserializer(companyEventStatusTypeIdsRef, objectMapper)
      );

      TypeReference<List<Long>> processStepStatusTypeIdsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "processStepStatusTypeIds",
        new JsonCollectionDeserializer(processStepStatusTypeIdsRef, objectMapper)
      );

      TypeReference<List<Long>> eventStatusTypeIdsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "eventStatusTypeIds",
        new JsonCollectionDeserializer(eventStatusTypeIdsRef, objectMapper)
      );

      TypeReference<List<Long>> objectCategoryIdsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "objectCategoryIds",
        new JsonObjectDeserializer<>(objectCategoryIdsRef, objectMapper)
      );
    }
  }
}
