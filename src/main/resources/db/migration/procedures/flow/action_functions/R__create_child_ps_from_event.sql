drop function if exists flow.create_child_ps_from_event(integer, integer);
CREATE OR REPLACE FUNCTION flow.create_child_ps_from_event(p_pps_event_id integer, p_user_id integer,
                                                           p_process_step_id_to_create integer,
                                                           p_initial_cpsst_id integer, p_cancel_cpsst_id integer,
                                                           p_override_existing_active boolean)
  RETURNS integer
  LANGUAGE plpgsql AS
$$
DECLARE
  v_project_id              integer;
  v_company_id              integer;
  v_event_process_id        integer;
  v_process_step_process_id integer;
  v_process_step_event_id   integer;
  v_status_check_count      bigint;
  v_has_existing_active     boolean default true;
  v_canceled_is_canceled    boolean;
  v_active_is_active        boolean;
  v_created_pps_id          integer;
BEGIN

  --verify that the cancelled status is actually a cancelled status
  select process_step_status_type_id = 3
  into v_canceled_is_canceled
  from flow.company_process_step_status_type
  where id = p_cancel_cpsst_id;

  --verify that the initial status is actually an active status
  select process_step_status_type_id = 1
  into v_active_is_active
  from flow.company_process_step_status_type
  where id = p_initial_cpsst_id;

  -- get the company id, process_id and process_step_event_id using the pps_event_id
  select ps.company_id, psp.company_process_id, ppse.process_step_event_id, pps.project_id
  into v_company_id, v_event_process_id, v_process_step_event_id, v_project_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
         inner join flow.process_step ps on pps.process_step_id = ps.id
         inner join flow.process_step_process psp on ps.id = psp.process_step_id
  where ppse.id = p_pps_event_id;

  --get the process_id for the process step
  select psp.company_process_id
  into v_process_step_process_id
  from flow.process_step ps
         inner join flow.process_step_process psp on ps.id = psp.process_step_id
  where ps.id = p_process_step_id_to_create;

  -- get the number of statuses assigned to the event that match the initial and cancelled status (we verify that this is 2 every time)
  select count(1)
  into v_status_check_count
  from flow.process_step_company_process_step_status_type pscpsst
  where pscpsst.process_step_id = p_process_step_id_to_create
    and pscpsst.archived is false
    and pscpsst.company_process_step_status_type_id in (p_initial_cpsst_id, p_cancel_cpsst_id);

  if (p_override_existing_active is not true) then
    --if not override then check to see if there is already an active of the same ps_id
    select count(1) > 0
    into v_has_existing_active
    from flow.project_process_step pps2
           inner join flow.company_process_step_status_type cpsst on pps2.company_process_step_status_type_id = cpsst.id
    where pps2.project_id = v_project_id
      and pps2.process_step_id = p_process_step_id_to_create
      and cpsst.process_step_status_type_id = 1;
  end if;

  -- ensure that the pps_event_id and the p_process_step_id_to_create share the same process_id
  -- ensure the v_status_check_count is 2, must always be 2
  -- if overide then do it, if not override then check the existing count
  if (v_event_process_id = v_process_step_process_id AND v_status_check_count = 2 AND
      v_canceled_is_canceled is true AND v_active_is_active is true AND (
          p_override_existing_active is true OR (p_override_existing_active is false AND v_has_existing_active is false)
        )) then
    --do the insert of the pps
    select insert_project_process_step into v_created_pps_id from flow.insert_project_process_step(v_project_id, p_process_step_id_to_create, null, p_user_id,
                                             v_company_id, null, p_initial_cpsst_id, p_cancel_cpsst_id, p_pps_event_id);

    return v_created_pps_id::int;

  else
    return null::int;
  end if;


END;
$$
