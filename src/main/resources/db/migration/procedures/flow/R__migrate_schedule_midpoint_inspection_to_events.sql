CREATE OR REPLACE function flow.migrate_schedule_midpoint_inspection_to_events(p_event_id integer,
                                                                                p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_midpoint_pps_id       integer;
  v_verify_midpoint_pps_id integer;
BEGIN


  select id
  into v_pending_midpoint_pps_id
  from flow.project_process_step
  where process_step_id = 166
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_midpoint_pps_id is not null then
    select id
    into v_verify_midpoint_pps_id
    from flow.project_process_step
    where process_step_id = 167
      and parent_project_process_step_id = v_pending_midpoint_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1197);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1201);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1318);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17330);

  if v_pending_midpoint_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_midpoint_pps_id,
                                                                       1395);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_midpoint_pps_id,
                                                                       1394);
  end if;




  if v_verify_midpoint_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_midpoint_pps_id,
                                                                       641);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_midpoint_pps_id,
                                                                       642);

  end if;



--this update parent to the appropriate parent
  if v_pending_midpoint_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_midpoint_pps_id
      and case
            when v_verify_midpoint_pps_id is not null then
              id != v_verify_midpoint_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_midpoint_pps_id;
  end if;

  if v_verify_midpoint_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_midpoint_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_midpoint_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

