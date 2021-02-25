insert into flow.process_step_requirement_type(process_step_requirement_type)
select 'Process Step - Status' where not exists (select * from flow.process_step_requirement_type where process_step_requirement_type = 'Process Step - Status');

alter table flow.process_step_requirement
add column if not exists reference_process_step_id int references flow.process_step(id);

alter table flow.process_step_requirement
    add column if not exists fail_if_no_reference_step_found boolean not null default false;

drop function if exists flow.get_project_process_step_requirements_with_values(INTEGER, INTEGER[]);
-- 2350550
-- 2845
-- 1
;
