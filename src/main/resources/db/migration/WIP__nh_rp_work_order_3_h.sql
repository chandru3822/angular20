SET session_replication_role = replica;
-- DO
-- $do$
--   declare
--     x record;
--     v_project_process_step_id bigint;
--     v_project_process_step__event_id bigint;
--     v_lov_scope_of_work bigint[];
--     v_count bigint;
--     v_total bigint;
--   BEGIN
--     raise notice '12 START = %',clock_timestamp();
--     v_count = 0;
--     v_total = 0;
--     for x in select wo.*,p.id as project_id,
--                     lov1.id as  lov1_priority_id,
--                     lov2.id as  lov2_service_type_c_id,
--                     lov3.id as  lov3_disposition_reason_c_id,
--                     lov4.id as  lov4_inspection_type_c_id,
--                     lov5.id as  lov5_follow_up_reason_c_id
--              from brs.work_order wo
--                     inner join brs.account a on a.id = wo.account_id
--                     inner join flow.contact c on c.nw_migration_id = a.id
--                     inner join flow.project p on p.contact_id = c.id
--                     left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25526
--                     left join flow.list_of_value lov2 on lov2.name = wo.service_type_c and lov2.parent_id = 25809
--                     left join flow.list_of_value lov3 on lov3.name = wo.disposition_reason_c and lov3.parent_id = 225812
--                     left join flow.list_of_value lov4 on lov4.name = wo.inspection_type_c and lov4.parent_id = 25816
--                     left join flow.list_of_value lov5 on lov5.name = wo.follow_up_reason_c and lov5.parent_id = 25814
--              where wo.record_type_id in ('0122T000000HtKlQAK')
--
--
--       loop
--         v_count = v_count + 1;
--         v_total = v_total + 1;
--         if v_count = 5000 then
--           raise notice 'v_count = %',v_count;
--           --commit;
--           v_count = 0;
--         end if;
--         v_project_process_step_id = null;
--         v_project_process_step__event_id = null;
--         select id
--         into v_project_process_step_id
--         from flow.project_process_step pps
--         where pps.project_id = x.project_id and pps.process_step_id = 3797;
--
--         if v_project_process_step_id is null then
--           insert into flow.project_process_step (project_id, process_step_id, user_position_id,
--                                                  company_process_step_status_type_id,
--                                                  process_step_complete_date, date_created, date_modified, created_by_id,
--                                                  modified_by_id, archived, main, parent_project_process_step_id,
--                                                  cancelled_date, parent_project_process_step_event_id,nw_migration_id)
--           values (x.project_id, 3797, null,  1 , null, now(), now(), 2384850, 2384850, false,
--                   true , null, null, null,x.id)
--           returning id into v_project_process_step_id;
--         end if;
--
--         insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
--                                                     company_event_status_type_id, start_time, end_time,
--                                                     date_created,
--                                                     date_modified, created_by_id, modified_by_id, archived,
--                                                     cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
--         values (v_project_process_step_id, 273, null,
--                 case when x.status = 'New' then 119
--                      when x.status = 'Assigned' then 111
--                      when x.status = 'In Progress' then 106
--                      when x.status = 'Closed' then 115
--                      when x.status = 'Action Completed' then 112
--                      when x.status = 'Closed - Unresolved' then 113
--                      when x.status = 'Closed - Duplicate' then 114
--                      when x.status = 'Scheduled' then 120
--                      when x.status = 'Dispatched' then 116
--                      when x.status = 'Completed' then 3
--                      when x.status = 'Canceled' then 2
--                      when x.status = 'Pending Customer' then 117
--                      when x.status = 'Cannot Complete' then 118 else 119 end
--                  , null, null, now(), now(), 2384850, 2384850, false, null,
--                 null, null, 1,x.id)
--         returning id into v_project_process_step__event_id;
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29252, x.completed_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29253, flow.get_user_id_nh(x.owner_id::text)::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29254, x.lov1_priority_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29255, x.lov2_service_type_c_id::text,true);
--         v_lov_scope_of_work = null;
--         if x.scope_of_work_c is not null then
--           select array_agg(lov.id)
--           into v_lov_scope_of_work
--           from (
--                  SELECT unnest(string_to_array(aggregated_column, ';')) scope_of_work_c
--                  FROM (
--                         SELECT STRING_AGG(scope_of_work_c, ';') AS aggregated_column
--                         from brs.work_order w
--                         where id = x.id
--                       ) AS subquery) as foo
--                  inner join flow.list_of_value lov on lov.name = foo.scope_of_work_c and lov.parent_id = 25810;
--           perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29256, v_lov_scope_of_work::text,true);
--         end if;
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29257, x.requested_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29258, x.lov3_disposition_reason_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29270, x.additional_comments_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29259, x.sss_sent_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29269, x.lov4_inspection_type_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29260, x.scheduled_with_self_service_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29261, x.rescheduled_with_self_service_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29262, x.canceled_by_self_service_user_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29263, x.follow_up_work_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29264, x.lov5_follow_up_reason_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29265, x.follow_up_reason_details_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29266, x.subject::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29267, x.description::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29268, x.intake_notes_c::text,true);
--
--
--
--       end loop;
--     raise notice '12 END = %',clock_timestamp();
--     raise notice '12 END total = %',v_total;
--   end
-- $do$;

