-- drop function if exists flow.set_main_project_process_step(int, int, int, int);

CREATE OR REPLACE FUNCTION flow.set_main_project_process_step(p_project_process_step_id int, p_active_company_process_step_status_type_id int, p_cancelled_company_process_step_status_type_id int, p_user_id int)
  RETURNS void
  LANGUAGE plpgsql AS
$$
DECLARE
  v_project_id int;
  v_process_step_id int;
  v_company_id int;
  v_company_active_status_ids int[];
  v_previous_main_project_process_step_id int;
  v_previous_main_company_process_step_status_type_id int;
BEGIN

  select pps.project_id, pps.process_step_id, cp.company_id into v_project_id, v_process_step_id, v_company_id
  from flow.project_process_step pps
         inner join flow.project p on p.id = pps.project_id
         inner join flow.company_process cp on cp.id = p.company_process_id
  where pps.id = p_project_process_step_id;

  -- Flip main flag on previous main step
  update flow.project_process_step
  set main = false,
      modified_by_id = p_user_id,
      date_modified = now()
  where
      project_id = v_project_id and
      process_step_id = v_process_step_id and
      main = true
  returning id, company_process_step_status_type_id into v_previous_main_project_process_step_id, v_previous_main_company_process_step_status_type_id;

  -- set main flag
  -- Set active status on current step if given new status isn't null (if the new main step is already complete, it can stay that way or become active)
  update flow.project_process_step
  set main = true,
      company_process_step_status_type_id = coalesce(p_active_company_process_step_status_type_id, company_process_step_status_type_id),
      modified_by_id = p_user_id,
      date_modified = now()
  where project_process_step.id = p_project_process_step_id;

  -- Grab the active statuses for this company
  select array(
    select id
    from flow.company_process_step_status_type
    where
       company_id = v_company_id and
       process_step_status_type_id = 1 and
       archived is not true
   ) into v_company_active_status_ids;

  IF v_previous_main_company_process_step_status_type_id = any(v_company_active_status_ids)
  THEN
    update flow.project_process_step
    set company_process_step_status_type_id = p_cancelled_company_process_step_status_type_id
    where id = v_previous_main_project_process_step_id;
  END IF;
END;
$$