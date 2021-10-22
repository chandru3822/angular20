-- DROP FUNCTION IF EXISTS flow.get_pps_with_actions_and_requirements(integer);

CREATE OR REPLACE FUNCTION flow.get_pps_with_actions_and_requirements(p_project_process_step_id integer)
  RETURNS json AS
$$
DECLARE
  v_json json;

BEGIN

  SELECT row_to_json(sub_rows)
  INTO v_json
  FROM (
         with reqs as (
--         This query is where we'll join in the already run actions and  exclude those
           select array_agg(psl.process_step_requirement_id) as ids
           from flow.process_step_logic psl
                  inner join flow.process_step_action psa on psa.id = psl.process_step_action_id
                  inner join flow.process_step ps on ps.id = psa.process_step_id
                  inner join flow.project_process_step pps on pps.process_step_id = ps.id
           where
               pps.id = p_project_process_step_id and
             psl.process_step_requirement_id is not null and
             psa.archived is not true and
             psa.trigger_automatically is true and
               psa.action_type_id = 2
         )
         select
           ps.id as "processStepId",
           pps.id as "projectProcessStepId",
           pps.project_id as "projectId",
           pps.process_step_complete_date as "processStepCompleteDate",
           pps.main as "main",
           coalesce(pps.date_modified, pps.date_created) as "lastUpdated",
           cpsst.process_step_status_type_id as "processStepStatusTypeId",
           cpsst.process_step_status_type as "processStepStatusType",
           cpsst.id as "companyProcessStepStatusTypeId",
           ps.process_step_name as "processStepName",
           (
             select row_to_json(o) from (
                                          select
                                            u.id as "userId",
                                            u.first_name as "firstName",
                                            u.last_name as "lastName",
                                            up.id as "userPositionId",
                                            concat(u.first_name, ' ', u.last_name) AS "fullName",
                                            p.position
                                          from flow.user u
                                                 inner join flow.user_position up on up.user_id = u.id
                                                 inner join flow.position p on p.id = up.position_id
                                          where up.id = pps.user_position_id
                                        ) o
           ) as owner,
           psp.id as "processStepProcessId",
           coalesce((select array_to_json(array_agg(row_to_json(r))) from (
                                                                            select
                                                                              id,
                                                                              project_id as "projectId",
                                                                              process_step_requirement_type_id as "processStepRequirementTypeId",
                                                                              process_step_id as "processStepId",
                                                                              operator_type_id as "operatorTypeId",
                                                                              requirement_value as "requirementValue",
                                                                              custom_field_group_assignment_id as "customFieldGroupAssignmentId",
                                                                              company_function_id as "companyFunctionId",
                                                                              requirement_nbr as "requirementNbr",
                                                                              date_created as "dateCreated",
                                                                              date_modified as "dateModified",
                                                                              immutable as "immutable",
                                                                              created_by_id as "createdById",
                                                                              modified_by_id as "modifiedById",
                                                                              archived as "archived",
                                                                              secondary_requirement_value as "secondaryRequirementValue",
                                                                              data_type_requirement_id as "dataTypeRequirementId",
                                                                              list_of_value_id as "listOfValueId",
                                                                              list_of_value_ids as "listOfValueIds",
                                                                              operator_type as "operatorType",
                                                                              process_step_requirement_type as "processStepRequirementType",
                                                                              id as "parentId",
                                                                              custom_value as "customValue",
                                                                              process_step_name as "parentName",
                                                                              field_name as "fieldName",
                                                                              custom_field_sql_key as "customFieldSqlKey",
                                                                              company_system_list_id as "companySystemListId",
                                                                              system_list_option_id as "systemListOptionId",
                                                                              custom_sql_option_id as "customSqlOptionId",
                                                                              time_zone as "timeZone",
                                                                              project_custom_field_value_id as "projectCustomFieldValueId",
                                                                              project_process_step_id as "projectProcessStepId",
                                                                              text_value as "textValue",
                                                                              date_value as "dateValue",
                                                                              timestamp_value as "timestampValue",
                                                                              boolean_value as "booleanValue",
                                                                              numeric_value as "numericValue",
                                                                              reference_process_step_id as "referenceProcessStepId",
                                                                              fail_if_no_reference_step_found as "failIfNoReferenceStepFound",
                                                                              int_value as "intValue",
                                                                              int_array_value as "intArrayValue",
                                                                              system_list_option_ids as "systemListOptionIds",
                                                                              data_type_requirement as "dataTypeRequirement",
                                                                              list_of_value as "listOfValue",
                                                                              list_of_values as list_of_values,
                                                                              data_type_id as "dataTypeId",
                                                                              has_list_values as "hasListValues",
                                                                              company_function_name as "companyFunctionName",
                                                                              function_name as "functionName",
                                                                              requirement_param_dynamic_values as "requirementParamDynamicValues",
                                                                              company_function_params as "companyFunctionParams",
                                                                              available_list_of_values as "availableListOfValues"
                                                                            from flow.get_project_process_step_requirements_with_values(p_project_process_step_id::integer, reqs.ids::integer[])
                                                                          ) r), '[]') as "autoTriggeredActionRequirements",
           coalesce((select array_to_json(array_agg(row_to_json(a))) from (
                                                                            select
                                                                              psa.id,
                                                                              psa.process_step_id as "processStepId",
                                                                              psa.trigger_automatically as "triggerAutomatically",
                                                                              psa.hide_from_mobile as "hidden",
                                                                              psa.hide_from_mobile as "hideFromMobile",
                                                                              psa.hide_from_web as "hideFromWeb",
                                                                              psa.multiple_uses as "multipleUses",
                                                                              psa.remove_process_step_owner as "removeProcessStepOwner",
                                                                              psa.action_name as "actionName",
                                                                              psa.action_type_id as "actionTypeId",
                                                                              psa.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
                                                                              psa.company_project_status_type_id as "companyProjectStatusTypeId",
                                                                              psa.display_order as "displayOrder",
                                                                              psa.always_enabled as "alwaysEnabled",
                                                                              cpsst.process_step_status_type_id as "processStepStatusTypeId",
                                                                              cpsst.process_step_status_type as "processStepStatusType",
                                                                              at.action_type as "actionType",
                                                                              case when
                                                                                     (select id
                                                                                      from flow.project_process_step_action ppsa
                                                                                      where ppsa.project_process_step_id = p_project_process_step_id
                                                                                        and ppsa.process_step_action_id = psa.id limit 1) is null
                                                                                     then false else true end as "alreadyTriggered",
                                                                              coalesce((
                                                                                         SELECT array_to_json(array_agg(row_to_json(logic)))
                                                                                         FROM (
                                                                                                SELECT psl.id,
                                                                                                       psl.archived,
                                                                                                       psl.process_step_requirement_id as "processStepRequirementId",
                                                                                                       psl.operation_type_id as "operationTypeId",
                                                                                                       ot.operation_type as "operationType",
                                                                                                       ot.operation_code as "operationCode",
                                                                                                       psl.created_by_id as "createdById",
                                                                                                       psl.modified_by_id as "modifiedById",
                                                                                                       psr.requirement_nbr as "requirementNbr",
                                                                                                       psr.immutable as "processStepRequirementImmutable",
                                                                                                       psl.sql_order as "sqlOrder"
                                                                                                FROM flow.process_step_logic psl
                                                                                                       left join flow.operation_type ot on ot.id = psl.operation_type_id
                                                                                                       left join flow.process_step_requirement psr on psr.id = psl.process_step_requirement_id
                                                                                                WHERE psl.process_step_action_id = psa.id
                                                                                                  and psl.archived is not true
                                                                                                ORDER BY psl.sql_order ) logic), '[]') AS "processStepLogicList",
                                                                              coalesce((
                                                                                         SELECT array_to_json(array_agg(row_to_json(children)))
                                                                                         FROM (
                                                                                                SELECT psacp.id,
                                                                                                       psacp.archived,
                                                                                                       psacp.process_step_action_id as "processStepActionId",
                                                                                                       psacp.existing_company_process_step_status_type_id as "existingCompanyProcessStepStatusTypeId",
                                                                                                       psacp.initial_company_process_step_status_type_id as "initialCompanyProcessStepStatusTypeId",
                                                                                                       psacp.process_step_id as "processStepId",
                                                                                                       psacp.display_order as "displayOrder",
                                                                                                       psacp.created_by_id as "createdById",
                                                                                                       psacp.modified_by_id as "modifiedById",
                                                                                                       ps.process_step_name as "processStepName",
                                                                                                       (
                                                                                                         select count(*)
                                                                                                         from flow.process_step_action psa
                                                                                                         where
                                                                                                             psa.process_step_id = ps.id and
                                                                                                           psa.trigger_automatically is true and
                                                                                                           psa.archived is not true
                                                                                                       ) as "autoTriggerActionCount"
                                                                                                FROM flow.process_step_action_child_process psacp
                                                                                                       inner join flow.process_step ps on ps.id = psacp.process_step_id
                                                                                                WHERE psacp.process_step_action_id = psa.id
                                                                                                  and psacp.archived is not true
                                                                                                order by psacp.display_order, ps.process_step_name
                                                                                              ) children), '[]') AS "processStepActionChildProcesses",
                                                                              coalesce((
                                                                                         SELECT array_to_json(array_agg(row_to_json(childFn)))
                                                                                         FROM (
                                                                                                SELECT psacf.id,
                                                                                                       psacf.archived,
                                                                                                       psacf.process_step_action_id as "processStepActionId",
                                                                                                       psacf.company_function_id as "companyFunctionId",
                                                                                                       psacf.display_order as "displayOrder",
                                                                                                       psacf.created_by_id as "createdById",
                                                                                                       psacf.modified_by_id as "modifiedById",
                                                                                                       cf.company_function_name as "companyFunctionName",
                                                                                                       coalesce((
                                                                                                                  SELECT array_to_json(array_agg(row_to_json(params)))
                                                                                                                  FROM (
                                                                                                                         select apdv.id,
                                                                                                                                apdv.archived,
                                                                                                                                dfp.db_function_id as "dbFunctionId",
                                                                                                                                dfp.parameter_name as "parameterName",
                                                                                                                                dfp.data_type_id as "dataTypeId",
                                                                                                                                apdv.db_function_param_id as "dbFunctionParamId",
                                                                                                                                apdv.process_step_action_company_function_id as "processStepActionCompanyFunctionId",
                                                                                                                                apdv.dynamic_value as "dynamicValue"
                                                                                                                         from flow.db_function_param dfp
                                                                                                                                left join flow.action_param_dynamic_value apdv on apdv.db_function_param_id = dfp.id and apdv.process_step_action_company_function_id = psacf.id
                                                                                                                         where dfp.db_function_id = cf.db_function_id
                                                                                                                           and dfp.parameter_type_id = 2
                                                                                                                           and apdv.archived is not true
                                                                                                                       ) params), '[]') AS "actionParamDynamicValues"
                                                                                                FROM flow.process_step_action_company_function psacf
                                                                                                       inner join flow.company_function cf on cf.id = psacf.company_function_id
                                                                                                WHERE psacf.process_step_action_id = psa.id
                                                                                                  and psacf.archived is not true
                                                                                                order by psacf.display_order, cf.company_function_name
                                                                                              ) childFn), '[]') AS "processStepActionChildFunctions",
                                                                              coalesce((
                                                                                         SELECT array_to_json(array_agg(row_to_json(links)))
                                                                                         FROM (
                                                                                                SELECT psal.id,
                                                                                                       psal.archived,
                                                                                                       psal.process_step_action_id as "processStepActionId",
                                                                                                       psal.created_by_id as "createdById",
                                                                                                       psal.modified_by_id as "modifiedById",
                                                                                                       l.link,
                                                                                                       l.url
                                                                                                FROM flow.process_step_action_link psal
                                                                                                       inner join flow.link l on l.id = psal.link_id
                                                                                                WHERE psal.process_step_action_id = psa.id
                                                                                                  and psal.archived is not true
                                                                                                order by l.link
                                                                                              ) links), '[]') AS "processStepActionLinks"
                                                                            from flow.process_step_action psa
                                                                                   left join flow.company_process_step_status_type cpsst on cpsst.id = psa.company_process_step_status_type_id
                                                                                   left join flow.company_project_status_type cpst on cpst.id = psa.company_project_status_type_id
                                                                                   inner join flow.action_type at on at.id = psa.action_type_id
                                                                            where psa.process_step_id = ps.id and
                                                                              psa.archived is not true
                                                                            order by psa.display_order
                                                                          ) a), '[]') as "actions",
           coalesce((
                      SELECT array_to_json(array_agg(row_to_json(events)))
                      FROM (
                             SELECT ppse.id,
                                    ppse.archived,
                                    ppse.process_step_event_id as "processStepEventId",
                                    ppse.company_event_status_type_id as "companyEventStatusTypeId",
                                    cest.event_status_type as "eventStatusType",
                                    ppse.created_by_id as "createdById",
                                    ppse.start_time as "startTime",
                                    ppse.end_time as "endTime",
                                    ppse.resource_id as "resourceId",
                                    case when sl.system_list_type_id = 1 then o.org_name else concat(u.first_name, ' ', u.last_name) end as resource,
                                    ppse.modified_by_id as "modifiedById",
                                    pse.event_id as "eventId",
                                    e.event_name as "eventName"
                             FROM flow.project_process_step_event ppse
                                    inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
                                    inner join flow.event e on pse.event_id = e.id
                                    inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
                                    left join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
                                    left join flow.user_position up on up.id = ppse.resource_id
                                    left join flow.user u on u.id = up.user_id
                                    left join flow.org o on o.id = ppse.resource_id
                                    inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
                                    inner join flow.system_list sl on sl.id = csl.system_list_id
                             WHERE ppse.project_process_step_id = pps.id
                               and ppse.archived is not true
                           ) events), '[]') AS "projectProcessStepEvents"
         from reqs, flow.project_process_step pps
                      inner join flow.process_step ps on ps.id = pps.process_step_id
                      inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
                      inner join flow.project p on p.id = pps.project_id
                      inner join flow.company_process cp on cp.id = p.company_process_id
                      left join flow.process_step_process psp on psp.process_step_id = pps.process_step_id and psp.company_process_id = cp.id
         where pps.id = p_project_process_step_id
       ) as sub_rows;
  RETURN v_json;
END;
$$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;


--drop FUNCTION if exists flow.get_project_process_step_event_requirements_with_values(INTEGER, INTEGER[]);

CREATE OR REPLACE FUNCTION flow.get_project_process_step_event_requirements_with_values(p_project_process_step_id INTEGER, p_requirement_ids INTEGER[])

  RETURNS TABLE (id int, project_id int, process_step_requirement_type_id int, process_step_id int, operator_type_id int, requirement_value varchar, custom_field_group_assignment_id int,
                 company_function_id int, reference_process_step_id int, requirement_nbr int, date_created timestamp, date_modified timestamp, immutable boolean, created_by_id int, modified_by_id int,
                 archived boolean, secondary_requirement_value varchar, data_type_requirement_id int, list_of_value_id int, list_of_value_ids json, operator_type varchar,
                 process_step_requirement_type varchar, parent_id int, custom_value boolean, parent_name varchar, field_name varchar, custom_field_sql_key varchar,
                 company_system_list_id int, system_list_option_id int, custom_sql_option_id int, time_zone varchar, project_custom_field_value_id int, project_process_step_id int, text_value text,
                 date_value date, timestamp_value timestamp, boolean_value boolean, numeric_value numeric, int_value int, int_array_value json, system_list_option_ids json,
                 data_type_requirement json, list_of_value json, list_of_values json, data_type_id int, has_list_values boolean, company_function_name varchar, function_name varchar, requirement_param_dynamic_values json,
                 company_function_params json, available_list_of_values json) AS