DO
$do$
  declare
    x                                record;
    v_project_process_step_id        bigint;
    v_project_process_step__event_id bigint;
    v_lov_scope_of_work bigint[];
    v_count bigint;
    v_total bigint;
  BEGIN
    v_count = 0;
    v_total = 0;
    raise notice '13 START = %',clock_timestamp();
    for x in select wo.completed_date_c,
                    wo.scope_of_work_c,
                    wo.id,
                    wo.requested_date_c,
                    wo.additional_comments_c,
                    wo.sss_sent_date_c,
                    wo.scheduled_with_self_service_c,
                    wo.rescheduled_with_self_service_c,
                    wo.canceled_by_self_service_user_c,
                    wo.follow_up_work_c,
                    wo.follow_up_reason_details_c,
                    wo.subject,
                    wo.description,
                    case when wo.work_order_owner_id is null and wo.owner_id is not null then
                           2495780::bigint
                         else
                           work_order_owner_id end as work_order_owner_id,
                    wo.intake_notes_c,
                    wo.status,
                    wo.owner_id,
                    p.id as project_id,
                    lov1.id as  lov1_priority_id,
                    lov2.id as  lov2_service_type_c_id,
                    lov3.id as  lov3_disposition_reason_c_id,
                    lov4.id as  lov4_inspection_type_c_id,
                    lov5.id as  lov5_follow_up_reason_c_id
             from brs.work_order wo
                    inner join brs.residential_project_c rpc on rpc.account_c = wo.account_id
                    inner join flow.project p on p.nw_migration_id = rpc.id
                    left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
                    left join flow.list_of_value lov2 on lov2.name = wo.service_type_c and lov2.parent_id = 25809
                    left join flow.list_of_value lov3 on lov3.name = wo.disposition_reason_c and lov3.parent_id = 25812
                    left join flow.list_of_value lov4 on lov4.name = wo.inspection_type_c and lov4.parent_id = 25816
                    left join flow.list_of_value lov5 on lov5.name = wo.follow_up_reason_c and lov5.parent_id = 25814
             where wo.record_type_id in ('0122T000000HtKlQAK')
               and wo.residential_project_c is null
               and wo.account_id is not null

      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;
        v_project_process_step_id = null;
        v_project_process_step__event_id = null;
        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and pps.process_step_id = 3797;
        if v_project_process_step_id is null then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id,nw_migration_id)
          values (x.project_id, 3797, null, 1, null, now(), now(), 2384850, 2384850, false,
                  true, null, null, null,x.id)
          returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
        values (v_project_process_step_id, 273, null,
                case
                  when x.status = 'New' then 119
                  when x.status = 'Assigned' then 111
                  when x.status = 'In Progress' then 106
                  when x.status = 'Closed' then 115
                  when x.status = 'Action Completed' then 112
                  when x.status = 'Closed - Unresolved' then 113
                  when x.status = 'Closed - Duplicate' then 114
                  when x.status = 'Scheduled' then 120
                  when x.status = 'Dispatched' then 116
                  when x.status = 'Completed' then 3
                  when x.status = 'Canceled' then 2
                  when x.status = 'Pending Customer' then 117
                  when x.status = 'Cannot Complete' then 118
                  else 119 end
                 , null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1,x.id)
        returning id into v_project_process_step__event_id;
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29252, x.completed_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29253, x.work_order_owner_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29254, x.lov1_priority_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29255, x.lov2_service_type_c_id::text,true);
        v_lov_scope_of_work = null;
        if x.scope_of_work_c is not null then
          select array_agg(lov.id)
          into v_lov_scope_of_work
          from (
                 SELECT unnest(string_to_array(aggregated_column, ';')) scope_of_work_c
                 FROM (
                        SELECT STRING_AGG(scope_of_work_c, ';') AS aggregated_column
                        from brs.work_order w
                        where id = x.id
                      ) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.scope_of_work_c and lov.parent_id = 25810;
          perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29256, v_lov_scope_of_work::text,true);
        end if;

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29257, x.requested_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29258, x.lov3_disposition_reason_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29270, x.additional_comments_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29259, x.sss_sent_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29269, x.lov4_inspection_type_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29260, x.scheduled_with_self_service_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29261, x.rescheduled_with_self_service_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29262, x.canceled_by_self_service_user_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29263, x.follow_up_work_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29264, x.lov5_follow_up_reason_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29265, x.follow_up_reason_details_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29266, x.subject::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29267, x.description::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29268, x.intake_notes_c::text,true);


      end loop;
    raise notice '13 END = %',clock_timestamp();
    raise notice '13 END total = %',v_total;
  end
