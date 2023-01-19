package com.albatross.api.v1.flow.queries.customFieldValues;

public class UserCfvQuery {

  //language=PostgreSQL
  public final static String getUserProfileFields = """
    select ucv.id,
              ucv.user_id as "userId",
              ucv.date_value as "dateValue",
              ucv.custom_field_group_assignment_id as "customFieldGroupAssignmentId",
              ucv.timestamp_value as "timestampValue",
              ucv.boolean_value as "booleanValue",
              ucv.text_value as "textValue",
              ucv.rich_text_value as "richTextValue",
              ucv.numeric_value as "numericValue",
              ucv.int_value as "intValue",
              ucv.int_array_value as "intArrayValue",
              cfga.custom_field_group_id as "customFieldGroupId",
              cfga.id as "customFieldGroupAssignmentId",
              cfga.read_only as "customFieldGroupAssignmentReadOnly",
              cfga.required,
              cfga.hidden as "customFieldGroupAssignmentHidden",
              cfga.custom_field_id as "customFieldId",
              cfga.field_order as "fieldOrder",
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
              cf.custom_field_sql_key as "customFieldSqlKey",
              cf.custom_field_sql as "customFieldSql",
                                cf.custom_field_sql_smartlist as "customFieldSqlSmartlist",
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
                                         (lov.archived is true AND (lov.id = ucv.int_value
                                           OR lov.id = any( ucv.int_array_value ))))
                                  order by
                                    case when cf.sort_list_values_alphabetically is true  then lov.name end,
                                    case when cf.sort_list_values_alphabetically is false then lov.display_order end
                              ) listOfValues), '[]') AS "listOfValues"
        from flow.custom_field_group_assignment cfga
              inner join flow.custom_field cf on cf.id = cfga.custom_field_id
              inner join flow.custom_field_group cfg2 on cfg2.id = cfga.custom_field_group_id
              inner join flow.company_object_type cot on cfg2.company_object_type_id = cot.id
              inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
              left join flow.user_custom_field_value ucv on ucv.custom_field_group_assignment_id = cfga.id and ucv.user_id = :userId
        where cfga.show_on_user_profile is true
         and cfga.archived is not true
         and cot.object_type_id = :objectTypeId
        order by cfga.field_order, cf.field_name
        """;

  //language=PostgreSQL
  public final static String getCustomFieldGroupsAndValues = """
    select cfg.id,
           cfg.group_name as "groupName",
           cfg.group_order as "groupOrder",
           coalesce((
                        SELECT array_to_json(array_agg(row_to_json(fields)))
                        FROM (
                                 select ucv.id,
                                        ucv.user_id as "userId",
                                        ucv.date_value as "dateValue",
                                        ucv.custom_field_group_assignment_id as "customFieldGroupAssignmentId",
                                        ucv.timestamp_value as "timestampValue",
                                        ucv.boolean_value as "booleanValue",
                                        ucv.text_value as "textValue",
                                        ucv.rich_text_value as "richTextValue",
                                        ucv.numeric_value as "numericValue",
                                        ucv.int_value as "intValue",
                                        ucv.int_array_value as "intArrayValue",
                                        cfga.custom_field_group_id as "customFieldGroupId",
                                        cfga.id as "customFieldGroupAssignmentId",
                                        cfga.read_only as "customFieldGroupAssignmentReadOnly",
                                        cfga.required,
                                        cfga.hidden as "customFieldGroupAssignmentHidden",
                                        cfga.custom_field_id as "customFieldId",
                                        cfga.field_order as "fieldOrder",
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
                                                                 (lov.archived is true AND (lov.id = ucv.int_value
                                                                   OR lov.id = any(ucv.int_array_value))))
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
                                          inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                                          inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                                          left join flow.user_custom_field_value ucv on ucv.custom_field_group_assignment_id = cfga.id and ucv.user_id = :sourceId
                                 where cfga.custom_field_group_id = cfg.id
                                   and cfga.archived is not true
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
        where cot.object_type_id = :objectTypeId
              and cfg.archived is not true
              and cot.company_id = :companyId
            order by cfg.group_order
        """;

  //language=PostgreSQL
  public final static String upsertCustomFieldValue = """
    insert into flow.user_custom_field_value(user_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, rich_text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
        select :sourceId, :dateValue::date,
               (select cfga.id from flow.custom_field_group_assignment cfga
                 inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                  inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id and cot.object_type_id = 3
                   where cfga.id = :customFieldGroupAssignmentId
                 and cfga.archived is not true),
               :timestampValue::timestamp, :booleanValue, :textValue, :richTextValue, :numericValue, :intValue, :intArrayValue::bigint[], :userId, now(), :userId, now()
        ON CONFLICT (user_id, custom_field_group_assignment_id)
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
                                     left join flow.user_custom_field_value pcv on pcv.custom_field_group_assignment_id = cfga1.id and pcv.user_id = :idToUse
                              where cfga.custom_field_group_id = cfg.id
                                and cfga.archived is not true
                              order by cfga.field_order, cf.field_name
                            ) fields), '[]') AS "customFieldValues"
          from flow.custom_field_group cfg
                 inner join flow.user_attachment_type pat on cfg.user_attachment_type_id = pat.id
                 inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
          where pat.attachment_type_id = :attachmentTypeId
            and cfg.archived is not true
            and cot.company_id = :companyId
          order by cfg.group_order
        """;

}
