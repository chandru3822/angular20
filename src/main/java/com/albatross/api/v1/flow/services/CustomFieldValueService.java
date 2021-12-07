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
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.sql.DataSource;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomFieldValueService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final SystemListService systemListService;
  private final UserPositionService userPositionService;
  private final ProjectService projectService;
  private final ObjectMapper om;
  private final DataSource dataSource;

  public void handleCustomListOfValue (List<CustomFieldGroup> results, Long companyId) {
    handleCustomListOfValue(results, null, null, companyId);
  }

  public void handleCustomListOfValue (List<CustomFieldGroup> results, Long projectId, Long userId, Long companyId) {
    for(CustomFieldGroup cfg : results) {
      for(CustomFieldValue cv : cfg.getCustomFieldValues()){
        handleCustomListValueForCfv(cv, projectId, userId, companyId);
      }
    }
  }

  private void handleCustomListValueForCfv(CustomFieldValue cv, Long projectId, Long userId, Long companyId) {
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
      List<ListOfValue> listOfValues = systemListService.getSystemListOptionsForCompany(cv.getCompanySystemListId(), true, cv.getSystemListOptionIds(), cv.getIntValue(), companyId);
      cv.setListOfValues(listOfValues);
    }
  }

  public List<CustomFieldGroup> updateCustomFieldValues(List<CustomFieldValue> values, Long sourceId, String objectType) {
    try {
      User currentUser = securityService.getCurrentUser();
      for (CustomFieldValue cfv : values) {
        //if the field came here it was dirty and should always be saved
        HashMap<String, Object> params = new HashMap<>();
        params.put("dateValue", cfv.getDateValue());
        params.put("timestampValue", cfv.getTimestampValue());
        params.put("booleanValue", cfv.getBooleanValue());
        params.put("textValue", cfv.getTextValue());
        params.put("numericValue", cfv.getNumericValue());
        params.put("intValue", cfv.getIntValue());
//        params.put("intArrayValue", cfv.getIntArrayValue());
        params.put("intArrayValue", null != cfv.getIntArrayValue() && cfv.getIntArrayValue().size() > 0 ? createSqlArrayOfType("int", cfv.getIntArrayValue()) : null);
        params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());
        params.put("sourceId", sourceId);
        params.put("userId", currentUser.trueUserId());

        //only used on upsert
        params.put("id", cfv.getId());

        String sql = "customFieldValues." + objectType + ".upsertCustomFieldValue";
        sqlCache.update(sql, params);
      }
      return getCustomFieldGroupsAndValues(objectType, sourceId);
    } catch (Exception e) {
      log.error("CFV: error saving value");
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unknown Error Occurred", new Exception());
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

  public List<CustomFieldGroup> getCustomFieldGroupsAndValues(String objectType, Long id) {
    //todo: @randa - this has a security bug - if a user were to send in a contact id for a company they did not have access to it would still load the data
    try {
      User user;
      Boolean systemAdmin;
      List<UserPosition> userPositions;
      try {
        user = securityService.getCurrentUser();
        systemAdmin = user.getHighestCompanyId() == 1L;
        userPositions = userPositionService.getAllActiveUserPositions(user.getId());
      } catch (Exception e) {
        // Handle values for Cron job call for Genesys contacts
        user = null;
        systemAdmin = false;
        userPositions = null;
      }

      HashMap<String, Object> params = new HashMap<>();
      params.put("objectTypeId", ObjectType.get(objectType).id);
      params.put("sourceId", id);
      params.put("userPositions", null != userPositions && userPositions.size() > 0 ? createSqlArrayOfType("int", userPositions.stream().map(up -> up.getPositionId()).collect(Collectors.toList())) : null);
      params.put("systemAdmin", systemAdmin);
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
        handleCustomListOfValue(fieldGroups, id, user.getId(), companyId);
      } else if (objectType.equals("process_step")) {
        Long projectId = projectService.getProjectIdByProjectProcessStepId(id);
        handleCustomListOfValue(fieldGroups, projectId, user.getId(), companyId);
      } else {
        handleCustomListOfValue(fieldGroups, companyId);
      }

      return fieldGroups;

    } catch (SQLException e) {
      //this error should never happen
      log.error("SQL", e);
      return null;
    }
  }

  public void updateProjectCustomFieldValue(CustomFieldValue cfv, Long projectId, Long customFieldId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("customFieldId", customFieldId);
    params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());
    params.put("intValue", cfv.getIntValue());
    params.put("timestampValue", cfv.getTimestampValue());
    params.put("dateValue", cfv.getDateValue());
    params.put("userId", user.trueUserId());
    sqlCache.update("customFieldValue.project.updateValueUsingCfId", params);
  }

  public List<CustomFieldValue> getUserProfileFields(Long companyId, Long objectTypeId) {
    User user = securityService.getCurrentUser();
    Long realCompanyId = null != companyId ? companyId : user.getCompanyId();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", realCompanyId);
    params.put("objectTypeId", objectTypeId);
    params.put("userId", user.trueUserId());

    List<CustomFieldValue> results = sqlCache.query("customFieldValues.user.getUserProfileFields", params, new CustomFieldValueMapper<>(CustomFieldValue.class, om));

    for(CustomFieldValue cv : results) {
      handleCustomListValueForCfv(cv, null, user.trueUserId(), realCompanyId);
    }

    return results;
  }

  public List<Long> getIdsByPPSId(Long ppsId) {
    return sqlCache.query("customFieldGroupAssignment.getIdsByPPSId", Map.of("ppsId", ppsId), new SingleColumnRowMapper<>(Long.class));
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

      TypeReference<List<WhiteListedPosition>> hiddenWhiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "hiddenWhiteListedPositions",
          new JsonCollectionDeserializer(hiddenWhiteListedPositionsRef, objectMapper));
    }
  }

  public static class CustomFieldValueMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CustomFieldValueMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ListOfValue>> listOfValueRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "listOfValues",
        new JsonCollectionDeserializer(listOfValueRef, objectMapper));

    }
  }
}
