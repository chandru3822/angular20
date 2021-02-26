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
                    psa.hidden as "hidden",
                       psa.multiple_uses as "multipleUses",
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
            ) a), '[]') as "actions"
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
