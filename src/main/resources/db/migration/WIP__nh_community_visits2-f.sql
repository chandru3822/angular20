SET session_replication_role = replica;
DO
$do$
  declare
    t                                       record;
    v_count                                 bigint;
    v_total                                 bigint;
    v_project_process_step_visits_id        bigint;
    v_project_process_step_visits_events_id bigint;
  BEGIN
    raise notice '3 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    for t in select ncvc.id          as nh_visit_id,
                    ncvc.visit_notes_c,
                    ncvc.RECENT_VISIT_DATE_C,
                    lov1.id          as lov1_role_c_id,
                    p.id             as project_id,
                    co.id            as community_id,
                    CASE
                      WHEN row_number() OVER (PARTITION BY co.id ORDER BY co.id) = 1 THEN TRUE
                      ELSE FALSE END AS is_first_row
             from brs.NH_COMMUNITY_VISIT_C ncvc
                    inner join brs.NH_COMMUNITY_C co on co.id = ncvc.nh_community_c
                    inner join flow.project p on p.nw_migration_id = co.id
                    left join flow.list_of_value lov1 on lov1.name = ncvc.role_c and lov1.parent_id = 25304
             where ncvc.is_deleted = false
              order by co.id
      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;


        if t.is_first_row is true then
          v_project_process_step_visits_id = null;
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (t.project_id, 3757, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null,
                  t.community_id)
          returning id into v_project_process_step_visits_id;
        end if;


        v_project_process_step_visits_events_id = null;
        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version,
                                                    nw_migration_id)
        values (v_project_process_step_visits_id, 237, null, 3, (t.recent_visit_date_c + INTERVAL '16 hours')::timestamp, null, now(), now(), 2384850,
                2384850, false, null,
                null, null, 1, t.nh_visit_id)
        returning id into v_project_process_step_visits_events_id;

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_visits_events_id, 2384850, 28114,
                                                 t.lov1_role_c_id::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_visits_events_id, 2384850, 28115,
                                                 t.visit_notes_c::text, true);

      end loop;


    raise notice '3 END = %',clock_timestamp();
    raise notice '3 END total = %',v_total;
  end
$do$;
