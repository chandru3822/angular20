package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import com.albatross.api.v1.company.blueraven.models.CustomFieldValue;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.SqlArrayService;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@PreAuthorize("hasCompanyAccess(3)")
@RequiredArgsConstructor
public class BlueravenCustomFieldValueService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final SqlArrayService sqlArrayService;

  // use this method when only saving dirty cfvs...the other ones are crap and require updating
  // every field
  // also this method doesn't return anything because of how specific types have to return the data
  // todo: maybe a generic return type can be added for object types without special requirements
  // but i dont need that atm so im not doing it. wah
  public void updateCustomFieldValues(
    List<CustomFieldValue> values, Long sourceId, @NonNull ObjectType objectType) {
    try {
      User currentUser = securityService.getCurrentUser();
      for (CustomFieldValue cfv : values) {
        // if the field came here it was dirty and should always be saved
        HashMap<String, Object> params = new HashMap<>();
        params.put("dateValue", cfv.getDateValue());
        params.put("timestampValue", cfv.getTimestampValue());
        params.put("booleanValue", cfv.getBooleanValue());
        params.put("textValue", cfv.getTextValue());
        params.put("richTextValue", cfv.getRichTextValue());
        params.put("numericValue", cfv.getNumericValue());
        params.put("intValue", cfv.getIntValue());
        params.put(
            "intArrayValue",
            null != cfv.getIntArrayValue() && cfv.getIntArrayValue().size() > 0
                ? sqlArrayService.createSqlArrayOfType("int", cfv.getIntArrayValue())
                : null);
        params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());
        params.put("sourceId", sourceId);
        params.put("userId", currentUser.trueUserId());

        // only used on upsert
        params.put("id", cfv.getId());

        // this is actually doing an upsert
        String sql = getInsertSqlStatement(objectType.textValue());
        sqlCache.updateBySql(sql, params);
      }
    } catch (Exception e) {
      log.error("CFV: error saving value: {}", e.getMessage());
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Unknown Error Occurred", new Exception());
    }
  }

  public void handleSavingCustomFieldValuesUsingGroups(
      String objectType, List<CustomFieldGroup> groups, Long sourceId) {
    User currentUser = securityService.getCurrentUser();

    if (groups != null && groups.size() > 0) {
      for (CustomFieldGroup group : groups) {
        for (CustomFieldValue cfv : group.getCustomFieldValues()) {
          if (fieldHasValue(cfv) && cfv.getValueWasChanged()) {
            HashMap<String, Object> params = new HashMap<>();
            params.put("dateValue", cfv.getDateValue());
            params.put("timestampValue", cfv.getTimestampValue());
            params.put("richTextValue", cfv.getRichTextValue());
            params.put("booleanValue", cfv.getBooleanValue());
            params.put("textValue", cfv.getTextValue());
            params.put("numericValue", cfv.getNumericValue());
            params.put("intValue", cfv.getIntValue());
            params.put("intArrayValue", cfv.getIntArrayValue());
            params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());

            if (null != cfv.getId()) {
              params.put("id", cfv.getId());
              params.put("modifiedById", currentUser.trueUserId());

              sqlCache.updateBySql(getUpdateSqlStatement(objectType, false), params);
            } else {
              params.put("sourceId", sourceId);
              params.put("userId", currentUser.trueUserId());

              sqlCache.updateBySql(getInsertSqlStatement(objectType), params);
            }
          }
        }
      }
    }
  }

  public String getUpdateSqlStatement(String objectType, Boolean isMultiple) {
    String sql =
        "update brs."
            + objectType
            + "_custom_field_value"
            + "    set date_value = :dateValue::date,\n"
            + "        timestamp_value = :timestampValue::timestamp,\n"
            + "        boolean_value = :booleanValue,\n"
            + "        text_value = :textValue,\n"
            + "        rich_text_value = :richTextValue,\n"
            + "        numeric_value = :numericValue,\n"
            + "        int_value = :intValue,\n"
            + "        int_array_value = :intArrayValue,\n"
            + "        modified_by_id = :modifiedById,\n"
            + "        date_modified = now()\n";
    if (isMultiple) {
      sql += "    where id in (:cfvIds)";
    } else {
      sql += "    where id = :id";
    }

    return sql;
  }

  public String getInsertSqlStatement(String objectType) {
    // writing this as an upsert so it can be used for new or existing
    String primaryKeyColumn = ObjectType.get(objectType).primaryKeyColumn;
    String sql =
        "insert into brs."
            + objectType
            + "_custom_field_value"
            + "("
            + primaryKeyColumn
            + ", date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, rich_text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)"
            + " values (:sourceId, :dateValue::date, :customFieldGroupAssignmentId, :timestampValue::timestamp, :booleanValue, :textValue, :richTextValue, :numericValue, :intValue, :intArrayValue::bigint[], :userId, now(), :userId, now())"
            + " ON CONFLICT ("
            + primaryKeyColumn
            + ", custom_field_group_assignment_id)\n"
            + "      DO UPDATE\n"
            + "        set date_value = :dateValue::date,\n"
            + "        timestamp_value = :timestampValue::timestamp,\n"
            + "        boolean_value = :booleanValue,\n"
            + "        text_value = :textValue,\n"
            + "        rich_text_value = :richTextValue,\n"
            + "        numeric_value = :numericValue,\n"
            + "        int_value = :intValue,\n"
            + "        int_array_value = :intArrayValue::bigint[],\n"
            + "        modified_by_id = :userId,\n"
            + "        date_modified = now()";
    return sql;
  }

  public Boolean fieldHasValue(CustomFieldValue cv) {
    return null != cv.getId()
        || null != cv.getDateValue()
        || null != cv.getTimestampValue()
        || null != cv.getRichTextValue()
        || null != cv.getBooleanValue()
        || null != cv.getTextValue()
        || null != cv.getNumericValue()
        || null != cv.getIntValue()
        || null != cv.getIntArrayValue();
  }

  public void bulkHandleSavingCustomFieldValuesUsingGroups(
      String objectType, List<CustomFieldGroup> groups, List<Long> sourceIds) {
    User currentUser = securityService.getCurrentUser();

    if (groups != null && groups.size() > 0) {
      for (CustomFieldGroup group : groups) {
        for (CustomFieldValue cfv : group.getCustomFieldValues()) {
          if (fieldHasValue(cfv) && cfv.getValueWasChanged()) {
            HashMap<String, Object> params = new HashMap<>();
            params.put("dateValue", cfv.getDateValue());
            params.put("timestampValue", cfv.getTimestampValue());
            params.put("booleanValue", cfv.getBooleanValue());
            params.put("textValue", cfv.getTextValue());
            params.put("richTextValue", cfv.getRichTextValue());
            params.put("numericValue", cfv.getNumericValue());
            params.put("intValue", cfv.getIntValue());
            params.put("intArrayValue", cfv.getIntArrayValue());
            params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());
            params.put("modifiedById", currentUser.trueUserId());
            params.put("userId", currentUser.trueUserId());

            ArrayList<Long> cfvIds = new ArrayList<>();

            sourceIds.forEach(
                sourceId -> {
                  // the additional source ids are passed into the function
                  // this determines if there is already a record in the custom_field_value table
                  // that needs to be updated
                  // if no, do insert, if yes, add to ids to get updated at the end
                  params.put("sourceId", sourceId);

                  String primaryKeyColumn = ObjectType.get(objectType).primaryKeyColumn;
                  String sql =
                      "select id from brs."
                          + objectType
                          + "_custom_field_value"
                          + " where "
                          + primaryKeyColumn
                          + " = :sourceId "
                          + " and custom_field_group_assignment_id = :customFieldGroupAssignmentId";

                  Optional<Long> id =
                      sqlCache.getBySql(
                          sql,
                          params,
                          new SingleColumnRowMapper<>(
                              Long.class)); // only returns ids of rows that need to be updated

                  if (id.isEmpty()) {
                    sqlCache.updateBySql(getInsertSqlStatement(objectType), params);
                  } else {
                    cfvIds.add(id.get());
                  }
                });

            if (cfvIds.size() > 0) {
              params.put("cfvIds", cfvIds);
              sqlCache.updateBySql(getUpdateSqlStatement(objectType, true), params);
            }
          }
        }
      }
    }
  }
}