$do$;
--todo this is where I left off
-- DO
-- $do$
--   declare
--     x                                record;
--     v_project_process_step_id        bigint;
--     v_project_process_step__event_id bigint;
--     v_lov_scope_of_work bigint[];
--     v_count bigint;
--     v_total bigint;
--   BEGIN
--     v_count = 0;
--     v_total = 0;
--     raise notice '14 START = %',clock_timestamp();
--     for x in select wo.completed_date_c,
--                     wo.scope_of_work_c,
--                     wo.id,
--                     wo.requested_date_c,
--                     wo.additional_comments_c,
--                     wo.sss_sent_date_c,
--                     wo.scheduled_with_self_service_c,
--                     wo.rescheduled_with_self_service_c,
--                     wo.canceled_by_self_service_user_c,
--                     wo.follow_up_work_c,
--                     wo.follow_up_reason_details_c,
--                     wo.subject,
--                     wo.description,
--                     wo.intake_notes_c,
--                     wo.status,
--                     wo.owner_id,
--                     p.id as project_id,
--                     lov1.id as  lov1_priority_id,
--                     lov2.id as  lov2_service_type_c_id,
--                     lov3.id as  lov3_disposition_reason_c_id,
--                     lov4.id as  lov4_inspection_type_c_id,
--                     lov5.id as  lov5_follow_up_reason_c_id
--              from brs.work_order wo
--                     inner join brs.case c on c.id = wo.case_id
--                     inner join brs.residential_project_c rpc on rpc.id = c.residential_project_c
--                     inner join flow.project p on p.nw_migration_id = rpc.id
--                     left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
--                     left join flow.list_of_value lov2 on lov2.name = wo.service_type_c and lov2.parent_id = 25809
--                     left join flow.list_of_value lov3 on lov3.name = wo.disposition_reason_c and lov3.parent_id = 25812
--                     left join flow.list_of_value lov4 on lov4.name = wo.inspection_type_c and lov4.parent_id = 25816
--                     left join flow.list_of_value lov5 on lov5.name = wo.follow_up_reason_c and lov5.parent_id = 25814
--              where wo.record_type_id in ('0122T000000HtKlQAK')
--                and wo.case_id is not null and wo.account_id is null
--
--       loop
--         v_count = v_count + 1;
--         v_total = v_total + 1;
--         if v_count = 5000 then
--           raise notice 'v_count = %',v_count;
--           --commit;
--           v_count = 0;
--         end if;
--         v_project_process_step_id = null;
--         v_project_process_step__event_id = null;
--         select id
--         into v_project_process_step_id
--         from flow.project_process_step pps
--         where pps.project_id = x.project_id and pps.process_step_id = 3797;
--         if v_project_process_step_id is null then
--           insert into flow.project_process_step (project_id, process_step_id, user_position_id,
--                                                  company_process_step_status_type_id,
--                                                  process_step_complete_date, date_created, date_modified, created_by_id,
--                                                  modified_by_id, archived, main, parent_project_process_step_id,
--                                                  cancelled_date, parent_project_process_step_event_id,nw_migration_id)
--           values (x.project_id, 3797, null, 1, null, now(), now(), 2384850, 2384850, false,
--                   true, null, null, null,x.id)
--           returning id into v_project_process_step_id;
--         end if;
--
--         insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
--                                                     company_event_status_type_id, start_time, end_time,
--                                                     date_created,
--                                                     date_modified, created_by_id, modified_by_id, archived,
--                                                     cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
--         values (v_project_process_step_id, 273, null,
--                 case
--                   when x.status = 'New' then 119
--                   when x.status = 'Assigned' then 111
--                   when x.status = 'In Progress' then 106
--                   when x.status = 'Closed' then 115
--                   when x.status = 'Action Completed' then 112
--                   when x.status = 'Closed - Unresolved' then 113
--                   when x.status = 'Closed - Duplicate' then 114
--                   when x.status = 'Scheduled' then 120
--                   when x.status = 'Dispatched' then 116
--                   when x.status = 'Completed' then 3
--                   when x.status = 'Canceled' then 2
--                   when x.status = 'Pending Customer' then 117
--                   when x.status = 'Cannot Complete' then 118
--                   else 119 end
--                  , null, null, now(), now(), 2384850, 2384850, false, null,
--                 null, null, 1,x.id)
--         returning id into v_project_process_step__event_id;
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29252, x.completed_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29253, flow.get_user_id_nh(x.owner_id::text)::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29254, x.lov1_priority_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29255, x.lov2_service_type_c_id::text,true);
--         v_lov_scope_of_work = null;
--         if x.scope_of_work_c is not null then
--           select array_agg(lov.id)
--           into v_lov_scope_of_work
--           from (
--                  SELECT unnest(string_to_array(aggregated_column, ';')) scope_of_work_c
--                  FROM (
--                         SELECT STRING_AGG(scope_of_work_c, ';') AS aggregated_column
--                         from brs.work_order w
--                         where id = x.id
--                       ) AS subquery) as foo
--                  inner join flow.list_of_value lov on lov.name = foo.scope_of_work_c and lov.parent_id = 25810;
--           perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29256, v_lov_scope_of_work::text,true);
--         end if;
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29257, x.requested_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29258, x.lov3_disposition_reason_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29270, x.additional_comments_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29259, x.sss_sent_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29269, x.lov4_inspection_type_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29260, x.scheduled_with_self_service_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29261, x.rescheduled_with_self_service_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29262, x.canceled_by_self_service_user_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29263, x.follow_up_work_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29264, x.lov5_follow_up_reason_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29265, x.follow_up_reason_details_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29266, x.subject::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29267, x.description::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29268, x.intake_notes_c::text,true);
--
--
--       end loop;
--     raise notice '14 END = %',clock_timestamp();
--     raise notice '14 END total = %',v_total;
--   end
-- $do$;
--todo start with Mandy
DO
$do$
  declare
    x record;
    v_project_process_step_id bigint;
    v_project_process_step__event_id bigint;
    v_lov_scope_of_work bigint[];
    v_count bigint;
    v_total bigint;
  BEGIN
    raise notice '21 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    for x in select wo.completed_date_c,
                    wo.status,
                    wo.id,
                    wo.requested_date_c,
                    wo.additional_comments_c,
                    wo.scheduled_with_self_service_c,
                    wo.rescheduled_with_self_service_c,
                    wo.canceled_by_self_service_user_c,
                    wo.follow_up_work_c,
                    wo.follow_up_reason_details_c,
                    wo.subject,
                    wo.description,
                    wo.intake_notes_c,
                    wo.priority,
                    wo.service_type_c,
                    wo.disposition_reason_c,
                    wo.inspection_type_c,
                    wo.follow_up_reason_c,
                    p.id    as project_id,
                    lov1.id as lov1_priority_id,
                    lov2.id as lov2_service_type_c_id,
                    lov3.id as lov3_disposition_reason_c_id,
                    lov4.id as lov4_inspection_type_c_id,
                    lov5.id as lov5_follow_up_reason_c_id,
                    case when wo.work_order_owner_id is null and wo.owner_id is not null then
                           2495780::bigint
                         else
                           work_order_owner_id end as work_order_owner_id
             from brs.work_order wo
                    inner join flow.project p on p.nw_migration_id = wo.residential_project_c
                    left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
                    left join flow.list_of_value lov2 on lov2.name = wo.service_type_c and lov2.parent_id = 25809
                    left join flow.list_of_value lov3 on lov3.name = wo.disposition_reason_c and lov3.parent_id = 25812
                    left join flow.list_of_value lov4 on lov4.name = wo.inspection_type_c and lov4.parent_id = 25816
                    left join flow.list_of_value lov5 on lov5.name = wo.follow_up_reason_c and lov5.parent_id = 25814
             where wo.record_type_id in ('0122T000000HtKkQAK')
               and wo.residential_project_c is not null

      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;
        v_project_process_step_id = null;
        v_project_process_step__event_id = null;
        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and pps.process_step_id = 3797;

        if v_project_process_step_id is null then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id,nw_migration_id)
          values (x.project_id, 3797, null,  1 , null, now(), now(), 2384850, 2384850, false,
                  true , null, null, null,x.id)
          returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
        values (v_project_process_step_id, 273, null,
                case when x.status = 'New' then 119
                     when x.status = 'Assigned' then 111
                     when x.status = 'In Progress' then 106
                     when x.status = 'Closed' then 115
                     when x.status = 'Action Completed' then 112
                     when x.status = 'Closed - Unresolved' then 113
                     when x.status = 'Closed - Duplicate' then 114
                     when x.status = 'Scheduled' then 120
                     when x.status = 'Dispatched' then 116
                     when x.status = 'Completed' then 3
                     when x.status = 'Canceled' then 2
                     when x.status = 'Pending Customer' then 117
                     when x.status = 'Cannot Complete' then 118 else 119 end
                 , null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1,x.id)
        returning id into v_project_process_step__event_id;

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29802, x.completed_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29803, x.work_order_owner_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29804, x.lov1_priority_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29805, x.lov2_service_type_c_id::text,true);
        --         v_lov_scope_of_work = null;
--         if x.scope_of_work_c is not null then
--           select array_agg(lov.id)
--           into v_lov_scope_of_work
--           from (
--                  SELECT unnest(string_to_array(aggregated_column, ';')) scope_of_work_c
--                  FROM (
--                         SELECT STRING_AGG(scope_of_work_c, ';') AS aggregated_column
--                         from brs.work_order w
--                         where id = x.id
--                       ) AS subquery) as foo
--                  inner join flow.list_of_value lov on lov.name = foo.scope_of_work_c and lov.parent_id = 25810;
--           perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29256, v_lov_scope_of_work::text,true);
--         end if;

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29806, x.requested_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29807, x.lov3_disposition_reason_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29808, x.additional_comments_c::text,true);
        --perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29259, x.sss_sent_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29809, x.lov4_inspection_type_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29810, x.scheduled_with_self_service_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29811, x.rescheduled_with_self_service_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29812, x.canceled_by_self_service_user_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29813, x.follow_up_work_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29814, x.lov5_follow_up_reason_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29815, x.follow_up_reason_details_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29816, x.subject::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29817, x.description::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29818, x.intake_notes_c::text,true);



      end loop;
    raise notice '21 END = %',clock_timestamp();
    raise notice '21 END total = %',v_total;
  end
$do$;

