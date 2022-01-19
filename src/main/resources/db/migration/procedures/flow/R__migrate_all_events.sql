CREATE OR REPLACE function flow.migrate_all_events()
  returns void as
$$
declare
  v_site_survey_event_id                   integer;
  v_schedule_resurvey_id                   integer;
  v_cfg_id_98                              integer;
  v_cfg_id_40_io                           integer;
  v_cfg_id_40_ri                           integer;
  v_cfg_id_40_ns                           integer;
  v_ahj_inspection_sc_event_id             integer;
  v_ahj_inspection_nsc_event_id            integer;
  v_ahj_reinspection_wc_event_id           integer;
  v_cfg_id_153_io                          integer;
  v_cfg_id_153_ns                          integer;
  v_cfg_id_153_ri                          integer;
  v_installation_id                        integer;
  v_permit_pickup_delivery_id              integer;
  v_permit_submission_id                   integer;
  v_energization_id                        integer;
  v_retrofit_energization_id               integer;
  v_eto_rebate_inspection_id               integer;
  v_schedule_structural_upgrade_ns_id      integer;
  v_schedule_ac_compressor_id              integer;
  v_schedule_reroof_id                     integer;
  v_schedule_tree_trimming_id              integer;
  v_schedule_trenching_id                  integer;
  v_schedule_deadfront_id                  integer;
  v_non_standard_visit_id                  integer;
  v_meter_pull_id                          integer;
  v_outsource_mpu_id                       integer;
  v_inhouse_mpu_id                         integer;
  v_rma_work_order_id                      integer;
  v_rook_leak_repair_id                    integer;
  v_in_person_work_order_id                integer;
  v_in_person_work_order2_id               integer;
  v_in_person_work_order3_id               integer;
  v_add_arti_id                            integer;
  v_add_artwo                              integer;
  v_rarti                                  integer;
  v_mid_point_insepction_id                integer;
  v_permit_signature_id                    integer;
  v_additional_permit_signature_id         integer;
  v_asbuilt_permit_signature_id            integer;
  v_addtl_permit_pickup_delivery_id        integer;
  v_addtl_permit_pack_submission_id        integer;
  v_asbuilt_permit_pickup_delivery_id      integer;
  v_panel_removal_id                       integer;
  v_panel_reinstallation_id                integer;
  v_ahj_inspection_work_id                 integer;
  v_critter_guard_id                       integer;
  v_inhouse_mpu_inspection_id              integer;
  v_inhouse_mpu_permit_pickup_id           integer;
  v_retrofit_inspection_id                 integer;
  v_retrofit_inspection_correction_work_id integer;
  v_retrofit_installation_id               integer;
  v_retrofit_installation_closeout_work_id integer;
  v_retrofit_permit_submission_id          integer;
  v_retrofit_permit_pickup_delivery        integer;
  v_retrofit_meter_pull_id                 integer;
  v_retrofit_inhouse_mpu_id                integer;
  v_retrofit_outsource_mpu_id              integer;
  v_retrofit_trenching_id                  integer;
  v_retrofit_tree_trimming_id              integer;
  v_retrofit_structural_upgrade_id         integer;
  v_retrofit_site_survey_id                integer;
  v_additional_inspection_customer_id      integer;
  v_inhouse_mpu_permit_submission_id       integer;
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

  select id
  into v_retrofit_energization_id
  from flow.event
  where temp_cfg_id = 6811;

  select id
  into v_eto_rebate_inspection_id
  from flow.event
  where temp_cfg_id = 6706;

  select id
  into v_schedule_structural_upgrade_ns_id
  from flow.event
  where temp_cfg_id = 135;

  select id
  into v_schedule_ac_compressor_id
  from flow.event
  where temp_cfg_id = 139;

  select id
  into v_schedule_reroof_id
  from flow.event
  where temp_cfg_id = 136;

  select id
  into v_schedule_tree_trimming_id
  from flow.event
  where temp_cfg_id = 138;

  select id
  into v_schedule_trenching_id
  from flow.event
  where temp_cfg_id = 137;

  select id
  into v_schedule_deadfront_id
  from flow.event
  where temp_cfg_id = 143;

  select id
  into v_non_standard_visit_id
  from flow.event
  where temp_cfg_id = 6723;

  select id
  into v_meter_pull_id
  from flow.event
  where temp_cfg_id = 6329;

  select id
  into v_outsource_mpu_id
  from flow.event
  where temp_cfg_id = 133;

  select id
  into v_inhouse_mpu_id
  from flow.event
  where temp_cfg_id = 76;

  select id
  into v_rma_work_order_id
  from flow.event
  where temp_cfg_id = 7006;

  select id
  into v_rook_leak_repair_id
  from flow.event
  where temp_cfg_id = 6692;

  select id
  into v_in_person_work_order_id
  from flow.event
  where temp_cfg_id = 64;

  select id
  into v_in_person_work_order2_id
  from flow.event
  where temp_cfg_id = 5656;

  select id
  into v_in_person_work_order3_id
  from flow.event
  where temp_cfg_id = 5661;

  select id
  into v_add_arti_id
  from flow.event
  where temp_cfg_id = 6163;

  select id
  into v_add_artwo
  from flow.event
  where temp_cfg_id = 6965;

  select id
  into v_rarti
  from flow.event
  where temp_cfg_id = 6840;

  select id
  into v_mid_point_insepction_id
  from flow.event
  where temp_cfg_id = 298;

  select id
  into v_permit_signature_id
  from flow.event
  where temp_cfg_id = 48;

  select id
  into v_additional_permit_signature_id
  from flow.event
  where temp_cfg_id = 6255;

  select id
  into v_asbuilt_permit_signature_id
  from flow.event
  where temp_cfg_id = 232;

  select id
  into v_addtl_permit_pickup_delivery_id
  from flow.event
  where temp_cfg_id = 6243;

  select id
  into v_addtl_permit_pack_submission_id
  from flow.event
  where temp_cfg_id = 6230;

  select id
  into v_asbuilt_permit_pickup_delivery_id
  from flow.event
  where temp_cfg_id = 240;

  select id
  into v_panel_removal_id
  from flow.event
  where temp_cfg_id = 6322;

  select id
  into v_panel_reinstallation_id
  from flow.event
  where temp_cfg_id = 6325;

  select id
  into v_ahj_inspection_work_id
  from flow.event
  where temp_cfg_id = 81;

  select id
  into v_critter_guard_id
  from flow.event
  where temp_cfg_id = 6960;

  select id
  into v_inhouse_mpu_inspection_id
  from flow.event
  where temp_cfg_id = 304;

  select id
  into v_inhouse_mpu_permit_pickup_id
  from flow.event
  where temp_cfg_id = 187;

  select id
  into v_retrofit_inspection_id
  from flow.event
  where temp_cfg_id = 6763;

  select id
  into v_retrofit_inspection_correction_work_id
  from flow.event
  where temp_cfg_id = 6781;

  select id
  into v_retrofit_installation_id
  from flow.event
  where temp_cfg_id = 6633;

  select id
  into v_retrofit_installation_closeout_work_id
  from flow.event
  where temp_cfg_id = 6949;

  select id
  into v_retrofit_permit_submission_id
  from flow.event
  where temp_cfg_id = 6630;

  select id
  into v_retrofit_permit_pickup_delivery
  from flow.event
  where temp_cfg_id = 6642;

  select id
  into v_retrofit_meter_pull_id
  from flow.event
  where temp_cfg_id = 6915;

  select id
  into v_retrofit_inhouse_mpu_id
  from flow.event
  where temp_cfg_id = 6875;

  select id
  into v_retrofit_outsource_mpu_id
  from flow.event
  where temp_cfg_id = 6906;

  select id
  into v_retrofit_trenching_id
  from flow.event
  where temp_cfg_id = 6931;

  select id
  into v_retrofit_tree_trimming_id
  from flow.event
  where temp_cfg_id = 6925;

  select id
  into v_retrofit_structural_upgrade_id
  from flow.event
  where temp_cfg_id = 6937;

  select id
  into v_retrofit_site_survey_id
  from flow.event
  where temp_cfg_id = 6616;

  select id
  into v_additional_inspection_customer_id
  from flow.event
  where temp_cfg_id = 279;

  select id
  into v_inhouse_mpu_permit_submission_id
  from flow.event
  where temp_cfg_id = 42;


  drop trigger if exists update_events_trg on flow.project_process_step_event;
  drop trigger if exists update_project_details_from_events_trg on flow.project_process_step_event_custom_field_value;
  drop trigger if exists project_process_step_event_custom_field_value_audit_trg ON flow.project_process_step_event_custom_field_value;
  drop trigger if exists concrete_project_process_step_event_audit_trg ON flow.project_process_step_event;
  drop trigger if exists project_process_step_audit_trg ON flow.project_process_step_custom_field_value;
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
  perform flow.migrate_insert_new_group('No-Show', 12, null, v_installation_id);
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

  raise notice 'starting retrofit Energization';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_energization_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_retrofit_energization_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_retrofit_energization_id);

  perform flow.migrate_events(3431);

  raise notice 'starting ETO Rebate Inspection';
  perform flow.migrate_insert_new_group('Details', 1, null, v_eto_rebate_inspection_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_eto_rebate_inspection_id);


  perform flow.migrate_events(129);

  raise notice 'starting schedule structure upgrade non standard';
  perform flow.migrate_insert_new_group('Details', 1, null, v_schedule_structural_upgrade_ns_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_schedule_structural_upgrade_ns_id);


  perform flow.migrate_events(138);

  raise notice 'starting schedule ac compressor relocation';
  perform flow.migrate_insert_new_group('Details', 1, null, v_schedule_ac_compressor_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_schedule_ac_compressor_id);


  perform flow.migrate_events(146);

  raise notice 'starting schedule reroof';
  perform flow.migrate_insert_new_group('Details', 1, null, v_schedule_reroof_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_schedule_reroof_id);


  perform flow.migrate_events(140);

  raise notice 'starting schedule tree trimming';
  perform flow.migrate_insert_new_group('Details', 1, null, v_schedule_tree_trimming_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_schedule_tree_trimming_id);


  perform flow.migrate_events(144);

  raise notice 'starting schedule trenching';
  perform flow.migrate_insert_new_group('Details', 1, null, v_schedule_trenching_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_schedule_trenching_id);


  perform flow.migrate_events(142);

  raise notice 'starting schedule deadfront';
  perform flow.migrate_insert_new_group('Details', 1, null, v_schedule_deadfront_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_schedule_deadfront_id);


  perform flow.migrate_events(148);

  raise notice 'starting schedule non standard visit';
  perform flow.migrate_insert_new_group('Details', 1, null, v_non_standard_visit_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_non_standard_visit_id);


  perform flow.migrate_events(3414);

  raise notice 'starting schedule meter pull';
  perform flow.migrate_insert_new_group('Details', 1, null, v_meter_pull_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_meter_pull_id);


  perform flow.migrate_events(3362);

  raise notice 'starting schedule outsource mpu';
  perform flow.migrate_insert_new_group('Details', 1, null, v_outsource_mpu_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_outsource_mpu_id);


  perform flow.migrate_events(134);

  raise notice 'starting schedule inhouse mpu';
  perform flow.migrate_insert_new_group('Details', 1, null, v_inhouse_mpu_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_inhouse_mpu_id);


  perform flow.migrate_events(28);

  raise notice 'starting schedule rma work order';
  perform flow.migrate_insert_new_group('Details', 1, null, v_rma_work_order_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_rma_work_order_id);


  perform flow.migrate_events(3487);

  raise notice 'starting schedule roof leak repair';
  perform flow.migrate_insert_new_group('Details', 1, null, v_rook_leak_repair_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_rook_leak_repair_id);


  perform flow.migrate_events(3409);

  raise notice 'starting schedule in person work order';
  perform flow.migrate_insert_new_group('Details', 1, null, v_in_person_work_order_id);
  perform flow.migrate_insert_new_group('Reschedule Details', 2, null, v_in_person_work_order_id);
  perform flow.migrate_insert_new_group('Outcome', 3, null, v_in_person_work_order_id);
  perform flow.migrate_insert_new_group('No-Show', 4, null, v_in_person_work_order_id);

  perform flow.migrate_events(54);

  raise notice 'starting schedule in person work order2';
  perform flow.migrate_insert_new_group('Details', 1, null, v_in_person_work_order2_id);
  perform flow.migrate_insert_new_group('Reschedule Details', 2, null, v_in_person_work_order2_id);
  perform flow.migrate_insert_new_group('Outcome', 3, null, v_in_person_work_order2_id);
  perform flow.migrate_insert_new_group('No-Show', 4, null, v_in_person_work_order2_id);

  perform flow.migrate_events(2838);

  raise notice 'starting schedule in person work order3';
  perform flow.migrate_insert_new_group('Details', 1, null, v_in_person_work_order3_id);
  perform flow.migrate_insert_new_group('Reschedule Details', 2, null, v_in_person_work_order3_id);
  perform flow.migrate_insert_new_group('Outcome', 3, null, v_in_person_work_order3_id);
  perform flow.migrate_insert_new_group('No-Show', 4, null, v_in_person_work_order3_id);

  perform flow.migrate_events(2841);

  raise notice 'starting schedule add additional resource to install';
  perform flow.migrate_insert_new_group('Details', 1, null, v_add_arti_id);
  perform flow.migrate_events(3091);

  raise notice 'starting schedule add additional resource to work order';
  perform flow.migrate_insert_new_group('Details', 1, null, v_add_artwo);
  perform flow.migrate_events(3480);

  raise notice 'starting schedule add retrofit additional resource to install';
  perform flow.migrate_insert_new_group('Details', 1, null, v_rarti);
  perform flow.migrate_events(3441);

  raise notice 'starting schedule Mid point inspection';
  perform flow.migrate_insert_new_group('Details', 1, null, v_mid_point_insepction_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_mid_point_insepction_id);
  perform flow.migrate_insert_new_group('Reschedule Details', 3, null, v_mid_point_insepction_id);


  perform flow.migrate_events(165);

  raise notice 'starting permit signature';
  perform flow.migrate_insert_new_group('Details', 1, null, v_permit_signature_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_permit_signature_id);


  perform flow.migrate_events(66);

  raise notice 'starting additional permit signature';
  perform flow.migrate_insert_new_group('Details', 1, null, v_additional_permit_signature_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_additional_permit_signature_id);


  perform flow.migrate_events(3107);

  raise notice 'starting asbuilt permit signature';
  perform flow.migrate_insert_new_group('Details', 1, null, v_asbuilt_permit_signature_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_asbuilt_permit_signature_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_asbuilt_permit_signature_id);


  perform flow.migrate_events(192);

  raise notice 'starting additional permit pickup and delivery';
  perform flow.migrate_insert_new_group('Details', 1, null, v_addtl_permit_pickup_delivery_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_addtl_permit_pickup_delivery_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_addtl_permit_pickup_delivery_id);


  perform flow.migrate_events(3103);

  raise notice 'starting additional permit pickup and delivery';
  perform flow.migrate_insert_new_group('Details', 1, null, v_addtl_permit_pack_submission_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_addtl_permit_pack_submission_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_addtl_permit_pack_submission_id);


  perform flow.migrate_events(3099);

  raise notice 'starting asbuilt permit pickup and delivery';
  perform flow.migrate_insert_new_group('Details', 1, null, v_asbuilt_permit_pickup_delivery_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_asbuilt_permit_pickup_delivery_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_asbuilt_permit_pickup_delivery_id);


  perform flow.migrate_events(196);

  raise notice 'starting panel removal';
  perform flow.migrate_insert_new_group('Details', 1, null, v_panel_removal_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_panel_removal_id);
  perform flow.migrate_insert_new_group('No-Show', 3, null, v_panel_removal_id);


  perform flow.migrate_events(3359);

  raise notice 'starting panel re-installation ';
  perform flow.migrate_insert_new_group('Details', 1, null, v_panel_reinstallation_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_panel_reinstallation_id);
  perform flow.migrate_insert_new_group('No-Show', 3, null, v_panel_reinstallation_id);


  perform flow.migrate_events(3360);

  raise notice 'starting schedule AHJ inspection work';
  perform flow.migrate_insert_new_group('Details', 1, null, v_ahj_inspection_work_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_ahj_inspection_work_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_ahj_inspection_work_id);
  perform flow.migrate_insert_new_group('No-Show', 4, null, v_ahj_inspection_work_id);

  perform flow.migrate_events(44);

  raise notice 'starting schedule critter guard';
  perform flow.migrate_insert_new_group('Details', 1, null, v_critter_guard_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_critter_guard_id);
  perform flow.migrate_insert_new_group('No-Show', 3, null, v_critter_guard_id);
  perform flow.migrate_insert_new_group('Reschedule', 4, null, v_critter_guard_id);


  perform flow.migrate_events(3479);

  raise notice 'starting schedule in-house mpu inspection';
  perform flow.migrate_insert_new_group('Details', 1, null, v_inhouse_mpu_inspection_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_inhouse_mpu_inspection_id);


  perform flow.migrate_events(222);

  raise notice 'starting in-house mpu permit pack pickup';
  perform flow.migrate_insert_new_group('Details', 1, null, v_inhouse_mpu_permit_pickup_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_inhouse_mpu_permit_pickup_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_inhouse_mpu_permit_pickup_id);

  perform flow.migrate_events(172);

  raise notice 'starting retrofit inspection';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_inspection_id);
  perform flow.migrate_insert_new_group('Schedule with AHJ', 2, null, v_retrofit_inspection_id);
  perform flow.migrate_insert_new_group('Outcome', 3, null, v_retrofit_inspection_id);
  perform flow.migrate_insert_new_group('No-Show', 4, null, v_retrofit_inspection_id);
  perform flow.migrate_insert_new_group('Reschedule', 5, null, v_retrofit_inspection_id);
  perform flow.migrate_insert_new_group('Inspection Disposition', 6, null, v_retrofit_inspection_id);

  perform flow.migrate_events(3427);

  raise notice 'starting retrofit inspection Correction work';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_inspection_correction_work_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_retrofit_inspection_correction_work_id);
  perform flow.migrate_insert_new_group('No-Show', 3, null, v_retrofit_inspection_correction_work_id);
  perform flow.migrate_insert_new_group('Reschedule', 4, null, v_retrofit_inspection_correction_work_id);


  perform flow.migrate_events(3428);

  raise notice 'starting retrofit installation';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_installation_id);
  perform flow.migrate_insert_new_group('Material Delivery Materials', 2, null, v_retrofit_installation_id);
  perform flow.migrate_insert_new_group('Installer Feedback', 3, null, v_retrofit_installation_id);
  perform flow.migrate_insert_new_group('Outcome', 4, null, v_retrofit_installation_id);


  perform flow.migrate_events(3397);

  raise notice 'starting retrofit installation Close out Work';
  perform flow.migrate_insert_new_group('Closeout Work Details', 1, null, v_retrofit_installation_closeout_work_id);
  perform flow.migrate_insert_new_group('Closeout Work Outcome', 2, null, v_retrofit_installation_closeout_work_id);


  perform flow.migrate_events(3478);

  raise notice 'starting retrofit permit submission';
  perform flow.migrate_insert_new_group('Online Submission', 1, null, v_retrofit_permit_submission_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_retrofit_permit_submission_id);


  perform flow.migrate_events(3395);

  raise notice 'starting retrofit permit pickup and delivery';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_permit_pickup_delivery);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_retrofit_permit_pickup_delivery);


  perform flow.migrate_events(3399);

  raise notice 'starting retrofit meter pull';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_meter_pull_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_retrofit_meter_pull_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_retrofit_meter_pull_id);


  perform flow.migrate_events(3471);

  raise notice 'starting retrofit inhouse mpu';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_inhouse_mpu_id);
  perform flow.migrate_insert_new_group('Audit', 2, null, v_retrofit_inhouse_mpu_id);
  perform flow.migrate_insert_new_group('Outcome', 3, null, v_retrofit_inhouse_mpu_id);
  perform flow.migrate_insert_new_group('Reschedule', 4, null, v_retrofit_inhouse_mpu_id);


  perform flow.migrate_events(3459);

  raise notice 'starting retrofit outsource mpu';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_outsource_mpu_id);
  perform flow.migrate_insert_new_group('Audit', 2, null, v_retrofit_outsource_mpu_id);
  perform flow.migrate_insert_new_group('Outcome', 3, null, v_retrofit_outsource_mpu_id);
  perform flow.migrate_insert_new_group('Reschedule', 4, null, v_retrofit_outsource_mpu_id);


  perform flow.migrate_events(3470);

  raise notice 'starting retrofit trenching';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_trenching_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_retrofit_trenching_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_retrofit_trenching_id);


  perform flow.migrate_events(3473);

  raise notice 'starting retrofit tree trimming';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_tree_trimming_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_retrofit_tree_trimming_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_retrofit_tree_trimming_id);


  perform flow.migrate_events(3472);

  raise notice 'starting retrofit structural upgrade';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_structural_upgrade_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_retrofit_structural_upgrade_id);
  perform flow.migrate_insert_new_group('Reschedule', 3, null, v_retrofit_structural_upgrade_id);


  perform flow.migrate_events(3474);

  raise notice 'starting retrofit site survey';
  perform flow.migrate_insert_new_group('Details', 1, null, v_retrofit_site_survey_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_retrofit_site_survey_id);


  perform flow.migrate_events(3391);

  raise notice 'starting additional inspection with customer';
  perform flow.migrate_insert_new_group('Details', 1, null, v_additional_inspection_customer_id);
  perform flow.migrate_insert_new_group('Schedule with AHJ', 2, null, v_additional_inspection_customer_id);
  perform flow.migrate_insert_new_group('Outcome', 3, null, v_additional_inspection_customer_id);
  perform flow.migrate_insert_new_group('Reschedule', 4, null, v_additional_inspection_customer_id);
  perform flow.migrate_insert_new_group('No-Show', 5, null, v_additional_inspection_customer_id);


  perform flow.migrate_events(170);

  raise notice 'starting in house mpu permit submission';
  perform flow.migrate_insert_new_group('Details', 1, null, v_inhouse_mpu_permit_submission_id);
  perform flow.migrate_insert_new_group('Outcome', 2, null, v_inhouse_mpu_permit_submission_id);
  perform flow.migrate_insert_new_group('No-Show', 3, null, v_inhouse_mpu_permit_submission_id);
  perform flow.migrate_insert_new_group('Reschedule', 4, null, v_inhouse_mpu_permit_submission_id);



  perform flow.migrate_events(25);


  --this updates all project_details
  raise notice 'starting update project details';
   perform flow.migrate_update_project_details();

  CREATE TRIGGER project_process_step_event_custom_field_value_audit_trg
    after INSERT or update or delete
    ON flow.project_process_step_event_custom_field_value
    FOR EACH ROW
  EXECUTE PROCEDURE flow.project_process_step_event_custom_field_audit();


  CREATE TRIGGER concrete_project_process_step_event_audit_trg
    after INSERT or update
    ON flow.project_process_step_event
    FOR EACH ROW
  EXECUTE PROCEDURE flow.concrete_project_process_step_event_audit();


  CREATE TRIGGER update_project_details_from_events_trg
    after INSERT or update
    ON flow.project_process_step_event_custom_field_value
    FOR EACH ROW
  EXECUTE PROCEDURE flow.update_project_details_process_steps_from_events();


  CREATE TRIGGER update_events_trg
    after INSERT or update
    ON flow.project_process_step_event
    FOR EACH ROW
  EXECUTE PROCEDURE flow.update_events();

  CREATE TRIGGER project_process_step_audit_trg
    after INSERT or update or delete ON flow.project_process_step_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.project_process_step_audit();

  --TODO  insert into brs.project_detail_events_config