$BODY$
BEGIN
  RETURN QUERY
    select
      psr.id,
      pps.project_id,
      psr.process_step_requirement_type_id,
      pse.process_step_id,
      psr.operator_type_id,
      psr.requirement_value,
      psr.custom_field_group_assignment_id,
      psr.company_function_id,
      psr.reference_process_step_id,
      psr.requirement_nbr,
      psr.date_created,
      psr.date_modified,
      psr.immutable,
      psr.created_by_id,
      psr.modified_by_id,
      psr.archived,
      psr.secondary_requirement_value,
      psr.data_type_requirement_id,
      psr.list_of_value_id,
      array_to_json(psr.list_of_value_ids) as list_of_value_ids,
      ot.operator_type,
      psrt.process_step_requirement_type,
      ps.id as parent_id,
      case when psr.data_type_requirement_id is null then true else false end as custom_value,
      ps.process_step_name as parent_name,
      cf.field_name,
      cf.custom_field_sql_key,
      cf.company_system_list_id,
      psr.system_list_option_id,
      psr.custom_sql_option_id,
      p.time_zone,
      case when pps1.id is not null then ppscfv1.id else ppscfv.id end as project_custom_field_value_id,
      case when pps1.id is not null then ppscfv1.project_process_step_id else ppscfv.project_process_step_id end as "projectprocessStepId",
      case when psr.process_step_requirement_type_id = 1 then
             case when pps1.id is not null then ppscfv1.text_value else ppscfv.text_value end
           when psr.process_step_requirement_type_id = 3 then
             pcfv.text_value
           when psr.process_step_requirement_type_id = 4 then
             ccfv.text_value
        end as "textValue",
      case when psr.process_step_requirement_type_id = 1 then
             case when pps1.id is not null then ppscfv1.date_value else ppscfv.date_value end
           when psr.process_step_requirement_type_id = 3 then
             pcfv.date_value
           when psr.process_step_requirement_type_id = 4 then
             ccfv.date_value
        end as "dateValue",
      case when psr.process_step_requirement_type_id = 1 then
             case when pps1.id is not null then ppscfv1.timestamp_value else ppscfv.timestamp_value end
           when psr.process_step_requirement_type_id = 3 then
             pcfv.timestamp_value
           when psr.process_step_requirement_type_id = 4 then
             ccfv.timestamp_value
        end as "timestampValue",
      case when psr.process_step_requirement_type_id = 1 then
             case when pps1.id is not null then ppscfv1.boolean_value else ppscfv.boolean_value end
           when psr.process_step_requirement_type_id = 3 then
             pcfv.boolean_value
           when psr.process_step_requirement_type_id = 4 then
             ccfv.boolean_value
        end as "booleanValue",
      case when psr.process_step_requirement_type_id = 1 then
             case when pps1.id is not null then ppscfv1.numeric_value else ppscfv.numeric_value end
           when psr.process_step_requirement_type_id = 3 then
             pcfv.numeric_value
           when psr.process_step_requirement_type_id = 4 then
             ccfv.numeric_value
        end as "numericValue",
      case when psr.process_step_requirement_type_id = 1 then
             case when pps1.id is not null then ppscfv1.int_value else ppscfv.int_value end
           when psr.process_step_requirement_type_id = 3 then
             pcfv.int_value
           when psr.process_step_requirement_type_id = 4 then
             ccfv.int_value
        end as "intValue",
      case when psr.process_step_requirement_type_id = 1 then
             case when pps1.id is not null then coalesce(array_to_json(ppscfv1.int_array_value), '[]') else coalesce(array_to_json(ppscfv.int_array_value), '[]') end
           when psr.process_step_requirement_type_id = 3 then
             coalesce(array_to_json(pcfv.int_array_value), '[]')
           when psr.process_step_requirement_type_id = 4 then
             coalesce(array_to_json(ccfv.int_array_value), '[]')
        end as "intArrayValue",
      array_to_json(cf.system_list_option_ids) as system_list_option_ids,
      (select json_build_object(
                'id', dtr.id,
                'dataTypeValue', dtr.data_type_value,
                'secondaryRequirement', dtr.secondary_requirement
                ))                                     as data_type_requirement,
      (select json_build_object(
                'id', lov.id,
                'name', lov.name
                ))                                     as list_of_value,
      coalesce((
                 SELECT array_to_json(array_agg(row_to_json(lov)))
                 FROM (
                        select lv.id,
                               lv.name
                        from flow.list_of_value lv
                        where lv.id = any (psr.list_of_value_ids)
                      ) lov), '[]') AS list_of_values,
      coalesce(cdt.data_type_id, df.return_data_type_id) as data_type_id,
      cdt.has_list_values,
      cfn.company_function_name,
      df.function_name,
      coalesce((
                 SELECT array_to_json(array_agg(row_to_json(params)))
                 FROM (
                        select rpdv.id,
                               rpdv.archived,
                               dfp.db_function_id as "dbFunctionId",
                               dfp.parameter_name as "parameterName",
                               dfp.data_type_id as "dataTypeId",
                               rpdv.db_function_param_id as "dbFunctionParamId",
                               rpdv.process_step_requirement_id as "processStepRequirementId",
                               rpdv.dynamic_value as "dynamicValue"
                        from flow.db_function_param dfp
                               left join flow.requirement_param_dynamic_value rpdv on rpdv.db_function_param_id = dfp.id and rpdv.process_step_requirement_id = psr.id
                        where dfp.db_function_id = cfn.db_function_id
                          and dfp.parameter_type_id = 2
                          and rpdv.archived is not true
                      ) params), '[]') AS requirement_param_dynamic_values,
      coalesce((
                 SELECT array_to_json(array_agg(row_to_json(params)))
                 FROM (
                        select dfp.data_type_id as "dataTypeId",
                               dfp.parameter_type_id as "parameterTypeId",
                               dfp.display_order as "displayOrder",
                               ppscfv.text_value as "textValue",
                               ppscfv.date_value as "dateValue",
                               ppscfv.timestamp_value as "timestampValue",
                               ppscfv.boolean_value as "booleanValue",
                               ppscfv.numeric_value as "numericValue",
                               ppscfv.int_value as "intValue",
                               dfp.system_value_id as "systemValueId",
                               rpdv.dynamic_value as "dynamicValue"
                        from flow.db_function_param dfp
                               left join flow.company_function_param cfp on cfp.db_function_param_id = dfp.id and cfp.archived is not true
                               left join flow.system_value sv on sv.id = dfp.system_value_id
                               left join flow.requirement_param_dynamic_value rpdv on rpdv.db_function_param_id = dfp.id and rpdv.process_step_requirement_id = psr.id
                               left join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = cfp.custom_field_group_assignment_id
                        where dfp.db_function_id = df.id
                          and dfp.archived is not true
                        order by dfp.display_order) params), '[]') AS "companyFunctionParams",
      case when cf.list_of_value_id is not null then
             coalesce((
                        SELECT array_to_json(array_agg(row_to_json(lov)))
                        FROM (
                               select lv.id,
                                      lv.name
                               from flow.list_of_value lv
                               where lv.parent_id = cf.list_of_value_id
                             ) lov), '[]')
           when cf.company_system_list_id is not null then
             coalesce((
                        SELECT array_to_json(array_agg(row_to_json(lov)))
                        FROM (
                               select * from flow.get_system_list_options(cf.company_id, cf.company_system_list_id, true, cf.system_list_option_ids)
                             ) lov), '[]')
           else '[]' end AS available_list_of_values
    from flow.process_step_event_requirement psr
           inner join flow.process_step_event pse on psr.process_step_event_id = pse.id
           inner join flow.operator_type ot on ot.id = psr.operator_type_id
           inner join flow.process_step_requirement_type psrt on psrt.id = psr.process_step_requirement_type_id
           inner join flow.project_process_step pps on pps.process_step_id = pse.process_step_id
           inner join flow.project p on p.id = pps.project_id
           left join flow.custom_field_group_assignment cfga on cfga.id = psr.custom_field_group_assignment_id
           left join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
           left join flow.project_process_step pps1 on pps1.project_id = pps.project_id and pps1.process_step_id = cfg.process_step_id and pps1.main is true and pps1.archived is false
           left join flow.custom_field cf on cf.id = cfga.custom_field_id
           left join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
           left join flow.process_step ps on ps.id = cfg.process_step_id
           left join flow.company_function cfn on cfn.id = psr.company_function_id
           left join flow.db_function df on df.id = cfn.db_function_id
           left join flow.data_type_requirement dtr on dtr.id = psr.data_type_requirement_id
           left join flow.list_of_value lov on lov.id = psr.list_of_value_id
           left join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = cfga.id
           left join flow.project_process_step_custom_field_value ppscfv1 on ppscfv1.custom_field_group_assignment_id = cfga.id and ppscfv1.project_process_step_id = pps1.id and ppscfv1.archived is not true
           left join flow.project_custom_field_value pcfv on pcfv.custom_field_group_assignment_id = cfga.id and pcfv.project_id = pps.project_id and pcfv.archived is not true
           left join flow.contact_custom_field_value ccfv on ccfv.custom_field_group_assignment_id = cfga.id and ccfv.contact_id = p.contact_id and ccfv.archived is not true
    where
      psr.archived is not true and
      cfga.archived is not true and
        pps.id = p_project_process_step_id and
        psr.id = any (array[p_requirement_ids]::int[])
    order by psr.requirement_nbr;

END;
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100
  ROWS 1000;




CREATE OR REPLACE function flow.migrate_fields_to_group(p_to_custom_field_group_id integer,
                                                        p_custom_field_group_assignment_id integer,
                                                        p_field_order integer)
  returns void as
$$
BEGIN
  update flow.custom_field_group_assignment
  set custom_field_group_id = p_to_custom_field_group_id,
      field_order = p_field_order
  where id = p_custom_field_group_assignment_id;

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_group_to_event(p_custom_field_group_id integer, p_event_type_id integer,p_group_order integer)
  returns void as
$$
BEGIN


  with update_data as (
    select cfg.id,
           cfg.group_name,
           (select cot.id
            from flow.company_object_type cot
                   inner join flow.object_type ot on cot.object_type_id = ot.id
            where cot.company_id = 3
              and ot.object_type = 'Event') company_object_type_id,
           p_event_type_id                  event_id
    from flow.custom_field_group cfg
           inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
           inner join flow.object_type ot on cot.object_type_id = ot.id
    where cfg.id = p_custom_field_group_id
      and cot.company_id = 3)
  update flow.custom_field_group cfg3
  set company_object_type_id = ud.company_object_type_id,
      event_id               = ud.event_id,
      process_step_id        = null,
      group_order            = p_group_order
  from update_data ud
  where ud.id = cfg3.id;

  update flow.custom_field_group_assignment
  set archived = true
  where custom_field_group_id = p_custom_field_group_id
    and ancillary_custom_field_group_assignment_id is not null;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_insert_event_custom_field_value(p_event_id integer,
                                                                        p_cfga_id integer,
                                                                        p_timestamp timestamp,
                                                                        p_text text,
                                                                        p_int_array integer[],
                                                                        p_date_created timestamp,
                                                                        p_date_modified timestamp,
                                                                        p_created_by_id integer,
                                                                        p_modified_by_id integer,
                                                                        p_new_cfga_id boolean default false,
                                                                        p_event_type_id integer default null)
  returns void as
$$

BEGIN
  --raise notice 'p_event_id = %  p_project_process_step_id = % p_cfga_id = % p_event_type_id = %',p_event_id,p_project_process_step_id,p_cfga_id,p_event_type_id;
  insert into flow.project_process_step_event_custom_field_value(project_process_step_event_id,
                                                                 custom_field_group_assignment_id,
                                                                 timestamp_value,
                                                                 text_value,
                                                                 int_array_value,
                                                                 date_created,
                                                                 date_modified, created_by_id, modified_by_id)
  values (p_event_id,
          case
            when p_new_cfga_id is true and p_cfga_id is not null then
              (select cfga.id
               from flow.custom_field_group_assignment cfga
                      inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                      inner join flow.event e on e.id = cfg.event_id and e.id = p_event_type_id
               where migrated_cfga_id = p_cfga_id)
            else p_cfga_id end,
          p_timestamp,
          p_text,
          p_int_array,
          p_date_created,
          p_date_modified,
          p_created_by_id,
          p_modified_by_id);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_insert_new_group(p_group_name varchar,
                                                         p_group_order integer,
                                                         p_process_step_id integer,
                                                         p_event_type_id integer)
  returns integer as
$$
declare
  v_company_object_type_id integer;
  v_cfg_id                 integer;
BEGIN

  if p_event_type_id is not null then
    select cot.id
    into v_company_object_type_id
    from flow.company_object_type cot
           inner join flow.object_type ot on cot.object_type_id = ot.id
    where cot.company_id = 3
      and ot.object_code = 'EVENT';
  else
    select cot.id
    into v_company_object_type_id
    from flow.company_object_type cot
           inner join flow.object_type ot on cot.object_type_id = ot.id
    where cot.company_id = 3
      and ot.object_code = 'PROCESS_STEP';
  end if;

  insert into flow.custom_field_group(group_name, company_object_type_id, group_order,
                                      process_step_id, event_id, date_created,
                                      created_by_id)
  values (p_group_name, v_company_object_type_id, p_group_order, p_process_step_id, p_event_type_id, now(), 2350555)
  returning id into v_cfg_id;

  return v_cfg_id;
END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_project_process_step_event_custom_field_value(p_event_id integer,
                                                                                      p_group_id integer,
                                                                                      p_project_process_step_id integer,
                                                                                      p_cfga_id integer,
                                                                                      p_new_cfga_id boolean default false,
                                                                                      p_event_type_id integer default null)
  returns void as
$$
declare
  v_cfga_ids integer[];
BEGIN
  if p_group_id is not null then
    select array_agg(cfga.id)::integer[]
    into v_cfga_ids
    from flow.custom_field_group_assignment cfga
    where cfga.custom_field_group_id = p_group_id
      and cfga.archived is false and cfga.ancillary_custom_field_group_assignment_id is null;
  else
    select array_agg(cfga.id)::integer[]
    into v_cfga_ids
    from flow.custom_field_group_assignment cfga
    where cfga.id = p_cfga_id;
  end if;
--raise notice 'p_event_id = %  p_project_process_step_id = % p_cfga_id = % p_event_type_id = %',p_event_id,p_project_process_step_id,p_cfga_id,p_event_type_id;
  insert into flow.project_process_step_event_custom_field_value(project_process_step_event_id,
                                                                 custom_field_group_assignment_id,
                                                                 date_value, timestamp_value, boolean_value,
                                                                 text_value,
                                                                 numeric_value, int_value, int_array_value,
                                                                 date_created,
                                                                 date_modified, created_by_id, modified_by_id,
                                                                 migrate_project_process_step_custom_field_value_id)
    (select p_event_id,
            case when p_new_cfga_id is true and p_cfga_id is not null then
                   (select cfga.id
                    from flow.custom_field_group_assignment cfga
                           inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                           inner join flow.event e on e.id = cfg.event_id and e.id = p_event_type_id
                    where migrated_cfga_id = p_cfga_id) else ppscfv2.custom_field_group_assignment_id end,
            ppscfv2.date_value,
            ppscfv2.timestamp_value,
            ppscfv2.boolean_value,
            ppscfv2.text_value,
            ppscfv2.numeric_value,
            ppscfv2.int_value,
            ppscfv2.int_array_value,
            ppscfv2.date_created,
            ppscfv2.date_modified,
            ppscfv2.created_by_id,
            ppscfv2.modified_by_id,
            ppscfv2.id
     from flow.project_process_step_custom_field_value ppscfv2
     where ppscfv2.custom_field_group_assignment_id = any (v_cfga_ids)
       and ppscfv2.project_process_step_id = p_project_process_step_id
    );

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_schedule_ac_compressor_relocation_to_events(p_event_id integer,
                                                                                    p_project_process_step_id integer)
  returns void as
$$
declare
  v_ac_compressor_holding_id integer;
  v_verify_ac_compressor_id  integer;
BEGIN
  select id
  into v_ac_compressor_holding_id
  from flow.project_process_step
  where process_step_id = 214
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_ac_compressor_holding_id is not null then
    select id
    into v_verify_ac_compressor_id
    from flow.project_process_step
    where process_step_id = 147
      and parent_project_process_step_id = v_ac_compressor_holding_id
    order by project_process_step.date_created desc
    limit 1;
  end if;





  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19070);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17504);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17327);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19509);

  if v_verify_ac_compressor_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_ac_compressor_id,
                                                                       552);
  end if;


  --this update parent to the appropriate parent
  if v_ac_compressor_holding_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_ac_compressor_holding_id
      and case
            when v_verify_ac_compressor_id is not null then
                id != v_verify_ac_compressor_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_ac_compressor_holding_id;
  end if;

  if v_verify_ac_compressor_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_ac_compressor_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_ac_compressor_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_schedule_ahj_inspection_nsc_to_events(p_event_id integer,
                                                                              p_project_process_step_id integer)
  returns void as
$$

declare
  v_schedule_inspection_with_ahj_id      integer;
  v_pending_ahj_inspection_id            integer;
  v_need_ahj_verification_pps_id         integer;
  v_ahj_inspection_nsc_event_id          integer;
  v_inspection_pending_reschedule_needed timestamp;
  v_inspection_pending_reschedule_reason text;
  v_inspection_pending_category          integer[];
  v_inspection_need_reschedule_needed    timestamp;
  v_inspection_need_reschedule_reason    text;
  v_inspection_need_category             integer[];
  v_need_id                              integer;
  v_need_reason_id                       integer;
  v_need_category_id                     integer;
  v_date_created_pending_needed          timestamp;
  v_date_created_pending_reason          timestamp;
  v_date_created_pending_cat             timestamp;
  v_date_created_need_reason             timestamp;
  v_date_created_need_needed             timestamp;
  v_date_created_need_cat                timestamp;
  v_date_modified_pending_needed         timestamp;
  v_date_modified_pending_reason         timestamp;
  v_date_modified_pending_cat            timestamp;
  v_date_modified_need_reason            timestamp;
  v_date_modified_need_needed            timestamp;
  v_date_modified_need_cat               timestamp;
  v_created_by_id_pending_needed         integer;
  v_created_by_id_pending_reason         integer;
  v_created_by_id_pending_cat            integer;
  v_created_by_id_need_reason            integer;
  v_created_by_id_need_needed            integer;
  v_created_by_id_need_cat               integer;
  v_modified_by_id_pending_needed        integer;
  v_modified_by_id_pending_reason        integer;
  v_modified_by_id_pending_cat           integer;
  v_modified_by_id_need_reason           integer;
  v_modified_by_id_need_needed           integer;
  v_modified_by_id_need_cat              integer;
