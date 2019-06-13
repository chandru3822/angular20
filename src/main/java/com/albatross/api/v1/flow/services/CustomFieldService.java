package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldObjectType;
import com.albatross.api.v1.flow.model.ListOfValue;
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

  public List<CustomFieldObjectType> getCustomFieldObjectTypes(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    List<CustomFieldObjectType> result = sqlCache.query("customField.getCustomFieldObjectTypes", params, CustomFieldObjectType.class);
    return result;
  }

  public CustomField saveField(CustomField customField) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("fieldName", customField.getFieldName());
    Long id = null;

    if(null != customField.getId()) {
      // edit existing custom field
      id = customField.getId();
      params.put("id", id);
      sqlCache.update("customField.saveField", params);

      // todo: handle adding/editing/deleting the dropdown fields here
    } else {
      Long parentId = null;
      // insert the list of values first if needed to get the listOfValueId
      if(customField.getDropdownOptions() != null && !customField.getDropdownOptions().isEmpty()) {
        //insert the parent row
        HashMap<String, Object> lovParent = new HashMap<>();
        lovParent.put("name", customField.getFieldName());
        lovParent.put("parentId", null);
        lovParent.put("createdById", customField.getCreatedById());
        lovParent.put("displayOrder", null);
        parentId = sqlCache.updateReturningId("customField.insertListOfValue", lovParent, "id").longValue();

        //insert the rest of the list values
        for(ListOfValue lov : customField.getDropdownOptions()) {
          HashMap<String, Object> lovParams = new HashMap<>();
          lovParams.put("name", lov.getName());
          lovParams.put("parentId", parentId);
          lovParams.put("createdById", customField.getCreatedById());
          lovParams.put("displayOrder", lov.getDisplayOrder());
          sqlCache.updateReturningId("customField.insertListOfValue", lovParams, "id");
        }
      }

      params.put("listOfValueId", parentId);
      params.put("companyId", customField.getCompanyId());
      params.put("createdById", customField.getCreatedById());
      params.put("companyDataTypeId", customField.getCompanyDataTypeId());

      // insert new custom field
      id = sqlCache.updateReturningId("customField.insertField", params, "id").longValue();
    }

    return findCustomFieldById(id);
  }

  public void deleteField(Long fieldId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("fieldId", fieldId);

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
      TypeReference<List<Long>> selectedCustomFieldObjectTypeRef = new TypeReference<List<Long>>() {};
      TypeReference<List<ListOfValue>> listOfValueRef = new TypeReference<List<ListOfValue>>() {};

      bw.registerCustomEditor(List.class, "selectedCustomFieldObjectTypes",
          new JsonCollectionDeserializer(selectedCustomFieldObjectTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "dropdownOptions",
          new JsonCollectionDeserializer(listOfValueRef, objectMapper));
    }
  }
}
