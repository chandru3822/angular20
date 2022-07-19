package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.processStep.ProcessStep;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEvent;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.*;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@Slf4j
@Service
@RequiredArgsConstructor
public class DataViewService {

  private final SqlCache sqlCache;
  private final SqlArrayService sqlArrayService;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<DataView> getCompanyDataViews() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<DataView> results = sqlCache.query("dataView.getAllForCompany", params, new DataViewMapper<>(DataView.class, om));
    return results;
  }

  public Optional<DataView> getDataView(Long companyId, String tableName) {
    //it would be hard for the dynamic sql to return the id and only 7oaks should be doing this so we will just get it by name
    Map<String, Object> params = new HashMap<>();
    params.put("tableName", tableName);
    params.put("companyId", companyId);
    return sqlCache.get("dataView.getDataView", params, new DataViewMapper<>(DataView.class, om));
  }

  public Optional<DataView> saveDataView(DataView dataView) throws SQLException {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("companyProcessIds", sqlArrayService.createSqlArrayOfType("int", dataView.getCompanyProcessIds()));
    params.put("displayName", dataView.getDisplayName());
    params.put("userId", user.trueUserId());
    Long id;
    if(null != dataView.getId()) {
      id= dataView.getId();
      params.put("id", id);

      sqlCache.update("dataView.update", params);
    } else {
      params.put("viewName", dataView.getViewName());

      id = sqlCache.updateReturningId("dataView.add", params, "id").longValue();

      params.put("id", id);
      sqlCache.query("dataView.addTableForView", params, String.class);
    }

    return getDataView(user.getCompanyId(), dataView.getDisplayName());
  }

  public Optional<DataView> getView(Long viewId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
//    use company id to verify user has access to this view
    params.put("companyId", user.getCompanyId());
    params.put("viewId", viewId);
    Optional<DataView> result = sqlCache.get("dataView.getOne", params, new DataViewMapper<>(DataView.class, om));
    return result;
  }

  public Optional<DataViewChildFieldConfig> saveChildFieldConfig(Long viewId, Long fieldId, DataViewChildFieldConfig childField) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("viewId", viewId);
    params.put("fieldId", fieldId);
    params.put("displayName", childField.getDisplayName());
    params.put("fieldToUpdate", childField.getFieldToUpdate());
    params.put("uniqueBehaviorTypeId", childField.getUniqueBehaviorTypeId());
    params.put("userId", user.trueUserId());

    //we cant remember why we put this in. but leaving here in case we remember
    //Boolean invalid = fieldConflictWithDefault(childField.getFieldToUpdate());

//    if(!invalid) {
    Long id;
      if(childField.getId() != null) {
        id = childField.getId();
        params.put("id", id);
        //user can currently only change the display name
        sqlCache.update("dataView.updateChildFieldConfig", params);
      } else {
        id = sqlCache.updateReturningId("dataView.addChildFieldConfig", params, "id").longValue();
        params.put("id", id);
        //only on insert add child column to table
        sqlCache.query("dataView.addChildColumnToTable", params, String.class);
      }

      return getDataViewChildFieldConfig(id);