BEGIN
  select id
  into v_schedule_inspection_with_ahj_id
  from flow.project_process_step
  where process_step_id = 204
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  select id
  into v_pending_ahj_inspection_id
  from flow.project_process_step
  where process_step_id = 152
    and parent_project_process_step_id = v_schedule_inspection_with_ahj_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_ahj_inspection_id is null then
    select id
    into v_pending_ahj_inspection_id
    from flow.project_process_step
    where process_step_id = 152
      and parent_project_process_step_id = p_project_process_step_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_ahj_inspection_id is not null then
    select id
    into v_need_ahj_verification_pps_id
    from flow.project_process_step
    where process_step_id = 46
      and parent_project_process_step_id = v_pending_ahj_inspection_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_need_ahj_verification_pps_id is  null then
    select id
    into v_need_ahj_verification_pps_id
    from flow.project_process_step
    where process_step_id = 46
      and parent_project_process_step_id = p_project_process_step_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_ahj_inspection_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_pending_reschedule_needed,
      v_date_created_pending_needed,v_date_modified_pending_needed,
      v_created_by_id_pending_needed,v_modified_by_id_pending_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1397
      and project_process_step_id = v_pending_ahj_inspection_id;
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_pending_reschedule_reason,
      v_date_created_pending_reason,v_date_modified_pending_reason,
      v_created_by_id_pending_reason,v_modified_by_id_pending_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1398
      and project_process_step_id = v_pending_ahj_inspection_id;
    select int_array_value, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_pending_category,v_date_created_pending_cat,v_date_modified_pending_cat,
      v_created_by_id_pending_cat,v_modified_by_id_pending_cat
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 21608
      and project_process_step_id = v_pending_ahj_inspection_id;
  end if;

  if v_need_ahj_verification_pps_id is not null then
    select timestamp_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_need_reschedule_needed,v_need_id,
      v_date_created_need_needed,v_date_modified_need_needed,
      v_created_by_id_need_needed,v_modified_by_id_need_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19027
      and project_process_step_id = v_need_ahj_verification_pps_id;
    select text_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_need_reschedule_reason,v_need_reason_id,
      v_date_created_need_reason,v_date_modified_need_reason,
      v_created_by_id_need_reason,v_modified_by_id_need_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19028
      and project_process_step_id = v_need_ahj_verification_pps_id;
    select int_array_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_need_category,v_need_category_id,
      v_date_created_need_cat,v_date_modified_need_cat,
      v_created_by_id_need_cat,v_modified_by_id_need_cat
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 21609
      and project_process_step_id = v_need_ahj_verification_pps_id;
  end if;

  select id
  into v_ahj_inspection_nsc_event_id
  from flow.event
  where temp_cfg_id = 57;

  -- this migrates scheduling complete

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     334,
                                                                     p_project_process_step_id,
                                                                     null);


  if v_need_ahj_verification_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       153, true, v_ahj_inspection_nsc_event_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       152, true, v_ahj_inspection_nsc_event_id);

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       998, true, v_ahj_inspection_nsc_event_id);
  end if;

  if v_inspection_need_reschedule_needed is not null or v_inspection_pending_reschedule_needed is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         19027,
                                                         coalesce(v_inspection_need_reschedule_needed,
                                                                  v_inspection_pending_reschedule_needed)::timestamp,
                                                         null::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_need_needed, v_date_created_pending_needed),
                                                         coalesce(v_date_modified_need_needed, v_date_modified_pending_needed),
                                                         coalesce(v_created_by_id_need_needed, v_created_by_id_pending_needed),
                                                         coalesce(v_modified_by_id_need_needed,
                                                                  v_modified_by_id_pending_needed), true,
                                                         v_ahj_inspection_nsc_event_id);
  end if;
  if v_inspection_need_reschedule_reason is not null or v_inspection_pending_reschedule_reason is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         19028,
                                                         null::timestamp,
                                                         coalesce(v_inspection_need_reschedule_reason,
                                                                  v_inspection_pending_reschedule_reason)::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_need_reason, v_date_created_pending_reason),
                                                         coalesce(v_date_modified_need_reason, v_date_modified_pending_reason),
                                                         coalesce(v_created_by_id_need_reason, v_created_by_id_pending_reason),
                                                         coalesce(v_modified_by_id_need_reason,
                                                                  v_modified_by_id_pending_reason), true,
                                                         v_ahj_inspection_nsc_event_id);
  end if;
  if v_inspection_need_category is not null or v_inspection_pending_category is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         21609,
                                                         null::timestamp,
                                                         null::text,
                                                         coalesce(v_inspection_need_category, v_inspection_pending_category)::integer[],
                                                         coalesce(v_date_created_need_cat, v_date_created_pending_cat),
                                                         coalesce(v_date_modified_need_cat, v_date_modified_pending_cat),
                                                         coalesce(v_created_by_id_need_cat, v_created_by_id_pending_cat),
                                                         coalesce(v_modified_by_id_need_cat, v_modified_by_id_pending_cat),
                                                         true, v_ahj_inspection_nsc_event_id);
  end if;


--this update parent to the appropriate parent
  if v_schedule_inspection_with_ahj_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_schedule_inspection_with_ahj_id
      and case
            when v_pending_ahj_inspection_id is not null then
                id != v_pending_ahj_inspection_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_schedule_inspection_with_ahj_id;
  end if;

  if v_pending_ahj_inspection_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_ahj_inspection_id
      and case
            when v_need_ahj_verification_pps_id is not null then
                id != v_need_ahj_verification_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_ahj_inspection_id;
  end if;

  if v_need_ahj_verification_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_need_ahj_verification_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_need_ahj_verification_pps_id;
  end if;



END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_ahj_inspection_sc_to_events(p_event_id integer,
                                                                             p_project_process_step_id integer)
  returns void as
$$

declare
  v_schedule_inspection_with_ahj_id      integer;
  v_pending_ahj_inspection_id            integer;
  v_need_ahj_verification_pps_id         integer;
  v_date_created_pending_needed          timestamp;
  v_date_created_pending_reason          timestamp;
  v_date_created_pending_cat             timestamp;
  v_date_created_need_reason             timestamp;
  v_date_created_need_needed             timestamp;
  v_date_created_need_cat                timestamp;
  v_date_modified_pending_needed         timestamp;
  v_date_modified_pending_reason         timestamp;
  v_date_modified_pending_cat            timestamp;
  v_date_modified_need_reason            timestamp;
  v_date_modified_need_needed            timestamp;
  v_date_modified_need_cat               timestamp;
  v_created_by_id_pending_needed         integer;
  v_created_by_id_pending_reason         integer;
  v_created_by_id_pending_cat            integer;
  v_created_by_id_need_reason            integer;
  v_created_by_id_need_needed            integer;
  v_created_by_id_need_cat               integer;
  v_modified_by_id_pending_needed        integer;
  v_modified_by_id_pending_reason        integer;
  v_modified_by_id_pending_cat           integer;
  v_modified_by_id_need_reason           integer;
  v_modified_by_id_need_needed           integer;
  v_modified_by_id_need_cat              integer;
  v_inspection_pending_reschedule_needed timestamp;
  v_inspection_pending_reschedule_reason text;
  v_inspection_pending_category          integer[];
  v_inspection_need_reschedule_needed    timestamp;
  v_inspection_need_reschedule_reason    text;
  v_inspection_need_category             integer[];
  v_need_id                              integer;
  v_need_reason_id                       integer;
  v_need_category_id                     integer;
BEGIN

  select id
  into v_schedule_inspection_with_ahj_id
  from flow.project_process_step
  where process_step_id = 204
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  select id
  into v_pending_ahj_inspection_id
  from flow.project_process_step
  where process_step_id = 152
    and parent_project_process_step_id = v_schedule_inspection_with_ahj_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_ahj_inspection_id is null then
    select id
    into v_pending_ahj_inspection_id
    from flow.project_process_step
    where process_step_id = 152
      and parent_project_process_step_id = p_project_process_step_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_ahj_inspection_id is not null then
    select id
    into v_need_ahj_verification_pps_id
    from flow.project_process_step
    where process_step_id = 46
      and parent_project_process_step_id = v_pending_ahj_inspection_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_need_ahj_verification_pps_id is null then
    select id
    into v_need_ahj_verification_pps_id
    from flow.project_process_step
    where process_step_id = 46
      and parent_project_process_step_id = p_project_process_step_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_ahj_inspection_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_pending_reschedule_needed,
      v_date_created_pending_needed,v_date_modified_pending_needed,
      v_created_by_id_pending_needed,v_modified_by_id_pending_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1397
      and project_process_step_id = v_pending_ahj_inspection_id;
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_pending_reschedule_reason,
      v_date_created_pending_reason,v_date_modified_pending_reason,
      v_created_by_id_pending_reason,v_modified_by_id_pending_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1398
      and project_process_step_id = v_pending_ahj_inspection_id;
    select int_array_value, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_pending_category,v_date_created_pending_cat,v_date_modified_pending_cat,
      v_created_by_id_pending_cat,v_modified_by_id_pending_cat
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 21608
      and project_process_step_id = v_pending_ahj_inspection_id;
  end if;

  if v_need_ahj_verification_pps_id is not null then
    select timestamp_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_need_reschedule_needed,v_need_id,
      v_date_created_need_needed,v_date_modified_need_needed,
      v_created_by_id_need_needed,v_modified_by_id_need_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19027
      and project_process_step_id = v_need_ahj_verification_pps_id;
    select text_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_need_reschedule_reason,v_need_reason_id,
      v_date_created_need_reason,v_date_modified_need_reason,
      v_created_by_id_need_reason,v_modified_by_id_need_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19028
      and project_process_step_id = v_need_ahj_verification_pps_id;
    select int_array_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_inspection_need_category,v_need_category_id,
      v_date_created_need_cat,v_date_modified_need_cat,
      v_created_by_id_need_cat,v_modified_by_id_need_cat
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 21609
      and project_process_step_id = v_need_ahj_verification_pps_id;
  end if;


  -- this migrates scheduling complete

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     335,
                                                                     p_project_process_step_id,
                                                                     null);


  if v_need_ahj_verification_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       153);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       152);

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       998);
  end if;

  if v_inspection_need_reschedule_needed is not null or v_inspection_pending_reschedule_needed is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         19027,
                                                         coalesce(v_inspection_need_reschedule_needed,
                                                                  v_inspection_pending_reschedule_needed)::timestamp,
                                                         null::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_need_needed, v_date_created_pending_needed),
                                                         coalesce(v_date_modified_need_needed, v_date_modified_pending_needed),
                                                         coalesce(v_created_by_id_need_needed, v_created_by_id_pending_needed),
                                                         coalesce(v_modified_by_id_need_needed,
                                                                  v_modified_by_id_pending_needed));
  end if;
  if v_inspection_need_reschedule_reason is not null or v_inspection_pending_reschedule_reason is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         19028,
                                                         null::timestamp,
                                                         coalesce(v_inspection_need_reschedule_reason,
                                                                  v_inspection_pending_reschedule_reason)::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_need_reason, v_date_created_pending_reason),
                                                         coalesce(v_date_modified_need_reason, v_date_modified_pending_reason),
                                                         coalesce(v_created_by_id_need_reason, v_created_by_id_pending_reason),
                                                         coalesce(v_modified_by_id_need_reason,
                                                                  v_modified_by_id_pending_reason));
  end if;
  if v_inspection_need_category is not null or v_inspection_pending_category is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         21609,
                                                         null::timestamp,
                                                         null::text,
                                                         coalesce(v_inspection_need_category, v_inspection_pending_category)::integer[],
                                                         coalesce(v_date_created_need_cat, v_date_created_pending_cat),
                                                         coalesce(v_date_modified_need_cat, v_date_modified_pending_cat),
                                                         coalesce(v_created_by_id_need_cat, v_created_by_id_pending_cat),
                                                         coalesce(v_modified_by_id_need_cat, v_modified_by_id_pending_cat));
  end if;

--this update parent to the appropriate parent

  if v_schedule_inspection_with_ahj_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_schedule_inspection_with_ahj_id
      and case
            when v_pending_ahj_inspection_id is not null then
                id != v_pending_ahj_inspection_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_schedule_inspection_with_ahj_id;
  end if;


  if v_pending_ahj_inspection_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_ahj_inspection_id
      and case
            when v_need_ahj_verification_pps_id is not null then
                id != v_need_ahj_verification_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_ahj_inspection_id;
  end if;

  if v_need_ahj_verification_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_need_ahj_verification_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_need_ahj_verification_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_ahj_reinspection_wc_to_events(p_event_id integer,
                                                                               p_project_process_step_id integer)
  returns void as
$$

declare
  v_schedule_reinspection_with_ahj_id        integer;
  v_pending_ahj_reinspection_id            integer;
  v_need_ahj_verification_pps_id           integer;
  v_ahj_reinspection_wc_event_id           integer;
  v_reinspection_pending_reschedule_needed timestamp;
  v_reinspection_pending_reschedule_reason text;
  v_reinspection_need_reschedule_needed    timestamp;
  v_reinspection_need_reschedule_reason    text;
  v_need_id                                integer;
  v_need_reason_id                         integer;
  v_project_id                             integer;
  v_date_created_pending_needed            timestamp;
  v_date_created_pending_reason            timestamp;
  v_date_created_need_needed               timestamp;
  v_date_created_need_reason               timestamp;
  v_date_modified_pending_needed           timestamp;
  v_date_modified_pending_reason           timestamp;
  v_date_modified_need_needed              timestamp;
  v_date_modified_need_reason              timestamp;
  v_created_by_id_pending_needed           integer;
  v_created_by_id_pending_reason           integer;
  v_created_by_id_need_needed              integer;
  v_created_by_id_need_reason              integer;
  v_modified_by_id_pending_needed          integer;
  v_modified_by_id_pending_reason          integer;
  v_modified_by_id_need_needed             integer;
  v_modified_by_id_need_reason             integer;
BEGIN

  select project_id
  into v_project_id
  from flow.project_process_step
  where id = p_project_process_step_id;

  select id
  into v_schedule_reinspection_with_ahj_id
  from flow.project_process_step
  where process_step_id = 205
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  select id
  into v_pending_ahj_reinspection_id
  from flow.project_process_step
  where process_step_id = 154
    and parent_project_process_step_id = v_schedule_reinspection_with_ahj_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_ahj_reinspection_id is not null then
    select id
    into v_need_ahj_verification_pps_id
    from flow.project_process_step
    where process_step_id = 46
      and parent_project_process_step_id = v_pending_ahj_reinspection_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_ahj_reinspection_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_reinspection_pending_reschedule_needed,v_date_created_pending_needed,
      v_date_modified_pending_needed,v_created_by_id_pending_needed,v_modified_by_id_pending_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1409
      and project_process_step_id = v_pending_ahj_reinspection_id;
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_reinspection_pending_reschedule_reason,v_date_created_pending_reason,
      v_date_modified_pending_reason,v_created_by_id_pending_reason,v_modified_by_id_pending_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1410
      and project_process_step_id = v_pending_ahj_reinspection_id;
  end if;

  if v_need_ahj_verification_pps_id is not null then
    select timestamp_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_reinspection_need_reschedule_needed,v_need_id,
      v_date_created_need_needed,v_date_modified_need_needed,v_created_by_id_need_needed,
      v_modified_by_id_need_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19027
      and project_process_step_id = v_need_ahj_verification_pps_id;
    select text_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_reinspection_need_reschedule_reason,v_need_reason_id,
      v_date_created_need_reason,v_date_modified_need_reason,
      v_created_by_id_need_reason,v_modified_by_id_need_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19028
      and project_process_step_id = v_need_ahj_verification_pps_id;
  end if;

  select id
  into v_ahj_reinspection_wc_event_id
  from flow.event
  where temp_cfg_id = 5644;
  -- this migrates scheduling complete

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     338,
                                                                     p_project_process_step_id,
                                                                     null);


  if v_need_ahj_verification_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       153, true, v_ahj_reinspection_wc_event_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       152, true, v_ahj_reinspection_wc_event_id);

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       998, true, v_ahj_reinspection_wc_event_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       21609, true, v_ahj_reinspection_wc_event_id);


  end if;
  if v_reinspection_need_reschedule_needed is not null or v_reinspection_pending_reschedule_needed is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         19027,
                                                         coalesce(v_reinspection_need_reschedule_needed,
                                                                  v_reinspection_pending_reschedule_needed),
                                                         null::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_need_needed, v_date_created_pending_needed),
                                                         coalesce(v_date_modified_need_needed, v_date_modified_pending_needed),
                                                         coalesce(v_created_by_id_need_needed, v_created_by_id_pending_needed),
                                                         coalesce(v_modified_by_id_need_needed,
                                                                  v_modified_by_id_pending_needed),
                                                         true, v_ahj_reinspection_wc_event_id);
  end if;
  if v_reinspection_need_reschedule_reason is not null or v_reinspection_pending_reschedule_reason is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         19028,
                                                         null::timestamp,
                                                         coalesce(v_reinspection_need_reschedule_reason,
                                                                  v_reinspection_pending_reschedule_reason)::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_need_reason, v_date_created_pending_reason),
                                                         coalesce(v_date_modified_need_reason, v_date_modified_pending_reason),
                                                         coalesce(v_created_by_id_need_reason, v_created_by_id_pending_reason),
                                                         coalesce(v_modified_by_id_need_reason,
                                                                  v_modified_by_id_pending_reason)
      , true, v_ahj_reinspection_wc_event_id);
  end if;
--this update parent to the appropriate parent

  if v_schedule_reinspection_with_ahj_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_schedule_reinspection_with_ahj_id
      and case
            when v_pending_ahj_reinspection_id is not null then
                id != v_pending_ahj_reinspection_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_schedule_reinspection_with_ahj_id;
  end if;

  if v_pending_ahj_reinspection_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_ahj_reinspection_id
      and case
            when v_need_ahj_verification_pps_id is not null then
                id != v_need_ahj_verification_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_ahj_reinspection_id;
  end if;

  if v_need_ahj_verification_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_need_ahj_verification_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_need_ahj_verification_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_closer_appointment_to_events(p_event_id integer,
                                                                              p_project_process_step_id integer)
  returns void as
$$

declare
  v_closer_appointment_pps_id integer;
BEGIN


  select id
  into v_closer_appointment_pps_id
  from flow.project_process_step
  where process_step_id = 2
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

---Notes for closer


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1427);

  if v_closer_appointment_pps_id is not null then
    -- this migrates closer disposition
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       2,
                                                                       v_closer_appointment_pps_id,
                                                                       null);
    ---rework requests


    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       6670,
                                                                       v_closer_appointment_pps_id,
                                                                       null);

    --remote appointment
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_closer_appointment_pps_id,
                                                                       19033);
  end if;


--this update parent to the appropriate parent
  if v_closer_appointment_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_closer_appointment_pps_id;

    ---archives closer appointment project_process_step
    update flow.project_process_step
    set archived = true
    where id = v_closer_appointment_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_deadfront_to_events(p_event_id integer,
                                                                     p_project_process_step_id integer)
  returns void as
$$
declare
  v_verify_deadfront_id  integer;
BEGIN
  select id
  into v_verify_deadfront_id
  from flow.project_process_step
  where process_step_id = 149
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19087);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17505);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17328);


  if v_verify_deadfront_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_deadfront_id,
                                                                       553);
  end if;


  --this update parent to the appropriate parent


  if v_verify_deadfront_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_deadfront_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_deadfront_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_energization_to_events(p_event_id integer,
                                                                        p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_energization_pps_id integer;
  v_verify_energization_pps_id  integer;

BEGIN


  select id
  into v_pending_energization_pps_id
  from flow.project_process_step
  where process_step_id = 96
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_energization_pps_id is not null then
    select id
    into v_verify_energization_pps_id
    from flow.project_process_step
    where process_step_id = 97
      and parent_project_process_step_id = v_pending_energization_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;





  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1327);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17319);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1291);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19325);

  if v_pending_energization_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_energization_pps_id,
                                                                       1416);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_energization_pps_id,
                                                                       1417);
  end if;
  if v_verify_energization_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_energization_pps_id,
                                                                       478);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_energization_pps_id,
                                                                       989);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_energization_pps_id,
                                                                       1002);

  end if;






