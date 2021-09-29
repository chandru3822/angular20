CREATE OR REPLACE function flow.migrate_schedule_resurvey_to_events(p_event_id integer,
                                                                    p_project_process_step_id integer)
  returns void as
$$

declare
  v_resurvey_pps_id                 integer;
  v_site_survey_verification_pps_id integer;
  v_schedule_resurvey_id            integer;
BEGIN

  select id
  into v_resurvey_pps_id
  from flow.project_process_step
  where process_step_id = 99
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_resurvey_pps_id is not null then
    select id
    into v_site_survey_verification_pps_id
    from flow.project_process_step
    where process_step_id = 3346
      and parent_project_process_step_id = v_resurvey_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  select id
  into v_schedule_resurvey_id
  from flow.event
  where temp_cfg_id = 121;
  -- this migrates Resurvey Details

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     308,
                                                                     p_project_process_step_id,
                                                                     null);


/*closeout details for resurvey*/

  if v_site_survey_verification_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 19360, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 19363, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 19364, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21122, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 20859, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21201, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21202, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21205, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21203, true,v_schedule_resurvey_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_site_survey_verification_pps_id, 21204, true,v_schedule_resurvey_id);
  end if;

  if v_resurvey_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_resurvey_pps_id, 1353);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_resurvey_pps_id, 1072);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null,
                                                                       v_resurvey_pps_id, 1006);
  end if;


--this update parent to the appropriate parent
  if v_resurvey_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_resurvey_pps_id
      and case
            when v_site_survey_verification_pps_id is not null then
              id != v_site_survey_verification_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_resurvey_pps_id;
  end if;

  if v_site_survey_verification_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_site_survey_verification_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_site_survey_verification_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

