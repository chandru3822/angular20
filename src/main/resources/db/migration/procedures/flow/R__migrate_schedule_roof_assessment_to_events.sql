CREATE OR REPLACE function flow.migrate_schedule_roof_assessment_to_events(p_event_id integer,
                                                                              p_project_process_step_id integer)
  returns void as
$$

BEGIN

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     7037,
                                                                     p_project_process_step_id,
                                                                     null);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     7038,
                                                                     p_project_process_step_id,
                                                                     null);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     7039,
                                                                     p_project_process_step_id,
                                                                     null);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