--this update parent to the appropriate parent
  if v_pending_energization_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_energization_pps_id
      and case
            when v_verify_energization_pps_id is not null then
                id != v_verify_energization_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_energization_pps_id;
  end if;

  if v_verify_energization_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_energization_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_energization_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_eto_rebate_inspection_to_events(p_event_id integer,
                                                                                 p_project_process_step_id integer)
  returns void as
$$
BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21132);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21536);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21131);


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_in_person_work_order_to_events(p_event_id integer,
                                                                                p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_work_order_pps_id       integer;
  v_verify_verify_work_order_pps_id integer;
  v_pending_work_order_needed       timestamp;
  v_verify_work_order_needed        timestamp;
  v_pending_work_order_reason       text;
  v_verify_work_order_reason        text;
  v_date_created_pending_needed     timestamp;
  v_date_modified_pending_needed    timestamp;
  v_created_by_id_pending_needed    integer;
  v_modified_by_id_pending_needed   integer;
  v_date_created_verify_needed      timestamp;
  v_date_modified_verify_needed     timestamp;
  v_created_by_id_verify_needed     integer;
  v_modified_by_id_verify_needed    integer;
  v_date_created_pending_reason     timestamp;
  v_date_modified_pending_reason    timestamp;
  v_created_by_id_pending_reason    integer;
  v_modified_by_id_pending_reason   integer;
  v_date_created_verify_reason      timestamp;
  v_date_modified_verify_reason     timestamp;
  v_created_by_id_verify_reason     integer;
  v_modified_by_id_verify_reason    integer;
BEGIN


  select id
  into v_pending_work_order_pps_id
  from flow.project_process_step
  where process_step_id = 104
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_work_order_pps_id is not null then
    select id
    into v_verify_verify_work_order_pps_id
    from flow.project_process_step
    where process_step_id = 55
      and parent_project_process_step_id = v_pending_work_order_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_work_order_pps_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_work_order_needed,v_date_created_pending_needed,v_date_modified_pending_needed,v_created_by_id_pending_needed,v_modified_by_id_pending_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 18859
      and project_process_step_id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_work_order_needed,v_date_created_verify_needed,v_date_modified_verify_needed,v_created_by_id_verify_needed,v_modified_by_id_verify_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19190
      and project_process_step_id = v_verify_verify_work_order_pps_id;
  end if;

  if v_pending_work_order_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_work_order_reason,v_date_created_pending_reason,v_date_modified_pending_reason,v_created_by_id_pending_reason,v_modified_by_id_pending_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 18860
      and project_process_step_id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_work_order_reason,v_date_created_verify_reason,v_date_modified_verify_reason,v_created_by_id_verify_reason,v_modified_by_id_verify_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19187
      and project_process_step_id = v_verify_verify_work_order_pps_id;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19081);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     18773);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1207);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17256);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17316);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     18771);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     20960);


  if v_verify_verify_work_order_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_verify_work_order_pps_id,
                                                                       162);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_verify_work_order_pps_id,
                                                                       992);

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
      and custom_field_group_assignment_id = 19160 and int_value is not null;

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
      and custom_field_group_assignment_id = 19172 and text_value  is not null;

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
      and custom_field_group_assignment_id = 22329 and int_value is not null;

  end if;


  if v_verify_work_order_needed is not null or v_pending_work_order_needed is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         19190,
                                                         coalesce(v_verify_work_order_needed, v_pending_work_order_needed)::timestamp,
                                                         null::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify_needed, v_date_created_pending_needed),
                                                         coalesce(v_date_modified_verify_needed, v_date_modified_pending_needed),
                                                         coalesce(v_created_by_id_verify_needed, v_created_by_id_pending_needed),
                                                         coalesce(v_modified_by_id_verify_needed, v_modified_by_id_pending_needed));
  end if;

  if v_verify_work_order_reason is not null or v_pending_work_order_reason is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         19187,
                                                         null::timestamp,
                                                         coalesce(v_verify_work_order_reason, v_pending_work_order_reason)::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify_reason, v_date_created_pending_reason),
                                                         coalesce(v_date_modified_verify_reason, v_date_modified_pending_reason),
                                                         coalesce(v_created_by_id_verify_reason, v_created_by_id_pending_reason),
                                                         coalesce(v_modified_by_id_verify_reason, v_modified_by_id_pending_reason));
  end if;


--this update parent to the appropriate parent
  if v_pending_work_order_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_work_order_pps_id
      and case
            when v_verify_verify_work_order_pps_id is not null then
                id != v_verify_verify_work_order_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_verify_work_order_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_verify_work_order_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_schedule_inhouse_mpu_to_events(p_event_id integer,
                                                                       p_project_process_step_id integer)
  returns void as
$$
declare
  v_inhouse_mpu_holding_id integer;
  v_verify_inhouse_mpu_id  integer;
BEGIN
  select id
  into v_inhouse_mpu_holding_id
  from flow.project_process_step
  where process_step_id = 239
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_inhouse_mpu_holding_id is not null then
    select id
    into v_verify_inhouse_mpu_id
    from flow.project_process_step
    where process_step_id = 137
      and parent_project_process_step_id = v_inhouse_mpu_holding_id
    order by project_process_step.date_created desc
    limit 1;
  end if;







  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1234);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17309);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19431);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21310);


  if v_verify_inhouse_mpu_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_inhouse_mpu_id,
                                                                       19433);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_inhouse_mpu_id,
                                                                       543);
  end if;


  --this update parent to the appropriate parent
  if v_inhouse_mpu_holding_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_inhouse_mpu_holding_id
      and case
            when v_verify_inhouse_mpu_id is not null then
                id != v_verify_inhouse_mpu_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_inhouse_mpu_holding_id;
  end if;

  if v_verify_inhouse_mpu_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_inhouse_mpu_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_inhouse_mpu_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_installation_closeout_to_events(p_event_id integer,
                                                                                 p_project_process_step_id integer)
  returns void as
$$
BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     6660,
                                                                     p_project_process_step_id,
                                                                     null);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     6360,
                                                                     p_project_process_step_id,
                                                                     null);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_installation_to_events(p_event_id integer,
                                                                        p_project_process_step_id integer)
  returns void as
$$
BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     6347,
                                                                     p_project_process_step_id,
                                                                     null);


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     19661);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     19662);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     21015);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     19667);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     20994);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     21504);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     22019);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     19681);




END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_meter_pull_to_events(p_event_id integer,
                                                                      p_project_process_step_id integer)
  returns void as
$$
declare
  v_meter_pull_holding_id integer;
  v_verify_meter_pull_id  integer;
BEGIN
  select id
  into v_meter_pull_holding_id
  from flow.project_process_step
  where process_step_id = 3363
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_meter_pull_holding_id is not null then
    select id
    into v_verify_meter_pull_id
    from flow.project_process_step
    where process_step_id = 3364
      and parent_project_process_step_id = v_meter_pull_holding_id
    order by project_process_step.date_created desc
    limit 1;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19588);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19589);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19590);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19591);

  if v_verify_meter_pull_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_meter_pull_id,
                                                                       19594);
  end if;


  --this update parent to the appropriate parent
  if v_meter_pull_holding_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_meter_pull_holding_id
      and case
            when v_verify_meter_pull_id is not null then
                id != v_verify_meter_pull_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_meter_pull_holding_id;
  end if;

  if v_verify_meter_pull_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_meter_pull_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_meter_pull_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_non_standard_visit_to_events(p_event_id integer,
                                                                              p_project_process_step_id integer)
  returns void as
$$

BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21222);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21223);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21227);


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21224);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21226);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21225);


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_outsource_mpu_to_events(p_event_id integer,
                                                                         p_project_process_step_id integer)
  returns void as
$$
declare
  v_outsource_mpu_holding_id integer;
  v_verify_outsource_mpu_id  integer;
BEGIN
  select id
  into v_outsource_mpu_holding_id
  from flow.project_process_step
  where process_step_id = 208
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_outsource_mpu_holding_id is not null then
    select id
    into v_verify_outsource_mpu_id
    from flow.project_process_step
    where process_step_id = 135
      and parent_project_process_step_id = v_outsource_mpu_holding_id
    order by project_process_step.date_created desc
    limit 1;
  end if;




  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19083);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17321);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19511);


  if v_verify_outsource_mpu_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_outsource_mpu_id,
                                                                       542);
  end if;


  --this update parent to the appropriate parent
  if v_outsource_mpu_holding_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_outsource_mpu_holding_id
      and case
            when v_verify_outsource_mpu_id is not null then
                id != v_verify_outsource_mpu_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_outsource_mpu_holding_id;
  end if;

  if v_verify_outsource_mpu_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_outsource_mpu_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_outsource_mpu_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_permit_pickup_delivery_to_events(p_event_id integer,
                                                                                  p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_permit_pickup_id    integer;
  v_verify_permit_pickup_pps_id integer;
  v_pending_reschedule_needed   timestamp;
  v_verify_reschedule_needed    timestamp;
  v_verify_id                   integer;
  v_project_id                  integer;
  v_date_created_pending        timestamp;
  v_date_modified_pending       timestamp;
  v_created_by_id_pending       integer;
  v_modified_by_id_pending      integer;
  v_date_created_verify         timestamp;
  v_date_modified_verify        timestamp;
  v_created_by_id_verify        integer;
  v_modified_by_id_verify       integer;
BEGIN

  select project_id
  into v_project_id
  from flow.project_process_step
  where id = p_project_process_step_id;

  select id
  into v_pending_permit_pickup_id
  from flow.project_process_step
  where process_step_id = 233
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_permit_pickup_id is not null then
    select id
    into v_verify_permit_pickup_pps_id
    from flow.project_process_step
    where process_step_id = 17
      and parent_project_process_step_id = v_pending_permit_pickup_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_permit_pickup_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_reschedule_needed,v_date_created_pending,v_date_modified_pending,v_created_by_id_pending,v_modified_by_id_pending
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1370
      and project_process_step_id = v_pending_permit_pickup_id;
  end if;

  if v_verify_permit_pickup_pps_id is not null then
    select timestamp_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_reschedule_needed,v_verify_id,v_date_created_verify,v_date_modified_verify,v_created_by_id_verify,v_modified_by_id_verify
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 21984
      and project_process_step_id = v_verify_permit_pickup_pps_id;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     6174,
                                                                     p_project_process_step_id,
                                                                     null);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1279);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17311);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     18958);


  if v_pending_permit_pickup_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_permit_pickup_id,
                                                                       1371);

  end if;

  if v_verify_permit_pickup_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       75,
                                                                       v_verify_permit_pickup_pps_id,
                                                                       null);
  end if;
  if v_verify_reschedule_needed is not null or v_pending_reschedule_needed is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         21984,
                                                         coalesce(v_verify_reschedule_needed, v_pending_reschedule_needed)::timestamp,
                                                         null::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify, v_date_created_pending),
                                                         coalesce(v_date_modified_verify, v_date_modified_pending),
                                                         coalesce(v_created_by_id_verify, v_created_by_id_pending),
                                                         coalesce(v_modified_by_id_verify, v_modified_by_id_pending));
  end if;


--this update parent to the appropriate parent
  if v_pending_permit_pickup_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_permit_pickup_id
      and case
            when v_verify_permit_pickup_pps_id is not null then
                id != v_verify_permit_pickup_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_permit_pickup_id;
  end if;

  if v_verify_permit_pickup_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_permit_pickup_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_permit_pickup_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_permit_submission_to_events(p_event_id integer,
                                                                             p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_permit_pack_submission_pps_id integer;
  v_verify_permit_pack_submission_pps_id  integer;
  v_pending_permit_pack_needed            timestamp;
  v_verify_permit_pack_needed             timestamp;
  v_verify_id                             integer;
  v_date_created_pending                  timestamp;
  v_date_modified_pending                 timestamp;
  v_created_by_id_pending                 integer;
  v_modified_by_id_pending                integer;
  v_date_created_verify                   timestamp;
  v_date_modified_verify                  timestamp;
  v_created_by_id_verify                  integer;
  v_modified_by_id_verify                 integer;
BEGIN


  select id
  into v_pending_permit_pack_submission_pps_id
  from flow.project_process_step
  where process_step_id = 94
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_permit_pack_submission_pps_id is not null then
    select id
    into v_verify_permit_pack_submission_pps_id
    from flow.project_process_step
    where process_step_id = 67
      and parent_project_process_step_id = v_pending_permit_pack_submission_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_permit_pack_submission_pps_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_permit_pack_needed,v_date_created_pending,v_date_modified_pending,v_created_by_id_pending,v_modified_by_id_pending
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1354
      and project_process_step_id = v_pending_permit_pack_submission_pps_id;
  end if;

  if v_verify_permit_pack_submission_pps_id is not null then
    select timestamp_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_permit_pack_needed,v_verify_id,v_date_created_verify,v_date_modified_verify,v_created_by_id_verify,v_modified_by_id_verify
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 21983
      and project_process_step_id = v_verify_permit_pack_submission_pps_id;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19085);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19107);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19108);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1268);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     100);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     101);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     103);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22000);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22001);

  if v_pending_permit_pack_submission_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_permit_pack_submission_pps_id,
                                                                       1355);
  end if;
  if v_verify_permit_pack_submission_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_permit_pack_submission_pps_id,
                                                                       18956);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_permit_pack_submission_pps_id,
                                                                       104);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_permit_pack_submission_pps_id,
                                                                       1019);

  end if;


  if v_verify_permit_pack_needed is not null or v_pending_permit_pack_needed is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         21983,
                                                         coalesce(v_verify_permit_pack_needed, v_pending_permit_pack_needed)::timestamp,
                                                         null::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify, v_date_created_pending),
                                                         coalesce(v_date_modified_verify, v_date_modified_pending),
                                                         coalesce(v_created_by_id_verify, v_created_by_id_pending),
                                                         coalesce(v_modified_by_id_verify, v_modified_by_id_pending));
  end if;


--this update parent to the appropriate parent
  if v_pending_permit_pack_submission_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_permit_pack_submission_pps_id
      and case
            when v_verify_permit_pack_submission_pps_id is not null then
                id != v_verify_permit_pack_submission_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_permit_pack_submission_pps_id;
  end if;

  if v_verify_permit_pack_submission_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_permit_pack_submission_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_permit_pack_submission_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_reroof_to_events(p_event_id integer,
                                                                  p_project_process_step_id integer)
  returns void as
$$
declare
  v_reroof_step_id integer;
  v_verify_reroof_id  integer;
BEGIN
  select id
  into v_reroof_step_id
  from flow.project_process_step
  where process_step_id = 211
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_reroof_step_id is not null then
    select id
    into v_verify_reroof_id
    from flow.project_process_step
    where process_step_id = 141
      and parent_project_process_step_id = v_reroof_step_id
    order by project_process_step.date_created desc
    limit 1;
  end if;



  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19086);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17501);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17324);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19512);

  if v_verify_reroof_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_reroof_id,
                                                                       549);
  end if;


  --this update parent to the appropriate parent
  if v_reroof_step_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_reroof_step_id
      and case
            when v_verify_reroof_id is not null then
                id != v_verify_reroof_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_reroof_step_id;
  end if;

  if v_verify_reroof_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_reroof_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_reroof_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_resurvey_to_events(p_event_id integer,
                                                                    p_project_process_step_id integer)
  returns void as
$$

declare
  v_resurvey_pps_id                 integer;
  v_site_survey_verification_pps_id integer;
  v_schedule_resurvey_id            integer;
BEGIN

  select id
  into v_resurvey_pps_id
  from flow.project_process_step
  where process_step_id = 99
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_resurvey_pps_id is not null then
    select id
    into v_site_survey_verification_pps_id
    from flow.project_process_step
    where process_step_id = 3346
      and parent_project_process_step_id = v_resurvey_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  select id
  into v_schedule_resurvey_id
  from flow.event
  where temp_cfg_id = 121;
  -- this migrates Resurvey Details

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     308,
                                                                     p_project_process_step_id,
                                                                     null);


/*closeout details for resurvey*/

  if v_site_survey_verification_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 19360, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 19363, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 19364, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21122, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 20859, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21201, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21202, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21205, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21203, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21204, true,v_schedule_resurvey_id);
  end if;

  if v_resurvey_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_resurvey_pps_id, 1353);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_resurvey_pps_id, 1072);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_resurvey_pps_id, 1006);
  end if;


--this update parent to the appropriate parent
  if v_resurvey_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_resurvey_pps_id
      and case
            when v_site_survey_verification_pps_id is not null then
                id != v_site_survey_verification_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_resurvey_pps_id;
  end if;

  if v_site_survey_verification_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_site_survey_verification_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_site_survey_verification_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_retrofit_energization_to_events(p_event_id integer,
                                                                                 p_project_process_step_id integer)
  returns void as
$$
BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21529);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21523);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21528);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21530);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21527);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21525);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_rma_work_order_to_events(p_event_id integer,
                                                                          p_project_process_step_id integer)
  returns void as
$$

BEGIN




  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22067);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22374);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22066);






  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22375);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22079);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22089);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22080);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22081);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22082);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22068);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_roof_leak_repair_to_events(p_event_id integer,
                                                                            p_project_process_step_id integer)
  returns void as
$$

BEGIN








  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21107);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21106);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21108);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21288);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21109);





  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21610);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21110);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21111);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21112);





  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21113);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21121);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21115);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21116);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21117);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21118);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21244);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21119);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21120);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_site_survey_to_events(p_event_id integer,
                                                                       p_project_process_step_id integer)
  returns void as
$$

declare
  v_site_survey_pps_id              integer;
  v_site_survey_verification_pps_id integer;
BEGIN

  select id
  into v_site_survey_pps_id
  from flow.project_process_step
  where process_step_id = 60
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_site_survey_pps_id is not null then
    select id
    into v_site_survey_verification_pps_id
    from flow.project_process_step
    where process_step_id = 3346
      and parent_project_process_step_id = v_site_survey_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  -- this migrates site survey details

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     156,
                                                                     p_project_process_step_id,
                                                                     null);


---delay reason


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     6152,
                                                                     p_project_process_step_id,
                                                                     null);

