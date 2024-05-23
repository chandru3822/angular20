drop function if exists flow.get_pps_with_actions_and_requirements(p_project_process_step_id bigint, p_company_id bigint);
  CREATE OR REPLACE FUNCTION flow.get_pps_with_actions_and_requirements(p_project_process_step_id bigint, p_company_id bigint)
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
             concat(creator.first_name, ' ', creator.last_name) as "createdBy",
             pps.date_created as "dateCreated",
             ps.id as "processStepId",
             ps.company_id as "companyId",
             ps.readonly,
             case when (select psat.id
                        from flow.process_step_attachment_type psat
                        where psat.process_step_id = ps.id
                          and psat.archived is false
                          and (psat.linkable is true or psat.allow_upload is true)
                        limit 1) is null then false else true end as "hasAttachmentTypesAssigned",
             coalesce((
                        SELECT array_to_json(array_agg(row_to_json(wlp)))
                        FROM (
                               SELECT wlp.id,
                                      wlp.position_id as "positionId",
                                      wlp.process_step_id as "processStepId",
                                      wlp.created_by_id as "createdById",
                                      wlp.modified_by_id as "modifiedById",
                                      wlp.archived
                               FROM flow.white_listed_position wlp
                               WHERE wlp.white_list_type_id = 9
                                 AND wlp.archived is not true
                                 and wlp.company_id = p_company_id
                                 and wlp.process_step_id = ps.id) wlp), '[]') AS "whiteListedPositions",
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
             psp.id as "processStepProcessId",
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
                    coalesce(psa.company_process_step_status_type_ids, array[]::bigint[]) as "companyProcessStepStatusTypeIds",
                    coalesce(psa.process_step_status_type_ids, array[]::bigint[]) as "processStepStatusTypeIds",
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
                                          FROM flow.process_step_action_logic psl
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
                                      ) links), '[]') AS "processStepActionLinks",
							(select ppsa.date_created
                                     from flow.project_process_step_action ppsa
                                     where ppsa.project_process_step_id = pps.id
										and ppsa.process_step_action_id = psa.id
                                     order by ppsa.date_created desc limit 1) as "actionRunDate",
							(select concat(u.first_name, ' ', left(u.last_name, 1))
							from flow.project_process_step_action ppsa
								     inner join flow."user" u on ppsa.created_by_id = u.id
							where ppsa.project_process_step_id = pps.id
							  and ppsa.process_step_action_id = psa.id
							order by ppsa.date_created desc limit 1) as "actionRunBy"
                from flow.process_step_action psa
                         left join flow.company_process_step_status_type cpsst on cpsst.id = psa.company_process_step_status_type_id
                         left join flow.company_project_status_type cpst on cpst.id = psa.company_project_status_type_id
                         inner join flow.action_type at on at.id = psa.action_type_id
                where psa.process_step_id = ps.id and
                    psa.archived is not true and
                      psa.action_type_id != 3 -- 3 = banners
                 order by psa.display_order
            ) a), '[]') as "actions",
             coalesce((select array_to_json(array_agg(row_to_json(a))) from (
                    select
                      psa.id,
                      psa.remove_process_step_owner as "removeProcessStepOwner",
                      psa.action_name as "actionName",
                      psa.content,
                      psa.bg_color as "bgColor",
                      psa.color,
                      false as "alreadyTriggered",
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
                                        FROM flow.process_step_action_logic psl
                                               left join flow.operation_type ot on ot.id = psl.operation_type_id
                                               left join flow.process_step_requirement psr on psr.id = psl.process_step_requirement_id
                                        WHERE psl.process_step_action_id = psa.id
                                          and psl.archived is not true
                                        ORDER BY psl.sql_order ) logic), '[]') AS "processStepLogicList",
                      psa.always_enabled as "alwaysEnabled",
                      psa.display_order as "displayOrder",
                      psa.action_type_id as "actionTypeId"
                    from flow.process_step_action psa
                    where psa.process_step_id = ps.id and
                      psa.archived is not true and
                        psa.action_type_id = 3 -- 3 = banners
                    order by psa.display_order
                  ) a), '[]') as "banners"
         from reqs, flow.project_process_step pps
                        inner join flow.process_step ps on ps.id = pps.process_step_id
                        inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
                        inner join flow.project p on p.id = pps.project_id
                        inner join flow.company_process cp on cp.id = p.company_process_id
                        left join flow.process_step_process psp on psp.process_step_id = pps.process_step_id and psp.company_process_id = cp.id and psp.archived is false
                        inner join flow."user" creator on creator.id = pps.created_by_id
         where pps.id = p_project_process_step_id and
               pps.archived is false and
               --this ensures that a user from company A cannot load pps details from company B
               ps.company_id = p_company_id
) as sub_rows;
RETURN v_json;
END;
$$
    LANGUAGE plpgsql
    VOLATILE
    COST 100;
