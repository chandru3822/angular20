SET session_replication_role = replica;
DO
$do$
  declare
    x record;
    v_project_process_step_id bigint;
    v_count bigint;
    v_total bigint;
  BEGIN
    raise notice '8 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    v_project_process_step_id = null;
    for x in select p.id as project_id,
                    o.id,
                    o.opportunity_owner_s_manager_c,
                    o.close_date,
                    o.lead_qualification_notes_c,
                    o.APPOINTMENT_TIME_C,
                    o.APPOINTMENT_DATE_C,
                    o.first_contacted_date_time_c,
                    o.description,
                    o.reason_won_lost_comments_c,
                    lov1.id as lov1_stage_name_id,
                    lov2.id as lov2_sub_stage_c_id,
                    lov3.id as lov3_reason_won_lost_c_id,
                    case when o.opportunity_opportunity_owner_s_manager_c is null and o.opportunity_owner_s_manager_c is not null then
                           2495780::bigint
                         else
                           o.opportunity_opportunity_owner_s_manager_c end as opportunity_opportunity_owner_s_manager_c
             from brs.opportunity o
                    inner join brs.residential_project_c rpc on rpc.opportunity_c = o.id
                    inner join flow.project p on rpc.id = p.nw_migration_id
                    left join flow.list_of_value lov1 on lov1.name = o.stage_name and lov1.parent_id = 25746
                    left join flow.list_of_value lov2 on lov2.name = o.sub_stage_c and lov1.parent_id =25796
                    left join flow.list_of_value lov3 on lov3.name = o.reason_won_lost_c and lov1.parent_id =25798

      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;
        v_project_process_step_id = null;
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id,nw_migration_id)
        values (x.project_id, 3795, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null,x.id)
        returning id into v_project_process_step_id;

        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29221,x.opportunity_opportunity_owner_s_manager_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29228,x.close_date::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29233,x.lead_qualification_notes_c::text, true);
        if x.appointment_date_c is not null and x.APPOINTMENT_TIME_C is not null then
          begin
            perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29234, TO_TIMESTAMP(CONCAT(x.APPOINTMENT_DATE_C, ' ', x.APPOINTMENT_TIME_C), 'YYYY-MM-DD HH12:MI PM')::text, true);
          exception when others then
            raise notice 'opportunity id = % APPOINTMENT_DATE_C = %, APPOINTMENT_TIME_C = %',x.id,x.APPOINTMENT_DATE_C,x.APPOINTMENT_TIME_C;
          end;
        end if;
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29235,x.first_contacted_date_time_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29240,x.description::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29239,x.reason_won_lost_comments_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29222,x.lov1_stage_name_id::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29236,x.lov2_sub_stage_c_id::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29238,x.lov3_reason_won_lost_c_id::text, true);
      end loop;
    raise notice '8 END = %',clock_timestamp();
    raise notice '8 END total = %',v_total;
  end
$do$;
