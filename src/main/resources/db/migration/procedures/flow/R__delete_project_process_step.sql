drop function if exists flow.delete_project_process_step(p_project_process_step_id bigint, p_run_by_id bigint);
  create or replace function flow.delete_project_process_step(p_project_process_step_id bigint, p_run_by_id bigint)
returns boolean
as
$$
begin
insert into flow.company_function_log(function_name, parameters, run_by_id)
values ('Delete Project Process Step', 'p_project_process_step_id: ' || p_project_process_step_id ||
                                       ' p_run_by_id: ' || p_run_by_id,
        p_run_by_id);

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
