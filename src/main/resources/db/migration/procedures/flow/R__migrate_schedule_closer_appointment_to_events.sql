CREATE OR REPLACE function flow.migrate_schedule_closer_appointment_to_events(p_event_id integer,
                                                                              p_project_process_step_id integer)
  returns void as
$$

declare
  v_closer_appointment_pps_id integer;
BEGIN


  select id
  into v_closer_appointment_pps_id
  from flow.project_process_step
  where process_step_id = 2
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

---Notes for closer


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1427);

  if v_closer_appointment_pps_id is not null then
    -- this migrates closer disposition
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       2,
                                                                       v_closer_appointment_pps_id,
                                                                       null);
    ---rework requests


    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       6670,
                                                                       v_closer_appointment_pps_id,
                                                                       null);

    --remote appointment
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_closer_appointment_pps_id,
                                                                       19033);
  end if;


--this update parent to the appropriate parent
  if v_closer_appointment_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_closer_appointment_pps_id;

    ---archives closer appointment project_process_step
    update flow.project_process_step
    set archived = true
    where id = v_closer_appointment_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

