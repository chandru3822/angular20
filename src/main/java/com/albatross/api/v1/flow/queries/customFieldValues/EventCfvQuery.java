package com.albatross.api.v1.flow.queries.customFieldValues;

public class EventCfvQuery {


  //language=PostgreSQL
  public final static String upsertCustomFieldValue = """
insert into flow.project_process_step_event_custom_field_value(project_process_step_event_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, rich_text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
      select :sourceId, :dateValue::date,
             (select cfga.id
              from flow.custom_field_group_assignment cfga
                     inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and (cfg.event_id = (select pse.event_id from flow.project_process_step_event ppse
                                                                                                                                            inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
                                                                                                                                              where ppse.id = :sourceId))
              where cfga.id = :customFieldGroupAssignmentId
                and cfga.archived is not true), :timestampValue::timestamp, :booleanValue, :textValue, :richTextValue, :numericValue, :intValue, :intArrayValue::bigint[], :userId, now(), :userId, now()
      ON CONFLICT (project_process_step_event_id, custom_field_group_assignment_id)
        DO UPDATE
        set date_value = :dateValue::date,
            timestamp_value = :timestampValue::timestamp,
            boolean_value = :booleanValue,
            text_value = :textValue,
            rich_text_value = :richTextValue,
            numeric_value = :numericValue,
            int_value = :intValue,
            int_array_value = :intArrayValue::bigint[],
            modified_by_id = :userId,
            date_modified = now()
    """;

  //language=PostgreSQL
  public final static String getAncillaryCustomFieldGroupsAndValuesForAttachments = """
select
        cfg.id,
        cfg.group_name as "groupName",
        cfg.company_object_type_tab_id as "companyObjectTypeTabId",
        cfg.group_order as "groupOrder",
        coalesce((
                   SELECT array_to_json(array_agg(row_to_json(fields)))
                   FROM (
                          select
                            pcv.id,
                            (select project_id from flow.project_process_step_event ppse
                              inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
                              where ppse.id = :idToUse::int) as "projectId",
                            pcv.date_value as "dateValue",
                            case when df.id = 10 then ppse.start_time
                                 when df.id = 11 then ppse.end_time
                                 else pcv.timestamp_value end as "timestampValue",
                            pcv.boolean_value as "booleanValue",
                            pcv.text_value as "textValue",
                            pcv.rich_text_value as "richTextValue",
                            pcv.numeric_value as "numericValue",
                            pcv.int_value as "intValue",
                            pcv.int_array_value as "intArrayValue",
                            cfga.custom_field_group_id as "customFieldGroupId",
                            cfga.id as "customFieldGroupAssignmentId",
                            cfga.read_only as "customFieldGroupAssignmentReadOnly",
                            cfga.required,
                            coalesce(cfga.custom_field_id, cfga1.custom_field_id) as "customFieldId",
                            cfga.field_order as "fieldOrder",
                            cfga.ancillary_custom_field_group_assignment_id as "ancillaryCustomFieldGroupAssignmentId",
                            cfga.use_parent_data as "useParentData",
                            cf.list_of_value_id as "listOfValueId",
                            coalesce(cf.field_name, df.field_name) as "fieldName",
                            cf.allow_now as "allowNow",
                            cf.allow_select_self as "allowSelectSelf",
                            case when df.id is not null then true when cf.system_readonly is true then cf.system_readonly else cf.readonly end as "readonly",
                            case when df.id is not null then true else cf.system_readonly end as "systemReadonly",
                            cf.sort_list_values_alphabetically as "sortListValuesAlphabetically",
                            cf.custom_field_sql_key as "customFieldSqlKey",
                            cf.custom_field_sql as "customFieldSql",
                                cf.custom_field_sql_smartlist as "customFieldSqlSmartlist",
                            cf.company_system_list_id as "companySystemListId",
                            cf.system_list_option_ids as "systemListOptionIds",
                            cf.company_data_type_id as "companyDataTypeId",
                            coalesce(cdt.data_type_id, df.data_type_id) as "dataTypeId",
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
                                                     (lov.archived is true AND (lov.id = pcv.int_value
                                                       OR lov.id = any(pcv.int_array_value))))
                                              order by
                                                case when cf.sort_list_values_alphabetically is true  then lov.name end,
                                                case when cf.sort_list_values_alphabetically is false then lov.display_order end
                                            ) listOfValues), '[]') AS "listOfValues"
                          from flow.custom_field_group_assignment cfga
                                 left join flow.custom_field_group_assignment cfga1 on cfga1.id = cfga.ancillary_custom_field_group_assignment_id
                                 left join flow.default_field df on cfga.default_field_id = df.id
                                 left join flow.custom_field cf on cf.id = cfga.custom_field_id or cf.id = cfga1.custom_field_id
                                 left join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                                 left join flow.project_process_step_event_custom_field_value pcv on pcv.custom_field_group_assignment_id = cfga1.id and pcv.project_process_step_event_id = :idToUse
                                 left join flow.project_process_step_event ppse on ppse.id = :idToUse
                          where cfga.custom_field_group_id = cfg.id
                            and cfga.archived is not true
                          order by cfga.field_order, cf.field_name
                        ) fields), '[]') AS "customFieldValues"
      from flow.custom_field_group cfg
             inner join flow.event_attachment_type pat on cfg.event_attachment_type_id = pat.id and pat.event_id = (
                select pse.event_id
                from flow.project_process_step_event ppse
                  inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
               where ppse.id = :idToUse
              )
             inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
      where pat.attachment_type_id = :attachmentTypeId
        and cfg.archived is not true
        and cot.company_id = :companyId
      order by cfg.group_order
    """;

}
