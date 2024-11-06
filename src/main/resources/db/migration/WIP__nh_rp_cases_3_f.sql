SET session_replication_role = replica;
DO
$do$
  declare
    x                               record;
    v_project_process_step_id       bigint;
    v_project_process_step_event_id bigint;
    v_count bigint;
    v_total bigint;
  BEGIN
    raise notice '9 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    for x in select
               case_id,
               c.sub_categories_c,
               c.subject,
               c.jira_ticket_number_c,
               c.resolution_comment_c,
               project_id,
               lov1_category_c_id,
               lov3_status_id,
               c.record_type_id,
               case_number,
               c.owner_id,
               c.ORIGIN,
               c.created_date,
               c.closed_date,
               lov4_resolution_c_id,
               c.description,
               c.commitment_date_c,
               c.created_by_id,
               lov5_case_differentiator_c_id,
               lov6_location_c_id,
               c.requested_due_date_c,
               c.shipper_tracking_number_c,
               lov7_type_id,
               lov8_origin_id,
               lov9_sub_categories_id,
               case_created_by_id,
               case_owner_id,
               created_by_id_name,
              owner_id_name
             from brs.sp_case_vw1 c
      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;
        v_project_process_step_event_id = null;
        v_project_process_step_id = null;

        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and
          pps.process_step_id = 3788;

        if v_project_process_step_id is null then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id,nw_migration_id)
          values (x.project_id, 3788, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null,x.case_id)
          returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
        values (v_project_process_step_id, 238, null, 3, null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1,x.case_id)
        returning id into v_project_process_step_event_id;

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29949, x.created_by_id_name::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29950, x.owner_id_name::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 28351, x.lov1_category_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29237, x.sub_categories_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29878, x.lov9_sub_categories_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 28350, x.subject::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 28731, x.lov3_status_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 28352, x.jira_ticket_number_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 28353, x.resolution_comment_c::text, true);

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29786,
                                                 case when x.record_type_id = '01280000000379rAAA' then 25928::text
                                                                   when x.record_type_id = '01280000000379vAAA' then 25929::text
                                                                   when x.record_type_id = '01280000000379uAAA' then 25930::text
                                                                   when x.record_type_id = '01234000000M4kLAAS' then 25983::text
                                                                   when x.record_type_id = '01280000000Q1s0AAC' then 25984::text
                                                                   when x.record_type_id = '01280000000Q7JmAAK' then 25985::text
                                                                   when x.record_type_id = '0122T000000BqOYQA0' then 25986::text
                                                                   when x.record_type_id = '0122T000000HtNdQAK' then 25987::text
                                                                   when x.record_type_id = '01234000000UQNbAAO' then 25988::text
                                                                   when x.record_type_id = '01234000000QEUwAAO' then 25989::text
                                                                   when x.record_type_id = '012800000003M3lAAE' then 25990::text
                                                      else null end, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29787, x.case_number::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29788, x.case_owner_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29797, x.case_created_by_id::text, true);


        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29790, x.lov8_origin_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29791, x.created_date::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29793, x.closed_date::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29794, x.lov4_resolution_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29795, x.description::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29796, x.commitment_date_c::text, true);

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29799, x.lov5_case_differentiator_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29800, x.lov6_location_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29798, x.requested_due_date_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29801, x.shipper_tracking_number_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29851, x.lov7_type_id::text, true);


      end loop;
    raise notice '9 END = %',clock_timestamp();
    raise notice '9 END total = %',v_total;
  end
$do$;

SET session_replication_role = replica;
DO
$do$
  declare
    x                               record;
    v_project_process_step_id       bigint;
    v_project_process_step_event_id bigint;
    v_count bigint;
    v_total bigint;
  BEGIN
    raise notice '10 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    for x in select case_id,
                    c.sub_categories_c,
                    c.subject,
                    c.jira_ticket_number_c,
                    c.resolution_comment_c,
                    c.project_id,
                    lov1_category_c_id,
                    lov3_status_id,
                    c.record_type_id,
                    case_number,
                    c.owner_id,
                    c.ORIGIN,
                    c.created_date,
                    c.closed_date,
                    lov4_resolution_c_id,
                    c.description,
                    c.commitment_date_c,
                    c.created_by_id,
                    lov5_case_differentiator_c_id,
                    lov6_location_c_id,
                    c.requested_due_date_c,
                    c.shipper_tracking_number_c,
                    lov7_type_id,
                    lov8_origin_id,
                    lov9_sub_categories_id,
                     case_created_by_id,
                     case_owner_id,
                    created_by_id_name,
                    owner_id_name
             from brs.sp_case_vw c

      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          raise notice 'v_total = %',v_total;
          --commit;
          v_count = 0;
        end if;
        v_project_process_step_event_id = null;
        v_project_process_step_id = null;

        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and
          pps.process_step_id = 3788;

        if v_project_process_step_id is null then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id,nw_migration_id)
          values (x.project_id, 3788, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null,x.case_id)
          returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
        values (v_project_process_step_id, 238, null, 3, null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1,x.case_id)
        returning id into v_project_process_step_event_id;

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29949, x.created_by_id_name::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29950, x.owner_id_name::text, true);

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 28351, x.lov1_category_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29237, x.sub_categories_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29878, x.lov9_sub_categories_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 28350, x.subject::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 28731, x.lov3_status_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 28352, x.jira_ticket_number_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 28353, x.resolution_comment_c::text, true);

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29786,
                                                 case when x.record_type_id = '01280000000379rAAA' then 25928::text
                                                                                                       when x.record_type_id = '01280000000379vAAA' then 25929::text
                                                                                                       when x.record_type_id = '01280000000379uAAA' then 25930::text
                                                                                                       when x.record_type_id = '01234000000M4kLAAS' then 25983::text
                                                                                                       when x.record_type_id = '01280000000Q1s0AAC' then 25984::text
                                                                                                       when x.record_type_id = '01280000000Q7JmAAK' then 25985::text
                                                                                                       when x.record_type_id = '0122T000000BqOYQA0' then 25986::text
                                                                                                       when x.record_type_id = '0122T000000HtNdQAK' then 25987::text
                                                                                                       when x.record_type_id = '01234000000UQNbAAO' then 25988::text
                                                                                                       when x.record_type_id = '01234000000QEUwAAO' then 25989::text
                                                                                                       when x.record_type_id = '012800000003M3lAAE' then 25990::text
                                                      else null end, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29787, x.case_number::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29788, x.case_owner_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29797, x.case_created_by_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29790, x.lov8_origin_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29791, x.created_date::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29793, x.closed_date::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29794, x.lov4_resolution_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29795, x.description::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29796, x.commitment_date_c::text, true);

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29799, x.lov5_case_differentiator_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29800, x.lov6_location_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29798, x.requested_due_date_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29801, x.shipper_tracking_number_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_id, 2384850, 29851, x.lov7_type_id::text, true);
      end loop;
    raise notice '10 END = %',clock_timestamp();
    raise notice '10 END total = %',v_total;
  end
$do$;
