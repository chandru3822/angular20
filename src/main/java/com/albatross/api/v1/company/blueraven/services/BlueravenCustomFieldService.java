package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.CustomFieldService;
import com.albatross.api.v1.flow.services.SqlArrayService;
import com.albatross.api.v1.flow.services.SystemListService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@PreAuthorize("hasCompanyAccess(3)")
@RequiredArgsConstructor
public class BlueravenCustomFieldService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;
  private final SqlArrayService sqlArrayService;
  private final SystemListService systemListService;
  private final CustomFieldService customFieldService;

  public List<CustomField> getAllCustomFields() {
    User user = securityService.getCurrentUser();
    return sqlCache.query(
        "blueravenCustomField.getAll",
        Map.of("companyId", user.getCompanyId()),
        new CustomField.CustomFieldMapper<>(CustomField.class, om));
  }

  public List<CustomField> findCustomFieldsByObjectCode(String code) {
    Assert.notNull(code, "Code must be provided");

    final var currentUser = securityService.getCurrentUser();
    final Map<String, Object> params =
        Map.of("companyId", currentUser.getCompanyId(), "objectCode", code);

    final var customFieldBeanPropertyRowMapper =
        new CustomField.CustomFieldMapper<>(CustomField.class, om);
    return sqlCache
        .query("blueravenCustomField.getByObjectCode", params, customFieldBeanPropertyRowMapper)
        .stream()
        .peek(
            cf -> {
              if (cf.shouldHaveListOfValues()) {
                cf.setHasListValues(true);

                if (!cf.getLazyLoadValues()) {
                  final List<ListOfValue> values = getListOfValues(cf, currentUser, Map.of());
                  if (values != null && !values.isEmpty()) {
                    cf.setListOfValues(values);
                  }
                }
              }
            })
        .toList();
  }

  public List<ListOfValue> getCustomFieldListOfValues(Long id, String query) {
    final var currentUser = securityService.getCurrentUser();
    final var customFieldById = findCustomFieldById(id);
    if (customFieldById == null) {
      throw new RuntimeException("Blueraven custom field id=" + id + " not found!");
    }
    return getListOfValues(customFieldById, currentUser, Map.of("query", query));
  }

  private List<ListOfValue> getListOfValues(
      CustomField cf, User user, Map<String, Object> context) {

    if (cf.getListOfValues() != null && !cf.getListOfValues().isEmpty()) {
      return cf.getListOfValues();
    }

    if (cf.getCustomFieldSql() != null) {
      final var sql = cf.getCustomFieldSql();
      if (sql != null) {
        Map<String, Object> params =
            new HashMap<>(Map.of("userId", user.trueUserId(), "companyId", user.getCompanyId()));
        if (context != null) {
          params.putAll(context);
        }
        return sqlCache.queryBySql(sql, params, ListOfValue.class);
      }
    }

    if (cf.getCompanySystemListId() != null) {
      return systemListService.getSystemListOptionsForCompany(
          cf.getCompanySystemListId(), true, cf.getSystemListOptionIds(), user.getCompanyId());
    }

    if (cf.getFlowCustomFieldId() != null){
      return customFieldService.getCustomFieldListOfValues(cf.getFlowCustomFieldId());
    }

    return List.of();
  }

  public CustomField findCustomFieldById(Long id) {
    Assert.notNull(id, "Field ID must be provided");

    Optional<CustomField> result =
        sqlCache.get(
            "blueravenCustomField.getOne",
            Map.of("id", id),
            new CustomField.CustomFieldMapper<>(CustomField.class, om));
    return result.orElse(null);
  }

  public CustomField saveField(CustomField customField) throws SQLException {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put(
        "lazyLoadValues",
        customField.getLazyLoadValues() != null && customField.getLazyLoadValues());
    params.put("fieldName", customField.getFieldName());
    params.put("sortListValuesAlphabetically", customField.getSortListValuesAlphabetically());
    params.put("systemListId", customField.getCompanySystemListId());
    params.put("customFieldSql", customField.getCustomFieldSql());
    params.put("customFieldSqlReferenceTable", customField.getCustomFieldSqlReferenceTable());
    params.put("flowCustomFieldId", customField.getFlowCustomFieldId());
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
      sqlCache.update("blueravenCustomField.saveField", params);
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
                .updateReturningId("blueravenCustomField.insertListOfValue", lovParent, "id")
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
          sqlCache.update("blueravenCustomField.updateListOfValue", lovParams);
        } else if (lov.getArchived()) {
          // do archive of row
          lovParams.put("id", lov.getId());
          sqlCache.update("blueravenCustomField.archiveListOfValue", lovParams);
        } else {
          // do row insert
          sqlCache.update("blueravenCustomField.insertListOfValue", lovParams);
        }
      }
    }

    if (doInsertAfterHandlingOtherScenarios) {
      params.put("listOfValueId", parentId);
      params.put("customFieldSql", customField.getCustomFieldSql());
      params.put("customFieldSqlReferenceTable", customField.getCustomFieldSqlReferenceTable());
      params.put("companyId", customField.getCompanyId());
      params.put("systemListId", customField.getCompanySystemListId());
      params.put(
          "listOptionIds",
          sqlArrayService.createSqlArrayOfType("int", customField.getSystemListOptionIds()));
      params.put("createdById", user.trueUserId());
      params.put("companyDataTypeId", customField.getCompanyDataTypeId());
      params.put(
          "lazyLoadValues",
          customField.getLazyLoadValues() != null && customField.getLazyLoadValues());
      params.put("flowCustomFieldId", customField.getFlowCustomFieldId());

      // insert new custom field with listOfValueId if needed
      id = sqlCache.updateReturningId("blueravenCustomField.insertField", params, "id").longValue();
    }

    return findCustomFieldById(id);
  }

  public List<CustomField> deleteField(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("fieldId", id);
    params.put("modifiedById", currentUser.trueUserId());

    // todo: add in the validations after this is all working
    //       check if field is in use by a custom field group
    List<CustomField> fields =
        sqlCache.query("blueravenCustomField.getGroupsUsingField", params, CustomField.class);

    // if the field is assigned somewhere, return those values to frontend
    if (!fields.isEmpty()) {
      return fields;
    } else {
      // archive single custom field
      sqlCache.update("blueravenCustomField.deleteField", params);
      return null;
    }
  }

  public Long saveManagementCompany(String companyName){
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("name", companyName);
    params.put("createdById", user.trueUserId());
    if(sqlCache.update("blueravenCustomField.insertManagementCompany", params) == 1){
      HashMap<String, Object> nameParam = new HashMap<>();
      return sqlCache.queryForObject("blueravenCustomField.getListOfValueIdByName", params, Long.class);
    }
    else {
      return null;
    }
  }
}