/*closeout details*/

  if v_site_survey_verification_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 19360);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 19363);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 19364);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21122);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 20859);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21201);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21202);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21205);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21203);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21204);
  end if;

  if v_site_survey_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       6283,
                                                                       v_site_survey_pps_id,
                                                                       null);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       6817,
                                                                       v_site_survey_pps_id,
                                                                       null);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_site_survey_pps_id, 20);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_site_survey_pps_id, 19137);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_site_survey_pps_id, 21533);
  end if;


--this update parent to the appropriate parent
  if v_site_survey_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_site_survey_pps_id
      and case
            when v_site_survey_verification_pps_id is not null then
                id != v_site_survey_verification_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_site_survey_pps_id;
  end if;

  if v_site_survey_verification_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_site_survey_verification_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_site_survey_verification_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_structural_upgrade_non_standard_to_events(p_event_id integer,
                                                                                           p_project_process_step_id integer)
  returns void as
$$
declare
  v_structural_upgrade_holding_id integer;
  v_verify_structural_upgrade_id  integer;
BEGIN
  select id
  into v_structural_upgrade_holding_id
  from flow.project_process_step
  where process_step_id = 210
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_structural_upgrade_holding_id is not null then
    select id
    into v_verify_structural_upgrade_id
    from flow.project_process_step
    where process_step_id = 139
      and parent_project_process_step_id = v_structural_upgrade_holding_id
    order by project_process_step.date_created desc
    limit 1;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19088);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17500);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17323);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19514);

  if v_verify_structural_upgrade_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_structural_upgrade_id,
                                                                       547);
  end if;


  --this update parent to the appropriate parent
  if v_structural_upgrade_holding_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_structural_upgrade_holding_id
      and case
            when v_verify_structural_upgrade_id is not null then
                id != v_verify_structural_upgrade_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_structural_upgrade_holding_id;
  end if;

  if v_verify_structural_upgrade_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_structural_upgrade_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_structural_upgrade_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_tree_trimming_to_events(p_event_id integer,
                                                                         p_project_process_step_id integer)
  returns void as
$$
declare
  v_tt_step_id integer;
  v_verify_tt_id  integer;
BEGIN
  select id
  into v_tt_step_id
  from flow.project_process_step
  where process_step_id = 213
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_tt_step_id is not null then
    select id
    into v_verify_tt_id
    from flow.project_process_step
    where process_step_id = 145
      and parent_project_process_step_id = v_tt_step_id
    order by project_process_step.date_created desc
    limit 1;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19089);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17503);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17326);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19515);

  if v_verify_tt_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_tt_id,
                                                                       551);
  end if;


  --this update parent to the appropriate parent
  if v_tt_step_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_tt_step_id
      and case
            when v_verify_tt_id is not null then
                id != v_verify_tt_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_tt_step_id;
  end if;

  if v_verify_tt_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_tt_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_tt_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_trenching_to_events(p_event_id integer,
                                                                     p_project_process_step_id integer)
  returns void as
$$
declare
  v_trenching_step_id integer;
  v_verify_trenching_id  integer;
BEGIN
  select id
  into v_trenching_step_id
  from flow.project_process_step
  where process_step_id = 212
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_trenching_step_id is not null then
    select id
    into v_verify_trenching_id
    from flow.project_process_step
    where process_step_id = 143
      and parent_project_process_step_id = v_trenching_step_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19090);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17502);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17325);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19516);

  if v_verify_trenching_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_trenching_id,
                                                                       550);
  end if;


  --this update parent to the appropriate parent
  if v_trenching_step_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_trenching_step_id
      and case
            when v_verify_trenching_id is not null then
                id != v_verify_trenching_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_trenching_step_id;
  end if;

  if v_verify_trenching_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_trenching_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_trenching_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_update_project_details()
  returns void as
$$
BEGIN

  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.setter_milestone_pay_ppsecfv_id
    where setter_milestone_pay is not null and setter_milestone_pay_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set setter_milestone_pay_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;


  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.first_appointment_pitched_ppsecfv_id
    where first_appointment_pitched is not null and first_appointment_pitched_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set first_appointment_pitched_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;

  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.first_appointment_missed_ppsecfv_id
    where first_appointment_missed is not null and first_appointment_missed_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set first_appointment_missed_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;


  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.first_appointment_not_pitched_or_missed_ppsecfv_id
    where first_appointment_not_pitched_or_missed is not null and first_appointment_not_pitched_or_missed_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set first_appointment_not_pitched_or_missed_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;


  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.site_survey_verified_date_ppsecfv_id
    where site_survey_verified_date is not null and site_survey_verified_date_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set site_survey_verified_date_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;

  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.appointment_check_in_ppsecfv_id
    where pd.appointment_check_in is not null and appointment_check_in_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set appointment_check_in_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;



  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.ahj_final_inspection_verified_ppsecfv_id
    where pd.ahj_final_inspection_verified is not null and ahj_final_inspection_verified_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set ahj_final_inspection_verified_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;

  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.ahj_inspection_scheduled_date_ppsecfv_id
    where pd.ahj_inspection_scheduled_date is not null and ahj_inspection_scheduled_date_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set appointment_check_in_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;


  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.installation_scheduled_ppsecfv_id
    where pd.installation_scheduled is not null and installation_scheduled_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set installation_scheduled_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;

  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.online_submission_time_ppsecfv_id
    where pd.online_submission_time is not null and online_submission_time_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set online_submission_time_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;

  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.first_appointment_id_ppsecfv_id
    where pd.first_appointment_id is not null and first_appointment_id_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set first_appointment_id_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE FUNCTION flow.project_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;


drop trigger if exists project_audit_trg ON flow.project_custom_field_value;
CREATE TRIGGER project_audit_trg
  after INSERT or update or delete ON flow.project_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE flow.project_audit();


CREATE OR REPLACE FUNCTION flow.user_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists user_audit_trg ON flow.user_custom_field_value;
CREATE TRIGGER user_audit_trg
  after INSERT or update or delete ON flow.user_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE flow.user_audit();


CREATE OR REPLACE FUNCTION flow.contact_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists contact_audit_trg ON flow.contact_custom_field_value;
CREATE TRIGGER contact_audit_trg
  after INSERT or update or delete ON flow.contact_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE flow.contact_audit();


CREATE OR REPLACE FUNCTION flow.organization_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists organization_audit_trg ON flow.organization_custom_field_value;
CREATE TRIGGER organization_audit_trg
  after INSERT or update or delete ON flow.organization_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE flow.organization_audit();



CREATE OR REPLACE FUNCTION flow.project_process_step_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists project_process_step_audit_trg ON flow.project_process_step_custom_field_value;
CREATE TRIGGER project_process_step_audit_trg
  after INSERT or update or delete ON flow.project_process_step_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE flow.project_process_step_audit();


