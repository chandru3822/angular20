package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.CustomField;
import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import com.albatross.api.v1.company.blueraven.models.CustomFieldValue;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.CustomFieldService;
import com.albatross.api.v1.flow.services.SystemListService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

@Slf4j
@Service
@PreAuthorize("hasCompanyAccess(3)")
@RequiredArgsConstructor
public class BlueravenCustomFieldGroupService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;
  private final SystemListService systemListService;
  private final CustomFieldService customFieldService;

  public List<CustomFieldGroup> getCustomFieldGroupAssignmentsByObjectTypeId(
      Long sourceId, Long objectTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    params.put("objectTypeId", objectTypeId);

    String objectType = ObjectType.getById(objectTypeId).textValue();

    List<CustomFieldGroup> results =
        sqlCache.queryBySql(
            getCfgaSql(objectType),
            params,
            new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    // default brs custom fields cannot call custom sql that requires projectId, etc
    handleCustomListOfValue(results, 3L, null);

    return results;
  }

  public void handleCustomListOfValue(
      List<CustomFieldGroup> results, Long companyId, Long projectId) {
    for (CustomFieldGroup cfg : results) {
      for (CustomFieldValue cv : cfg.getCustomFieldValues()) {
        handleCustomListValueForCfv(cv, companyId, projectId);
      }
    }
  }

  private void handleCustomListValueForCfv(CustomFieldValue cv, Long companyId, Long projectId) {
    if (null != cv.getCustomFieldSqlKey()) {
      cv.setHasListValues(true);
      String sql = sqlCache.getByKey(cv.getCustomFieldSqlKey());
      if (null != sql) {
        cv.setHasListValues(true);
        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", projectId);
        List<ListOfValue> listOfValues = sqlCache.queryBySql(sql, params, ListOfValue.class);
        cv.setListOfValues(listOfValues);
      }
    } else if (null != cv.getCompanySystemListId()) {
      cv.setHasListValues(true);
      //          cv.getIntValue() is passed so we can add to the sub option list any option already
      // selected but no longer available in the list
      List<ListOfValue> listOfValues =
          systemListService.getSystemListOptionsForCompany(
              cv.getCompanySystemListId(),
              true,
              cv.getSystemListOptionIds(),
              cv.getIntValue(),
              companyId);
      cv.setListOfValues(listOfValues);
    } else if (cv.getFlowCustomFieldId() != null) {
      final List<ListOfValue> listOfValues =
          customFieldService.getCustomFieldListOfValues(cv.getFlowCustomFieldId());
      cv.setHasListValues(true);
      cv.setListOfValues(listOfValues);
    }
  }

  public List<CustomFieldGroup> getCustomFieldGroupsByObjectTypeId(Long objectTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("objectTypeId", objectTypeId);

    return sqlCache.query(
        "blueravenCustomFieldGroup.assignment.getByObjectTypeId",
        params,
        new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));
  }

  public CustomFieldGroup addCustomFieldGroup(
      CustomFieldGroup customFieldGroup, Long objectTypeId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("groupName", customFieldGroup.getGroupName());
    params.put("objectTypeId", objectTypeId);
    params.put("createdById", user.trueUserId());

    Long id =
        sqlCache
            .updateReturningId("blueravenCustomFieldGroup.insertCustomFieldGroup", params, "id")
            .longValue();
    params.put("id", id);

    Optional<CustomFieldGroup> group =
        sqlCache.get(
            "blueravenCustomFieldGroup.assignment.getOne",
            params,
            new CustomFieldGroupMapper<>(CustomFieldGroup.class, om));

    return group.orElse(null);
  }

  public CustomFieldGroup updateCustomFieldGroup(CustomFieldGroup customFieldGroup) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customFieldGroup.getId());
    params.put("groupOrder", customFieldGroup.getGroupOrder());
    params.put("groupName", customFieldGroup.getGroupName());
    params.put("modifiedById", user.trueUserId());

    sqlCache.update("blueravenCustomFieldGroup.updateCustomFieldGroup", params);

    return sqlCache
        .get(
            "blueravenCustomFieldGroup.assignment.getOne",
            params,
            new CustomFieldGroupMapper<>(CustomFieldGroup.class, om))
        .orElse(null);
  }

  public void updateCustomFieldGroups(List<CustomFieldGroup> customFieldGroups) {
    for (CustomFieldGroup cfg : customFieldGroups) {
      updateCustomFieldGroup(cfg);
    }
  }

  public void deleteFieldFromGroup(Long cfgaId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());
    params.put("id", cfgaId);

    sqlCache.update("blueravenCustomFieldGroup.assignment.deleteFieldFromGroup", params);
  }

  public List<CustomField> getAvailableCustomFieldsInGroup(Long companyObjectTypeId, Long groupId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyObjectTypeId", companyObjectTypeId);
    params.put("groupId", groupId);

    return sqlCache.query(
        "blueravenCustomFieldGroup.assignment.getAvailableCustomFieldsInGroup",
        params,
        CustomField.class);
  }

  public CustomField addFieldToGroup(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("customFieldGroupId", customField.getCustomFieldGroupId());
    params.put("customFieldId", customField.getId());
    params.put("createdById", currentUser.trueUserId());
    params.put("fieldOrder", customField.getFieldOrder());
    params.put(
        "ancillaryCustomFieldGroupAssignmentId",
        customField.getAncillaryCustomFieldGroupAssignmentId());

    Long id =
        sqlCache
            .updateReturningId("blueravenCustomFieldGroup.assignment.addFieldToGroup", params, "id")
            .longValue();

    return getCustomField(id);
  }

  public CustomField getCustomField(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache
        .get("blueravenCustomFieldGroup.assignment.getCustomField", params, CustomField.class)
        .orElse(null);
  }

  public void deleteFieldGroup(Long cfgId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());
    params.put("id", cfgId);

    sqlCache.update("blueravenCustomFieldGroup.deleteCustomFieldGroup", params);
  }

  public void updateFieldInGroup(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", customField.getId());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("fieldOrder", customField.getFieldOrder());

    sqlCache.update("blueravenCustomFieldGroup.assignment.updateFieldInGroup", params);
  }

  public void updateFieldsInGroup(List<CustomField> customFields) {
    for (CustomField cf : customFields) {
      updateFieldInGroup(cf);
    }
  }

  public void saveUseParentData(CustomField customField) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("useParentData", customField.getUseParentData());
    params.put("cfgaId", customField.getCustomFieldGroupAssignmentId());

    sqlCache.update("blueravenCustomFieldGroup.assignment.saveUseParentData", params);
  }

  public void updateRequired(CustomField customField) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("cfgaId", customField.getCustomFieldGroupAssignmentId());
    params.put("userId", user.trueUserId());
    params.put("required", null != customField.getRequired() ? customField.getRequired() : false);

    sqlCache.update("blueravenCustomFieldGroup.assignment.saveRequired", params);
  }

  public void saveMinMax(CustomField customField) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("cfgaId", customField.getCustomFieldGroupAssignmentId());
    params.put("userId", user.trueUserId());
    params.put("minValue", customField.getMinValue());
    params.put("maxValue", customField.getMaxValue());

    sqlCache.update("blueravenCustomFieldGroup.assignment.saveMinMax", params);
  }


  public void updateConditionalOnId(CustomField customField){
    User user = securityService.getCurrentUser();

    if(!Objects.equals(customField.getCustomFieldGroupId(), customField.getConditionalOnId())){
      final HashMap<String, Object> params = new HashMap<>();
      params.put("cfgaId", customField.getCustomFieldGroupAssignmentId());
      params.put("modifiedById", user.trueUserId());
      params.put("conditionalOnId", customField.getConditionalOnId());

      sqlCache.update("blueravenCustomFieldGroup.assignment.updateConditionalOnId", params);
    }
  }

  public String getCfgaSql(String objectType) {
    String primaryKeyColumn = ObjectType.get(objectType).primaryKeyColumn;
    String sql =
        "select cfg.id,\n"
            + "       cfg.group_name as \"groupName\",\n"
            + "       cfg.group_order as \"groupOrder\",\n"
            + "       coalesce((\n"
            + "                  SELECT array_to_json(array_agg(row_to_json(fields)))\n"
            + "                  FROM (\n"
            + "                         select cfv.id,\n"
            + "                                cfv."
            + primaryKeyColumn
            + " as \"sourceId\",\n"
            + "                                false as \"valueWasChanged\",\n"
            + "                                cfv.date_value as \"dateValue\",\n"
            + "                                cfv.timestamp_value as \"timestampValue\",\n"
            + "                                cfv.boolean_value as \"booleanValue\",\n"
            + "                                cfv.text_value as \"textValue\",\n"
            + "                                cfv.numeric_value as \"numericValue\",\n"
            + "                                cfv.int_value as \"intValue\",\n"
            + "                                cfv.int_array_value as \"intArrayValue\",\n"
            + "                                cfga.custom_field_group_id as \"customFieldGroupId\",\n"
            + "                                cfga.id as \"customFieldGroupAssignmentId\",\n"
            + "                                cfga.custom_field_id as \"customFieldId\",\n"
            + "                                cfga.field_order as \"fieldOrder\",\n"
            + "                                cfga.required as \"required\",\n"
            + "                                cf.list_of_value_id as \"listOfValueId\",\n"
            + "                                cf.field_name as \"fieldName\",\n"
            + "                                cf.custom_field_sql_key as \"customFieldSqlKey\",\n"
            + "                                cf.company_system_list_id as \"companySystemListId\",\n"
            + "                                cf.system_list_option_ids as \"systemListOptionIds\",\n"
            + "                                cf.company_data_type_id as \"companyDataTypeId\",\n"
            + "                                cf.sort_list_values_alphabetically as \"sortListValuesAlphabetically\",\n"
            + "                                cfg.object_type_id as \"objectTypeId\",\n"
            + "                                cdt.data_type_id as \"dataTypeId\",\n"
            + "                                cdt.has_list_values as \"hasListValues\",\n"
            + "                                coalesce((\n"
            + "                                           SELECT array_to_json(array_agg(row_to_json(listOfValues)))\n"
            + "                                           FROM (\n"
            + "                                                  select lov.id,\n"
            + "                                                         lov.name,\n"
            + "                                                         lov.code,\n"
            + "                                                         lov.parent_id as \"parentId\",\n"
            + "                                                         lov.show_other as \"showOther\",\n"
            + "                                                         lov.display_order as \"displayOrder\"\n"
            + "                                                  from brs.list_of_value lov\n"
            + "                                                  where lov.parent_id is not null\n"
            + "                                                    and lov.parent_id = cf.list_of_value_id\n"
            + "                                                    and lov.archived is not true\n"
            + "                                                  order by\n"
            + "                                                    case when cf.sort_list_values_alphabetically is true  then lov.name end,\n"
            + "                                                    case when cf.sort_list_values_alphabetically is false then lov.display_order end\n"
            + "                                                ) listOfValues), '[]') AS \"listOfValues\"\n"
            + "                         from brs.custom_field_group_assignment cfga\n"
            + "                                inner join brs.custom_field cf on cf.id = cfga.custom_field_id\n"
            + "                                inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id\n"
            + "                                left join brs."
            + objectType
            + "_custom_field_value cfv on cfv.custom_field_group_assignment_id = cfga.id and cfv."
            + primaryKeyColumn
            + " = :sourceId\n"
            + "                         where cfga.custom_field_group_id = cfg.id\n"
            + "                           and cfga.archived is not true\n"
            + "                         order by cfga.field_order, cf.field_name\n"
            + "                       ) fields), '[]') AS \"customFieldValues\"\n"
            + " from brs.custom_field_group cfg\n"
            + "       inner join brs.object_type cot on cot.id = cfg.object_type_id\n"
            + " where cot.id = :objectTypeId\n"
            + "  and cfg.archived is not true\n"
            + " order by cfg.group_order";
    return sql;
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
      bw.registerCustomEditor(
          List.class,
          "customFields",
          new JsonCollectionDeserializer(customFieldTypeRef, objectMapper));

      TypeReference<List<CustomFieldValue>> customFieldValueRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "customFieldValues",
          new JsonCollectionDeserializer(customFieldValueRef, objectMapper));
    }
  }
}