-- DO
-- $do$
--   declare
--     x                                record;
--     v_project_process_step_id        bigint;
--     v_project_process_step__event_id bigint;
--     v_lov_scope_of_work bigint[];
--     v_count bigint;
--     v_total bigint;
--   BEGIN
--     v_count = 0;
--     v_total = 0;
--     raise notice '22 START = %',clock_timestamp();
--     for x in select wo.completed_date_c,
--                     wo.scope_of_work_c,
--                     wo.id,
--                     wo.requested_date_c,
--                     wo.additional_comments_c,
--                     wo.sss_sent_date_c,
--                     wo.scheduled_with_self_service_c,
--                     wo.rescheduled_with_self_service_c,
--                     wo.canceled_by_self_service_user_c,
--                     wo.follow_up_work_c,
--                     wo.follow_up_reason_details_c,
--                     wo.subject,
--                     wo.description,
--                     wo.intake_notes_c,
--                     wo.owner_id,
--                     wo.status,
--                     p.id as project_id,
--                     lov1.id as  lov1_priority_id,
--                     lov2.id as  lov2_service_type_c_id,
--                     lov3.id as  lov3_disposition_reason_c_id,
--                     lov4.id as  lov4_inspection_type_c_id,
--                     lov5.id as  lov5_follow_up_reason_c_id
--              from brs.work_order wo
--                     inner join brs.residential_project_c rpc on rpc.account_c = wo.account_id
--                     inner join flow.project p on p.nw_migration_id = rpc.id
--                     left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
--                     left join flow.list_of_value lov2 on lov2.name = wo.service_type_c and lov2.parent_id = 25809
--                     left join flow.list_of_value lov3 on lov3.name = wo.disposition_reason_c and lov3.parent_id = 25812
--                     left join flow.list_of_value lov4 on lov4.name = wo.inspection_type_c and lov4.parent_id = 25816
--                     left join flow.list_of_value lov5 on lov5.name = wo.follow_up_reason_c and lov5.parent_id = 25814
--              where wo.record_type_id in ('0122T000000HtKkQAK')
--                and wo.account_id is not null
--
--       loop
--         v_count = v_count + 1;
--         v_total = v_total + 1;
--         if v_count = 5000 then
--           raise notice 'v_count = %',v_count;
--           --commit;
--           v_count = 0;
--         end if;
--         v_project_process_step_id = null;
--         v_project_process_step__event_id = null;
--         select id
--         into v_project_process_step_id
--         from flow.project_process_step pps
--         where pps.project_id = x.project_id and pps.process_step_id = 3797;
--         if v_project_process_step_id is null then
--           insert into flow.project_process_step (project_id, process_step_id, user_position_id,
--                                                  company_process_step_status_type_id,
--                                                  process_step_complete_date, date_created, date_modified, created_by_id,
--                                                  modified_by_id, archived, main, parent_project_process_step_id,
--                                                  cancelled_date, parent_project_process_step_event_id,nw_migration_id)
--           values (x.project_id, 3797, null, 1, null, now(), now(), 2384850, 2384850, false,
--                   true, null, null, null,x.id)
--           returning id into v_project_process_step_id;
--         end if;
--
--         insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
--                                                     company_event_status_type_id, start_time, end_time,
--                                                     date_created,
--                                                     date_modified, created_by_id, modified_by_id, archived,
--                                                     cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
--         values (v_project_process_step_id, 273, null,
--                 case
--                   when x.status = 'New' then 119
--                   when x.status = 'Assigned' then 111
--                   when x.status = 'In Progress' then 106
--                   when x.status = 'Closed' then 115
--                   when x.status = 'Action Completed' then 112
--                   when x.status = 'Closed - Unresolved' then 113
--                   when x.status = 'Closed - Duplicate' then 114
--                   when x.status = 'Scheduled' then 120
--                   when x.status = 'Dispatched' then 116
--                   when x.status = 'Completed' then 3
--                   when x.status = 'Canceled' then 2
--                   when x.status = 'Pending Customer' then 117
--                   when x.status = 'Cannot Complete' then 118
--                   else 119 end
--                  , null, null, now(), now(), 2384850, 2384850, false, null,
--                 null, null, 1,x.id)
--         returning id into v_project_process_step__event_id;
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29802, x.completed_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29803, flow.get_user_id_nh(x.owner_id::text)::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29804, x.lov1_priority_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29805, x.lov2_service_type_c_id::text,true);
--         --         v_lov_scope_of_work = null;
-- --         if x.scope_of_work_c is not null then
-- --           select array_agg(lov.id)
-- --           into v_lov_scope_of_work
-- --           from (
-- --                  SELECT unnest(string_to_array(aggregated_column, ';')) scope_of_work_c
-- --                  FROM (
-- --                         SELECT STRING_AGG(scope_of_work_c, ';') AS aggregated_column
-- --                         from brs.work_order w
-- --                         where id = x.id
-- --                       ) AS subquery) as foo
-- --                  inner join flow.list_of_value lov on lov.name = foo.scope_of_work_c and lov.parent_id = 25810;
-- --           perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29256, v_lov_scope_of_work::text,true);
-- --         end if;
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29806, x.requested_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29807, x.lov3_disposition_reason_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29808, x.additional_comments_c::text,true);
--         --perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29259, x.sss_sent_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29809, x.lov4_inspection_type_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29810, x.scheduled_with_self_service_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29811, x.rescheduled_with_self_service_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29812, x.canceled_by_self_service_user_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29813, x.follow_up_work_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29814, x.lov5_follow_up_reason_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29815, x.follow_up_reason_details_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29816, x.subject::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29817, x.description::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29818, x.intake_notes_c::text,true);
--
--
--       end loop;
--     raise notice '22 END = %',clock_timestamp();
--     raise notice '22 END total = %',v_total;
--   end
-- $do$;

