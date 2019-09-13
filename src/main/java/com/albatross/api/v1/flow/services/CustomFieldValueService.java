package com.albatross.api.v1.flow.services;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class CustomFieldValueService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<CustomFieldGroup> getCustomerCustomValues(Long primaryId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("primaryId", primaryId);
    params.put("objectTypeId", ObjectType.CUSTOMER.id);

    List<CustomFieldGroup> results = sqlCache.query("customFieldValues.getCustomerFieldValues", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    handleCustomListOfValue(results);

    return results;
  }

  public void handleCustomListOfValue (List<CustomFieldGroup> results) {
    for(CustomFieldGroup cfg : results) {
      for(CustomFieldValue cv : cfg.getCustomFieldValues()){
        if(null != cv.getCustomFieldSqlKey()) {
          String sql = sqlCache.getByKey(cv.getCustomFieldSqlKey());
          if(null != sql) {
            List<ListOfValue> listOfValues = sqlCache.queryBySql(sql, Collections.emptyMap(), ListOfValue.class);
            cv.setListOfValues(listOfValues);
          }
        }
      }
    }
  }

  public List<CustomFieldGroup> getProjectCustomValues(Long projectId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("objectTypeId", ObjectType.PROJECT.id);
    params.put("projectId", projectId);

    List<CustomFieldGroup> fieldGroups = sqlCache.query("customFieldValues.getProjectFieldValues", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    handleCustomListOfValue(fieldGroups);

    return fieldGroups;
  }

  public static class CustomFieldGroupMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CustomFieldGroupMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomFieldValue>> customFieldValueRef = new TypeReference<List<CustomFieldValue>>() {};
      bw.registerCustomEditor(List.class, "customFieldValues",
          new JsonCollectionDeserializer(customFieldValueRef, objectMapper));

      TypeReference<List<CustomField>> customFieldRef = new TypeReference<List<CustomField>>() {};
      bw.registerCustomEditor(List.class, "customFields",
          new JsonCollectionDeserializer(customFieldRef, objectMapper));
    }
  }


}
