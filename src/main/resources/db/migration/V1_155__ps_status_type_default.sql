alter table flow.company_process_step_status_type
add column if not exists is_default boolean not null default false;

update flow.company_process_step_status_type
set is_default = true
where process_step_status_type_id = 1
and archived is not true;
