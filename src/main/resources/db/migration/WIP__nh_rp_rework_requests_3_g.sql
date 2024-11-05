SET session_replication_role = replica;
DO
$do$
  declare
    x record;
    v_project_process_step_id bigint;
    v_count bigint;
    v_total bigint;
  BEGIN
    raise notice '11 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    for x in
      select
        id,
        created_date,
        created_by_id,
        case when created_by_id123 is null and created_by_id is not null then
               2495780::bigint
             else
               created_by_id123 end as created_by_id123,
        action_required_c,
        end_date_time_c,
        open_date_time_c,
        rework_quality_tag_c,
        severity_c,
        rca_tag_c,
        explanation_c,
        rework_reason_c,
        rework_reason_2_c,
        rework_reason_3_c,
        row_type,
        residential_project_c,
        project_id,
        lov1_action_required_c_id,
        lov2_rework_quality_tag_c_id,
        lov3_severity_c_id,
        lov4_rca_tag_c_id,
        lov5_rework_reason_c_id,
        lov6_rework_reason_2_c_id,
        lov7_rework_reason_3_c_ID,
        created_by_id_name,
        CASE WHEN row_number() OVER (PARTITION BY residential_project_c ORDER BY created_date desc ) = 1 THEN TRUE ELSE FALSE END AS is_last_row
      from (
             select trr.id,
                    trr.created_date,
                    trr.created_by_id,
                    trr.task_rework_request_c_created_by_id as created_by_id123,
                    null as action_required_c,
                    trr.end_date_time_c,
                    null as open_date_time_c,
                    trr.rework_quality_tag_c,
                    trr.severity_c,
                    trr.rca_tag_c,
                    trr.explanation_c,
                    null as rework_reason_c,
                    null as rework_reason_2_c,
                    null as rework_reason_3_c,
                    'TASK_REWORK_REQUEST_C' as row_type,
                    trr.residential_project_c,
                    p.id as project_id,
                    lov3.id as lov3_severity_c_id,
                    lov4.id as lov4_rca_tag_c_id,
                    null as lov1_action_required_c_id,
                    null as lov2_rework_quality_tag_c_id,
                    null as lov5_rework_reason_c_id,
                    null as lov6_rework_reason_2_c_id,
                    null as lov7_rework_reason_3_c_ID,
                    concat(su.first_name,' ',su.email) as created_by_id_name
             from flow.project p
                    inner join brs.residential_project_c rpc on rpc.id = p.nw_migration_id
                    inner join  brs.TASK_REWORK_REQUEST_C trr on trr.residential_project_c = rpc.id
                    left join brs.sp_user su on su.id = trr.created_by_id
                    left join flow.list_of_value lov3 on lov3.name = severity_c and lov3.parent_id = 25801
                    left join flow.list_of_value lov4 on lov4.name = rca_tag_c and lov4.parent_id = 25802
             where trr.is_deleted = false
             union
             select rrc.id,
                    rrc.created_date,
                    rrc.created_by_id,
                    rrc.rework_requests_c_created_by_id as created_by_id123,
                    rrc.action_required_c,
                    rrc.end_date_time_c,
                    rrc.open_date_time_c,
                    rrc.rework_quality_tag_c,
                    null as severity_c,
                    null as rca_tag_c,
                    null as explanation_c,
                    rrc.rework_reason_c,
                    rrc.rework_reason_2_c,
                    rrc.rework_reason_3_c,
                    'REWORK_REQUESTS_C' as row_type,
                    rrc.residential_project_c,
                    p.id as project_id,
                    null,
                    null,
                    lov1.id as lov1_action_required_c_id,
                    lov2.id as lov2_rework_quality_tag_c_id,
                    lov5.id as lov5_rework_reason_c_id,
                    lov6.id as lov6_rework_reason_2_c_id,
                    lov7.id as lov7_rework_reason_3_c_ID,
                    concat(su.first_name,' ',su.email) as created_by_id_name
             from flow.project p
                    inner join brs.residential_project_c rpc on rpc.id = p.nw_migration_id
                    inner join  brs.REWORK_REQUESTS_C rrc on rrc.residential_project_c = rpc.id
                    left join brs.sp_user su on su.id = rrc.created_by_id
                    left join flow.list_of_value lov1 on lov1.name = action_required_c and lov1.parent_id = 25799
                    left join flow.list_of_value lov2 on lov2.name = rework_quality_tag_c and lov2.parent_id = 25800
                    left join flow.list_of_value lov5 on lov5.name = rework_reason_c and lov5.parent_id = 25803
                    left join flow.list_of_value lov6 on lov6.name = rework_reason_2_c and lov6.parent_id = 25804
                    left join flow.list_of_value lov7 on lov7.name = rework_reason_3_c and lov7.parent_id = 25805
             where rrc.is_deleted = false) as foo
      order by residential_project_c,created_date

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
        values (x.project_id, 3796, null,  2 , null, now(), now(), 2384850, 2384850, false,
                case when x.is_last_row is true then true else false end, null, null, null,x.id) returning id into v_project_process_step_id;


        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,29241,x.created_by_id123::text , true);
        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,29242,x.lov1_action_required_c_id::text , true);
        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,29243,x.end_date_time_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,29244,x.open_date_time_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,29245,x.lov2_rework_quality_tag_c_id::text , true);
        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,29246,x.lov3_severity_c_id::text , true);
        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,29247,x.lov4_rca_tag_c_id::text , true);
        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,29248,x.explanation_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,29249,x.lov5_rework_reason_c_id::text , true);
        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,29250,x.lov6_rework_reason_2_c_id::text , true);
        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,29251,x.lov7_rework_reason_3_c_ID::text , true);
        perform flow.set_project_cfv_no_checks(v_project_process_step_id , 2384850,30017,x.created_by_id_name::text , true);
      end loop;
    raise notice '11 END = %',clock_timestamp();
    raise notice '11 END total = %',v_total;
  end
$do$;
