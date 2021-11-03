CREATE OR REPLACE function flow.migrate_schedule_retrofit_site_survey_to_events(p_event_id integer,
                                                                              p_project_process_step_id integer)
  returns void as
$$

BEGIN






  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     20900);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     20901);







  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     20902);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     20903);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21165);


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

