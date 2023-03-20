insert into flow.white_list_type (white_list_type)
select 'EVENT_HIDDEN' WHERE not exists (select id from flow.white_list_type where white_list_type.white_list_type = 'EVENT_HIDDEN');

alter table if exists  flow.event
	add column if not exists hidden boolean default false not null;

drop function if exists flow.get_pps_with_actions_and_requirements(p_project_process_step_id bigint, p_company_id bigint);

