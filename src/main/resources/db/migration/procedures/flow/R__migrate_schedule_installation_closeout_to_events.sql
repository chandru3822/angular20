CREATE OR REPLACE function flow.migrate_schedule_installation_closeout_to_events(p_event_id integer,
                                                                        p_project_process_step_id integer)
  returns void as
$$
BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     6660,
                                                                     p_project_process_step_id,
                                                                     null);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     6360,
                                                                     p_project_process_step_id,
                                                                     null);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