CREATE OR REPLACE FUNCTION flow.project_process_step_event_custom_field_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.project_process_step_event_custom_field_value_audit(project_process_step_event_custom_field_value_id, old_value,
                                                                         new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.project_process_step_event_custom_field_value_audit(project_process_step_event_custom_field_value_id,
                                                                         old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.project_process_step_event_custom_field_value_audit(project_process_step_event_custom_field_value_id,
                                                                         old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists project_process_step_event_custom_field_value_audit_trg ON flow.project_process_step_event_custom_field_value;
CREATE TRIGGER project_process_step_event_custom_field_value_audit_trg
  after INSERT or update or delete ON flow.project_process_step_event_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE flow.project_process_step_event_custom_field_audit();




CREATE OR REPLACE FUNCTION flow.concrete_project_audit()
  RETURNS TRIGGER AS $$
BEGIN

  insert into flow.project_audit(project_id, contact_id, company_process_id, project_name,
                                 date_created, date_modified, created_by_id, modified_by_id,
                                 company_project_status_type_id, user_position_id, street1, street2,
                                 city, postal_code, time_zone, latitude, longitude, company_state_id,
                                 company_country_id)
  values(new.id, new.contact_id, new.company_process_id, new.project_name,
         new.date_created, new.date_modified, new.created_by_id, new.modified_by_id,
         new.company_project_status_type_id, new.user_position_id, new.street1, new.street2,
         new.city, new.postal_code, new.time_zone, new.latitude, new.longitude, new.company_state_id,
         new.company_country_id);

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_project_audit_trg ON flow.project;
CREATE TRIGGER concrete_project_audit_trg
  after INSERT or update ON flow.project
  FOR EACH ROW EXECUTE PROCEDURE flow.concrete_project_audit();


CREATE OR REPLACE FUNCTION flow.concrete_contact_audit()
  RETURNS TRIGGER AS $$
BEGIN
  insert into flow.contact_audit(contact_id, contact_type_id, first_name, last_name,
                                 street1, street2, city, postal_code, phone, email,
                                 prospect_status, mobile, mailing_street1, mailing_street2,
                                 mailing_city, mailing_postal_code, date_created, date_modified,
                                 created_by_id, modified_by_id, company_id, archived, title,
                                 owner_user_position_id, migrate_lead_id, company_state_id,
                                 mailing_company_state_id, company_country_id)
  values(new.id, new.contact_type_id, new.first_name, new.last_name,
         new.street1, new.street2, new.city, new.postal_code, new.phone, new.email,
         new.prospect_status, new.mobile, new.mailing_street1, new.mailing_street2,
         new.mailing_city, new.mailing_postal_code, new.date_created, new.date_modified,
         new.created_by_id, new.modified_by_id, new.company_id, new.archived, new.title,
         new.owner_user_position_id, new.migrate_lead_id, new.company_state_id,
         new.mailing_company_state_id, new.company_country_id);

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_contact_audit_trg ON flow.contact;
CREATE TRIGGER concrete_contact_audit_trg
  after INSERT or update ON flow.contact
  FOR EACH ROW EXECUTE PROCEDURE flow.concrete_contact_audit();

CREATE OR REPLACE FUNCTION flow.concrete_user_audit()
  RETURNS TRIGGER AS $$
BEGIN
  insert into flow.user_audit(user_id, first_name, last_name, email,
                              password, phone_number, created_by_id, date_created,
                              modified_by_id, date_modified, default_company_id,
                              username, archived, uuid, expiry_date)
  values(new.id, new.first_name, new.last_name, new.email,
         new.password, new.phone_number, new.created_by_id, new.date_created,
         new.modified_by_id, new.date_modified, new.default_company_id,
         new.username, new.archived, new.uuid, new.expiry_date);


  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_user_audit_trg ON flow.user;
CREATE TRIGGER concrete_user_audit_trg
  after INSERT or update ON flow.user
  FOR EACH ROW EXECUTE PROCEDURE flow.concrete_user_audit();



CREATE OR REPLACE FUNCTION flow.concrete_project_process_step_audit()
  RETURNS TRIGGER AS $$
BEGIN
  insert into flow.project_process_step_audit(project_process_step_id, project_id, process_step_id,
                                              user_position_id, company_process_step_status_type_id,
                                              process_step_complete_date, date_created, date_modified,
                                              created_by_id, modified_by_id, archived, main, migrated_created_date,
                                              migrated_work_type_id, migrated_org_id, migrated_start_time, migrated_end_time)
  values(new.id, new.project_id, new.process_step_id,
         new.user_position_id, new.company_process_step_status_type_id,
         new.process_step_complete_date, new.date_created, new.date_modified,
         new.created_by_id, new.modified_by_id, new.archived, new.main, new.migrated_created_date,
         new.migrated_work_type_id, new.migrated_org_id, new.migrated_start_time, new.migrated_end_time);


  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_project_process_step_audit_trg ON flow.project_process_step;
CREATE TRIGGER concrete_project_process_step_audit_trg
  after INSERT or update ON flow.project_process_step
  FOR EACH ROW EXECUTE PROCEDURE flow.concrete_project_process_step_audit();


CREATE OR REPLACE FUNCTION flow.concrete_project_process_step_event_audit()
  RETURNS TRIGGER AS $$
BEGIN
  insert into flow.project_process_step_event_audit(project_process_step_event_id, project_process_step_id,
                                                    process_step_event_id, resource_id, company_event_status_type_id,
                                                    start_time, end_time, date_created, date_modified,
                                                    created_by_id, modified_by_id, archived)
  values(new.id, new.project_process_step_id,
         new.process_step_event_id, new.resource_id, new.company_event_status_type_id,
         new.start_time, new.end_time, new.date_created, new.date_modified,
         new.created_by_id, new.modified_by_id, new.archived);


  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_project_process_step_event_audit_trg ON flow.project_process_step_event;
CREATE TRIGGER concrete_project_process_step_event_audit_trg
  after INSERT or update ON flow.project_process_step_event
  FOR EACH ROW EXECUTE PROCEDURE flow.concrete_project_process_step_event_audit();


CREATE OR REPLACE FUNCTION flow.concrete_postal_code_zone_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.postal_code_zone_audit(postal_code_zone_id, company_id, zone_name, archived, date_created,
                                            date_modified, created_by_id, modified_by_id,
                                            distribution_time_frame_days, schedulable_future_days,
                                            date_zone_created)
    values(new.id, new.company_id, new.zone_name, new.archived, new.date_created,
           new.date_modified, new.created_by_id, new.modified_by_id,
           new.distribution_time_frame_days, new.schedulable_future_days,
           now());
  elsif (TG_OP = 'UPDATE')  THEN
    update flow.postal_code_zone_audit
    set postal_code_zone_id = new.id,
        company_id = new.company_id,
        zone_name = new.zone_name,
        archived = new.archived,
        date_created = new.date_created,
        date_modified = new.date_modified,
        created_by_id = new.created_by_id,
        modified_by_id = new.modified_by_id,
        distribution_time_frame_days = new.distribution_time_frame_days,
        schedulable_future_days = new.schedulable_future_days,
        date_zone_archived = case when new.archived is true and old.archived is false then
                                    now() else date_zone_archived end
    where postal_code_zone_id = new.id;

  end if;


  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_postal_code_zone_audit_trg ON flow.postal_code_zone;
CREATE TRIGGER concrete_postal_code_zone_audit_trg
  after INSERT or update ON flow.postal_code_zone
  FOR EACH ROW EXECUTE PROCEDURE flow.concrete_postal_code_zone_audit();


CREATE OR REPLACE FUNCTION flow.concrete_postal_code_zone_user_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.postal_code_zone_user_audit(postal_code_zone_user_id, postal_code_zone_id, archived, date_created,
                                                 date_modified, created_by_id, modified_by_id,
                                                 postal_code_zone_user_type_id, user_id, manual_allocation,
                                                 date_user_created)
    values(new.id, new.postal_code_zone_id, new.archived, new.date_created,
           new.date_modified, new.created_by_id, new.modified_by_id,
           new.postal_code_zone_user_type_id, new.user_id, new.manual_allocation,
           now());
  elsif (TG_OP = 'UPDATE') THEN
    update flow.postal_code_zone_user_audit
    set postal_code_zone_id = new.postal_code_zone_id,
        archived = new.archived,
        date_created = new.date_created,
        date_modified = new.date_modified,
        created_by_id = new.created_by_id,
        modified_by_id = new.modified_by_id,
        postal_code_zone_user_type_id = new.postal_code_zone_user_type_id,
        user_id = new.user_id,
        manual_allocation = new.manual_allocation,
        date_user_archived = case when new.archived is true and old.archived is false then
                                    now() else date_user_archived end
    where postal_code_zone_user_id = new.id;
  end if;
  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_postal_code_zone_user_audit_trg ON flow.postal_code_zone_user;
CREATE TRIGGER concrete_postal_code_zone_user_audit_trg
  after INSERT or update ON flow.postal_code_zone_user
  FOR EACH ROW EXECUTE PROCEDURE flow.concrete_postal_code_zone_user_audit();



CREATE OR REPLACE FUNCTION flow.project_details_from_contact()
  RETURNS TRIGGER AS
$$
declare
  v_owner_user_position_id integer;
  v_owner_user_id          integer;
  v_project_ids            integer[];
BEGIN
  select owner_user_position_id, up.user_id
  into v_owner_user_position_id,v_owner_user_id
  from flow.contact c
         left join flow.user_position up on up.id = c.owner_user_position_id
  where c.id = new.id;


  select array_agg(id)
  into v_project_ids
  from flow.project
  where contact_id = new.id;

  update brs.project_details
  set setter_user_position_id = v_owner_user_position_id,
      setter_user_id          = v_owner_user_id
  where project_id = any (v_project_ids);

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists project_project_details_for_contact_trg on flow.contact;
CREATE TRIGGER project_project_details_for_contact_trg
  after update
  ON flow.contact
  FOR EACH ROW
EXECUTE PROCEDURE flow.project_details_from_contact();



CREATE OR REPLACE FUNCTION flow.project_details()
  RETURNS TRIGGER AS
$$
declare
  v_company_id                 integer;
  v_contact_email              character varying(255);
  v_contact_mobile_phone       character varying(50);
  v_contact_phone              character varying(50);
  v_state_id                   integer;
  v_state_abbrev               character varying(2);
  v_contact_name               character varying(150);
  v_owner_user_position_id     integer;
  v_owner_user_id              integer;
  v_user_id                    integer;
  v_closer_name                varchar;
  v_pd_closer_user_position_id integer;
  v_project_creator            varchar;
  v_new_project_status_type_id integer;
  v_old_project_status_type_id integer;
  v_cancelled_date             timestamp;
  v_on_hold_date               timestamp;
  v_off_hold_date              timestamp;
  v_company_project_status     character varying(100);
BEGIN
  select company_id
  into v_company_id
  from flow.company_process cp
  where process_id = new.company_process_id
  limit 1;

  select u3.first_name || ' ' || u3.last_name
  into v_project_creator
  from flow."user" u3
  where u3.id = new.created_by_id;

  select project_status_type
  into v_company_project_status
  from flow.company_project_status_type
  where id = new.company_project_status_type_id;

  if new.user_position_id is not null then
    select u.id, first_name || ' ' || last_name
    into v_user_id,v_closer_name
    from flow.user_position up
           inner join flow.user u on u.id = up.user_id
    where up.id = new.user_position_id;
  else
    select pd.closer_user_id, pd.closer_name, pd.closer_user_position_id
    into v_user_id,v_closer_name,v_pd_closer_user_position_id
    from brs.project_details pd
    where pd.project_id = new.id;
  end if;

  select email, phone, mobile, first_name || ' ' || last_name, owner_user_position_id, up.user_id
  into v_contact_email,v_contact_phone,v_contact_mobile_phone,v_contact_name,v_owner_user_position_id,v_owner_user_id
  from flow.contact c
         left join flow.user_position up on up.id = c.owner_user_position_id
  where c.id = new.contact_id;

  select s.id, s.abbreviation
  into v_state_id,v_state_abbrev
  from flow.company_state cs
         inner join flow.state s on cs.state_id = s.id
  where cs.id = new.company_state_id;

  select pst.id
  into v_new_project_status_type_id
  from flow.project_status_type pst
         inner join flow.company_project_status_type cpst on pst.id = cpst.project_status_type_id
  where cpst.id = new.company_project_status_type_id;

  select pst.id
  into v_old_project_status_type_id
  from flow.project_status_type pst
         inner join flow.company_project_status_type cpst on pst.id = cpst.project_status_type_id
  where cpst.id = old.company_project_status_type_id;

  select on_hold_date, off_hold_date
  into v_on_hold_date,v_off_hold_date
  from brs.project_details
  where project_id = new.id;

  if v_new_project_status_type_id = 1 and v_old_project_status_type_id = 2 then
    v_cancelled_date = null;
    update brs.project_details
    set cancelled_date = v_cancelled_date
    where project_id = new.id;
    if v_on_hold_date is not null and v_off_hold_date is null then
      v_off_hold_date = now();
      update brs.project_details
      set off_hold_date = v_off_hold_date
      where project_id = new.id;
    end if;

  elsif v_new_project_status_type_id = 1 and v_old_project_status_type_id = 3 then
    v_off_hold_date = now();
    update brs.project_details
    set off_hold_date = v_off_hold_date
    where project_id = new.id;
  elsif v_new_project_status_type_id = 2 and v_old_project_status_type_id = 1 then
    v_cancelled_date = now();
    update brs.project_details
    set cancelled_date = v_cancelled_date
    where project_id = new.id;
    --         insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id)
--         select 99999999,
--                concat('Project ID ', p.id, ' for ', p.project_name, ' at ', p.street1, ', ', p.city, ', ', s.abbreviation, ' has been canceled.'),
--                (SELECT md5(random()::text || clock_timestamp()::text)::uuid),
--                (select u.phone_number from flow.user_position up
--                                                inner join flow."user" u on up.user_id = u.id
--                 where up.id = p.user_position_id),
--                now(), 1
--         from flow.project p
--                  inner join flow.company_state cs on cs.id = p.company_state_id
--                  inner join flow.state s on cs.state_id = s.id
--         where p.id = new.id;
  elsif v_new_project_status_type_id = 2 and v_old_project_status_type_id = 3 then
    v_cancelled_date = now();
    update brs.project_details
    set cancelled_date = v_cancelled_date
    where project_id = new.id;
    --         insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id)
--         select 99999999,
--                concat('Project ID ', p.id, ' for ', p.project_name, ' at ', p.street1, ', ', p.city, ', ', s.abbreviation, ' has been canceled.'),
--                (SELECT md5(random()::text || clock_timestamp()::text)::uuid),
--                (select u.phone_number from flow.user_position up
--                                                inner join flow."user" u on up.user_id = u.id
--                 where up.id = p.user_position_id),
--                now(), 1
--         from flow.project p
--                  inner join flow.company_state cs on cs.id = p.company_state_id
--                  inner join flow.state s on cs.state_id = s.id
--         where p.id = new.id;
  elsif v_new_project_status_type_id = 3 and v_old_project_status_type_id = 1 then
    v_on_hold_date = now();
    v_off_hold_date = null;
    update brs.project_details
    set on_hold_date  = v_on_hold_date,
        off_hold_date = v_off_hold_date
    where project_id = new.id;
  elsif v_new_project_status_type_id = 3 and v_old_project_status_type_id = 2 then
    v_on_hold_date = now();
    v_off_hold_date = null;
    v_cancelled_date = null;
    update brs.project_details
    set on_hold_date   = v_on_hold_date,
        off_hold_date  = v_off_hold_date,
        cancelled_date = v_cancelled_date
    where project_id = new.id;
  end if;

  IF (TG_OP = 'INSERT') THEN
    insert into brs.project_details(project_id, company_id, contact_email,
                                    contact_phone, contact_mobile_phone,
                                    project_street1, project_city, project_postal_code,
                                    project_time_zone, project_state_id, project_state_abbreviation, contact_name,
                                    setter_user_position_id, setter_user_id, closer_user_id,
                                    closer_user_position_id, closer_name,
                                    project_creator, contact_id, project_created_date,
                                    company_project_status_type_id, company_project_status_type)
    values (new.id, v_company_id, v_contact_email, v_contact_phone, v_contact_mobile_phone,
            new.street1, new.city, new.postal_code, new.time_zone, v_state_id, v_state_abbrev, v_contact_name,
            v_owner_user_position_id, v_owner_user_id, v_user_id,
            coalesce(new.user_position_id, v_pd_closer_user_position_id), v_closer_name,
            v_project_creator, new.contact_id, new.date_created,
            new.company_project_status_type_id, v_company_project_status);
  elsif (TG_OP = 'UPDATE') THEN
    update brs.project_details
    set contact_email                  = v_contact_email,
        contact_phone                  = v_contact_phone,
        contact_mobile_phone           = v_contact_mobile_phone,
        project_street1                = new.street1,
        project_city                   = new.city,
        project_postal_code            = new.postal_code,
        project_time_zone              = new.time_zone,
        project_state_id               = v_state_id,
        project_state_abbreviation     = v_state_abbrev,
        contact_name                   = v_contact_name,
        setter_user_position_id        = v_owner_user_position_id,
        setter_user_id                 = v_owner_user_id,
        closer_name                    = v_closer_name,
        closer_user_position_id        = coalesce(new.user_position_id, v_pd_closer_user_position_id),
        closer_user_id                 = v_user_id,
        project_creator                = v_project_creator,
        contact_id                     = new.contact_id,
        project_created_date           = new.date_created,
        company_project_status_type_id = new.company_project_status_type_id,
        company_project_status_type    = v_company_project_status,
        archived                       = new.archived
    where project_id = new.id;

  elsif (TG_OP = 'DELETE') THEN
    DELETE FROM brs.project_details where project_id = old.id;
  end if;
  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists project_project_details_trg on flow.project;
CREATE TRIGGER project_project_details_trg
  after INSERT or delete or update
  ON flow.project
  FOR EACH ROW
EXECUTE PROCEDURE flow.project_details();


CREATE OR REPLACE FUNCTION flow.update_project_details_process_steps()
  RETURNS TRIGGER AS
$body$

declare
  v_project_id             integer;
  v_sql                    character varying;
  v_value                  character varying;
  v_record                 record;
  v_project_id1            integer;
  v_field_name             varchar;
  v_parent_custom_field_id integer;
  v_project_id2            integer;
BEGIN

  select pps.project_id
  into v_project_id
  from flow.project_process_step pps
  where pps.id = new.project_process_step_id
    and pps.main is true;

  select pps.project_id
  into v_project_id1
  from flow.project_process_step pps
         inner join flow.process_step ps on pps.process_step_id = ps.id
  where pps.id = new.project_process_step_id;


  select cf.field_name, cf.parent_custom_field_id
  into v_field_name,v_parent_custom_field_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.archived is false
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id and cf.archived is false
  where cfga.id = new.custom_field_group_assignment_id
    and cfga.archived is false;


  for v_record in
    select pdc.id,
           field_to_update,
           data_type_id,
           pdc.second_field_to_update,
           pdc.second_data_type_id,
           cf.list_of_value_id,
           pdc.update_first_value_only,
           pdc.update_first_value_only_id
    from brs.project_details_config pdc
           inner join flow.custom_field_group_assignment cfga on cfga.id = pdc.custom_field_group_assignment_id
           inner join flow.custom_field cf on cf.id = cfga.custom_field_id
    where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id
    loop

      if v_record.id is not null and v_record.data_type_id in (1, 2, 3, 4, 5, 6, 7) and
         (v_project_id is not null or v_record.update_first_value_only is true) then
        if v_record.data_type_id = 1 then
          case when new.date_value is null then select 'null' into v_value; else select quote_literal(new.date_value) into v_value; end case;
          v_value = v_value || '::date';
        elsif v_record.data_type_id = 2 then
          case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
          v_value = v_value || '::timestamp';
        elsif v_record.data_type_id = 4 then
          case when new.numeric_value is null then select 'null' into v_value; else select quote_literal(new.numeric_value) into v_value; end case;
          v_value = v_value || '::numeric';
        elsif v_record.data_type_id = 5 then
          case when new.text_value is null then select 'null' into v_value; else select quote_literal(new.text_value) into v_value; end case;
          v_value = v_value || '::text';
        elsif v_record.data_type_id = 6 then
          case when new.int_value is null then select 'null' into v_value; else select quote_literal(new.int_value) into v_value; end case;
          v_value = v_value || '::integer';
        elsif v_record.data_type_id = 3 then
          case when new.boolean_value is null then select 'null' into v_value; else select quote_literal(new.boolean_value) into v_value; end case;
          v_value = v_value || '::boolean';
        elsif v_record.data_type_id = 7 then
          case when new.int_array_value is null or new.int_array_value = '{}' then select 'null' into v_value; else select quote_literal(string_agg(lov.name, ', '))
                                                                                                                    from flow.list_of_value lov
                                                                                                                    where lov.id = any (new.int_array_value::integer[])
                                                                                                                    into v_value; end case;
          v_value = v_value || '::text';
        end if;
        v_project_id2 = coalesce(v_project_id, v_project_id1);
        case when v_record.update_first_value_only is false then
          v_sql = $$update brs.project_details set $$ || v_record.field_to_update || $$ = $$ || v_value || $$
                          where project_id = $$ || v_project_id2;
          -- raise notice 'what is the sql %',v_sql;
          else
            v_sql = $$update brs.project_details set $$ || v_record.field_to_update || $$ = $$ || v_value || $$,$$
                      || v_record.update_first_value_only_id || $$ = $$ || new.id || $$
                          where project_id = $$ || v_project_id2 || $$ and
                          ($$ || v_record.field_to_update ||
                    $$ is null or ( $$ || v_record.update_first_value_only_id || $$ is not null and  $$ ||
                    v_record.update_first_value_only_id || $$ = $$ || new.id || $$))$$;
          -- raise notice 'what is the sql %',v_sql;
          end case;

        begin
          execute v_sql;
        exception
          when others then
            insert into flow.trigger_error(project_process_step_custom_value_id, error)
            values (new.id, SQLERRM);
        end;


        if v_record.second_field_to_update is not null then
          if v_record.field_to_update in
             ('proposal_number_id', 'proposal_number_id_closer_appointment', 'proposal_number_id_booking',
              'proposal_number_id_final_design') then
            case when new.int_value is null then select 'null' into v_value;
              else
                select quote_literal(proposal_nbr)
                into v_value
                from brs.proposal_log_history
                where id = new.int_value;
              end case;
            --           elsif v_record.field_to_update = 'closer_user_position_id' and
--                 v_record.second_field_to_update = 'closer_user_id' then
--             case when new.int_value is null then select 'null' into v_value;
--               else
--                 select quote_literal(user_id)
--                 into v_value
--                 from flow.user_position
--                 where id = new.int_value;
--               end case;
--           elsif v_record.field_to_update = 'closer_user_position_id' and
--                 v_record.second_field_to_update = 'closer_name' then
--             case when new.int_value is null then select 'null' into v_value;
--               else
--                 select quote_literal(first_name || ' ' || last_name)
--                 into v_value
--                 from flow.user u
--                        inner join flow.user_position up on up.user_id = u.id
--                 where up.id = new.int_value;
--               end case;
          elsif v_record.field_to_update in ('installation_resource', 'permit_pack_submittal_resource',
                                             'in_house_mpu_permit_submittal_resource',
                                             'permit_pickup_resource', 'ac_compressor_relocation_resource',
                                             'as_built_permit_pickup_resource',
                                             'as_built_permit_submission_resource',
                                             'in_house_mpu_permit_pickup_resource', 'in_house_mpu_resource',
                                             'installation_closeout_resource',
                                             'non_standard_installation_resource',
                                             'outsource_mpu_resource', 'reroof_resource',
                                             'structural_upgrade_resource',
                                             'tree_trimming_resource', 'trenching_resource',
                                             'work_order_resource') then

            case when new.int_value is null then select 'null' into v_value;
              else
                select quote_literal(org_name)
                into v_value
                from flow.org o
                where o.id = new.int_value;
              end case;
            -- raise notice 'value&&&&&&&&&&&& = %',v_value;
          elsif v_record.list_of_value_id is not null then
            case when new.int_value is null then select 'null' into v_value;
              else
                select quote_literal(name)
                into v_value
                from flow.list_of_value
                where id = new.int_value;
              end case;
          elsif v_record.data_type_id = 2 and v_record.second_data_type_id = 1 then
            case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
            v_value = '(' || v_value || '::timestamp at time zone ' || quote_literal('UTC') ||
                      ' at time zone ' || quote_literal('US/Mountain') || ')::date';

          end if;
          case when v_record.update_first_value_only is false then
            --raise notice 'am I here*********';
            v_sql = $$update brs.project_details set $$ || v_record.second_field_to_update || $$ = $$ ||
                    v_value || $$
                            where project_id = $$ || v_project_id2;
            --raise notice 'what is the sql in the second field %',v_sql;
            else
              v_sql = $$update brs.project_details set $$ || v_record.second_field_to_update || $$ = $$ ||
                      v_value || $$,$$
                        || v_record.update_first_value_only_id || $$ = $$ || new.id || $$
                            where project_id = $$ || v_project_id2 || $$ and ($$ ||
                      v_record.second_field_to_update || $$ is null or ( $$ || v_record.update_first_value_only_id ||
                      $$ is not null and $$ || v_record.update_first_value_only_id || $$ = $$ || new.id || $$))$$;
            --raise notice 'what is the sql in the second field %',v_sql;
            end case;

          begin
            execute v_sql;
          exception
            when others then
              insert into flow.trigger_error(project_process_step_custom_value_id, error)
              values (new.id, SQLERRM);
          end;
        end if;
      end if;
    end loop;
  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_project_details_trg on flow.project_process_step_custom_field_value;
CREATE TRIGGER update_project_details_trg
  after INSERT or update
  ON flow.project_process_step_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_details_process_steps();



CREATE OR REPLACE FUNCTION flow.update_project_details_process_steps_from_events()
  RETURNS TRIGGER AS
$body$

declare
  v_project_id              integer;
  v_sql                     character varying;
  v_value                   character varying;
  v_record                  record;
  v_timestamp_value         timestamp;
  v_project_id1             integer;
  v_field_name              varchar;
  v_parent_custom_field_id  integer;
  v_project_id2             integer;
BEGIN

  select pps.project_id
  into v_project_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
  where ppse.id = new.project_process_step_event_id
    and pps.main is true;

  select pps.project_id
  into v_project_id1
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
         inner join flow.process_step ps on pps.process_step_id = ps.id
  where ppse.id = new.project_process_step_event_id;


  select cf.field_name, cf.parent_custom_field_id
  into v_field_name,v_parent_custom_field_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.archived is false
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id and cf.archived is false
  where cfga.id = new.custom_field_group_assignment_id
    and cfga.archived is false;


  if v_parent_custom_field_id = 10541 then

    select start_time
    into v_timestamp_value
    from flow.project_process_step_event ppse3
           inner join flow.project_process_step_event_custom_field_value ppsecfv
                      on ppse3.id = ppsecfv.project_process_step_event_id
    where ppse3.id = new.project_process_step_event_id;

    if new.int_value is not null then
      update brs.project_details
      set first_appointment_id     = new.int_value,
          first_appointment_ppse_id = new.id
      where project_id = v_project_id1
        and (first_appointment_id is null or
             (first_appointment_ppse_id is not null and first_appointment_ppse_id = new.id));
    end if;

    if new.int_value in (2, 1139, 1140) then

      update brs.project_details
      set setter_milestone_pay           = coalesce(v_timestamp_value, now()),
          setter_milestone_pay_ppsecfv_id = new.id
      where project_id = v_project_id1
        and (setter_milestone_pay is null or
             (setter_milestone_pay_ppsecfv_id is not null and setter_milestone_pay_ppsecfv_id = new.id));

      update brs.project_details
      set first_appointment_pitched           = coalesce(v_timestamp_value, now()),
          first_appointment_pitched_id        = new.int_value,
          first_appointment_pitched_ppsecfv_id = new.id
      where project_id = v_project_id1
        and (first_appointment_pitched is null or
             (first_appointment_pitched_ppsecfv_id is not null and first_appointment_pitched_ppsecfv_id = new.id));
    elsif new.int_value in (3) then
      update brs.project_details
      set setter_milestone_pay           = coalesce(v_timestamp_value, now()),
          setter_milestone_pay_ppsecfv_id = new.id
      where project_id = v_project_id1
        and (setter_milestone_pay is null or
             (setter_milestone_pay_ppsecfv_id is not null and setter_milestone_pay_ppsecfv_id = new.id));

      update brs.project_details
      set first_appointment_missed           = coalesce(v_timestamp_value, now()),
          first_appointment_missed_id        = new.int_value,
          first_appointment_missed_ppsecfv_id = new.id
      where project_id = v_project_id1
        and (first_appointment_missed is null or
             (first_appointment_missed_ppsecfv_id is not null and first_appointment_missed_ppsecfv_id = new.id));
    elseif new.int_value is not null and
           new.int_value not in (2, 3, 1139, 1140) then
      update brs.project_details
      set first_appointment_not_pitched_or_missed           =coalesce(v_timestamp_value, now()),
          first_appointment_not_pitched_or_missed_id        = new.int_value,
          first_appointment_not_pitched_or_missed_ppsecfv_id = new.id
      where project_id = v_project_id1
        and (first_appointment_not_pitched_or_missed is null or
             (first_appointment_not_pitched_or_missed_ppsecfv_id is not null and
              first_appointment_not_pitched_or_missed_ppsecfv_id = new.id));
    end if;
  end if;


  for v_record in
    select pdc.id,
           field_to_update,
           data_type_id,
           pdc.second_field_to_update,
           pdc.second_data_type_id,
           cf.list_of_value_id,
           pdc.update_first_value_only,
           pdc.update_first_value_only_id
    from brs.project_details_config pdc
           inner join flow.custom_field_group_assignment cfga on cfga.id = pdc.custom_field_group_assignment_id
           inner join flow.custom_field cf on cf.id = cfga.custom_field_id
    where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id
    loop

      if v_record.id is not null and v_record.data_type_id in (1, 2, 3, 4, 5, 6, 7) and
         (v_project_id is not null or v_record.update_first_value_only is true) then
        if v_record.data_type_id = 1 then
          case when new.date_value is null then select 'null' into v_value; else select quote_literal(new.date_value) into v_value; end case;
          v_value = v_value || '::date';
        elsif v_record.data_type_id = 2 then
          case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
          v_value = v_value || '::timestamp';
        elsif v_record.data_type_id = 4 then
          case when new.numeric_value is null then select 'null' into v_value; else select quote_literal(new.numeric_value) into v_value; end case;
          v_value = v_value || '::numeric';
        elsif v_record.data_type_id = 5 then
          case when new.text_value is null then select 'null' into v_value; else select quote_literal(new.text_value) into v_value; end case;
          v_value = v_value || '::text';
        elsif v_record.data_type_id = 6 then
          case when new.int_value is null then select 'null' into v_value; else select quote_literal(new.int_value) into v_value; end case;
          v_value = v_value || '::integer';
        elsif v_record.data_type_id = 3 then
          case when new.boolean_value is null then select 'null' into v_value; else select quote_literal(new.boolean_value) into v_value; end case;
          v_value = v_value || '::boolean';
        elsif v_record.data_type_id = 7 then
          case when new.int_array_value is null or new.int_array_value = '{}' then select 'null' into v_value; else select quote_literal(string_agg(lov.name, ', '))
                                                                                                                    from flow.list_of_value lov
                                                                                                                    where lov.id = any (new.int_array_value::integer[])
                                                                                                                    into v_value; end case;
          v_value = v_value || '::text';
        end if;
        v_project_id2 = coalesce(v_project_id, v_project_id1);
        case when v_record.update_first_value_only is false then
          v_sql = $$update brs.project_details set $$ || v_record.field_to_update || $$ = $$ || v_value || $$
                          where project_id = $$ || v_project_id2;
          -- raise notice 'what is the sql %',v_sql;
          else
            v_sql = $$update brs.project_details set $$ || v_record.field_to_update || $$ = $$ || v_value || $$,$$
                      || v_record.update_first_value_only_id || $$ = $$ || new.id || $$
                          where project_id = $$ || v_project_id2 || $$ and
                          ($$ || v_record.field_to_update ||
                    $$ is null or ( $$ || v_record.update_first_value_only_id || $$ is not null and  $$ ||
                    v_record.update_first_value_only_id || $$ = $$ || new.id || $$))$$;
          -- raise notice 'what is the sql %',v_sql;
          end case;

        begin
          execute v_sql;
        exception
          when others then
            insert into flow.trigger_error(project_process_step_custom_value_id, error)
            values (new.id, SQLERRM);
        end;


        if v_record.second_field_to_update is not null then
          if v_record.field_to_update in
             ('proposal_number_id', 'proposal_number_id_closer_appointment', 'proposal_number_id_booking',
              'proposal_number_id_final_design') then
            case when new.int_value is null then select 'null' into v_value;
              else
                select quote_literal(proposal_nbr)
                into v_value
                from brs.proposal_log_history
                where id = new.int_value;
              end case;
            --           elsif v_record.field_to_update = 'closer_user_position_id' and
--                 v_record.second_field_to_update = 'closer_user_id' then
--             case when new.int_value is null then select 'null' into v_value;
--               else
--                 select quote_literal(user_id)
--                 into v_value
--                 from flow.user_position
--                 where id = new.int_value;
--               end case;
--           elsif v_record.field_to_update = 'closer_user_position_id' and
--                 v_record.second_field_to_update = 'closer_name' then
--             case when new.int_value is null then select 'null' into v_value;
--               else
--                 select quote_literal(first_name || ' ' || last_name)
--                 into v_value
--                 from flow.user u
--                        inner join flow.user_position up on up.user_id = u.id
--                 where up.id = new.int_value;
--               end case;
          elsif v_record.field_to_update in ('installation_resource', 'permit_pack_submittal_resource',
                                             'in_house_mpu_permit_submittal_resource',
                                             'permit_pickup_resource', 'ac_compressor_relocation_resource',
                                             'as_built_permit_pickup_resource',
                                             'as_built_permit_submission_resource',
                                             'in_house_mpu_permit_pickup_resource', 'in_house_mpu_resource',
                                             'installation_closeout_resource',
                                             'non_standard_installation_resource',
                                             'outsource_mpu_resource', 'reroof_resource',
                                             'structural_upgrade_resource',
                                             'tree_trimming_resource', 'trenching_resource',
                                             'work_order_resource') then

            case when new.int_value is null then select 'null' into v_value;
              else
                select quote_literal(org_name)
                into v_value
                from flow.org o
                where o.id = new.int_value;
              end case;
            -- raise notice 'value&&&&&&&&&&&& = %',v_value;
          elsif v_record.list_of_value_id is not null then
            case when new.int_value is null then select 'null' into v_value;
              else
                select quote_literal(name)
                into v_value
                from flow.list_of_value
                where id = new.int_value;
              end case;
          elsif v_record.data_type_id = 2 and v_record.second_data_type_id = 1 then
            case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
            v_value = '(' || v_value || '::timestamp at time zone ' || quote_literal('UTC') ||
                      ' at time zone ' || quote_literal('US/Mountain') || ')::date';

          end if;
          case when v_record.update_first_value_only is false then
            --raise notice 'am I here*********';
            v_sql = $$update brs.project_details set $$ || v_record.second_field_to_update || $$ = $$ ||
                    v_value || $$
                            where project_id = $$ || v_project_id2;
            --raise notice 'what is the sql in the second field %',v_sql;
            else
              v_sql = $$update brs.project_details set $$ || v_record.second_field_to_update || $$ = $$ ||
                      v_value || $$,$$
                        || v_record.update_first_value_only_id || $$ = $$ || new.id || $$
                            where project_id = $$ || v_project_id2 || $$ and ($$ ||
                      v_record.second_field_to_update || $$ is null or ( $$ || v_record.update_first_value_only_id ||
                      $$ is not null and $$ || v_record.update_first_value_only_id || $$ = $$ || new.id || $$))$$;
            --raise notice 'what is the sql in the second field %',v_sql;
            end case;

          begin
            execute v_sql;
          exception
            when others then
              insert into flow.trigger_error(project_process_step_custom_value_id, error)
              values (new.id, SQLERRM);
          end;
        end if;
      end if;
    end loop;
  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;


drop trigger if exists update_project_details_from_events_trg on flow.project_process_step_event_custom_field_value;
CREATE TRIGGER update_project_details_from_events_trg
  after INSERT or update
  ON flow.project_process_step_event_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_details_process_steps_from_events();


CREATE OR REPLACE FUNCTION flow.update_events()
  RETURNS TRIGGER AS
$body$

declare
  v_project_id integer;
  v_closer_name varchar;
  v_user_id integer;
  v_user_position_id integer;
BEGIN

  select pps.project_id
  into v_project_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
  where ppse.id = new.id;

  select u.id,u.first_name ||' '||u.last_name,up.id
  into v_user_id,v_closer_name,v_user_position_id
  from flow.user u
         inner join flow.user_position up on u.id = up.user_id and up.primary_flag is true
  where up.id = new.resource_id;

  update brs.project_details
  set first_appointment        = new.start_time,
      first_appointment_ppse_id = new.id
  where project_id = v_project_id
    and (first_appointment is null or
         (first_appointment_ppse_id is not null and first_appointment_ppse_id = new.id));
  update brs.project_details
  set closer_user_id = v_user_id,
      closer_name = v_closer_name,
      closer_user_position_id = v_user_position_id
  where project_id = v_project_id;



  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_events_trg on flow.project_process_step_event;
CREATE TRIGGER update_events_trg
  after INSERT or update
  ON flow.project_process_step_event
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_events();


CREATE OR REPLACE FUNCTION flow.pps_update_project_details()
  RETURNS TRIGGER AS
$body$
declare
  v_parent_process_step_id integer;
BEGIN

  select ps.parent_process_step_id
  into v_parent_process_step_id
  from flow.process_step ps
  where new.process_step_id = ps.id;

  if v_parent_process_step_id = 3166 and new.process_step_complete_date is not null then
    update brs.project_details
    set complete_date_booking = new.process_step_complete_date
    where project_id = new.project_id
      and complete_date_booking is null;
  elsif v_parent_process_step_id = 3241 and new.process_step_complete_date is not null then
    update brs.project_details
    set complete_date_final_design_completion = new.process_step_complete_date
    where project_id = new.project_id
      and complete_date_final_design_completion is null;
  end if;

  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists pps_update_project_details_trg on flow.project_process_step;
CREATE TRIGGER pps_update_project_details_trg
  after INSERT or update
  ON flow.project_process_step
  FOR EACH ROW
EXECUTE PROCEDURE flow.pps_update_project_details();


CREATE OR REPLACE FUNCTION flow.update_project_details_project()
  RETURNS TRIGGER AS
$body$

declare
  v_field_to_update        character varying;
  v_data_type_id           integer;
  v_config_id              integer;
  v_sql                    character varying;
  v_value                  character varying;
  v_second_field_to_update character varying;
BEGIN

  select pdc.id, field_to_update, data_type_id, second_field_to_update
  into v_config_id,v_field_to_update,v_data_type_id,v_second_field_to_update
  from brs.project_details_config pdc
  where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id;


  if v_config_id is not null and v_data_type_id in (1, 2, 3, 4, 6, 5) then
    if v_data_type_id = 1 then
      case when new.date_value is null then select 'null' into v_value; else select quote_literal(new.date_value) into v_value; end case;
      v_value = v_value || '::date';
    elsif v_data_type_id = 2 then
      case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
      v_value = v_value || '::timestamp';
    elsif v_data_type_id = 4 then
      case when new.numeric_value is null then select 'null' into v_value; else select quote_literal(new.numeric_value) into v_value; end case;
      v_value = v_value || '::numeric';
    elsif v_data_type_id = 6 then
      case when new.int_value is null then select 'null' into v_value; else select quote_literal(new.int_value) into v_value; end case;
      v_value = v_value || '::integer';
    elsif v_data_type_id = 5 then
      case when new.text_value is null then select 'null' into v_value; else select quote_literal(new.text_value) into v_value; end case;
      v_value = v_value || '::text';
    elsif v_data_type_id = 3 then
      case when new.boolean_value is null then select 'null' into v_value; else select quote_literal(new.boolean_value) into v_value; end case;
      v_value = v_value || '::boolean';
    end if;

    v_sql = $$update brs.project_details set $$ || v_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || new.project_id;
    -- raise notice 'in if %',v_sql;
    execute v_sql;

    if v_second_field_to_update is not null then
      if v_field_to_update = 'ahj' and new.int_value is not null then
        select quote_literal(ahj.name)
        into v_value
        from brs.ahj ahj
        where ahj.id = new.int_value
        limit 1;
      elsif v_field_to_update = 'utility_company' and new.int_value is not null then
        select quote_literal(au.name)
        into v_value
        from brs.ahj_utility au
        where au.id = new.int_value
        limit 1;
      elsif v_field_to_update = 'sales_dev_representative_id' or v_field_to_update = 'inside_sales_consultant_id' then
        case when new.int_value is null then select 'null' into v_value;
          else
            select quote_literal(coalesce(u.first_name, ' ') || ' ' || coalesce(u.last_name, ' '))
            into v_value
            from flow.user_position up
                   inner join flow.user u on up.user_id = u.id
            where up.id = new.int_value;
          end case;
      else
        case when new.int_value is null then select 'null' into v_value;
          else
            select quote_literal(name)
            into v_value
            from flow.list_of_value
            where id = new.int_value;
          end case;
      end if;
      v_sql = $$update brs.project_details set $$ || v_second_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || new.project_id;
      execute v_sql;
    end if;
  end if;

  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_project_details_project_trg on flow.project_custom_field_value;
CREATE TRIGGER update_project_details_project_trg
  after INSERT or update
  ON flow.project_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_details_project();


CREATE OR REPLACE FUNCTION flow.update_contact_details_project_details()
  RETURNS TRIGGER AS
$body$

declare
  v_field_to_update character varying;
  v_data_type_id    integer;
  v_config_id       integer;
  v_sql             character varying;
  v_value           character varying;
  v_record          record;
  v_count           bigint;
BEGIN


  select pdc.id, field_to_update, data_type_id
  into v_config_id,v_field_to_update,v_data_type_id
  from brs.project_details_config pdc
  where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id;


  if v_config_id is not null and v_data_type_id in (1, 2, 3, 4, 6) then
    if v_data_type_id = 1 then
      case when new.date_value is null then select 'null' into v_value; else select quote_literal(new.date_value) into v_value; end case;
      v_value = v_value || '::date';
    elsif v_data_type_id = 2 then
      case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
      v_value = v_value || '::timestamp';
    elsif v_data_type_id = 4 then
      case when new.numeric_value is null then select 'null' into v_value; else select quote_literal(new.numeric_value) into v_value; end case;
      v_value = v_value || '::numeric';
    elsif v_data_type_id = 6 then
      case when new.int_value is null then select 'null' into v_value; else select quote_literal(new.int_value) into v_value; end case;
      v_value = v_value || '::integer';
    elsif v_data_type_id = 3 then
      case when new.boolean_value is null then select 'null' into v_value; else select quote_literal(new.boolean_value) into v_value; end case;
      v_value = v_value || '::boolean';
    end if;

    for v_record in select id
                    from flow.project
                    where contact_id = new.contact_id
      loop
        v_sql = $$update brs.project_details set $$ || v_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || v_record.id;
        -- raise notice 'in if %',v_sql;
        execute v_sql;
      end loop;


  end if;

  if (TG_OP = 'UPDATE') THEN

    select count(1)
    into v_count
    from flow.user_position up
           inner join flow.white_listed_position wlp on wlp.position_id = up.position_id and wlp.archived is false
    where up.user_id = new.modified_by_id
      and up.end_date is null
      and wlp.custom_field_group_assignment_id = 395;
    if new.custom_field_group_assignment_id = 395 and old.int_value != new.int_value and v_count < 1 then
      raise exception 'You do not have rights to update the Lead Source for this Contact.';
    end if;
  end if;

  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_contact_details_project_details_trg on flow.contact_custom_field_value;
CREATE TRIGGER update_contact_details_project_details_trg
  after INSERT or update
  ON flow.contact_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_contact_details_project_details();



-- CREATE OR REPLACE FUNCTION flow.update_project_process_step_custom_value()
--     RETURNS TRIGGER AS
-- $body$
--
-- declare
--     v_record record;
--     v_sql    text;
--     v_found  bigint;
--     v_count  integer = 0;
-- BEGIN
--
--     select count(1)
--     into v_found
--     from flow.project_process_step
--     where process_step_id = new.process_step_id
--       and project_id = new.project_id
--       and id != new.id
--       and main is false
--       and new.main is true;
--
--     if old.main is false and new.main is true or v_found > 0 then
--         v_sql = 'update brs.project_details set ';
--         for v_record in
--             select pdc.field_to_update, pdc.second_field_to_update
--             from flow.custom_field_group_assignment cfga
--                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
--                      inner join flow.custom_field cf on cf.id = cfga.custom_field_id
--                      inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
--                      inner join flow.data_type dt on dt.id = cdt.data_type_id
--                      inner join brs.project_details_config pdc on pdc.custom_field_group_assignment_id = cfga.id
--             where cfg.process_step_id = new.process_step_id
--               and cf.archived is false
--               and cfg.archived is false
--               and cfga.archived is false
--               and cf.parent_custom_field_id not in (10283, 10248,
--                                                 10057, 10118,
--                                                 10243, 10242)
--             loop
--                 v_count = v_count + 1;
--                 if v_record.second_field_to_update is not null then
--                     if not v_record.second_field_to_update = any (string_to_array(v_sql, ' ')) then
--                         v_sql = v_sql || v_record.second_field_to_update || ' = null , ';
--                     end if;
--                 end if;
--                 if not v_record.field_to_update = any (string_to_array(v_sql, ' ')) then
--                     v_sql = v_sql || v_record.field_to_update || ' = null , ';
--                 end if;
--             end loop;
--         v_sql = trim(trailing ' ,' from v_sql);
--         v_sql = v_sql || ' where project_id = ' || new.project_id || ';';
--         if v_count > 0 then
--             -- raise notice 'v_sql%',v_sql;
--             execute v_sql;
--         end if;
--     end if;
--
--     update flow.project_process_step_custom_field_value
--     set id = id
--     where project_process_step_id = new.id;
--     RETURN NULL;
-- END
-- $body$
--     LANGUAGE plpgsql;
--
-- drop trigger if exists update_project_process_step_custom_value_trg on flow.project_process_step;
-- CREATE TRIGGER update_project_process_step_custom_value_trg
--     after INSERT or update
--     ON flow.project_process_step
--     FOR EACH ROW
-- EXECUTE PROCEDURE flow.update_project_process_step_custom_value();



CREATE OR REPLACE function flow.migrate_schedule_in_person_work_order2_to_events(p_event_id integer,
                                                                                 p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_work_order_pps_id       integer;
  v_verify_verify_work_order_pps_id integer;
  v_pending_work_order_needed       timestamp;
  v_verify_work_order_needed        timestamp;
  v_pending_work_order_reason       text;
  v_verify_work_order_reason        text;
  v_date_created_pending_needed     timestamp;
  v_date_modified_pending_needed    timestamp;
  v_created_by_id_pending_needed    integer;
  v_modified_by_id_pending_needed   integer;
  v_date_created_verify_needed      timestamp;
  v_date_modified_verify_needed     timestamp;
  v_created_by_id_verify_needed     integer;
  v_modified_by_id_verify_needed    integer;
  v_date_created_pending_reason     timestamp;
  v_date_modified_pending_reason    timestamp;
  v_created_by_id_pending_reason    integer;
  v_modified_by_id_pending_reason   integer;
  v_date_created_verify_reason      timestamp;
  v_date_modified_verify_reason     timestamp;
  v_created_by_id_verify_reason     integer;
  v_modified_by_id_verify_reason    integer;
BEGIN


  select id
  into v_pending_work_order_pps_id
  from flow.project_process_step
  where process_step_id = 2839
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_work_order_pps_id is not null then
    select id
    into v_verify_verify_work_order_pps_id
    from flow.project_process_step
    where process_step_id = 2840
      and parent_project_process_step_id = v_pending_work_order_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_work_order_pps_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_work_order_needed,v_date_created_pending_needed,v_date_modified_pending_needed,v_created_by_id_pending_needed,v_modified_by_id_pending_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 17472
      and project_process_step_id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_work_order_needed,v_date_created_verify_needed,v_date_modified_verify_needed,v_created_by_id_verify_needed,v_modified_by_id_verify_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19189
      and project_process_step_id = v_verify_verify_work_order_pps_id;
  end if;

  if v_pending_work_order_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_work_order_reason,v_date_created_pending_reason,v_date_modified_pending_reason,v_created_by_id_pending_reason,v_modified_by_id_pending_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 17473
      and project_process_step_id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_work_order_reason,v_date_created_verify_reason,v_date_modified_verify_reason,v_created_by_id_verify_reason,v_modified_by_id_verify_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 17476
      and project_process_step_id = v_verify_verify_work_order_pps_id;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19082);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     18774);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17466);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17467);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     18772);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     20961);



  if v_verify_verify_work_order_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_verify_work_order_pps_id,
                                                                       17475);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_verify_work_order_pps_id,
                                                                       17474);

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
      and custom_field_group_assignment_id = 19161 and int_value is not null;

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
      and custom_field_group_assignment_id = 19173 and text_value  is not null;

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
      and custom_field_group_assignment_id = 22330 and int_value is not null;

  end if;


  if v_verify_work_order_needed is not null or v_pending_work_order_needed is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         19189,
                                                         coalesce(v_verify_work_order_needed, v_pending_work_order_needed)::timestamp,
                                                         null::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify_needed, v_date_created_pending_needed),
                                                         coalesce(v_date_modified_verify_needed, v_date_modified_pending_needed),
                                                         coalesce(v_created_by_id_verify_needed, v_created_by_id_pending_needed),
                                                         coalesce(v_modified_by_id_verify_needed, v_modified_by_id_pending_needed));
  end if;

  if v_verify_work_order_reason is not null or v_pending_work_order_reason is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         17476,
                                                         null::timestamp,
                                                         coalesce(v_verify_work_order_reason, v_pending_work_order_reason)::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify_reason, v_date_created_pending_reason),
                                                         coalesce(v_date_modified_verify_reason, v_date_modified_pending_reason),
                                                         coalesce(v_created_by_id_verify_reason, v_created_by_id_pending_reason),
                                                         coalesce(v_modified_by_id_verify_reason, v_modified_by_id_pending_reason));
  end if;


