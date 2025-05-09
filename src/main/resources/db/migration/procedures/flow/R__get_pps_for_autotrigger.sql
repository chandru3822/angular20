drop function if exists flow.get_pps_for_autotrigger(p_project_process_step_id bigint, p_company_id bigint);
create or replace function flow.get_pps_for_autotrigger(p_project_process_step_id bigint, p_company_id bigint)
    returns json as
$$
declare
    v_json json;

begin

select row_to_json(sub_rows)
into v_json
from (
    with reqs as (
        -- This query is where we'll join in the already run actions and exclude those
        select array_agg(psl.process_step_requirement_id) as ids
        from flow.process_step_action_logic psl
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
        pps.date_created as "dateCreated",
        ps.id as "processStepId",
        ps.company_id as "companyId",
        ps.readonly,
        ps.readonly_allow as "readonlyAllow",
        pps.id as "projectProcessStepId",
        pps.project_id as "projectId",
        pps.process_step_complete_date as "processStepCompleteDate",
        pps.main as "main",
        p.contact_id as "contactId",
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
        coalesce((select array_to_json(array_agg(row_to_json(a))) from (
            select
                psa.id,
                psa.process_step_id as "processStepId",
                psa.trigger_automatically as "triggerAutomatically",
                psa.multiple_uses as "multipleUses",
                psa.remove_process_step_owner as "removeProcessStepOwner",
                psa.action_name as "actionName",
                psa.action_type_id as "actionTypeId",
                psa.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
                psa.company_project_status_type_id as "companyProjectStatusTypeId",
                psa.display_order as "displayOrder",
                psa.always_enabled as "alwaysEnabled",
                coalesce(psa.company_process_step_status_type_ids, array[]::bigint[]) as "companyProcessStepStatusTypeIds",
                coalesce(psa.process_step_status_type_ids, array[]::bigint[]) as "processStepStatusTypeIds",
                cpsst.process_step_status_type_id as "processStepStatusTypeId",
                cpsst.process_step_status_type as "processStepStatusType",
                at.action_type as "actionType",
                case when exists (
                    select id
                    from flow.project_process_step_action ppsa
                    where
                        ppsa.project_process_step_id = p_project_process_step_id and
                        ppsa.process_step_action_id = psa.id
                    limit 1
                )
                then true else false end as "alreadyTriggered",
                coalesce((
                    select array_to_json(array_agg(row_to_json(logic)))
                    from (
                        select
                            psl.id,
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
                        from flow.process_step_action_logic psl
                        left join flow.operation_type ot on ot.id = psl.operation_type_id
                        left join flow.process_step_requirement psr on psr.id = psl.process_step_requirement_id
                        where
                            psl.process_step_action_id = psa.id and
                            psl.archived is not true
                        order by psl.sql_order ) logic), '[]'
                    ) as "processStepLogicList",
                coalesce((
                    select array_to_json(array_agg(row_to_json(children)))
                    from (
                        select
                            psacp.id,
                            psacp.archived,
                            psacp.process_step_action_id as "processStepActionId",
                            psacp.existing_company_process_step_status_type_id as "existingCompanyProcessStepStatusTypeId",
                            psacp.initial_company_process_step_status_type_id as "initialCompanyProcessStepStatusTypeId",
                            psacp.process_step_id as "processStepId",
                            psacp.display_order as "displayOrder",
                            psacp.created_by_id as "createdById",
                            psacp.modified_by_id as "modifiedById",
                            psacp.reopen_primary_if_applicable as "reopenPrimaryIfApplicable",
                            ps.process_step_name as "processStepName",
                            (
                                select count(*)
                                from flow.process_step_action psa
                                where
                                    psa.process_step_id = ps.id and
                                    psa.trigger_automatically is true and
                                    psa.archived is not true
                            ) as "autoTriggerActionCount"
                        from flow.process_step_action_child_process psacp
                        inner join flow.process_step ps on ps.id = psacp.process_step_id
                        where psacp.process_step_action_id = psa.id and
                              psacp.archived is not true
                        order by psacp.display_order, ps.process_step_name
                ) children), '[]') as "processStepActionChildProcesses"
            from flow.process_step_action psa
            left join flow.company_process_step_status_type cpsst on cpsst.id = psa.company_process_step_status_type_id
            left join flow.company_project_status_type cpst on cpst.id = psa.company_project_status_type_id
            inner join flow.action_type at on at.id = psa.action_type_id
            where
                psa.process_step_id = ps.id and
                psa.archived is not true and
                psa.action_type_id != 3 -- 3 = banners
            order by psa.display_order
        ) a), '[]') as "actions"
    from reqs, flow.project_process_step pps
    inner join flow.process_step ps on ps.id = pps.process_step_id
    inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
    inner join flow.project p on p.id = pps.project_id
    inner join flow.company_process cp on cp.id = p.company_process_id
    where
        pps.id = p_project_process_step_id and
        pps.archived is false and
        ps.company_id = p_company_id
) as sub_rows;
return v_json;

end
$$
language plpgsql
volatile
cost 100;
