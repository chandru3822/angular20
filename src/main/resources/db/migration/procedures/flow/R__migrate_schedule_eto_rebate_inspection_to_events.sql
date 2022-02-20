CREATE OR REPLACE function flow.migrate_schedule_eto_rebate_inspection_to_events(p_event_id integer,
                                                                             p_project_process_step_id integer)
  returns void as
$$
BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21132);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21536);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21131);


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

