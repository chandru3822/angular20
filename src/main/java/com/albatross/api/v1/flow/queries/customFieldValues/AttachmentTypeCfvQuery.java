package com.albatross.api.v1.flow.queries.customFieldValues;

public class AttachmentTypeCfvQuery {

  //language=PostgreSQL
  public final static String getCustomFieldGroupsAndValues = """
    select
            cfg.id,
            cfg.group_name as "groupName",
            cfg.group_order as "groupOrder",
            cfg.attachment_type_id as "attachmentTypeId",
            coalesce((
                       SELECT array_to_json(array_agg(row_to_json(fields)))
                       FROM (
                              select
                                acv.id,
                                acv.date_value as "dateValue",
                                acv.timestamp_value as "timestampValue",
                                acv.boolean_value as "booleanValue",
                                acv.text_value as "textValue",
                                acv.rich_text_value as "richTextValue",
                                acv.numeric_value as "numericValue",
                                acv.int_value as "intValue",
                                acv.int_array_value as "intArrayValue",
                                cfga.custom_field_group_id as "customFieldGroupId",
                                cfga.id as "customFieldGroupAssignmentId",
                                cfga.read_only as "customFieldGroupAssignmentReadOnly",
                                cfga.required,
                                cfga.hidden as "customFieldGroupAssignmentHidden",
                                cfga.custom_field_id as "customFieldId",
                                cfga.field_order as "fieldOrder",
                                cfga.ancillary_custom_field_group_assignment_id as "ancillaryCustomFieldGroupAssignmentId",
                                cfga.use_parent_data as "useParentData",
                                cf.list_of_value_id as "listOfValueId",
                                cf.field_name as "fieldName",
                                cf.allow_now as "allowNow",
                                cf.allow_select_self as "allowSelectSelf",
                                case when cf.system_readonly is true then cf.system_readonly else cf.readonly end as "readonly",
                                cf.system_readonly as "systemReadonly",
                                cf.sort_list_values_alphabetically as "sortListValuesAlphabetically",
                                cf.custom_field_sql_key as "customFieldSqlKey",
                                cf.custom_field_sql as "customFieldSql",
                                cf.custom_field_sql_smartlist as "customFieldSqlSmartlist",
                                cf.company_system_list_id as "companySystemListId",
                                cf.system_list_option_ids as "systemListOptionIds",
                                cf.company_data_type_id as "companyDataTypeId",
                                cdt.data_type_id as "dataTypeId",
                                cdt.has_list_values as "hasListValues",
                                coalesce((
                                           SELECT array_to_json(array_agg(row_to_json(listOfValues)))
                                           FROM (
                                                  select
                                                    lov.id,
                                                    lov.name,
                                                    lov.code,
                                                    lov.parent_id,
                                                    lov.display_order,
                                                    lov.archived
                                                  from flow.list_of_value lov
                                                  where lov.parent_id is not null
                                                    and lov.parent_id = cf.list_of_value_id
                                                    and (lov.archived is not true OR
                                                         (lov.archived is true AND (lov.id = acv.int_value
                                                           OR lov.id = any(acv.int_array_value))))
                                                  order by
                                                    case when cf.sort_list_values_alphabetically is true  then lov.name end,
                                                    case when cf.sort_list_values_alphabetically is false then lov.display_order end
                                                ) listOfValues), '[]') AS "listOfValues"
                              from flow.custom_field_group_assignment cfga
                                     inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                                     left join flow.attachment_custom_field_value acv on acv.custom_field_group_assignment_id = cfga.id and acv.attachment_id = :secondarySourceId
                              where cfga.custom_field_group_id = cfg.id
                                and cfga.archived is not true
                              order by cfga.field_order, cf.field_name
                            ) fields), '[]') AS "customFieldValues"
          from flow.custom_field_group cfg
                 inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
          where cot.object_type_id = :objectTypeId
            and cfg.attachment_type_id = :sourceId
            and cfg.archived is not true
            and cot.company_id = :companyId
          order by cfg.group_order
        """;

  //language=PostgreSQL
  public final static String upsertCustomFieldValue = """
    insert into flow.attachment_custom_field_value(attachment_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, rich_text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
        select :secondarySourceId, :dateValue::date,
               (select cfga.id from flow.custom_field_group_assignment cfga
                                      inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                                      inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id and cot.object_type_id = 7
                where cfga.id = :customFieldGroupAssignmentId
                  and cfga.archived is not true), :timestampValue::timestamp, :booleanValue, :textValue, :richTextValue, :numericValue, :intValue, :intArrayValue::int[], :userId, now(), :userId, now()
        ON CONFLICT (attachment_id, custom_field_group_assignment_id)
          DO UPDATE
          set date_value = :dateValue::date,
              timestamp_value = :timestampValue::timestamp,
              boolean_value = :booleanValue,
              text_value = :textValue,
              rich_text_value = :richTextValue,
              numeric_value = :numericValue,
              int_value = :intValue,
              int_array_value = :intArrayValue::int[],
              modified_by_id = :userId,
              date_modified = now()
        """;

  //language=PostgreSQL
  public final static String getCompanyId = """
    select at.company_id
        from flow.attachment_type at
        where at.id = :sourceId
        """;

}
