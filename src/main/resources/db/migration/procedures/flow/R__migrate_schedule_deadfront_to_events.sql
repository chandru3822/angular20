CREATE OR REPLACE function flow.migrate_schedule_deadfront_to_events(p_event_id integer,
                                                                                           p_project_process_step_id integer)
  returns void as
$$
declare
  v_verify_deadfront_id  integer;
BEGIN
  select id
  into v_verify_deadfront_id
  from flow.project_process_step
  where process_step_id = 149
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19087);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17505);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17328);


  if v_verify_deadfront_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       p_project_process_step_id,
                                                                       553);
  end if;


  --this update parent to the appropriate parent


  if v_verify_deadfront_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_deadfront_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_deadfront_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

