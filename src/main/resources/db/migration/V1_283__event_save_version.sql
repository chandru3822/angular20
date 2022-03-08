alter table flow.project_process_step_event
add column if not exists save_version integer;

update flow.project_process_step_event
set save_version = 1
where save_version is null;

alter table flow.project_process_step_event alter column save_version set not null;
