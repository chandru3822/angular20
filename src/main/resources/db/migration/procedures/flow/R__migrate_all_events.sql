CREATE OR REPLACE function flow.migrate_all_events()
  returns void as
$$
declare
  v_site_survey_event_id integer;
  v_schedule_resurvey_id integer;
  v_cfg_id_98            integer;
BEGIN

  select id
  into v_site_survey_event_id
  from flow.event
  where temp_cfg_id = 6;
  select id
  into v_schedule_resurvey_id
  from flow.event
  where temp_cfg_id = 121;
  drop trigger if exists update_project_details_from_events_trg on flow.project_process_step_event_custom_field_value;
  raise notice 'starting Schedule closer appointment';
  perform from flow.migrate_events(1);
  raise notice 'starting Site Survey Scheduling';
  perform flow.migrate_insert_new_group('Closeout Details', 3, null, v_site_survey_event_id);
  perform from flow.migrate_events(5);

  raise notice 'starting Schedule Resurvey';
  select flow.migrate_insert_new_group('Closeout Details', 2, null, v_schedule_resurvey_id)
  into v_cfg_id_98;
  perform flow.migrate_insert_new_group('Reschedule Site Survey', 3, null, v_schedule_resurvey_id);
  perform flow.migrate_insert_new_group('No-Show', 4, null, v_schedule_resurvey_id);
  insert into flow.custom_field_group_assignment(custom_field_group_id, custom_field_id,
                                                 ancillary_custom_field_group_assignment_id,
                                                 field_order, archived, date_created, date_modified, created_by_id,
                                                 modified_by_id, schedule_field_type_id, read_only,
                                                 migrated_cfga_id, use_parent_data, hidden)
    (select v_cfg_id_98,
            custom_field_id,
            ancillary_custom_field_group_assignment_id,
            field_order,
            archived,
            date_created,
            date_modified,
            created_by_id,
            modified_by_id,
            schedule_field_type_id,
            read_only,
            cfga.id,
            use_parent_data,
            hidden
     from flow.custom_field_group_assignment cfga
     where id in (19360,
                  19363,
                  19364,
                  21122,
                  20859,
                  21201,
                  21202,
                  21205,
                  21203,
                  21204));
  perform from flow.migrate_events(98);


  --this updates all project_details
  --perform flow.migrate_update_project_details();

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