-- DO
-- $do$
--   declare
--     x                                record;
--     v_project_process_step_id        bigint;
--     v_project_process_step__event_id bigint;
--     v_lov_scope_of_work bigint[];
--     v_count bigint;
--     v_total bigint;
--   BEGIN
--     v_count = 0;
--     v_total = 0;
--     raise notice '23 START = %',clock_timestamp();
--     for x in select wo.completed_date_c,
--                     wo.scope_of_work_c,
--                     wo.id,
--                     wo.requested_date_c,
--                     wo.additional_comments_c,
--                     wo.sss_sent_date_c,
--                     wo.scheduled_with_self_service_c,
--                     wo.rescheduled_with_self_service_c,
--                     wo.canceled_by_self_service_user_c,
--                     wo.follow_up_work_c,
--                     wo.follow_up_reason_details_c,
--                     wo.subject,
--                     wo.description,
--                     wo.intake_notes_c,
--                     wo.owner_id,
--                     wo.status,
--                     p.id as project_id,
--                     lov1.id as  lov1_priority_id,
--                     lov2.id as  lov2_service_type_c_id,
--                     lov3.id as  lov3_disposition_reason_c_id,
--                     lov4.id as  lov4_inspection_type_c_id,
--                     lov5.id as  lov5_follow_up_reason_c_id
--              from brs.work_order wo
--                     inner join brs.case c on c.id = wo.case_id
--                     inner join brs.residential_project_c rpc on rpc.id = c.residential_project_c
--                     inner join flow.project p on p.nw_migration_id = rpc.id
--                     left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
--                     left join flow.list_of_value lov2 on lov2.name = wo.service_type_c and lov2.parent_id = 25809
--                     left join flow.list_of_value lov3 on lov3.name = wo.disposition_reason_c and lov3.parent_id = 25812
--                     left join flow.list_of_value lov4 on lov4.name = wo.inspection_type_c and lov4.parent_id = 25816
--                     left join flow.list_of_value lov5 on lov5.name = wo.follow_up_reason_c and lov5.parent_id = 25814
--              where wo.record_type_id in ('0122T000000HtKkQAK')
--                 and wo.case_id is not null and wo.residential_project_c is null
--
--       loop
--         v_count = v_count + 1;
--         v_total = v_total + 1;
--         if v_count = 5000 then
--           raise notice 'v_count = %',v_count;
--           --commit;
--           v_count = 0;
--         end if;
--         v_project_process_step_id = null;
--         v_project_process_step__event_id = null;
--         select id
--         into v_project_process_step_id
--         from flow.project_process_step pps
--         where pps.project_id = x.project_id and pps.process_step_id = 3797;
--         if v_project_process_step_id is null then
--           insert into flow.project_process_step (project_id, process_step_id, user_position_id,
--                                                  company_process_step_status_type_id,
--                                                  process_step_complete_date, date_created, date_modified, created_by_id,
--                                                  modified_by_id, archived, main, parent_project_process_step_id,
--                                                  cancelled_date, parent_project_process_step_event_id,nw_migration_id)
--           values (x.project_id, 3797, null, 1, null, now(), now(), 2384850, 2384850, false,
--                   true, null, null, null,x.id)
--           returning id into v_project_process_step_id;
--         end if;
--
--         insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
--                                                     company_event_status_type_id, start_time, end_time,
--                                                     date_created,
--                                                     date_modified, created_by_id, modified_by_id, archived,
--                                                     cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
--         values (v_project_process_step_id, 273, null,
--                 case
--                   when x.status = 'New' then 119
--                   when x.status = 'Assigned' then 111
--                   when x.status = 'In Progress' then 106
--                   when x.status = 'Closed' then 115
--                   when x.status = 'Action Completed' then 112
--                   when x.status = 'Closed - Unresolved' then 113
--                   when x.status = 'Closed - Duplicate' then 114
--                   when x.status = 'Scheduled' then 120
--                   when x.status = 'Dispatched' then 116
--                   when x.status = 'Completed' then 3
--                   when x.status = 'Canceled' then 2
--                   when x.status = 'Pending Customer' then 117
--                   when x.status = 'Cannot Complete' then 118
--                   else 119 end
--                  , null, null, now(), now(), 2384850, 2384850, false, null,
--                 null, null, 1,x.id)
--         returning id into v_project_process_step__event_id;
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29802, x.completed_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29803, flow.get_user_id_nh(x.owner_id::text)::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29804, x.lov1_priority_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29805, x.lov2_service_type_c_id::text,true);
--         --         v_lov_scope_of_work = null;
-- --         if x.scope_of_work_c is not null then
-- --           select array_agg(lov.id)
-- --           into v_lov_scope_of_work
-- --           from (
-- --                  SELECT unnest(string_to_array(aggregated_column, ';')) scope_of_work_c
-- --                  FROM (
-- --                         SELECT STRING_AGG(scope_of_work_c, ';') AS aggregated_column
-- --                         from brs.work_order w
-- --                         where id = x.id
-- --                       ) AS subquery) as foo
-- --                  inner join flow.list_of_value lov on lov.name = foo.scope_of_work_c and lov.parent_id = 25810;
-- --           perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29256, v_lov_scope_of_work::text,true);
-- --         end if;
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29806, x.requested_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29807, x.lov3_disposition_reason_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29808, x.additional_comments_c::text,true);
--         --perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29259, x.sss_sent_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29809, x.lov4_inspection_type_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29810, x.scheduled_with_self_service_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29811, x.rescheduled_with_self_service_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29812, x.canceled_by_self_service_user_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29813, x.follow_up_work_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29814, x.lov5_follow_up_reason_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29815, x.follow_up_reason_details_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29816, x.subject::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29817, x.description::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29818, x.intake_notes_c::text,true);
--
--
--       end loop;
--     raise notice '23 END = %',clock_timestamp();
--     raise notice '23 END total = %',v_total;
--   end
-- $do$;

-- DO
-- $do$
--   declare
--     x record;
--     v_project_process_step_id bigint;
--     v_project_process_step__event_id bigint;
--     v_lov_reason_code bigint[];
--     v_count bigint;
--     v_total bigint;
--   BEGIN
--     raise notice '24 START = %',clock_timestamp();
--     v_count = 0;
--     v_total = 0;
--     for x in select wo.*,p.id as project_id,
--                     lov1.id as  lov1_priority_id,
--                     lov2.id as  lov2_service_type_c_id,
--                     lov3.id as  lov3_cancellation_reasons_c_id,
--                     lov4.id as  lov4_cancellation_details_c_id,
--                     lov6.id as  lov6_response_code_c_id
--              from brs.work_order wo
--                     inner join brs.account a on a.id = wo.account_id
--                     inner join flow.contact c on c.nw_migration_id = a.id
--                     inner join flow.project p on p.contact_id = c.id
--                     left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
--                     left join flow.list_of_value lov2 on lov2.name = wo.service_request_type_c and lov2.parent_id = 25818
--                     left join flow.list_of_value lov3 on lov3.name = wo.cancellation_reasons_c and lov3.parent_id = 25820
--                     left join flow.list_of_value lov4 on lov4.name = wo.cancellation_details_c and lov4.parent_id = 25822
--                     left join flow.list_of_value lov6 on lov6.name = wo.response_code_c and lov6.parent_id = 25968
--              where wo.record_type_id in ('01234000000BmSZAA0')
--
--
--       loop
--         v_count = v_count + 1;
--         v_total = v_total + 1;
--         if v_count = 5000 then
--           raise notice 'v_count = %',v_count;
--           --commit;
--           v_count = 0;
--         end if;
--         v_project_process_step_id = null;
--         v_project_process_step__event_id = null;
--         select id
--         into v_project_process_step_id
--         from flow.project_process_step pps
--         where pps.project_id = x.project_id and pps.process_step_id = 3797;
--
--         if v_project_process_step_id is null then
--           insert into flow.project_process_step (project_id, process_step_id, user_position_id,
--                                                  company_process_step_status_type_id,
--                                                  process_step_complete_date, date_created, date_modified, created_by_id,
--                                                  modified_by_id, archived, main, parent_project_process_step_id,
--                                                  cancelled_date, parent_project_process_step_event_id,nw_migration_id)
--           values (x.project_id, 3797, null,  1 , null, now(), now(), 2384850, 2384850, false,
--                   true , null, null, null,x.id)
--           returning id into v_project_process_step_id;
--         end if;
--
--         insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
--                                                     company_event_status_type_id, start_time, end_time,
--                                                     date_created,
--                                                     date_modified, created_by_id, modified_by_id, archived,
--                                                     cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
--         values (v_project_process_step_id, 273, null,
--                 case when x.status = 'New' then 119
--                      when x.status = 'Assigned' then 111
--                      when x.status = 'In Progress' then 106
--                      when x.status = 'Closed' then 115
--                      when x.status = 'Action Completed' then 112
--                      when x.status = 'Closed - Unresolved' then 113
--                      when x.status = 'Closed - Duplicate' then 114
--                      when x.status = 'Scheduled' then 120
--                      when x.status = 'Dispatched' then 116
--                      when x.status = 'Completed' then 3
--                      when x.status = 'Canceled' then 2
--                      when x.status = 'Pending Customer' then 117
--                      when x.status = 'Cannot Complete' then 118 else 119 end
--                  , null, null, now(), now(), 2384850, 2384850, false, null,
--                 null, null, 1,x.id)
--         returning id into v_project_process_step__event_id;
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29822, x.completed_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29823, flow.get_user_id_nh(x.owner_id::text)::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29824, x.lov1_priority_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29825, x.lov2_service_type_c_id::text,true);
--         v_lov_reason_code = null;
--         if x.reason_code_c is not null then
--           select array_agg(lov.id)
--           into v_lov_reason_code
--           from (
--                  SELECT unnest(string_to_array(aggregated_column, ';')) reason_code_c
--                  FROM (
--                         SELECT STRING_AGG(reason_code_c, ';') AS aggregated_column
--                         from brs.work_order w
--                         where id = x.id
--                       ) AS subquery) as foo
--                  inner join flow.list_of_value lov on lov.name = foo.reason_code_c and lov.parent_id = 25966;
--           perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29839, v_lov_reason_code::text,true);
--         end if;
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29826, x.requested_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29827, x.subject::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29828, x.description::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29829, x.appointment_cancellation_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29830, x.appointment_cancellation_notes_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29831, x.lov3_cancellation_reasons_c_id::text,true);
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29832, x.lov4_cancellation_details_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29833, x.sales_order_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29834, x.payment_reference_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29835, x.customer_po_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29836, x.payment_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29837, x.amount_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29838, x.rma_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29840, flow.get_user_id_nh(x.scheduler_c::text)::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29841, x.date_action_completed_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29842, x.lov6_response_code_c_id::text,true);
--
--       end loop;
--     raise notice '24 END = %',clock_timestamp();
--     raise notice '24 END total = %',v_total;
--   end
-- $do$;

