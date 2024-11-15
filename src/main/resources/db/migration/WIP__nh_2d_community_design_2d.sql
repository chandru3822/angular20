SET session_replication_role = replica;
DO
$do$
  declare
    z                                      record;
    v_project_process_step_event_design_id bigint;
    v_project_process_step_design_id       bigint;
    v_deliver_to_c_id                      bigint[];
    v_total                                bigint;
  BEGIN
    raise notice 'NH Community Design START = %',clock_timestamp();
    v_total = 0;
    for z in select dc.revision_of_c,
                    dc.missing_information_c,
                    dc.date_design_must_be_completed_c,
                    dc.date_design_request_verified_c,
                    dc.estimated_completion_date_c,
                    dc.design_start_date_c,
                    dc.date_completed_design_reviewed_c,
                    dc.design_completed_date_c,
                    dc.actual_time_hours_c,
                    dc.reason_for_late_delivery_c,
                    dc.for_eor_review_date_c,
                    dc.for_eor_rejection_date_c,
                    dc.design_approved_c,
                    dc.date_design_signed_c,
                    dc.date_design_shipped_c,
                    dc.applied_for_permit_c,
                    dc.permit_award_actual_c,
                    dc.shared_with_builder_c,
                    dc.design_work_located_in_c,
                    dc.number_of_sets_c,
                    dc.delivery_tracking_number_c,
                    dc.deliver_to_c,
                    dc.notes_from_requester_c,
                    dc.status_c,
                    dc.id,
                    dc.record_type_id,
                    case when dc.design_c_project_designer_c is null and dc.project_designer_c is not null then
                           2495780::bigint
                         else
                           dc.design_c_project_designer_c end as design_c_project_designer_c,
                    dc.name,
                    case when dc.record_type_id = '0122T00000048KsQAI' then 25567
                         when dc.record_type_id = '01234000000YN8CAAW' then 25569
                         when dc.record_type_id = '01234000000YN8BAAW' then 25568
                         when dc.record_type_id = '01234000000YN8DAAW' then 25573
                         when dc.record_type_id = '01280000000PzMoAAK' then 25571
                         when dc.record_type_id = '0122T000000M81gQAC' then 25570
                         when dc.record_type_id = '0122T000000BqCNQA0' then 25994
                      else null
                          end as design_type,
                    dc.project_designer_c,
                    case when dc.design_c_owner_id is null and dc.owner_id is not null then
                           2495780::bigint
                         else
                           dc.design_c_owner_id end as design_c_owner_id,
                    concat(su.first_name,' ',su.email) as project_designer_c_name,
                    concat(su1.first_name,' ',su1.email) as owner_id_name,
                    dc.owner_id,
                    lov1.id          as lov1_mppp_revision_needed_c_id,
                    lov2.id          as lov2_nh_urgent_request_type_c_id,
                    lov3.id          as lov3_incoming_request_had_all_information_c_id,
                    lov4.id          as lov4_pdf_copy_only_c_id,
                    lov5.id          as lov5_electrical_pe_signature_c_id,
                    lov6.id          as lov6_structural_pe_signature_c_id,
                    lov7.id          as lov7_reason_level_1_c_id,
                    lov8.id          as lov8_reason_level_2_c_id,
                    p.id             as project_id,
                    co.id            as community_id,
                    CASE
                      WHEN row_number() OVER (PARTITION BY co.id ORDER BY co.id) = 1 THEN TRUE
                      ELSE FALSE END AS is_first_row
             from brs.DESIGN_C DC
                    left join brs.sp_user su on su.id = dc.project_designer_c
                    left join brs.sp_user su1 on su1.id = dc.owner_id
                    inner join brs.NH_COMMUNITY_C co on co.id = dc.new_homes_community_c
                    inner join flow.project p on p.nw_migration_id = co.id
                    left join flow.list_of_value lov1
                              on lov1.name = dc.mppp_revision_needed_c and lov1.parent_id = 25617
                    left join flow.list_of_value lov2
                              on lov2.name = dc.nh_urgent_request_type_c and lov2.parent_id = 25620
                    left join flow.list_of_value lov3
                              on lov3.name = dc.incoming_request_had_all_information_c and lov3.parent_id = 25632
                    left join flow.list_of_value lov4 on lov4.name = dc.pdf_copy_only_c::text and lov4.parent_id = 25504
                    left join flow.list_of_value lov5
                              on lov5.name = dc.electrical_pe_signature_c and lov5.parent_id = 25635
                    left join flow.list_of_value lov6
                              on lov6.name = dc.structural_pe_signature_c and lov6.parent_id = 25643
                    left join flow.list_of_value lov7
                              on lov7.name = dc.reason_level_1_c and lov7.parent_id = 25589
                    left join flow.list_of_value lov8
                              on lov8.name = dc.reason_level_2_c and lov8.parent_id = 25594
             where dc.is_deleted = false
             order by co.id
      loop
        v_total = v_total + 1;

        if z.is_first_row is true then
          v_project_process_step_design_id = null;
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (z.project_id, 3738, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null,
                  z.community_id)
          returning id into v_project_process_step_design_id;
        end if;


        v_project_process_step_event_design_id = null;
        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version,
                                                    nw_migration_id)
        values (v_project_process_step_design_id, 240, null,
                case
                  when z.status_c is null then 90
                  when z.status_c = 'Not Started' then 90
                  when z.status_c = 'Pending MP Completion' then 91
                  when z.status_c = 'In Progress' then 106
                  when z.status_c = 'Request for Information' then 92
                  when z.status_c = 'Pending Information' then 93
                  when z.status_c = 'Under Review' then 94
                  when z.status_c = 'Rejected' then 95
                  when z.status_c = 'Approved' and z.record_type_id = '01234000000YN8CAAW' then 20
                  when z.status_c = 'Approved' then 96
                  when z.status_c = 'For Plotting' then 97
                  when z.status_c = 'Reference Only' then 98
                  when z.status_c = 'Sent to Builder' then 99
                  when z.status_c = 'Submitted to AHJ' then 100
                  when z.status_c = 'Rejected with Comments' then 101
                  when z.status_c = 'Received AHJ Approval' then 102
                  when z.status_c = 'Delivered to Builder' then 103
                  when z.status_c = 'Revised' then 107
                  when z.status_c = 'Built Out' then 108
                  when z.status_c = 'Cancelled' then 104
                  when z.status_c = 'Engineering Research' then 105 end, null, null, now(), now(), 2384850, 2384850,
                false, null,
                null, null, 1, z.id)
        returning id into v_project_process_step_event_design_id;

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 29948,
                                                 z.project_designer_c_name::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 29947,
                                                 z.owner_id_name::text, true);

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28740,
                                                 z.design_c_project_designer_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28428,
                                                 z.revision_of_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28429,
                                                 z.lov7_reason_level_1_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28430,
                                                 z.lov8_reason_level_2_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28739,
                                                 z.lov1_mppp_revision_needed_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28426, z.name::text,
                                                 true);
        if z.design_type is not null then
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28427, z.design_type::text, true);
        end if;
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28741,
                                                 z.lov2_nh_urgent_request_type_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28742, z.design_c_owner_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28743,
                                                 z.lov3_incoming_request_had_all_information_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28744,
                                                 z.missing_information_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28745,
                                                 z.date_design_must_be_completed_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28746,
                                                 z.date_design_request_verified_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28747,
                                                 z.estimated_completion_date_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28748,
                                                 z.design_start_date_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28749,
                                                 z.date_completed_design_reviewed_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28750,
                                                 z.design_completed_date_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28751,
                                                 z.actual_time_hours_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28752,
                                                 z.reason_for_late_delivery_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28753,
                                                 z.for_eor_review_date_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28754,
                                                 z.for_eor_rejection_date_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28755,
                                                 z.design_approved_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28756,
                                                 z.date_design_signed_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28757,
                                                 z.date_design_shipped_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28758,
                                                 z.applied_for_permit_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28759,
                                                 z.permit_award_actual_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28760,
                                                 z.shared_with_builder_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28761,
                                                 z.design_work_located_in_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28762,
                                                 z.number_of_sets_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28763,
                                                 z.lov4_pdf_copy_only_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28764,
                                                 z.lov5_electrical_pe_signature_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28765,
                                                 z.lov6_structural_pe_signature_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28766,
                                                 z.delivery_tracking_number_c::text, true);
        v_deliver_to_c_id = null;
        if z.deliver_to_c is not null then
          select array_agg(lov.id)
          into v_deliver_to_c_id
          from (SELECT unnest(string_to_array(aggregated_column, ';')) deliver_to_c
                FROM (SELECT STRING_AGG(deliver_to_c, ';') AS aggregated_column
                      from brs.design_c d
                      where id = z.id) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.deliver_to_c and lov.parent_id = 25647;
          perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28767,
                                                   v_deliver_to_c_id::text,
                                                   true);
        end if;
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_event_design_id, 2384850, 28768,
                                                 z.notes_from_requester_c::text, true);
      end loop;

    raise notice 'NH Community Design END = %',clock_timestamp();
    raise notice 'NH Community Design Total = %',v_total;
  end
$do$;