insert into brs.project_detail_events_config(company_id, process_step_event_id, field_to_update, field_to_use, display_name, second_field_to_update, update_first_value_only, update_first_value_only_id)
(
  select 3,pse.id,pdc.field_to_update,
         case when cfga.schedule_field_type_id = 1 then
           'start_time' when cfga.schedule_field_type_id = 2 then 'end_time'
             when cfga.schedule_field_type_id = 3 then 'resource_id' end,
           pdc.display_name,pdc.second_field_to_update,pdc.update_first_value_only,pdc.update_first_value_only_id
  from brs.project_details_config pdc
         inner join flow.custom_field_group_assignment cfga on cfga.id = pdc.custom_field_group_assignment_id
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
         inner join flow.process_step ps on ps.id = cfg.process_step_id
         inner join flow.event e on e.temp_cfg_id = cfg.id
         inner join flow.process_step_event pse on pse.event_id = e.id and pse.process_step_id = ps.id
  where pdc.company_id = 3 and cfga.schedule_field_type_id in (1,2,3) and cfga.archived is false);

update brs.project_detail_events_config
  set update_first_value_only_id = 'permit_pack_submittal_end_time_ppse_id'
  where update_first_value_only_id = 'permit_pack_submittal_end_time_ppsecfv_id';
  update brs.project_detail_events_config
  set update_first_value_only_id = 'ahj_inspection_start_time_ppse_id'
  where update_first_value_only_id = 'ahj_inspection_start_time_ppsecfv_id';



  delete
  from brs.project_details_config
  where field_to_update = 'closer_user_position_id';

  delete
  from brs.project_details_config
  where field_to_update = 'closer_appointment_end';

  delete
  from brs.project_details_config
  where field_to_update = 'closer_appointment_start';

  delete
  from brs.project_details_config
  where field_to_update in ('ahj_inspection_end_time','ahj_inspection_end_time','in_house_mpu_end_time',
                            'in_house_mpu_start_time','installation_closeout_resource','in_house_mpu_permit_submittal_end_date',
                            'in_house_mpu_permit_submittal_start_date','installation_closeout_start_time','installation_closeout_end_time',
                            'non_standard_installation_work_end_time','non_standard_installation_work_start_time','non_standard_installation_resource',
                            'permit_pack_submittal_start_time','permit_pickup_end_time','permit_pickup_start_time','in_house_mpu_resource',
                            'in_house_mpu_resource','structural_upgrade_resource','work_order_resource','site_survey_start_time','work_order_end_time',
                            'work_order_start_time','in_house_mpu_end_time','outsource_mpu_end_time','reroof_end_time','structural_upgrade_end_time',
                            'tree_trimming_end_time','trenching_end_time','ac_compressor_relocation_resource','ac_compressor_relocation_end_time',
                            'in_house_mpu_start_time','outsource_mpu_start_time','reroof_start_time','structural_upgrade_start_time',
                            'outsource_mpu_resource','reroof_resource','tree_trimming_resource','trenching_resource','as_built_permit_pickup_resource',
                            'as_built_permit_submission_resource','in_house_mpu_permit_pickup_resource','ac_compressor_relocation_start_time',
                            'tree_trimming_start_time','trenching_start_time','in_house_mpu_permit_pickup_end_time','in_house_mpu_permit_pickup_start_time',
                            'installation_start_time','installation_end_time','ahj_reinspection_start_time','ahj_inspection_start_time',
                            'site_survey_completed_date','additional_ahj_inspection_date','ahj_inspection_work_date','energization_visit_date',
                            'resurvey_date','as_built_permit_pickup_date','installation_resource','permit_pack_submittal_resource',
                            'in_house_mpu_permit_submittal_resource','permit_pickup_resource','permit_pack_submittal_end_time','ahj_inspection_start_time');

  /*This updates all custom fields for Events to be a part of the event company_object_type*/
  with update_data as (
    select cf.id
    from flow.custom_field_group_assignment cfga
           inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.archived is false
           inner join flow.custom_field cf on cfga.custom_field_id = cf.id and cf.archived is false
    where cfg.event_id is not null
      and cfga.archived is false)
  insert into flow.custom_field_object_type (custom_field_id, company_object_type_id,
                                      date_created, created_by_id)
   (select ud.id,(select cot.id from flow.company_object_type cot
                                       inner join flow.object_type ot on ot.id = cot.object_type_id where company_id = 3
                                                                                                      and ot.object_code = 'EVENT'),now(),2350555
     from update_data ud)
  on conflict do nothing;

  drop table if exists flow.migration_child_process_step;

  update brs.project_detail_events_config
  set update_first_value_only_id = 'ahj_inspection_start_time_ppse_id'
  where update_first_value_only_id = 'ahj_inspection_start_time_ppscfv_id';

  update brs.project_detail_events_config
  set update_first_value_only_id = 'permit_pack_submittal_end_time_ppse_id'
  where update_first_value_only_id = 'permit_pack_submittal_end_time_ppscfv_id';

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

