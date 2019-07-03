package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
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
public class CustomFieldService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public CustomField findCustomFieldById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<CustomField> result = sqlCache.get("customField.getOne", params, new CustomFieldMapper<>(CustomField.class, om));
    return result.orElse(null);
  }


  public List<CustomField> getAllCustomFields(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    List<CustomField> result = sqlCache.query("customField.getAll", params, new CustomFieldMapper<>(CustomField.class, om));
    return result;
  }

  public List<ObjectType> getObjectTypes(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    List<ObjectType> result = sqlCache.query("customField.getObjectTypes", params, ObjectType.class);
    return result;
  }

  /*
  * I think this handles saving all scenarios of custom fields
  *   Existing custom field changes
  *     With:
  *        new list of value options
  *        updating existing value options
  *        archiving existing value options
  *   New custom fields
  *     With or without value options (which would always be new/inserts)
   */
  public CustomField saveField(CustomField customField) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("fieldName", customField.getFieldName());
    Long id = null;
    boolean doInsertAfterListOfValues = false;
    boolean insertParentRecordIfNeeded = false;

    if(null != customField.getId()) {
      // edit existing custom field
      id = customField.getId();
      params.put("id", id);
      params.put("modifiedById", customField.getModifiedById());
      sqlCache.update("customField.saveField", params);
    } else {
      // have to insert the list of values first if needed to get the listOfValueId
      doInsertAfterListOfValues = true;
      // only insert the parent list value record if this is a new custom field
      insertParentRecordIfNeeded = true;
    }

    Long parentId = null;
    Long lovCreatedById;

    if(customField.getDropdownOptions() != null && !customField.getDropdownOptions().isEmpty()) {
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
      for(ListOfValue lov : customField.getDropdownOptions()) {
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

    if(doInsertAfterListOfValues) {
      params.put("listOfValueId", parentId);
      params.put("companyId", customField.getCompanyId());
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
    params.put("objectTypeId", null != cfot.getCustomFieldId() ? cfot.getObjectTypeId() : cfot.getId());

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
    // @randa: currentUser is null, comeback and fix
//    params.put("modifiedById", currentUser.getId());
    params.put("modifiedById", 99999999);

    // archive single custom field
    sqlCache.update("customField.deleteField", params);

    // archive all custom_field_group rows
    sqlCache.update("customFieldGroup.archiveRows", params);
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
      TypeReference<List<ListOfValue>> listOfValueRef = new TypeReference<List<ListOfValue>>() {};

      bw.registerCustomEditor(List.class, "customFieldObjectTypes",
          new JsonCollectionDeserializer(customFieldObjectTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "dropdownOptions",
          new JsonCollectionDeserializer(listOfValueRef, objectMapper));
    }
  }
}