//    } else {
//      throw new ResponseStatusException(
//        HttpStatus.BAD_REQUEST,
//        "ERROR: This Field to Update is Reserved by a Default Field",
//        new Exception());
//    }


  }

  public Optional<DataViewChildFieldConfig> getDataViewChildFieldConfig(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<DataViewChildFieldConfig> result = sqlCache.get("dataView.getChildFieldConfig", params, DataViewChildFieldConfig.class);
    return result;
  }

  public Optional<DataViewFieldConfig> saveFieldConfig(Long viewId, DataViewFieldConfig field) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("viewId", viewId);
    params.put("displayName", field.getDisplayName());
    params.put("userId", user.trueUserId());

    Long id;
    if(null != field.getId()) {
      id = field.getId();
      params.put("id", id);
      sqlCache.update("dataView.updateFieldConfig", params);
    } else {
      //we cant remember why we put this in. but leaving here in case we remember
      //Boolean invalid = fieldConflictWithDefault(field.getFieldToUpdate());

//      if(!invalid) {
        params.put("defaultFieldId", field.getDefaultFieldId());
        params.put("processStepEventId", field.getProcessStepEventId());
        params.put("processStepId", field.getProcessStepId());
        params.put("customFieldGroupAssignmentId", field.getCustomFieldGroupAssignmentId());
        params.put("fieldToUpdate", field.getFieldToUpdate());
        params.put("updateFirstValueOnly", null != field.getUpdateFirstValueOnly() && field.getUpdateFirstValueOnly());
        params.put("resetOnNew", null != field.getResetOnNew() && field.getResetOnNew());

        id = sqlCache.updateReturningId("dataView.addFieldConfig", params, "id").longValue();

        HashMap<String, Object> params2 = new HashMap<>();
        params2.put("id", id);
        sqlCache.query("dataView.addColumnToTable", params2, String.class);
//      } else {
//        throw new ResponseStatusException(
//          HttpStatus.BAD_REQUEST,
//          "ERROR: This Field to Update is Reserved by a Default Field",
//          new Exception());
//      }
    }

    return getDataViewFieldConfig(id);
  }

  public Boolean fieldConflictWithDefault(String fieldToUpdate) {
    //this function checks that the fieldToUpdate is not one of the default fields to update
    List<DefaultField> defaultFields = getAllDefaultFields();

    for(DefaultField df : defaultFields) {
      if(df.getColumnName().equals(fieldToUpdate)) {
        return true;
      }
    }

    return false;
  }

  public List<DefaultField> getAllDefaultFields() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());

    return sqlCache.query("dataView.getAllDefaultFields", params, DefaultField.class);
  }

  public Optional<DataViewFieldConfig> getDataViewFieldConfig(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<DataViewFieldConfig> result = sqlCache.get("dataView.getFieldConfig", params, new DataViewFieldConfigMapper<>(DataViewFieldConfig.class, om));
    return result;
  }

  public List<DefaultField> getAvailableDefaultFields(Long viewId) {
    Map<String, Object> params = new HashMap<>();
    params.put("viewId", viewId);
    List<DefaultField> result = sqlCache.query("dataView.getAvailableDefaultFields", params, DefaultField.class);
    return result;
  }

  public List<ProcessStepEvent> getAvailablePsEventsForDefaultField(Long viewId, Long defaultFieldId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("viewId", viewId);
    params.put("companyId", user.getCompanyId());
    params.put("defaultFieldId", defaultFieldId);
    List<ProcessStepEvent> result = sqlCache.query("dataView.getAvailablePsEventsForDefaultField", params, ProcessStepEvent.class);
    return result;
  }

  public List<ProcessStep> getAvailablePsForDefaultField(Long viewId, Long defaultFieldId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("viewId", viewId);
    params.put("companyId", user.getCompanyId());
    params.put("defaultFieldId", defaultFieldId);
    List<ProcessStep> result = sqlCache.query("dataView.getAvailablePsForDefaultField", params, ProcessStep.class);
    return result;
  }

  public List<UniqueBehaviorType> getUniqueBehaviorTypes() {
    List<UniqueBehaviorType> results = sqlCache.query("dataView.getUniqueBehaviorTypes", Collections.emptyMap(), UniqueBehaviorType.class);
    return results;
  }

  public static class DataViewMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public DataViewMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<DataViewFieldConfig>> fieldConfigsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "dataViewFieldConfigs",
        new JsonCollectionDeserializer(fieldConfigsRef, objectMapper));

      TypeReference<List<Long>> companyProcessIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "companyProcessIds",
        new JsonCollectionDeserializer(companyProcessIdsRef, objectMapper));

      TypeReference<List<CompanyProcess>> companyProcessesRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "companyProcesses",
        new JsonCollectionDeserializer(companyProcessesRef, objectMapper));
    }
  }

  public static class DataViewFieldConfigMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public DataViewFieldConfigMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<DataViewChildFieldConfig>> childFieldConfigsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "childFieldConfigs",
        new JsonCollectionDeserializer(childFieldConfigsRef, objectMapper));
    }
  }

}
