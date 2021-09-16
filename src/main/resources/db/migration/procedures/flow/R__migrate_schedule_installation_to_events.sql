CREATE OR REPLACE function flow.migrate_schedule_installation_to_events(p_event_id integer,
                                                                        p_project_process_step_id integer)
  returns void as
$$
BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     6347,
                                                                     p_project_process_step_id,
                                                                     null);


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     19661);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     19662);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     21015);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     19667);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     20994);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     21504);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     22019);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, p_project_process_step_id,
                                                                     19681);




END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

