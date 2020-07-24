package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class CustomFieldService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  SystemListService systemListService;

  @Autowired
  ObjectMapper om;

  private final DataSource dataSource;

  public CustomField findCustomFieldById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<CustomField> result = sqlCache.get("customField.getOne", params, new CustomFieldMapper<>(CustomField.class, om));
    return result.orElse(null);
  }


  public List<CustomField> getAllCustomFields() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<CustomField> result = sqlCache.query("customField.getAll", params, new CustomFieldMapper<>(CustomField.class, om));
    return result;
  }

  public List<CompanyObjectType> getCompanyObjectTypes() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<CompanyObjectType> result = sqlCache.query("customField.getCompanyObjectTypes", params, CompanyObjectType.class);
    return result;
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
    HashMap<String, Object> params = new HashMap<>();
    params.put("fieldName", customField.getFieldName());
    params.put("readonly", customField.getReadonly() == null ? false : customField.getReadonly());
    params.put("systemListId", customField.getCompanySystemListId());
    params.put("systemListOptionIds", null == customField.getSystemListOptionIds() || customField.getSystemListOptionIds().isEmpty()
                                          ? null : createSqlArrayOfType("int", customField.getSystemListOptionIds()));
    Long id = null;
    boolean doInsertAfterHandlingOtherScenarios = false;
    boolean insertParentRecordIfNeeded = false;
    boolean insertSqlKey = false;

    if(null != customField.getId()) {
      // edit existing custom field
      id = customField.getId();
      params.put("id", id);
      params.put("modifiedById", customField.getModifiedById());
      sqlCache.update("customField.saveField", params);
    } else {
      // have to insert the list of values first if needed to get the listOfValueId
      doInsertAfterHandlingOtherScenarios = true;
      // only insert the parent list value record if this is a new custom field
      insertParentRecordIfNeeded = true;
    }

    Long parentId = null;
    Long lovCreatedById;

    if(customField.getListOfValues() != null && !customField.getListOfValues().isEmpty()) {
      if(insertParentRecordIfNeeded) {
        // use created by unless field already existed then use modified id as the created for the list value row
        lovCreatedById = customField.getCreatedById();

        //insert the parent row if this is a new field
        HashMap<String, Object> lovParent = new HashMap<>();
        lovParent.put("name", customField.getFieldName());
        lovParent.put("parentId", null);
        lovParent.put("createdById", customField.getCreatedById());
        lovParent.put("displayOrder", null);
        parentId = sqlCache.updateReturningId("customField.insertListOfValue", lovParent, "id").longValue();
      } else {
        parentId = customField.getListOfValueId();
        lovCreatedById = customField.getModifiedById();
      }

      //insert the rest of the list values
      for(ListOfValue lov : customField.getListOfValues()) {
        HashMap<String, Object> lovParams = new HashMap<>();
        lovParams.put("name", lov.getName());
        lovParams.put("parentId", parentId);
        lovParams.put("createdById", lovCreatedById);
        lovParams.put("modifiedById", customField.getModifiedById());
        lovParams.put("displayOrder", lov.getDisplayOrder());

        if(null != lov.getId() && !lov.getArchived()) {
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

    if(doInsertAfterHandlingOtherScenarios) {
      params.put("listOfValueId", parentId);
      params.put("customFieldSqlKey", customField.getCustomFieldSqlKey());
      params.put("customFieldSqlReferenceTable", customField.getCustomFieldSqlReferenceTable());
      params.put("companyId", customField.getCompanyId());
      params.put("systemListId", customField.getCompanySystemListId());
      params.put("createdById", customField.getCreatedById());
      params.put("companyDataTypeId", customField.getCompanyDataTypeId());

      // insert new custom field with listOfValueId if needed
      id = sqlCache.updateReturningId("customField.insertField", params, "id").longValue();
    }

    // add / delete custom field object types
    if(null != customField.getCustomFieldObjectTypes()) {
      for(CustomFieldObjectType cfot : customField.getCustomFieldObjectTypes()) {
        handleCustomFieldObjectTypes(id, cfot);
      }
    }

    return findCustomFieldById(id);
  }

  public void handleCustomFieldObjectTypes(Long customFieldId, CustomFieldObjectType cfot) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("archived", cfot.getArchived());
    params.put("customFieldId", customFieldId);
    params.put("companyObjectTypeId", cfot.getCompanyObjectTypeId());

    // if it is a new field the cfot.getId() is actually the objectTypeId so do 2 checks here
    if(null != cfot.getId() && null != cfot.getCustomFieldId()) {
      params.put("id", cfot.getId());
      sqlCache.update("customField.updateCustomFieldObjectType", params);
    } else if (null != cfot.getArchived() && !cfot.getArchived()) {
      // do not need to insert new row if it is archived / not selected
      sqlCache.update("customField.insertCustomFieldObjectType", params);
    }
  }

  public void deleteField(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("fieldId", id);
    params.put("modifiedById", currentUser.getId());

    // archive single custom field
    sqlCache.update("customField.deleteField", params);

    //todo: is there more that needs to be archived when they delete a custom field?
  }

  public List<CustomField> getByParentProcessStep(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", id);
    List<CustomField> results = sqlCache.query("customField.getByParentProcessStep", params, new CustomFieldMapper<>(CustomField.class, om));

    // todo: this is duplicated from custom field value service but didn't quite match up, probably could re-write to combine the two
    for(CustomField cf : results ) {
      if(null != cf.getCustomFieldSqlKey()) {
        String sql = sqlCache.getByKey(cf.getCustomFieldSqlKey());
        if(null != sql) {
          List<ListOfValue> listOfValues = sqlCache.queryBySql(sql, Collections.emptyMap(), ListOfValue.class);
          cf.setListOfValues(listOfValues);
        }
      } else if (null != cf.getCompanySystemListId()) {
        List<ListOfValue> listOfValues = systemListService.getSystemListOptionsForCompany(cf.getCompanySystemListId(), true, cf.getSystemListOptionIds());
        cf.setListOfValues(listOfValues);
      }
    }

    return results;
  }

  public List<CustomField> getByParentType(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", id);
    List<CustomField> results = sqlCache.query("customField.getByParentType", params, new CustomFieldMapper<>(CustomField.class, om));

    for(CustomField cf : results ) {
      if(null != cf.getCustomFieldSqlKey()) {
        String sql = sqlCache.getByKey(cf.getCustomFieldSqlKey());
        if(null != sql) {
          List<ListOfValue> listOfValues = sqlCache.queryBySql(sql, Collections.emptyMap(), ListOfValue.class);
          cf.setListOfValues(listOfValues);
        }
      } else if (null != cf.getCompanySystemListId()) {
        List<ListOfValue> listOfValues = systemListService.getSystemListOptionsForCompany(cf.getCompanySystemListId(), true, cf.getSystemListOptionIds());
        cf.setListOfValues(listOfValues);
      }
    }

    return results;
  }

  private Array createSqlArrayOfType(String typeName, List<?> array) throws SQLException {
    if (array != null && !array.isEmpty()) {
      try (Connection connection = dataSource.getConnection()) {
        return connection.createArrayOf(typeName, array.toArray());
      }
    }
    return null;
  }

  public static class CustomFieldMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CustomFieldMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {

      TypeReference<List<CustomFieldObjectType>> customFieldObjectTypeRef = new TypeReference<List<CustomFieldObjectType>>() {};
      bw.registerCustomEditor(List.class, "customFieldObjectTypes",
          new JsonCollectionDeserializer(customFieldObjectTypeRef, objectMapper));

      TypeReference<List<ListOfValue>> listOfValueRef = new TypeReference<List<ListOfValue>>() {};
      bw.registerCustomEditor(List.class, "listOfValues",
          new JsonCollectionDeserializer(listOfValueRef, objectMapper));

      TypeReference<List<Long>> systemListOptionIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "systemListOptionIds",
          new JsonCollectionDeserializer(systemListOptionIdsRef, objectMapper));
    }
  }
}
