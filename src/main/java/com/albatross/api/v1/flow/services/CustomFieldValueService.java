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

import java.util.Collections;
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
  ObjectMapper om;

  public List<CustomFieldGroup> getContactCustomValues(Long primaryId) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("primaryId", primaryId);
    params.put("objectTypeId", ObjectType.CONTACT.id);

    Long companyId = sqlCache.queryForObject("contact.getContactCompanyId", params, Long.class);

    params.put("companyId", companyId);
    List<CustomFieldGroup> results = sqlCache.query("customFieldValues.getContactFieldValues", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    handleCustomListOfValue(results);
    return results;

  }

  public List<CustomFieldGroup> getOrgCustomValues(Long primaryId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("primaryId", primaryId);
    params.put("objectTypeId", ObjectType.ORGANIZATION.id);

    List<CustomFieldGroup> results = sqlCache.query("customFieldValues.getOrgFieldValues", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    handleCustomListOfValue(results);

    return results;
  }

  public List<CustomFieldGroup> getUserCustomValues(Long primaryId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("primaryId", primaryId);
    params.put("objectTypeId", ObjectType.USER.id);

    List<CustomFieldGroup> results = sqlCache.query("customFieldValues.getUserFieldValues", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

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
        } else if (null != cv.getCompanySystemListId()) {
          List<ListOfValue> listOfValues = systemListService.getSystemListOptionsForCompany(cv.getCompanySystemListId(), true, cv.getSystemListOptionIds());
          cv.setListOfValues(listOfValues);
        }
      }
    }
  }

  public List<CustomFieldGroup> getProjectCustomValues(Long projectId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("objectTypeId", ObjectType.PROJECT.id);
    params.put("processStepTypeId", ObjectType.PROCESS_STEP.id);
    params.put("projectId", projectId);

    List<CustomFieldGroup> fieldGroups = sqlCache.query("customFieldValues.getProjectFieldValues", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    handleCustomListOfValue(fieldGroups);

    return fieldGroups;
  }

  public List<CustomFieldGroup> updateProjectCustomFieldValues(Long projectId, List<CustomFieldGroup> groups) {
    User currentUser = securityService.getCurrentUser();
    for(CustomFieldGroup group : groups) {
      for(CustomFieldValue cfv : group.getCustomFieldValues()){
        //todo: only save if something changed
        if(fieldHasValue(cfv)) {
          HashMap<String, Object> params = new HashMap<>();
          params.put("dateValue", cfv.getDateValue());
          params.put("timestampValue", cfv.getTimestampValue());
          params.put("booleanValue", null != cfv.getBooleanValue() ? cfv.getBooleanValue() : false);
          params.put("textValue", cfv.getTextValue());
          params.put("numericValue", cfv.getNumericValue());
          params.put("intValue", cfv.getIntValue());
          params.put("intArrayValue", cfv.getIntArrayValue());
          params.put("projectId", projectId);
          params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());

          if(null != cfv.getId()){
            params.put("id", cfv.getId());
            params.put("modifiedById", currentUser.getId());
            sqlCache.update("customFieldValues.updateProjectCustomFieldValue", params);
          } else {
            params.put("createdById", currentUser.getId());
            sqlCache.update("customFieldValues.insertProjectCustomFieldValue", params);
          }
        }
      }
    }
    return getProjectCustomValues(projectId);
  }

  public List<CustomFieldGroup> getProjectProcessStepCustomValues(Long projectProcessStepId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("objectTypeId", ObjectType.PROCESS_STEP.id);
    params.put("projectProcessStepId", projectProcessStepId);

    List<CustomFieldGroup> fieldGroups = sqlCache.query("customFieldValues.getProjectProcessStepFieldValues", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    handleCustomListOfValue(fieldGroups);

    return fieldGroups;
  }

  private Boolean fieldHasValue (CustomFieldValue cv) {
    return null != cv.getDateValue() || null != cv.getTimestampValue() || null != cv.getBooleanValue() || null != cv.getTextValue()
      || null != cv.getNumericValue() || null != cv.getIntValue() || null != cv.getIntArrayValue();
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

      TypeReference<List<Long>> systemListOptionIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "systemListOptionIds",
          new JsonCollectionDeserializer(systemListOptionIdsRef, objectMapper));
    }
  }
}
