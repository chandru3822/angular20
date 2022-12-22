package com.albatross.api.v1.flow.queries.customFieldValues;

public class EventCfvQuery {

  //language=PostgreSQL
  public final static String getCustomFieldGroupsAndValues = """
select
          cfg.id,
          cot.id as "companyObjectTypeId",
          cfg.group_name as "groupName",
          cfg.group_order as "groupOrder",
          cfg.event_id as "eventId",
          cfg.unique_behavior_type_id,
          coalesce((
                     SELECT array_to_json(array_agg(row_to_json(fields)))
                     FROM (
                            select
                              pcv.id,
                              pps.project_id as "projectId",
                              pps.process_step_id as "processStepId",
                              coalesce(cot1.object_type_id, cotAnc.object_type_id) as "typehere",
                              case
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 1 then pcfv.date_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 2 then ccfv.date_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is null     then ecfv.date_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is not null then pcv.date_value
                                end as "dateValue",
                              case
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.timestamp_value
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.timestamp_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is null     then ecfv.timestamp_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is not null then pcv.timestamp_value
                                end as "timestampValue",
                              case
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.boolean_value
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.boolean_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is null     then ecfv.boolean_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is not null then pcv.boolean_value
                                end as "booleanValue",
                              case
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.text_value
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.text_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is null     then ecfv.text_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is not null then pcv.text_value
                                end as "textValue",
                              case
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.rich_text_value
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.rich_text_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is null     then ecfv.rich_text_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is not null then pcv.rich_text_value
                                end as "richTextValue",
                              case
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.numeric_value
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.numeric_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is null     then ecfv.numeric_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is not null then pcv.numeric_value
                                end as "numericValue",
                              case
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.int_value
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.int_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is null     then ecfv.int_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is not null then pcv.int_value
                                end as "intValue",
                              case
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.int_array_value
                                when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.int_array_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is null     then ecfv.int_array_value
                                when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is not null then pcv.int_array_value
                                end as "intArrayValue",
                              cfga.custom_field_group_id as "customFieldGroupId",
                              cfga.id as "customFieldGroupAssignmentId",
                              cfga.detail_view as "detailView",
                              cfga.read_only as "customFieldGroupAssignmentReadOnly",
                              cfga.required,
                              cfga.hidden as "customFieldGroupAssignmentHidden",
                              cfga.ancillary_custom_field_group_assignment_id as "ancillaryCustomFieldGroupAssignmentId",
                              cfga.custom_field_id as "customFieldId",
                              cfga.field_order as "fieldOrder",
                              cfga.use_parent_data as "useParentData",
                              cf.list_of_value_id as "listOfValueId",
                              cf.field_name as "fieldName",
                              cf.allow_now as "allowNow",
                              case when cf.system_readonly is true then cf.system_readonly else cf.readonly end as "readonly",
                              cf.system_readonly as "systemReadonly",
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
                                                       (lov.archived is true AND (lov.id = case
                                                                                             when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.int_value
                                                                                             when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.int_value
                                                                                             when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is null     then ecfv.int_value
                                                                                             when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is not null then pcv.int_value end
                                                         OR lov.id = any( case
                                                                            when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.int_array_value
                                                                            when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.int_array_value
                                                                            when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is null     then ecfv.int_array_value
                                                                            when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 6 and pcv.id is not null then pcv.int_array_value
                                                           end ))))
                                                order by
                                                  case when cf.sort_list_values_alphabetically is true  then lov.name end,
                                                  case when cf.sort_list_values_alphabetically is false then lov.display_order end
                                              ) listOfValues), '[]') AS "listOfValues",
                              coalesce((
                                         SELECT array_to_json(array_agg(row_to_json(wlp)))
                                         FROM (
                                                SELECT wlp.id,
                                                       wlp.position_id as "positionId",
                                                       wlp.custom_field_group_assignment_id as "custom_field_group_assignment_id",
                                                       wlp.created_by_id as "createdById",
                                                       wlp.modified_by_id as "modifiedById",
                                                       wlp.archived
                                                FROM flow.white_listed_position wlp
                                                WHERE wlp.custom_field_group_assignment_id = cfga.id
                                                  AND wlp.white_list_type_id = 1
                                                  AND wlp.archived is not true) wlp), '[]') AS "whiteListedPositions",
                              coalesce((
                                         SELECT array_to_json(array_agg(row_to_json(wlp)))
                                         FROM (
                                                SELECT wlp.id,
                                                       wlp.position_id as "positionId",
                                                       wlp.custom_field_group_assignment_id as "custom_field_group_assignment_id",
                                                       wlp.created_by_id as "createdById",
                                                       wlp.modified_by_id as "modifiedById",
                                                       wlp.archived
                                                FROM flow.white_listed_position wlp
                                                WHERE wlp.custom_field_group_assignment_id = cfga.id
                                                  AND wlp.white_list_type_id = 2
                                                  AND wlp.archived is not true) wlp), '[]') AS "hiddenWhiteListedPositions"
                            from flow.custom_field_group_assignment cfga
                                   left join flow.custom_field_group_assignment cfga1 on cfga1.id = cfga.ancillary_custom_field_group_assignment_id
                                   left join flow.custom_field_group cfg1 on cfg1.id = cfga.custom_field_group_id
                                   left join flow.custom_field_group cfgAnc on cfgAnc.id = cfga1.custom_field_group_id
                                   left join flow.company_object_type cot1 on cot1.id = cfg1.company_object_type_id
                                   left join flow.company_object_type cotAnc on cotAnc.id = cfgAnc.company_object_type_id
                                   inner join flow.custom_field cf on cf.id = cfga.custom_field_id or cf.id = cfga1.custom_field_id
                                   inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                                   left join flow.project_process_step_event_custom_field_value ecfv on ecfv.custom_field_group_assignment_id = cfga.id and ecfv.project_process_step_event_id = :sourceId
                                   left join flow.project_process_step pps3 on pps3.process_step_id = cfgAnc.process_step_id and pps3.project_id = pps.project_id
                                   left join flow.project_process_step_custom_field_value pcv on pcv.custom_field_group_assignment_id = cfga1.id and pcv.project_process_step_id = pps3.id
                                   left join flow.project_custom_field_value pcfv on pcfv.custom_field_group_assignment_id = cfga1.id and pcfv.project_id = pps.project_id
                                   left join flow.contact_custom_field_value ccfv on ccfv.custom_field_group_assignment_id = cfga1.id and ccfv.contact_id = p2.contact_id
                            where cfga.custom_field_group_id = cfg.id
                              and cfga.archived is not true
                              and cot1.archived is not true
                              and cotAnc.archived is not true
                              and case when cfga.hidden and :systemAdmin::boolean is false
                                         then cfga.id = ( select wlp2.custom_field_group_assignment_id from flow.white_listed_position wlp2
                                                          where wlp2.custom_field_group_assignment_id = cfga.id
                                                            and wlp2.white_list_type_id = 2
                                                            and wlp2.archived is not true
                                                            and wlp2.position_id = any(:userPositions::bigint[])
                                                          limit 1
                              )
                                       else 1=1 end
                            order by cfga.field_order, cf.field_name
                          ) fields), '[]') AS "customFieldValues"
        from flow.custom_field_group cfg
               inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
               inner join flow.process_step_event pse on pse.event_id = cfg.event_id
               inner join flow.project_process_step_event ppse on ppse.process_step_event_id = pse.id
               inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
               inner join flow.project p2 on p2.id = pps.project_id
               inner join flow.process_step ps on ps.id = pps.process_step_id
        where cot.object_type_id = :objectTypeId
          and cfg.archived is not true
          and ppse.id = :sourceId
          and cot.company_id = :companyId
        order by cfg.group_order
    """;

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
