package com.albatross.api.v1.flow.queries.customFieldValues;

public class ProcessStepCfvQuery {

  //language=PostgreSQL
  public final static String getCustomFieldGroupsAndValues = """
    select
                cfg.id,
                cot.id as "companyObjectTypeId",
                cfg.group_name as "groupName",
                cfg.group_order as "groupOrder",
                cfg.event_id as "eventId",
                pps.process_step_id,
                pps.parent_project_process_step_id,
                cfg.unique_behavior_type_id,
                coalesce((
                             SELECT array_to_json(array_agg(row_to_json(fields)))
                             FROM (
                                      select
                                          pcv.id,
                                          p.project_id as "projectId",
                                          p.process_step_id as "processStepId",
                                          case
                                               when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then '(Project)'
                                               when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then '(Contact)'
                                               when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 4 and cfga1.id is not null and cfga.use_parent_data is false then '(Primary)'
                                               when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 4 and cfga.use_parent_data is true then '(Parent)' end                                           as "ancillaryCustomFieldHint",
                                          case
                                              when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 1 then pcfv.date_value
                                              when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 2 then ccfv.date_value
                                              when coalesce(cot1.object_type_id, cotAnc.object_type_id) = 4 then
                                                  case when cfga1.id is not null then pcv1.date_value else pcv.date_value end
                                              end as "dateValue",
                                          case
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.timestamp_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.timestamp_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 4 then
                                                  case when cfga1.id is not null then pcv1.timestamp_value else pcv.timestamp_value end
                                              end as "timestampValue",
                                          case
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.boolean_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.boolean_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 4 then
                                                       case when cfga1.id is not null then pcv1.boolean_value else pcv.boolean_value end
                                              end as "booleanValue",
                                          case
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.text_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.text_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 4 then
                                                       case when cfga1.id is not null then pcv1.text_value else pcv.text_value end
                                              end as "textValue",
                                          case
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.rich_text_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.rich_text_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 4 then
                                                       case when cfga1.id is not null then pcv1.rich_text_value else pcv.rich_text_value end
                                              end as "richTextValue",
                                          case
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.numeric_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.numeric_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 4 then
                                                       case when cfga1.id is not null then pcv1.numeric_value else pcv.numeric_value end
                                              end as "numericValue",
                                          case
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.int_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.int_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 4 then
                                                  case when cfga1.id is not null then pcv1.int_value else pcv.int_value end
                                              end as "intValue",
                                          case
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.int_array_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.int_array_value
                                              when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 4 then
                                                  case when cfga1.id is not null then pcv1.int_array_value else pcv.int_array_value end
                                              end as "intArrayValue",
                                          cfga.custom_field_group_id as "customFieldGroupId",
                                          cfga.id as "customFieldGroupAssignmentId",
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
                                                                     (lov.archived is true AND (lov.id = case
                                                                                                           when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.int_value
                                                                                                           when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.int_value
                                                                                                           when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 4 then
                                                                                                             case when cfga1.id is not null then pcv1.int_value else pcv.int_value end end
                                                                       OR lov.id = any( case
                                                                                          when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 1 then pcfv.int_array_value
                                                                                          when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 2 then ccfv.int_array_value
                                                                                          when coalesce(cotAnc.object_type_id, cot1.object_type_id) = 4 then
                                                                                            case when cfga1.id is not null then pcv1.int_array_value else pcv.int_array_value end end ))))
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
                                               left join flow.project_process_step pps1 on pps1.project_id = pps.project_id and pps1.process_step_id = cfgAnc.process_step_id and pps1.archived is false
                                                                                    and case when cfga.use_parent_data is true then pps1.id = ( select id from flow.pps_parent_hierarchy(pps.id, cfga.ancillary_custom_field_group_assignment_id)) else pps1.main is true end
                                               left join flow.company_process_step_status_type cpsst on cpsst.id = pps1.company_process_step_status_type_id
                                               inner join flow.custom_field cf on cf.id = cfga.custom_field_id or cf.id = cfga1.custom_field_id
                                               inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                                               left join flow.project_process_step_custom_field_value pcv on pcv.custom_field_group_assignment_id = cfga.id and pcv.project_process_step_id = :sourceId
                                               left join flow.project_process_step_custom_field_value pcv1 on pcv1.custom_field_group_assignment_id = cfga.ancillary_custom_field_group_assignment_id and pcv1.project_process_step_id = pps1.id
                                               left join flow.project_process_step p on p.id = :sourceId
                                               left join flow.project proj on proj.id = p.project_id
                                               left join flow.project_custom_field_value pcfv on pcfv.custom_field_group_assignment_id = cfga1.id and pcfv.project_id = p.project_id
                                               left join flow.contact_custom_field_value ccfv on ccfv.custom_field_group_assignment_id = cfga1.id and ccfv.contact_id = proj.contact_id
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
                     inner join flow.project_process_step pps on pps.process_step_id = cfg.process_step_id
                     inner join flow.process_step ps on ps.id = cfg.process_step_id
            where cot.object_type_id = :objectTypeId
              and cfg.archived is not true
              and pps.id = :sourceId
              and cot.company_id = :companyId
            order by cfg.group_order
        """;

