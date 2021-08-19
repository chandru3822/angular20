package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.CustomField;
import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import com.albatross.api.v1.company.blueraven.models.CustomFieldValue;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
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
public class BlueravenCustomFieldGroupService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<CustomFieldGroup> getCustomFieldGroupAssignmentsByObjectTypeId(Long sourceId, Long objectTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    params.put("objectTypeId", objectTypeId);

    List<CustomFieldGroup> results = sqlCache.query("blueravenCustomFieldGroup.getAssignmentsByObjectType", params, new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));
    return results;
  }

  public Boolean fieldHasValue (CustomFieldValue cv) {
    return null != cv.getId() || null != cv.getDateValue() || null != cv.getTimestampValue() || null != cv.getBooleanValue() || null != cv.getTextValue()
        || null != cv.getNumericValue() || null != cv.getIntValue() || null != cv.getIntArrayValue();
  }

  public void handleSavingCustomFieldValues(List<CustomFieldGroup> groups, Long sourceId){
    User currentUser = securityService.getCurrentUser();
    if (groups != null && groups.size() > 0) {
      for(CustomFieldGroup group : groups) {
        for(CustomFieldValue cfv : group.getCustomFieldValues()) {
          if(fieldHasValue(cfv) && cfv.getValueWasChanged()) {
            HashMap<String, Object> params = new HashMap<>();
            params.put("dateValue", cfv.getDateValue());
            params.put("timestampValue", cfv.getTimestampValue());
            params.put("booleanValue", cfv.getBooleanValue());
            params.put("textValue", cfv.getTextValue());
            params.put("numericValue", cfv.getNumericValue());
            params.put("intValue", cfv.getIntValue());
            params.put("intArrayValue", cfv.getIntArrayValue());
            params.put("sourceId", sourceId);
            params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());

            if(null != cfv.getId()){
              params.put("id", cfv.getId());
              params.put("modifiedById", currentUser.trueUserId());
              sqlCache.update("blueravenCustomFieldGroup.updateCustomFieldValue", params);
            } else {
              params.put("createdById", currentUser.trueUserId());
              sqlCache.update("blueravenCustomFieldGroup.insertCustomFieldValue", params);
            }
          }
        }
      }
    }
  }

  public void bulkHandleSavingCustomFieldValues(List<CustomFieldGroup> groups, List<Long> sourceIds) {
    User currentUser = securityService.getCurrentUser();
    if (groups != null && groups.size() > 0) {
      for(CustomFieldGroup group : groups) {
        for(CustomFieldValue cfv : group.getCustomFieldValues()) {
          if(fieldHasValue(cfv) && cfv.getValueWasChanged()) {
            HashMap<String, Object> params = new HashMap<>();
            params.put("dateValue", cfv.getDateValue());
            params.put("timestampValue", cfv.getTimestampValue());
            params.put("booleanValue", cfv.getBooleanValue());
            params.put("textValue", cfv.getTextValue());
            params.put("numericValue", cfv.getNumericValue());
            params.put("intValue", cfv.getIntValue());
            params.put("intArrayValue", cfv.getIntArrayValue());
            params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());
            params.put("modifiedById", currentUser.trueUserId());
            params.put("createdById", currentUser.trueUserId());

            ArrayList<Long> cfvIds = new ArrayList<>();

            sourceIds.forEach(sourceId -> {
              params.put("sourceId", sourceId);
              Optional<Long> id = sqlCache.get("blueravenCustomFieldGroup.findBySourceId", params, new SingleColumnRowMapper<>(Long.class)); // only returns ids of rows that need to be updated

              if (id.isEmpty()) {
                sqlCache.update("blueravenCustomFieldGroup.insertCustomFieldValue", params);
              } else {
                cfvIds.add(id.get());
              }
            });

            if (cfvIds.size() > 0) {
              params.put("cfvIds", cfvIds);
              sqlCache.update("blueravenCustomFieldGroup.bulkUpdateCustomFieldValues", params);
            }
          }
        }
      }
    }
  }

  public static class CustomFieldGroupMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CustomFieldGroupMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomField>> customFieldTypeRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "customFields",
          new JsonCollectionDeserializer(customFieldTypeRef, objectMapper));

      TypeReference<List<CustomFieldValue>> customFieldValueRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "customFieldValues",
          new JsonCollectionDeserializer(customFieldValueRef, objectMapper));
    }
  }

}
