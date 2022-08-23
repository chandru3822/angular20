drop function if exists flow.delete_project_process_step(p_project_process_step_id bigint);
  create or replace function flow.delete_project_process_step(p_project_process_step_id bigint)
returns boolean
as
$$
begin

update flow.project_process_step
set archived = true
where id = p_project_process_step_id;

update flow.project_process_step_attachment
set archived = true
where project_process_step_id = p_project_process_step_id;

update flow.project_process_step_note
set archived = true
where project_process_step_id = p_project_process_step_id;

update flow.project_process_step_custom_field_value
set archived = true
where project_process_step_id = p_project_process_step_id;

return true;

end;
$$
language plpgsql
COST 100;