--this update parent to the appropriate parent
  if v_pending_work_order_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_work_order_pps_id
      and case
            when v_verify_verify_work_order_pps_id is not null then
                id != v_verify_verify_work_order_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_verify_work_order_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_verify_work_order_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_schedule_in_person_work_order3_to_events(p_event_id integer,
                                                                                 p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_work_order_pps_id       integer;
  v_verify_verify_work_order_pps_id integer;
  v_pending_work_order_needed       timestamp;
  v_verify_work_order_needed        timestamp;
  v_pending_work_order_reason       text;
  v_verify_work_order_reason        text;
  v_date_created_pending_needed     timestamp;
  v_date_modified_pending_needed    timestamp;
  v_created_by_id_pending_needed    integer;
  v_modified_by_id_pending_needed   integer;
  v_date_created_verify_needed      timestamp;
  v_date_modified_verify_needed     timestamp;
  v_created_by_id_verify_needed     integer;
  v_modified_by_id_verify_needed    integer;
  v_date_created_pending_reason     timestamp;
  v_date_modified_pending_reason    timestamp;
  v_created_by_id_pending_reason    integer;
  v_modified_by_id_pending_reason   integer;
  v_date_created_verify_reason      timestamp;
  v_date_modified_verify_reason     timestamp;
  v_created_by_id_verify_reason     integer;
  v_modified_by_id_verify_reason    integer;
BEGIN


  select id
  into v_pending_work_order_pps_id
  from flow.project_process_step
  where process_step_id = 2842
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_work_order_pps_id is not null then
    select id
    into v_verify_verify_work_order_pps_id
    from flow.project_process_step
    where process_step_id = 2843
      and parent_project_process_step_id = v_pending_work_order_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_work_order_pps_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_work_order_needed,v_date_created_pending_needed,v_date_modified_pending_needed,v_created_by_id_pending_needed,v_modified_by_id_pending_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id =17485
      and project_process_step_id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_work_order_needed,v_date_created_verify_needed,v_date_modified_verify_needed,v_created_by_id_verify_needed,v_modified_by_id_verify_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id =17488
      and project_process_step_id = v_verify_verify_work_order_pps_id;
  end if;

  if v_pending_work_order_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_work_order_reason,v_date_created_pending_reason,v_date_modified_pending_reason,v_created_by_id_pending_reason,v_modified_by_id_pending_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id =17486
      and project_process_step_id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_work_order_reason,v_date_created_verify_reason,v_date_modified_verify_reason,v_created_by_id_verify_reason,v_modified_by_id_verify_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id =17489
      and project_process_step_id = v_verify_verify_work_order_pps_id;
  end if;



  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     20962);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17495);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17480);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17481);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17490);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     20963);



  if v_verify_verify_work_order_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_verify_work_order_pps_id,
                                                                       17487);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_verify_work_order_pps_id,
                                                                       19188);

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
      and custom_field_group_assignment_id = 19162 and int_value is not null;

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
      and custom_field_group_assignment_id = 19174 and text_value  is not null;

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
      and custom_field_group_assignment_id = 22331 and int_value is not null;

  end if;


  if v_verify_work_order_needed is not null or v_pending_work_order_needed is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         17488,
                                                         coalesce(v_verify_work_order_needed, v_pending_work_order_needed)::timestamp,
                                                         null::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify_needed, v_date_created_pending_needed),
                                                         coalesce(v_date_modified_verify_needed, v_date_modified_pending_needed),
                                                         coalesce(v_created_by_id_verify_needed, v_created_by_id_pending_needed),
                                                         coalesce(v_modified_by_id_verify_needed, v_modified_by_id_pending_needed));
  end if;

  if v_verify_work_order_reason is not null or v_pending_work_order_reason is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         17489,
                                                         null::timestamp,
                                                         coalesce(v_verify_work_order_reason, v_pending_work_order_reason)::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify_reason, v_date_created_pending_reason),
                                                         coalesce(v_date_modified_verify_reason, v_date_modified_pending_reason),
                                                         coalesce(v_created_by_id_verify_reason, v_created_by_id_pending_reason),
                                                         coalesce(v_modified_by_id_verify_reason, v_modified_by_id_pending_reason));
  end if;


