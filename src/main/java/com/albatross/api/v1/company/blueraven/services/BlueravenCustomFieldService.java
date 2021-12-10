package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldObjectType;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.CustomFieldService;
import com.albatross.api.v1.flow.services.SystemListService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;
import org.springframework.web.server.ResponseStatusException;

import javax.sql.DataSource;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@Slf4j
@Service
@RequiredArgsConstructor
public class BlueravenCustomFieldService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;
  private final DataSource dataSource;
  private final SystemListService systemListService;

  public List<CustomField> getAllCustomFields() {
    User user = securityService.getCurrentUser();
    // basic security?
    if (user.getCompanyId() != 3) {
      throw new ResponseStatusException(
          HttpStatus.UNAUTHORIZED, "You do not have access to this company data.", new Exception());
    } else {
      HashMap<String, Object> params = new HashMap<>();
      params.put("companyId", user.getCompanyId());
      List<CustomField> result =
          sqlCache.query(
              "blueravenCustomField.getAll",
              params,
              new CustomFieldMapper<>(CustomField.class, om));
      return result;
    }
  }

  public List<CustomField> findCustomFieldsByObjectCode(String code) {
    Assert.notNull(code, "Code must be provided");

    final var currentUser = securityService.getCurrentUser();
    final Map<String, Object> params =
        Map.of("companyId", currentUser.getCompanyId(), "objectCode", code);

    final var customFieldBeanPropertyRowMapper = new CustomFieldMapper<>(CustomField.class, om);
    return sqlCache
        .query(
            "blueravenCustomFieldValue.getByObjectCode", params, customFieldBeanPropertyRowMapper)
        .stream()
        .map(cf -> resolveCustomField(currentUser, cf))
        .toList();
  }

  private CustomField resolveCustomField(User user, CustomField cf) {
    if (cf.getCustomFieldSqlKey() != null) {
      final var sql = sqlCache.getByKey(cf.getCustomFieldSqlKey());
      if (sql != null) {
        final var listOfValues =
            sqlCache.queryBySql(
                sql,
                Map.of("userId", user.trueUserId(), "companyId", user.getCompanyId()),
                ListOfValue.class);
        cf.setListOfValues(listOfValues);
      }
    } else if (cf.getCompanySystemListId() != null) {
      List<ListOfValue> listOfValues =
          systemListService.getSystemListOptionsForCompany(
              cf.getCompanySystemListId(), true, cf.getSystemListOptionIds(), user.getCompanyId());
      cf.setListOfValues(listOfValues);
    }

    if (!cf.getListOfValues().isEmpty()) {
      cf.setHasListValues(true);
    }

    return cf;
  }

  public CustomField findCustomFieldById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<CustomField> result =
        sqlCache.get(
            "blueravenCustomField.getOne",
            params,
            new CustomFieldService.CustomFieldMapper<>(CustomField.class, om));
    return result.orElse(null);
  }

  public CustomField saveField(CustomField customField) throws SQLException {
    User user = securityService.getCurrentUser();
    if (user.getCompanyId() != 3) {
      throw new ResponseStatusException(
          HttpStatus.UNAUTHORIZED, "You do not have access to this company data.", new Exception());
    } else {
      HashMap<String, Object> params = new HashMap<>();
      params.put("fieldName", customField.getFieldName());
      Long id = null;
      boolean doInsertAfterHandlingOtherScenarios = false;
      boolean insertParentRecordIfNeeded = false;
      boolean insertSqlKey = false;

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
        params.put("customFieldSqlKey", customField.getCustomFieldSqlKey());
        params.put("customFieldSqlReferenceTable", customField.getCustomFieldSqlReferenceTable());
        params.put("companyId", customField.getCompanyId());
        params.put("systemListId", customField.getCompanySystemListId());
        params.put(
            "listOptionIds", createSqlArrayOfType("int", customField.getSystemListOptionIds()));
        params.put("createdById", user.trueUserId());
        params.put("companyDataTypeId", customField.getCompanyDataTypeId());

        // insert new custom field with listOfValueId if needed
        id =
            sqlCache
                .updateReturningId("blueravenCustomField.insertField", params, "id")
                .longValue();
      }

      // add / delete custom field object types
      if (null != customField.getCustomFieldObjectTypes()) {
        for (CustomFieldObjectType cfot : customField.getCustomFieldObjectTypes()) {
          handleCustomFieldObjectTypes(id, cfot);
        }
      }

      return findCustomFieldById(id);
    }
  }

  public List<CustomField> deleteField(Long id) {
    User currentUser = securityService.getCurrentUser();
    if (currentUser.getCompanyId() != 3) {
      throw new ResponseStatusException(
          HttpStatus.UNAUTHORIZED, "You do not have access to this company data.", new Exception());
    } else {
      HashMap<String, Object> params = new HashMap<>();
      params.put("fieldId", id);
      params.put("modifiedById", currentUser.trueUserId());

      // todo: add in the validations after this is all working
      // check if field is in use by a custom field group
      //    List <CustomField> fields = sqlCache.query("customField.getGroupsUsingField", params,
      // CustomField.class);

      // if the field is assigned somewhere, return those values to frontend
      //    if(!fields.isEmpty()) {
      //      return fields;
      //    } else {
      // archive single custom field
      sqlCache.update("blueravenCustomField.deleteField", params);
      return null;
      //    }
    }
  }

  private Array createSqlArrayOfType(String typeName, List<?> array) throws SQLException {
    if (array != null && !array.isEmpty()) {
      try (Connection connection = dataSource.getConnection()) {
        return connection.createArrayOf(typeName, array.toArray());
      }
    }
    return null;
  }

  public void handleCustomFieldObjectTypes(Long customFieldId, CustomFieldObjectType cfot) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("archived", cfot.getArchived());
    params.put("customFieldId", customFieldId);
    params.put("userId", currentUser.trueUserId());
    params.put("objectTypeId", cfot.getObjectTypeId());

    // if it is a new field the cfot.getId() is actually the objectTypeId so do 2 checks here
    if (null != cfot.getId() && null != cfot.getCustomFieldId()) {
      params.put("id", cfot.getId());
      sqlCache.update("blueravenCustomField.updateCustomFieldObjectType", params);
    } else if (null != cfot.getArchived() && !cfot.getArchived()) {
      // do not need to insert new row if it is archived / not selected
      sqlCache.update("blueravenCustomField.insertCustomFieldObjectType", params);
    }
  }

  public static class CustomFieldMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CustomFieldMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {

      TypeReference<List<CustomFieldObjectType>> customFieldObjectTypeRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "customFieldObjectTypes",
          new JsonCollectionDeserializer(customFieldObjectTypeRef, objectMapper));

      TypeReference<List<ListOfValue>> listOfValueRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "listOfValues", new JsonCollectionDeserializer(listOfValueRef, objectMapper));

      TypeReference<List<Long>> systemListOptionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "systemListOptionIds",
          new JsonCollectionDeserializer(systemListOptionsRef, objectMapper));
    }
  }
}
