CREATE OR REPLACE function flow.migrate_schedule_inhouse_mpu_inspection_to_events(p_event_id integer,
                                                                                        p_project_process_step_id integer)
  returns void as
$$

declare
  v_verify_inhouse_mpu_inspection_pps_id  integer;
BEGIN


  select id
  into v_verify_inhouse_mpu_inspection_pps_id
  from flow.project_process_step
  where process_step_id = 223
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;




  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19077);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19078);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17336);




  if v_verify_inhouse_mpu_inspection_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_inhouse_mpu_inspection_pps_id,
                                                                       1045);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_inhouse_mpu_inspection_pps_id,
                                                                       1046);



  end if;


  if v_verify_inhouse_mpu_inspection_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_inhouse_mpu_inspection_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_inhouse_mpu_inspection_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

