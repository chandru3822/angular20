CREATE OR REPLACE function flow.migrate_schedule_add_additional_resource_to_wo_to_events(p_event_id integer,
                                                                              p_project_process_step_id integer)
  returns void as
$$

BEGIN


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21951);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     21952);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