-- DO
-- $do$
--   declare
--     x                                record;
--     v_project_process_step_id        bigint;
--     v_project_process_step__event_id bigint;
--     v_lov_reason_code bigint[];
--     v_count bigint;
--     v_total bigint;
--   BEGIN
--     v_count = 0;
--     v_total = 0;
--     raise notice '25 START = %',clock_timestamp();
--     for x in select wo.completed_date_c,
--                     wo.scope_of_work_c,
--                     wo.id,
--                     wo.requested_date_c,
--                     wo.additional_comments_c,
--                     wo.sss_sent_date_c,
--                     wo.scheduled_with_self_service_c,
--                     wo.rescheduled_with_self_service_c,
--                     wo.canceled_by_self_service_user_c,
--                     wo.follow_up_work_c,
--                     wo.follow_up_reason_details_c,
--                     wo.subject,
--                     wo.description,
--                     wo.intake_notes_c,
--                     wo.status,
--                     wo.owner_id,
--                     p.id as project_id,
--                     lov1.id as  lov1_priority_id,
--                     lov2.id as  lov2_service_type_c_id,
--                     lov3.id as  lov3_cancellation_reasons_c_id,
--                     lov4.id as  lov4_cancellation_details_c_id,
--                     lov6.id as  lov6_response_code_c_id,
--                     wo.reason_code_c,
--                     wo.appointment_cancellation_notes_c,
--                     wo.appointment_cancellation_c,
--                     wo.sales_order_c,
--                     wo.payment_reference_c,
--                     wo.customer_po_c,
--                     wo.payment_date_c,
--                     wo.amount_c,
--                     wo.date_action_completed_c,
--                     wo.scheduler_c,
--                     wo.rma_c
--              from brs.work_order wo
--                     inner join brs.residential_project_c rpc on rpc.account_c = wo.account_id
--                     inner join flow.project p on p.nw_migration_id = rpc.id
--                     left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
--                     left join flow.list_of_value lov2 on lov2.name = wo.service_request_type_c and lov2.parent_id = 25818
--                     left join flow.list_of_value lov3 on lov3.name = wo.cancellation_reasons_c and lov3.parent_id = 25820
--                     left join flow.list_of_value lov4 on lov4.name = wo.cancellation_details_c and lov4.parent_id =25822
--                     left join flow.list_of_value lov6 on lov6.name = wo.response_code_c and lov6.parent_id = 25968
--              where wo.record_type_id in ('01234000000BmSZAA0')
--                and wo.residential_project_c is null
--                and wo.account_id is not null
--
--       loop
--         v_count = v_count + 1;
--         v_total = v_total + 1;
--         if v_count = 5000 then
--           raise notice 'v_count = %',v_count;
--           --commit;
--           v_count = 0;
--         end if;
--         v_project_process_step_id = null;
--         v_project_process_step__event_id = null;
--         select id
--         into v_project_process_step_id
--         from flow.project_process_step pps
--         where pps.project_id = x.project_id and pps.process_step_id = 3797;
--         if v_project_process_step_id is null then
--           insert into flow.project_process_step (project_id, process_step_id, user_position_id,
--                                                  company_process_step_status_type_id,
--                                                  process_step_complete_date, date_created, date_modified, created_by_id,
--                                                  modified_by_id, archived, main, parent_project_process_step_id,
--                                                  cancelled_date, parent_project_process_step_event_id,nw_migration_id)
--           values (x.project_id, 3797, null, 1, null, now(), now(), 2384850, 2384850, false,
--                   true, null, null, null,x.id)
--           returning id into v_project_process_step_id;
--         end if;
--
--         insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
--                                                     company_event_status_type_id, start_time, end_time,
--                                                     date_created,
--                                                     date_modified, created_by_id, modified_by_id, archived,
--                                                     cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
--         values (v_project_process_step_id, 273, null,
--                 case
--                   when x.status = 'New' then 119
--                   when x.status = 'Assigned' then 111
--                   when x.status = 'In Progress' then 106
--                   when x.status = 'Closed' then 115
--                   when x.status = 'Action Completed' then 112
--                   when x.status = 'Closed - Unresolved' then 113
--                   when x.status = 'Closed - Duplicate' then 114
--                   when x.status = 'Scheduled' then 120
--                   when x.status = 'Dispatched' then 116
--                   when x.status = 'Completed' then 3
--                   when x.status = 'Canceled' then 2
--                   when x.status = 'Pending Customer' then 117
--                   when x.status = 'Cannot Complete' then 118
--                   else 119 end
--                  , null, null, now(), now(), 2384850, 2384850, false, null,
--                 null, null, 1,x.id)
--         returning id into v_project_process_step__event_id;
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29822, x.completed_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29823, flow.get_user_id_nh(x.owner_id::text)::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29824, x.lov1_priority_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29825, x.lov2_service_type_c_id::text,true);
--         v_lov_reason_code = null;
--         if x.reason_code_c is not null then
--           select array_agg(lov.id)
--           into v_lov_reason_code
--           from (
--                  SELECT unnest(string_to_array(aggregated_column, ';')) reason_code_c
--                  FROM (
--                         SELECT STRING_AGG(reason_code_c, ';') AS aggregated_column
--                         from brs.work_order w
--                         where id = x.id
--                       ) AS subquery) as foo
--                  inner join flow.list_of_value lov on lov.name = foo.reason_code_c and lov.parent_id = 25966;
--           perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29839, v_lov_reason_code::text,true);
--         end if;
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29826, x.requested_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29827, x.subject::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29828, x.description::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29829, x.appointment_cancellation_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29830, x.appointment_cancellation_notes_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29831, x.lov3_cancellation_reasons_c_id::text,true);
--
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29832, x.lov4_cancellation_details_c_id::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29833, x.sales_order_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29834, x.payment_reference_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29835, x.customer_po_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29836, x.payment_date_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29837, x.amount_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29838, x.rma_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29840, flow.get_user_id_nh(x.scheduler_c::text)::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29841, x.date_action_completed_c::text,true);
--         perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29842, x.lov6_response_code_c_id::text,true);
--
--
--       end loop;
--     raise notice '25 END = %',clock_timestamp();
--     raise notice '25 END total = %',v_total;
--   end
-- $do$;