--this update parent to the appropriate parent
  if v_pending_work_order_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_work_order_pps_id
      and case
            when v_verify_verify_work_order_pps_id is not null then
                id != v_verify_verify_work_order_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_verify_work_order_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_verify_work_order_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_schedule_add_additional_resource_to_install_to_events(p_event_id integer,
                                                                                              p_project_process_step_id integer)
  returns void as
$$

BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19018);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_schedule_add_additional_resource_to_wo_to_events(p_event_id integer,
                                                                                         p_project_process_step_id integer)
  returns void as
$$

BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21951);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21952);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_add_retro_addtln_resource_install_to_events(p_event_id integer,
                                                                                             p_project_process_step_id integer)
  returns void as
$$

BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21607);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_schedule_midpoint_inspection_to_events(p_event_id integer,
                                                                               p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_midpoint_pps_id       integer;
  v_verify_midpoint_pps_id integer;
BEGIN


  select id
  into v_pending_midpoint_pps_id
  from flow.project_process_step
  where process_step_id = 166
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_midpoint_pps_id is not null then
    select id
    into v_verify_midpoint_pps_id
    from flow.project_process_step
    where process_step_id = 167
      and parent_project_process_step_id = v_pending_midpoint_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1197);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1201);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1318);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17330);

  if v_pending_midpoint_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_midpoint_pps_id,
                                                                       1395);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_midpoint_pps_id,
                                                                       1394);
  end if;




  if v_verify_midpoint_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_midpoint_pps_id,
                                                                       641);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_midpoint_pps_id,
                                                                       642);

  end if;



--this update parent to the appropriate parent
  if v_pending_midpoint_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_midpoint_pps_id
      and case
            when v_verify_midpoint_pps_id is not null then
                id != v_verify_midpoint_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_midpoint_pps_id;
  end if;

  if v_verify_midpoint_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_midpoint_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_midpoint_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

CREATE OR REPLACE function flow.migrate_schedule_permit_signature_to_events(p_event_id integer,
                                                                            p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_permit_pps_id       integer;
  v_verify_permit_pps_id integer;
BEGIN


  select id
  into v_pending_permit_pps_id
  from flow.project_process_step
  where process_step_id = 228
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_permit_pps_id is not null then
    select id
    into v_verify_permit_pps_id
    from flow.project_process_step
    where process_step_id = 71
      and parent_project_process_step_id = v_pending_permit_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;






  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19084);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19104);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1174);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17312);






  if v_verify_permit_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_permit_pps_id,
                                                                       134);


  end if;



--this update parent to the appropriate parent
  if v_pending_permit_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_permit_pps_id
      and case
            when v_verify_permit_pps_id is not null then
                id != v_verify_permit_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_permit_pps_id;
  end if;

  if v_verify_permit_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_permit_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_permit_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_schedule_additional_permit_signature_to_events(p_event_id integer,
                                                                                       p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_permit_pps_id       integer;
  v_verify_permit_pps_id integer;
BEGIN


  select id
  into v_pending_permit_pps_id
  from flow.project_process_step
  where process_step_id = 3108
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_permit_pps_id is not null then
    select id
    into v_verify_permit_pps_id
    from flow.project_process_step
    where process_step_id = 3109
      and parent_project_process_step_id = v_pending_permit_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;



  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19275);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19271);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19270);







  if v_verify_permit_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_permit_pps_id,
                                                                       19280);


  end if;



--this update parent to the appropriate parent
  if v_pending_permit_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_permit_pps_id
      and case
            when v_verify_permit_pps_id is not null then
                id != v_verify_permit_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_permit_pps_id;
  end if;

  if v_verify_permit_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_permit_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_permit_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_schedule_asbuilt_permit_signature_to_events(p_event_id integer,
                                                                                    p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_asbuilt_permit_signature_pps_id integer;
  v_verify_asbuilt_permit_signature_pps_id  integer;
  v_pending_bn                              text;
  v_verify_bn                               text;
  v_pending_en                              text;
  v_verify_en                               text;
  v_date_created_pending_bn            timestamp;
  v_date_modified_pending_bn            timestamp;
  v_created_by_id_pending_bn            integer;
  v_modified_by_id_pending_bn           integer;
  v_date_created_verify_bn              timestamp;
  v_date_modified_verify_bn             timestamp;
  v_created_by_id_verify_bn            integer;
  v_modified_by_id_verify_bn            integer;
  v_date_created_pending_en             timestamp;
  v_date_modified_pending_en            timestamp;
  v_created_by_id_pending_en            integer;
  v_modified_by_id_pending_en           integer;
  v_date_created_verify_en              timestamp;
  v_date_modified_verify_en             timestamp;
  v_created_by_id_verify_en             integer;
  v_modified_by_id_verify_en            integer;
BEGIN


  select id
  into v_pending_asbuilt_permit_signature_pps_id
  from flow.project_process_step
  where process_step_id = 193
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_asbuilt_permit_signature_pps_id is not null then
    select id
    into v_verify_asbuilt_permit_signature_pps_id
    from flow.project_process_step
    where process_step_id = 194
      and parent_project_process_step_id = v_pending_asbuilt_permit_signature_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_asbuilt_permit_signature_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_bn,v_date_created_pending_bn,v_date_modified_pending_bn,v_created_by_id_pending_bn,v_modified_by_id_pending_bn
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 809
      and project_process_step_id = v_pending_asbuilt_permit_signature_pps_id;
  end if;

  if v_verify_asbuilt_permit_signature_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_bn,v_date_created_verify_bn,v_date_modified_verify_bn,v_created_by_id_verify_bn,v_modified_by_id_verify_bn
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 823
      and project_process_step_id = v_verify_asbuilt_permit_signature_pps_id;
  end if;

  if v_pending_asbuilt_permit_signature_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_en,v_date_created_pending_en,v_date_modified_pending_en,v_created_by_id_pending_en,v_modified_by_id_pending_en
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 810
      and project_process_step_id = v_pending_asbuilt_permit_signature_pps_id;
  end if;

  if v_verify_asbuilt_permit_signature_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_en,v_date_created_verify_en,v_date_modified_verify_en,v_created_by_id_verify_en,v_modified_by_id_verify_en
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 824
      and project_process_step_id = v_verify_asbuilt_permit_signature_pps_id;
  end if;



  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19072);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1274);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     812);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     811);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     813);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17334);


  if v_pending_asbuilt_permit_signature_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_asbuilt_permit_signature_pps_id,
                                                                       1366);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_asbuilt_permit_signature_pps_id,
                                                                       1367);
  end if;

  if v_verify_asbuilt_permit_signature_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_asbuilt_permit_signature_pps_id,
                                                                       826);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_asbuilt_permit_signature_pps_id,
                                                                       18961);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_asbuilt_permit_signature_pps_id,
                                                                       1364);



  end if;


  if v_verify_bn is not null or v_pending_bn is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         809,
                                                         null::timestamp,
                                                         coalesce(v_verify_bn, v_pending_bn)::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify_bn, v_date_created_pending_bn),
                                                         coalesce(v_date_modified_verify_bn,
                                                                  v_date_modified_pending_bn),
                                                         coalesce(v_created_by_id_verify_bn,
                                                                  v_created_by_id_pending_bn),
                                                         coalesce(v_modified_by_id_verify_bn,
                                                                  v_modified_by_id_pending_bn));
  end if;

  if v_verify_en is not null or v_pending_en is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         810,
                                                         null::timestamp,
                                                         coalesce(v_verify_en, v_pending_en)::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify_en, v_date_created_pending_en),
                                                         coalesce(v_date_modified_verify_en,
                                                                  v_date_modified_pending_en),
                                                         coalesce(v_created_by_id_verify_en,
                                                                  v_created_by_id_pending_en),
                                                         coalesce(v_modified_by_id_verify_en,
                                                                  v_modified_by_id_pending_en));
  end if;


--this update parent to the appropriate parent
  if v_pending_asbuilt_permit_signature_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_asbuilt_permit_signature_pps_id
      and case
            when v_verify_asbuilt_permit_signature_pps_id is not null then
                id != v_verify_asbuilt_permit_signature_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_asbuilt_permit_signature_pps_id;
  end if;

  if v_verify_asbuilt_permit_signature_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_asbuilt_permit_signature_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_asbuilt_permit_signature_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_schedule_addtl_permit_pickup_delivery_to_events(p_event_id integer,
                                                                                        p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_addtl_ppd_pps_id integer;
  v_verify_addtl_ppd_pps_id  integer;
BEGIN


  select id
  into v_pending_addtl_ppd_pps_id
  from flow.project_process_step
  where process_step_id = 3104
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_addtl_ppd_pps_id is not null then
    select id
    into v_verify_addtl_ppd_pps_id
    from flow.project_process_step
    where process_step_id = 3105
      and parent_project_process_step_id = v_pending_addtl_ppd_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;




  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19243);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19247);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19248);


  if v_pending_addtl_ppd_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_addtl_ppd_pps_id,
                                                                       19254);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_addtl_ppd_pps_id,
                                                                       19253);
  end if;
  if v_verify_addtl_ppd_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_addtl_ppd_pps_id,
                                                                       19255);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_addtl_ppd_pps_id,
                                                                       19256);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_addtl_ppd_pps_id,
                                                                       19257);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_addtl_ppd_pps_id,
                                                                       19258);


  end if;


--this update parent to the appropriate parent
  if v_pending_addtl_ppd_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_addtl_ppd_pps_id
      and case
            when v_verify_addtl_ppd_pps_id is not null then
                id != v_verify_addtl_ppd_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_addtl_ppd_pps_id;
  end if;

  if v_verify_addtl_ppd_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_addtl_ppd_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_addtl_ppd_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


CREATE OR REPLACE function flow.migrate_schedule_addtl_permit_pack_submission_to_events(p_event_id integer,
                                                                                        p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_addtl_pps_pps_id integer;
  v_verify_addtl_pps_pps_id  integer;
BEGIN


  select id
  into v_pending_addtl_pps_pps_id
  from flow.project_process_step
  where process_step_id = 3100
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_addtl_pps_pps_id is not null then
    select id
    into v_verify_addtl_pps_pps_id
    from flow.project_process_step
    where process_step_id = 3101
      and parent_project_process_step_id = v_pending_addtl_pps_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;



  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19199);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19200);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19201);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19202);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19203);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19204);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19205);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22450);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22451);


  if v_pending_addtl_pps_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_addtl_pps_pps_id,
                                                                       19222);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_addtl_pps_pps_id,
                                                                       19223);
  end if;
  if v_verify_addtl_pps_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_addtl_pps_pps_id,
                                                                       19224);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_addtl_pps_pps_id,
                                                                       19225);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_addtl_pps_pps_id,
                                                                       19226);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_addtl_pps_pps_id,
                                                                       22002);


  end if;


--this update parent to the appropriate parent
  if v_pending_addtl_pps_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_addtl_pps_pps_id
      and case
            when v_verify_addtl_pps_pps_id is not null then
                id != v_verify_addtl_pps_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_addtl_pps_pps_id;
  end if;

  if v_verify_addtl_pps_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_addtl_pps_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_addtl_pps_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

