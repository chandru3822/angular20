package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class CustomFieldValueService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  SystemListService systemListService;

  @Autowired
  ProjectService projectService;

  @Autowired
  ObjectMapper om;

  public void handleCustomListOfValue (List<CustomFieldGroup> results) {
    handleCustomListOfValue(results, null, null);
  }

  public void handleCustomListOfValue (List<CustomFieldGroup> results, Long projectId, Long userId) {
    for(CustomFieldGroup cfg : results) {
      for(CustomFieldValue cv : cfg.getCustomFieldValues()){
        if(null != cv.getCustomFieldSqlKey()) {
          cv.setHasListValues(true);
          String sql = sqlCache.getByKey(cv.getCustomFieldSqlKey());
          if(null != sql) {
            cv.setHasListValues(true);
            HashMap<String, Object> params = new HashMap<>();
            params.put("projectId", projectId);
            params.put("userId", userId);
            List<ListOfValue> listOfValues = sqlCache.queryBySql(sql, params, ListOfValue.class);
            cv.setListOfValues(listOfValues);
          }
        } else if (null != cv.getCompanySystemListId()) {
          cv.setHasListValues(true);
//          cv.getIntValue() is passed so we can add to the sub option list any option already selected but no longer available in the list
          List<ListOfValue> listOfValues = systemListService.getSystemListOptionsForCompany(cv.getCompanySystemListId(), true, cv.getSystemListOptionIds(), cv.getIntValue());
          cv.setListOfValues(listOfValues);
        }
      }
    }
  }

  public List<CustomFieldGroup> updateCustomFieldValues(List<CustomFieldValue> values, Long sourceId, String objectType) {
    User currentUser = securityService.getCurrentUser();
    for(CustomFieldValue cfv : values) {
      //if the field came here it was dirty and should always be saved
      HashMap<String, Object> params = new HashMap<>();
      params.put("dateValue", cfv.getDateValue());
      params.put("timestampValue", cfv.getTimestampValue());
      params.put("booleanValue", cfv.getBooleanValue());
      params.put("textValue", cfv.getTextValue());
      params.put("numericValue", cfv.getNumericValue());
      params.put("intValue", cfv.getIntValue());
      params.put("intArrayValue", cfv.getIntArrayValue());
      params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());
      params.put("sourceId", sourceId);

      String sqlPrefix = "customFieldValues." + objectType;

      if(null != cfv.getId()){
        params.put("id", cfv.getId());
        params.put("modifiedById", currentUser.getId());
        sqlCache.update(sqlPrefix + ".updateCustomFieldValue", params);
      } else {
        params.put("createdById", currentUser.getId());
        sqlCache.update(sqlPrefix + ".insertCustomFieldValue", params);
      }
    }
    return getCustomFieldGroupsAndValues(objectType, sourceId);
  }

  public List<CustomFieldGroup> getCustomFieldGroupsAndValues(String objectType, Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", ObjectType.get(objectType).id);
    params.put("sourceId", id);
    String sqlPrefix = "customFieldValues." + objectType;

//    note: this company id needs to be the company_id of the object (contact, project, org, process_step, user) so that users in the parent can see the custom field groups still
    Long companyId;
    if(objectType.equals("user")) {
      companyId = user.getCompanyId();
    } else {
      companyId = sqlCache.queryForObject(sqlPrefix + ".getCompanyId", params, Long.class);
    }
    params.put("companyId", companyId);

    List<CustomFieldGroup> fieldGroups = sqlCache.query(sqlPrefix + ".getCustomFieldGroupsAndValues", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    // this allows us to pass project_id and user_id to custom sql queries
    if(objectType.equals("project")) {
      handleCustomListOfValue(fieldGroups, id, user.getId());
    } else if (objectType.equals("process_step")) {
      Long projectId = projectService.getProjectIdByProjectProcessStepId(id);
      handleCustomListOfValue(fieldGroups, projectId, user.getId());
    } else {
      handleCustomListOfValue(fieldGroups);
    }

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
      TypeReference<List<CustomFieldValue>> customFieldValueRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "customFieldValues",
          new JsonCollectionDeserializer(customFieldValueRef, objectMapper));

      TypeReference<List<CustomField>> customFieldRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "customFields",
          new JsonCollectionDeserializer(customFieldRef, objectMapper));

      TypeReference<List<Long>> systemListOptionIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "systemListOptionIds",
          new JsonCollectionDeserializer(systemListOptionIdsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> whiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "whiteListedPositions",
          new JsonCollectionDeserializer(whiteListedPositionsRef, objectMapper));
    }
  }
}