DO
$do$
  declare
    x                                record;
    v_project_process_step_id        bigint;
    v_project_process_step__event_id bigint;
    v_lov_reason_code bigint[];
    v_count bigint;
    v_total bigint;
  BEGIN
    v_count = 0;
    v_total = 0;
    raise notice '26 START = %',clock_timestamp();
    for x in select wo.completed_date_c,
                    wo.scope_of_work_c,
                    wo.id,
                    wo.requested_date_c,
                    wo.additional_comments_c,
                    wo.sss_sent_date_c,
                    wo.scheduled_with_self_service_c,
                    wo.rescheduled_with_self_service_c,
                    wo.canceled_by_self_service_user_c,
                    wo.follow_up_work_c,
                    case when wo.work_order_scheduler_c is null and wo.scheduler_c is not null then
                           2495780::bigint
                         else
                           work_order_scheduler_c end as work_order_scheduler_c,
                    wo.follow_up_reason_details_c,
                    wo.subject,
                    wo.description,
                    wo.intake_notes_c,
                    wo.status,
                    wo.owner_id,
                    p.id as project_id,
                    lov1.id as  lov1_priority_id,
                    lov2.id as  lov2_service_type_c_id,
                    lov3.id as  lov3_cancellation_reasons_c_id,
                    lov4.id as  lov4_cancellation_details_c_id,
                    lov6.id as  lov6_response_code_c_id,
                    wo.reason_code_c,
                    wo.appointment_cancellation_notes_c,
                    wo.appointment_cancellation_c,
                    wo.sales_order_c,
                    wo.payment_reference_c,
                    wo.customer_po_c,
                    wo.payment_date_c,
                    case when wo.work_order_owner_id is null and wo.owner_id is not null then
                           2495780::bigint
                         else
                           work_order_owner_id end as work_order_owner_id,
                    wo.amount_c,
                    wo.date_action_completed_c,
                    wo.rma_c,
                    wo.scheduler_c
             from brs.work_order wo
                    inner join brs.case c on c.id = wo.case_id
               inner join brs.account a on a.id = c.account_id
               inner join brs.residential_project_c r on r.account_c = a.id
                  --  inner join brs.residential_project_c rpc on rpc.id = c.residential_project_c
                    inner join flow.project p on p.nw_migration_id = r.id
                    left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
                    left join flow.list_of_value lov2 on lov2.name = wo.service_request_type_c and lov2.parent_id = 25818
                    left join flow.list_of_value lov3 on lov3.name = wo.cancellation_reasons_c and lov3.parent_id = 25820
                    left join flow.list_of_value lov4 on lov4.name = wo.cancellation_details_c and lov4.parent_id =25822
                    left join flow.list_of_value lov6 on lov6.name = wo.response_code_c and lov6.parent_id = 25968
             where wo.record_type_id in ('01234000000BmSZAA0')
                and wo.case_id is not null

      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;
        v_project_process_step_id = null;
        v_project_process_step__event_id = null;
        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and pps.process_step_id = 3797;
        if v_project_process_step_id is null then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id,nw_migration_id)
          values (x.project_id, 3797, null, 1, null, now(), now(), 2384850, 2384850, false,
                  true, null, null, null,x.id)
          returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
        values (v_project_process_step_id, 273, null,
                case
                  when x.status = 'New' then 119
                  when x.status = 'Assigned' then 111
                  when x.status = 'In Progress' then 106
                  when x.status = 'Closed' then 115
                  when x.status = 'Action Completed' then 112
                  when x.status = 'Closed - Unresolved' then 113
                  when x.status = 'Closed - Duplicate' then 114
                  when x.status = 'Scheduled' then 120
                  when x.status = 'Dispatched' then 116
                  when x.status = 'Completed' then 3
                  when x.status = 'Canceled' then 2
                  when x.status = 'Pending Customer' then 117
                  when x.status = 'Cannot Complete' then 118
                  else 119 end
                 , null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1,x.id)
        returning id into v_project_process_step__event_id;
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29822, x.completed_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29823, x.work_order_owner_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29824, x.lov1_priority_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29825, x.lov2_service_type_c_id::text,true);
        v_lov_reason_code = null;
        if x.reason_code_c is not null then
          select array_agg(lov.id)
          into v_lov_reason_code
          from (
                 SELECT unnest(string_to_array(aggregated_column, ';')) reason_code_c
                 FROM (
                        SELECT STRING_AGG(reason_code_c, ';') AS aggregated_column
                        from brs.work_order w
                        where id = x.id
                      ) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.reason_code_c and lov.parent_id = 25966;
          perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29839, v_lov_reason_code::text,true);
        end if;

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29826, x.requested_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29827, x.subject::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29828, x.description::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29829, x.appointment_cancellation_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29830, x.appointment_cancellation_notes_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29831, x.lov3_cancellation_reasons_c_id::text,true);

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29832, x.lov4_cancellation_details_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29833, x.sales_order_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29834, x.payment_reference_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29835, x.customer_po_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29836, x.payment_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29837, x.amount_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29838, x.rma_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29840, x.work_order_scheduler_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29841, x.date_action_completed_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29842, x.lov6_response_code_c_id::text,true);

      end loop;
    raise notice '26 END = %',clock_timestamp();
    raise notice '26 END total = %',v_total;
  end
$do$;



