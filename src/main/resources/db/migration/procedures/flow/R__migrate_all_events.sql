CREATE OR REPLACE function flow.migrate_all_events()
  returns void as
$$
declare
  v_site_survey_event_id         integer;
  v_schedule_resurvey_id         integer;
  v_cfg_id_98                    integer;
  v_cfg_id_40_io                 integer;
  v_cfg_id_40_ri                 integer;
  v_cfg_id_40_ns                 integer;
  v_ahj_inspection_sc_event_id   integer;
  v_ahj_inspection_nsc_event_id  integer;
  v_ahj_reinspection_wc_event_id integer;
  v_cfg_id_153_io                integer;
  v_cfg_id_153_ns                integer;
  v_cfg_id_153_ri                integer;
  v_installation_id              integer;
  v_permit_pickup_delivery_id    integer;
  v_permit_submission_id         integer;
  v_energization_id              integer;

BEGIN

  select id
  into v_site_survey_event_id
  from flow.event
  where temp_cfg_id = 6;
  select id
  into v_schedule_resurvey_id
  from flow.event
  where temp_cfg_id = 121;

  select id
  into v_ahj_inspection_sc_event_id
  from flow.event
  where temp_cfg_id = 181;

  select id
  into v_ahj_inspection_nsc_event_id
  from flow.event
  where temp_cfg_id = 57;

  select id
  into v_ahj_reinspection_wc_event_id
  from flow.event
  where temp_cfg_id = 5644;

  select id
  into v_installation_id
  from flow.event
  where temp_cfg_id = 6661;

  select id
  into v_permit_pickup_delivery_id
  from flow.event
  where temp_cfg_id = 47;

  select id
  into v_permit_submission_id
  from flow.event
  where temp_cfg_id = 28;

  select id
  into v_energization_id
  from flow.event
  where temp_cfg_id = 362;

  drop trigger if exists update_project_details_from_events_trg on flow.project_process_step_event_custom_field_value;
  raise notice 'starting Schedule closer appointment';
  perform flow.migrate_events(1);
  raise notice 'starting Site Survey Scheduling';
  perform flow.migrate_insert_new_group('Closeout Details', 3, null, v_site_survey_event_id);
  perform flow.migrate_events(5);

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
  perform flow.migrate_events(98);

  /*staring schedule AHJ inspection substantially complete*/
  raise notice 'starting Schedule AHJ inspection substantially complete';
  perform flow.migrate_insert_new_group('Inspection Outcome', 2, null, v_ahj_inspection_sc_event_id);
  perform flow.migrate_insert_new_group('Reschedule Inspection', 3, null, v_ahj_inspection_sc_event_id);
  perform flow.migrate_insert_new_group('No-Show', 4, null, v_ahj_inspection_sc_event_id);
  perform flow.migrate_events(168);


  /*staring schedule AHJ inspection not substantially complete*/
  raise notice 'starting Schedule AHJ inspection not substantially complete';
  select flow.migrate_insert_new_group('Inspection Outcome', 2, null, v_ahj_inspection_nsc_event_id)
  into v_cfg_id_40_io;
  select flow.migrate_insert_new_group('Reschedule Inspection', 3, null, v_ahj_inspection_nsc_event_id)
  into v_cfg_id_40_ri;
  select flow.migrate_insert_new_group('No-Show', 4, null, v_ahj_inspection_nsc_event_id)
  into v_cfg_id_40_ns;

  insert into flow.custom_field_group_assignment(custom_field_group_id, custom_field_id,
                                                 ancillary_custom_field_group_assignment_id,
                                                 field_order, archived, date_created, date_modified, created_by_id,
                                                 modified_by_id, schedule_field_type_id, read_only,
                                                 migrated_cfga_id, use_parent_data, hidden)
    (select v_cfg_id_40_io,
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
     where id in (
                  152,
                  153));
  insert into flow.custom_field_group_assignment(custom_field_group_id, custom_field_id,
                                                 ancillary_custom_field_group_assignment_id,
                                                 field_order, archived, date_created, date_modified, created_by_id,
                                                 modified_by_id, schedule_field_type_id, read_only,
                                                 migrated_cfga_id, use_parent_data, hidden)
    (select v_cfg_id_40_ri,
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
     where id in (
                  21609,
                  19027,
                  19028));
  insert into flow.custom_field_group_assignment(custom_field_group_id, custom_field_id,
                                                 ancillary_custom_field_group_assignment_id,
                                                 field_order, archived, date_created, date_modified, created_by_id,
                                                 modified_by_id, schedule_field_type_id, read_only,
                                                 migrated_cfga_id, use_parent_data, hidden)
    (select v_cfg_id_40_ns,
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
     where id in (998));
  perform from flow.migrate_events(40);

  raise notice 'starting Schedule AHJ Re-inspection with Customer';
  select flow.migrate_insert_new_group('Inspection Outcome', 2, null, v_ahj_reinspection_wc_event_id)
  into v_cfg_id_153_io;
  insert into flow.custom_field_group_assignment(custom_field_group_id, custom_field_id,
                                                 ancillary_custom_field_group_assignment_id,
                                                 field_order, archived, date_created, date_modified, created_by_id,
                                                 modified_by_id, schedule_field_type_id, read_only,
                                                 migrated_cfga_id, use_parent_data, hidden)
    (select v_cfg_id_153_io,
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
     where id in (
                  152,
                  153));

  select flow.migrate_insert_new_group('Reschedule Inspection', 3, null, v_ahj_reinspection_wc_event_id)
  into v_cfg_id_153_ri;
  select flow.migrate_insert_new_group('No-Show', 4, null, v_ahj_reinspection_wc_event_id)
  into v_cfg_id_153_ns;
  insert into flow.custom_field_group_assignment(custom_field_group_id, custom_field_id,
                                                 ancillary_custom_field_group_assignment_id,
                                                 field_order, archived, date_created, date_modified, created_by_id,
                                                 modified_by_id, schedule_field_type_id, read_only,
                                                 migrated_cfga_id, use_parent_data, hidden)
    (select v_cfg_id_153_ns,
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
     where id in (998));

  insert into flow.custom_field_group_assignment(custom_field_group_id, custom_field_id,
                                                 ancillary_custom_field_group_assignment_id,
                                                 field_order, archived, date_created, date_modified, created_by_id,
                                                 modified_by_id, schedule_field_type_id, read_only,
                                                 migrated_cfga_id, use_parent_data, hidden)
    (select v_cfg_id_153_ri,
            custom_field_id,
            ancillary_custom_field_group_assignment_id,
            cfga.field_order,
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
     where id in (
                  21609, 19027, 19028));
  perform flow.migrate_events(153);

  raise notice 'starting installation process';
  perform flow.migrate_insert_new_group('Details', 1, null, v_installation_id);
  perform flow.migrate_insert_new_group('Outcome', 3, null, v_installation_id);
  perform flow.migrate_insert_new_group('No-Show', 4, null, v_installation_id);
  perform flow.migrate_events(3365);


  raise notice 'starting installation closeout process';
  perform flow.migrate_events(3383);

  raise notice 'starting Permit pickup delivery';
  perform flow.migrate_events(16);

  raise notice 'starting Permit Submission';
  perform flow.migrate_insert_new_group('Details', 1, null, v_permit_submission_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_permit_submission_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_permit_submission_id);

  perform flow.migrate_events(13);

  raise notice 'starting Energization';
  perform flow.migrate_insert_new_group('Details', 1, null, v_energization_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_energization_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_energization_id);

  perform flow.migrate_events(85);


  --this updates all project_details
  raise notice 'starting update project details';
--   perform flow.migrate_update_project_details();

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

