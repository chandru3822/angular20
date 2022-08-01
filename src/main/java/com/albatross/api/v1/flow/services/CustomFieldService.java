package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomFieldService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final SystemListService systemListService;
  private final ObjectMapper om;
  private final SqlArrayService sqlArrayService;

  public CustomField findCustomFieldById(Long id) {
    Optional<CustomField> result =
        sqlCache.get(
            "customField.getOne",
            Map.of("id", id),
            new CustomField.CustomFieldMapper<>(CustomField.class, om));
    return result.orElse(null);
  }

  public List<CustomField> getAllCustomFields(CustomFiledFilterCriteria criteria) {
    User user = securityService.getCurrentUser();
    final Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("hasListValues", criteria.hasListValues());
    params.put("query", criteria.query());

    return sqlCache.query(
        "customField.getAll", params, new CustomField.CustomFieldMapper<>(CustomField.class, om));
  }

  /*
   * I think this handles saving all scenarios of custom fields
   *   Existing custom field changes
   *     With:
   *        new list of value options
   *        updating existing value options
   *        archiving existing value options
   *        new sqk key
   *        updating sql key value
   *   New custom fields
   *     With or without value options (which would always be new/inserts)
   */
  public CustomField saveField(CustomField customField) throws SQLException {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("fieldName", customField.getFieldName());
    params.put(
        "sortListValuesAlphabetically",
        null != customField.getSortListValuesAlphabetically()
            && customField.getSortListValuesAlphabetically());
    params.put("readonly", customField.getReadonly() != null && customField.getReadonly());
    params.put("systemReadonly", customField.getSystemReadonly() != null && customField.getSystemReadonly());
    params.put("allowNow", customField.getAllowNow() != null && customField.getAllowNow());
    params.put("systemListId", customField.getCompanySystemListId());
    params.put(
        "systemListOptionIds",
        null == customField.getSystemListOptionIds()
                || customField.getSystemListOptionIds().isEmpty()
            ? null
            : sqlArrayService.createSqlArrayOfType("int", customField.getSystemListOptionIds()));
    Long id = null;
    boolean doInsertAfterHandlingOtherScenarios = false;
    boolean insertParentRecordIfNeeded = false;

    if (null != customField.getId()) {
      // edit existing custom field
      id = customField.getId();
      params.put("id", id);
      params.put("modifiedById", user.trueUserId());
      sqlCache.update("customField.saveField", params);
    } else {
      // have to insert the list of values first if needed to get the listOfValueId
      doInsertAfterHandlingOtherScenarios = true;
      // only insert the parent list value record if this is a new custom field
      insertParentRecordIfNeeded = true;
    }

    Long parentId = null;
    Long lovCreatedById;

    if (customField.getListOfValues() != null && !customField.getListOfValues().isEmpty()) {
      if (insertParentRecordIfNeeded) {
        // use created by unless field already existed then use modified id as the created for the
        // list value row (WUT? WHY? this should always be the logged in user)
        lovCreatedById = user.trueUserId();

        // insert the parent row if this is a new field
        HashMap<String, Object> lovParent = new HashMap<>();
        lovParent.put("name", customField.getFieldName());
        lovParent.put("parentId", null);
        lovParent.put("createdById", user.trueUserId());
        parentId =
            sqlCache
                .updateReturningId("customField.insertListOfValue", lovParent, "id")
                .longValue();
      } else {
        parentId = customField.getListOfValueId();
        lovCreatedById = user.trueUserId();
      }

      // insert the rest of the list values
      for (ListOfValue lov : customField.getListOfValues()) {
        HashMap<String, Object> lovParams = new HashMap<>();
        lovParams.put("name", lov.getName());
        lovParams.put("parentId", parentId);
        lovParams.put("createdById", lovCreatedById);
        lovParams.put("modifiedById", user.trueUserId());
        lovParams.put("displayOrder", lov.getDisplayOrder());

        if (null != lov.getId() && !lov.getArchived()) {
          // do update of row
          lovParams.put("id", lov.getId());
          sqlCache.update("customField.updateListOfValue", lovParams);
        } else if (lov.getArchived()) {
          // do archive of row
          lovParams.put("id", lov.getId());
          sqlCache.update("customField.archiveListOfValue", lovParams);
        } else {
          // do row insert
          sqlCache.update("customField.insertListOfValue", lovParams);
        }
      }
    }

    if (doInsertAfterHandlingOtherScenarios) {
      params.put("listOfValueId", parentId);
      params.put("customFieldSqlKey", customField.getCustomFieldSqlKey());
      params.put("customFieldSqlReferenceTable", customField.getCustomFieldSqlReferenceTable());
      params.put("companyId", customField.getCompanyId());
      params.put("systemListId", customField.getCompanySystemListId());
      params.put("createdById", user.trueUserId());
      params.put("companyDataTypeId", customField.getCompanyDataTypeId());

      // insert new custom field with listOfValueId if needed
      id = sqlCache.updateReturningId("customField.insertField", params, "id").longValue();
    }

    return findCustomFieldById(id);
  }

  public List<CustomField> deleteField(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("fieldId", id);
    params.put("modifiedById", currentUser.trueUserId());

    // check if field is in use by a custom field group
    List<CustomField> fields =
        sqlCache.query("customField.getGroupsUsingField", params, CustomField.class);

    // if the field is assigned somewhere, return those values to frontend
    if (!fields.isEmpty()) {
      return fields;
    } else {
      // archive single custom field
      sqlCache.update("customField.deleteField", params);
      return null;
    }
  }

  public List<CustomField> getByProcessStepEvent(Long id) {
    User user = securityService.getCurrentUser();
    return sqlCache
        .query(
            "customField.getByProcessStepEvent",
            Map.of("companyId", user.getCompanyId(), "id", id),
            new CustomField.CustomFieldMapper<>(CustomField.class, om))
        .stream()
        .peek(
            cf -> {
              final List<ListOfValue> listOfValues = getListOfValues(cf, user);
              cf.setHasListValues(
                  null != cf.getCustomFieldSqlKey() || null != cf.getCompanySystemListId());
              cf.setListOfValues(listOfValues);
            })
        .toList();
  }

  public List<CustomFieldWithDefault> getByEvent(Long id) {
    User user = securityService.getCurrentUser();
    //for now i am only returning start, end and resource from the default field list. will prob add the rest in later
    return sqlCache
      .query(
        "customField.getByEvent",
        Map.of("companyId", user.getCompanyId(), "id", id),
        new CustomField.CustomFieldMapper<>(CustomFieldWithDefault.class, om))
      .stream()
      .peek(
        cf -> {
          final List<ListOfValue> listOfValues = getListOfValues(cf, user);
          cf.setHasListValues(
            null != cf.getCustomFieldSqlKey() || null != cf.getCompanySystemListId());
          cf.setListOfValues(listOfValues);
        })
      .toList();
  }

  public List<CustomField> getByParentProcessStep(Long id, Boolean excludedUnhandledDataTypes) {
    User user = securityService.getCurrentUser();
    return sqlCache
        .query(
            "customField.getByParentProcessStep",
            Map.of("companyId", user.getCompanyId(), "id", id,
              "excludedUnhandledDataTypes", excludedUnhandledDataTypes != null ? excludedUnhandledDataTypes : false),
            new CustomField.CustomFieldMapper<>(CustomField.class, om))
        .stream()
        .peek(
            cf -> {
              final List<ListOfValue> listOfValues = getListOfValues(cf, user);
              cf.setHasListValues(
                  null != cf.getCustomFieldSqlKey() || null != cf.getCompanySystemListId());
              cf.setListOfValues(listOfValues);
            })
        .toList();
  }

  public List<CustomField> getByParentType(Long id, Boolean excludedUnhandledDataTypes) {
    User user = securityService.getCurrentUser();
    return sqlCache
        .query(
            "customField.getByParentType",
            Map.of("companyId", user.getCompanyId(), "id", id,
              "excludedUnhandledDataTypes", excludedUnhandledDataTypes != null ? excludedUnhandledDataTypes : false),
            new CustomField.CustomFieldMapper<>(CustomField.class, om))
        .stream()
        .peek(
            cf -> {
              final List<ListOfValue> listOfValues = getListOfValues(cf, user);
              cf.setHasListValues(
                  null != cf.getCustomFieldSqlKey() || null != cf.getCompanySystemListId());
              cf.setListOfValues(listOfValues);
            })
        .toList();
  }

  public List<ListOfValue> getCustomFieldListOfValues(Long id) {
    final var currentUser = securityService.getCurrentUser();
    final var customFieldById = findCustomFieldById(id);
    Assert.notNull(customFieldById, "Custom field id=" + id + " not found!");

    return getListOfValues(customFieldById, currentUser);
  }

  private List<ListOfValue> getListOfValues(CustomField cf, User user) {
    if (cf.getListOfValues() != null && !cf.getListOfValues().isEmpty()) {
      return cf.getListOfValues();
    }

    if (null != cf.getCustomFieldSqlKey()) {
      String sql = sqlCache.getByKey(cf.getCustomFieldSqlKey());
      if (null != sql) {
        HashMap<String, Object> params2 = new HashMap<>();
        params2.put("projectId", null);
        params2.put("userId", user.getId());
        return sqlCache.queryBySql(sql, params2, ListOfValue.class);
      }
    } else if (null != cf.getCompanySystemListId()) {
      return systemListService.getSystemListOptionsForCompany(
          cf.getCompanySystemListId(), true, cf.getSystemListOptionIds(), user.getCompanyId());
    }

    return null;
  }

  public List<CustomField> getCustomFieldsByPositionId(Long positionId) {
    User user = securityService.getCurrentUser();
    final Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("positionId", positionId);

    return sqlCache.query(
      "customField.getAllByPositionId", params, new CustomField.CustomFieldMapper<>(CustomField.class, om));
  }
}