DO
$do$
  declare
    x                                record;
    v_project_process_step_id        bigint;
    v_project_process_step__event_id bigint;
    v_count bigint;
    v_total bigint;
  BEGIN
    v_count = 0;
    v_total = 0;
    raise notice '15 START = %',clock_timestamp();
    for x in select wo.completed_date_c,
                    wo.scope_of_work_c,
                    wo.id,
                    wo.requested_date_c,
                    wo.additional_comments_c,
                    wo.sss_sent_date_c,
                    wo.scheduled_with_self_service_c,
                    wo.rescheduled_with_self_service_c,
                    wo.canceled_by_self_service_user_c,
                    wo.follow_up_work_c,
                    wo.follow_up_reason_details_c,
                    wo.subject,
                    wo.description,
                    case when wo.work_order_owner_id is null and wo.owner_id is not null then
                           2495780::bigint
                         else
                           work_order_owner_id end as work_order_owner_id,
                    wo.intake_notes_c,
                    wo.status,
                    wo.response_comments_c,
                    wo.appointment_cancellation_c,
                    wo.appointment_cancellation_notes_c,
                    wo.sales_order_c,
                    wo.payment_reference_c,
                    wo.customer_po_c,
                    wo.payment_date_c,
                    wo.owner_id,
                    wo.amount_c,
                    wo.commitment_date_c,
                    p.id as project_id,
                    lov1.id as lov1_priority_id,
                    lov2.id as lov2_service_request_type_c_id,
                    lov3.id as lov3_cancellation_reasons_c_id,
                    lov4.id as lov4_cancellation_details_c_id
             from brs.work_order wo
                    inner join brs.residential_project_c rpc on rpc.account_c = wo.account_id
                    inner join flow.project p on p.nw_migration_id = rpc.id
                    left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
                    left join flow.list_of_value lov2 on lov2.name = wo.service_request_type_c and lov2.parent_id = 25818
                    left join flow.list_of_value lov3 on lov3.name = wo.cancellation_reasons_c and lov3.parent_id = 25820
                    left join flow.list_of_value lov4 on lov4.name = wo.cancellation_details_c and lov4.parent_id = 25822
             where wo.record_type_id = '01234000000M5IcAAK'

      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;
        v_project_process_step_id = null;
        v_project_process_step__event_id = null;
        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and pps.process_step_id = 3788;
        if v_project_process_step_id is null then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id,nw_migration_id)
          values (x.project_id, 3788, null, 1, null, now(), now(), 2384850, 2384850, false,
                  true, null, null, null,x.id)
          returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
        values (v_project_process_step_id, 274, null,
                case
                  when x.status = 'New' then 119
                  when x.status = 'Assigned' then 111
                  when x.status = 'In Progress' then 106
                  when x.status = 'Closed' then 115
                  when x.status = 'Closed - Unresolved' then 113
                  when x.status = 'Closed - Duplicate' then 114
                  else 119 end
                 , null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1,x.id)
        returning id into v_project_process_step__event_id;

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29275, x.completed_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29271, x.work_order_owner_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29272, x.lov1_priority_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29273, x.lov2_service_request_type_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29283, x.lov3_cancellation_reasons_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29284, x.lov4_cancellation_details_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29274, x.requested_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29276, x.commitment_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29277, x.subject::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29278, x.description::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29290, x.intake_notes_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29280, x.response_comments_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29281, x.appointment_cancellation_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29282, x.appointment_cancellation_notes_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29285, x.sales_order_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29286, x.payment_reference_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29287, x.customer_po_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29288, x.payment_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29289, x.amount_c::text,true);

      end loop;
    raise notice '15 END = %',clock_timestamp();
    raise notice '15 END total = %',v_total;
  end
$do$;


DO
$do$
  declare
    x                                record;
    v_project_process_step_id        bigint;
    v_project_process_step__event_id bigint;
    v_count bigint;
    v_total bigint;
  BEGIN
    v_count = 0;
    v_total = 0;
    raise notice '16 START = %',clock_timestamp();
    for x in select wo.completed_date_c,
                    wo.scope_of_work_c,
                    wo.id,
                    wo.requested_date_c,
                    wo.additional_comments_c,
                    wo.sss_sent_date_c,
                    wo.scheduled_with_self_service_c,
                    wo.rescheduled_with_self_service_c,
                    wo.canceled_by_self_service_user_c,
                    wo.follow_up_work_c,
                    wo.follow_up_reason_details_c,
                    wo.subject,
                    wo.description,
                    wo.intake_notes_c,
                    wo.status,
                    wo.response_comments_c,
                    wo.appointment_cancellation_c,
                    wo.appointment_cancellation_notes_c,
                    wo.sales_order_c,
                    case when wo.work_order_owner_id is null and wo.owner_id is not null then
                           2495780::bigint
                         else
                           work_order_owner_id end as work_order_owner_id,
                    wo.payment_reference_c,
                    wo.customer_po_c,
                    wo.payment_date_c,
                    wo.owner_id,
                    wo.amount_c,
                    wo.commitment_date_c,
                    p.id as project_id,
                    lov1.id as lov1_priority_id,
                    lov2.id as lov2_service_request_type_c_id,
                    lov3.id as lov3_cancellation_reasons_c_id,
                    lov4.id as lov4_cancellation_details_c_id
             from brs.work_order wo
                    inner join brs.case c on c.id = wo.case_id
                    inner join brs.residential_project_c rpc on rpc.account_c = c.account_id
                    inner join flow.project p on p.nw_migration_id = rpc.id
                    left join flow.list_of_value lov1 on lov1.name = wo.priority and lov1.parent_id = 25516
                    left join flow.list_of_value lov2 on lov2.name = wo.service_request_type_c and lov2.parent_id = 25818
                    left join flow.list_of_value lov3 on lov3.name = wo.cancellation_reasons_c and lov3.parent_id = 25820
                    left join flow.list_of_value lov4 on lov4.name = wo.cancellation_details_c and lov4.parent_id = 25822
             where wo.record_type_id = '01234000000M5IcAAK'
               and wo.case_id is not null and wo.account_id is null

      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;
        v_project_process_step_id = null;
        v_project_process_step__event_id = null;
        select id
        into v_project_process_step_id
        from flow.project_process_step pps
        where pps.project_id = x.project_id and pps.process_step_id = 3788;
        if v_project_process_step_id is null then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id,nw_migration_id)
          values (x.project_id, 3788, null, 1, null, now(), now(), 2384850, 2384850, false,
                  true, null, null, null,x.id)
          returning id into v_project_process_step_id;
        end if;

        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
        values (v_project_process_step_id, 274, null,
                case
                  when x.status = 'New' then 119
                  when x.status = 'Assigned' then 111
                  when x.status = 'In Progress' then 106
                  when x.status = 'Closed' then 115
                  when x.status = 'Closed - Unresolved' then 113
                  when x.status = 'Closed - Duplicate' then 114
                  else 119 end
                 , null, null, now(), now(), 2384850, 2384850, false, null,
                null, null, 1,x.id)
        returning id into v_project_process_step__event_id;

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29275, x.completed_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29271, x.work_order_owner_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29272, x.lov1_priority_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29273, x.lov2_service_request_type_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29283, x.lov3_cancellation_reasons_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29284, x.lov4_cancellation_details_c_id::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29274, x.requested_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29276, x.commitment_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29277, x.subject::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29278, x.description::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29290, x.intake_notes_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29280, x.response_comments_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29281, x.appointment_cancellation_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29282, x.appointment_cancellation_notes_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29285, x.sales_order_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29286, x.payment_reference_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29287, x.customer_po_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29288, x.payment_date_c::text,true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step__event_id, 2384850, 29289, x.amount_c::text,true);


      end loop;
    raise notice '16 END = %',clock_timestamp();
    raise notice '16 END total = %',v_total;
  end
$do$;


