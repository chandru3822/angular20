CREATE OR REPLACE function flow.migrate_all_events()
  returns void as
$$
declare
  v_site_survey_event_id integer;
BEGIN

  select id
  into v_site_survey_event_id
  from flow.event
  where temp_cfg_id = 6;
  drop trigger if exists update_project_details_from_events_trg on flow.project_process_step_event_custom_field_value;
--   raise notice 'starting Schedule closer appointment';
--   perform from flow.migrate_events(1);
  raise notice 'starting Site Survey Scheduling';
  perform flow.migrate_insert_new_group('Closeout Details', 3, null, v_site_survey_event_id);
  perform from flow.migrate_events(5);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