  //language=PostgreSQL
  public final static String upsertCustomFieldValue = """
    insert into flow.project_process_step_custom_field_value(project_process_step_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, rich_text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
            select :sourceId, :dateValue::date, (
              select cfga.id
              from flow.custom_field_group_assignment cfga
                inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and (cfg.process_step_id = (select process_step_id from flow.project_process_step where id = :sourceId))
              where cfga.id = :customFieldGroupAssignmentId
                and cfga.archived is not true
              ), :timestampValue::timestamp, :booleanValue, :textValue, :richTextValue, :numericValue, :intValue, :intArrayValue::bigint[], :userId, now(), :userId, now()
            ON CONFLICT (project_process_step_id, custom_field_group_assignment_id)
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
  public final static String getCompanyId = """
    select c.company_id
        from flow.project_process_step pps
        inner join flow.project p on p.id = pps.project_id
        inner join flow.contact c on c.id = p.contact_id
        where pps.id = :sourceId
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
                          (select project_id from flow.project_process_step pps where id = :idToUse::int) as "projectId",
                          pcv.date_value as "dateValue",
                          pcv.timestamp_value as "timestampValue",
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
                          cfga.hidden as "customFieldGroupAssignmentHidden",
                          coalesce(cfga.custom_field_id, cfga1.custom_field_id) as "customFieldId",
                          cfga.field_order as "fieldOrder",
                          cfga.ancillary_custom_field_group_assignment_id as "ancillaryCustomFieldGroupAssignmentId",
                          cfga.use_parent_data as "useParentData",
                          cf.list_of_value_id as "listOfValueId",
                          cf.field_name as "fieldName",
                          cf.allow_now as "allowNow",
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
                                                   (lov.archived is true AND (lov.id = pcv.int_value
                                                     OR lov.id = any(pcv.int_array_value))))
                                            order by
                                              case when cf.sort_list_values_alphabetically is true  then lov.name end,
                                              case when cf.sort_list_values_alphabetically is false then lov.display_order end
                                          ) listOfValues), '[]') AS "listOfValues"
                        from flow.custom_field_group_assignment cfga
                               left join flow.custom_field_group_assignment cfga1 on cfga1.id = cfga.ancillary_custom_field_group_assignment_id
                               inner join flow.custom_field cf on cf.id = cfga.custom_field_id or cf.id = cfga1.custom_field_id
                               inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                               left join flow.project_process_step_custom_field_value pcv on pcv.custom_field_group_assignment_id = cfga1.id and pcv.project_process_step_id = :idToUse
                        where cfga.custom_field_group_id = cfg.id
                          and cfga.archived is not true
                        order by cfga.field_order, cf.field_name
                      ) fields), '[]') AS "customFieldValues"
    from flow.custom_field_group cfg
           inner join flow.process_step_attachment_type pat on cfg.process_step_attachment_type_id = pat.id
           inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
    where pat.attachment_type_id = :attachmentTypeId
      and cfg.archived is not true
      and cot.company_id = :companyId
    order by cfg.group_order
    """;

}
