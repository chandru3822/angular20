update flow.project_process_step_event
set modified_by_id = created_by_id
where modified_by_id is null;

alter table flow.project_process_step_event alter column modified_by_id set not null;
