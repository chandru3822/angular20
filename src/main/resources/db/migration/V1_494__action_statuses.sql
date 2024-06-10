alter table if exists flow.process_step_action
add if not exists company_process_step_status_type_ids bigint[] default null,
add if not exists process_step_status_type_ids bigint[] default null;

drop function if exists flow.get_pps_with_actions_and_requirements(p_project_process_step_id bigint, p_company_id bigint, p_systemAdmin boolean, p_userPositions bigint[]);