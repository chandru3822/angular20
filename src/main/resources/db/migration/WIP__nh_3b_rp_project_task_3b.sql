SET session_replication_role = replica;
DO
$do$
  declare
    w                         record;
    v_total                   bigint;
    v_project_process_step_id bigint;
  BEGIN
    raise notice 'Residential Property Project Tasks START = %',clock_timestamp();
    v_total = 0;
    for w in
      select distinct on (ptc.residential_project_c,ptc.name) ptc.description_c,
                                                              ptc.project_priority_c,
                                                              ptc.comment_c,
                                                              ptc.status_c,
                                                              ptc.assigned_to_c,
                                                              ptc.ip_owner_c,
                                                              ptc.role_assignment_c,
                                                              ptc.blocks_c,
                                                              ptc.start_date_time_c,
                                                              ptc.first_complete_end_date_time_c,
                                                              ptc.end_date_time_c,
                                                              ptc.completed_by_c,
                                                              case
                                                                when ptc.PROJECT_TASK_C_assigned_to_c is null and
                                                                     ptc.assigned_to_c is not null then
                                                                  2495780::bigint
                                                                else
                                                                  ptc.PROJECT_TASK_C_assigned_to_c end  as PROJECT_TASK_C_assigned_to_c,
                                                              case
                                                                when ptc.PROJECT_TASK_C_completed_by_c is null and
                                                                     ptc.completed_by_c is not null then
                                                                  2495780::bigint
                                                                else
                                                                  ptc.PROJECT_TASK_C_completed_by_c end as PROJECT_TASK_C_completed_by_c,
                                                              concat(su.first_name,' ',su.email) as assigned_to_c_name,
                                                              concat(su1.first_name,' ',su1.email) as completed_by_c_name,
                                                              ptc.name,
                                                              lov1.id                                   as lov1_project_priority_c_id,
                                                              lov2.id                                   as lov2_role_assignment_c_id,
                                                              lov3.id                                   as lov3_blocks_c_id,
                                                              p.id                                      as community_project_id,
                                                              ptc.id                                    as project_task_id
      from brs.PROJECT_TASK_C ptc
             left join brs.sp_user su on su.id = ptc.assigned_to_c
             left join brs.sp_user su1 on su1.id = ptc.completed_by_c
             inner join brs.RESIDENTIAL_PROJECT_C RPC on rpc.id = ptc.RESIDENTIAL_PROJECT_C
             inner join flow.project p on p.nw_migration_id = ptc.residential_project_c
             left join flow.list_of_value lov1 on lov1.name = ptc.project_priority_c and lov1.parent_id = 25516
             left join flow.list_of_value lov2 on lov2.name = ptc.role_assignment_c and lov2.parent_id = 25733
             left join flow.list_of_value lov3 on lov3.name = ptc.blocks_c and lov3.parent_id = 25741
      where ptc.status_c not in ('Not Started', 'Cancelled')
        and ptc.record_type_id = '01234000000BmbOAAS'
        and ptc.is_deleted = false
        and upper(ptc.path_type_c) = 'STANDARD'
        and rpc.STATUS_C != 'Cancelled'
        --and ptc.critical_path_c = false
       -- and  rpc.id not in ('a6l2T000003jKbuQAE','a6l2T000005DSlGQAW')
        and ptc.name in ('Input Promise Dates',
                         'Obtain Builder Plot Plan',
                         'Complete Design Package',
                         'Provide Stamping',
                         'Complete BOM',
                         'Preliminary IC Submission w/Utility',
                         'Upload Design',
                         'Apply for Permit',
                         'Designs Distributed',
                         'Permit Pickup',
                         'Complete Rough Wire',
                         'Complete Storage Rough',
                         'Obtain Builder WO',
                         'Create Material Lines & PO/SO',
                         'Preliminary IC Approval',
                         'Complete CF-2R in Registry',
                         'System Installation',
                         'Installation Checklist Uploaded',
                         'Storage Installation',
                         'Storage Checklist Completed',
                         'Affirm AHJ Inspection Complete',
                         'AHJ Storage Inspection',
                         'Closure of RevRec',
                         'Upload Final Building Permit',
                         'Invoice Packet Complete and Sent',
                         'Obtain HO Utility Information',
                         'Submit Documents for PTO',
                         'Receive PTO from Utility',
                         'Customer System Activation')
      order by ptc.residential_project_c, ptc.name, ptc.order_c desc,ptc.created_date desc
      loop

        v_total = v_total + 1;
        v_project_process_step_id = null;


        if w.name = 'Input Promise Dates' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3759, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                          else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;

          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29025, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29026,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29027, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29028,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29029, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29030,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29031, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29050, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29051,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29052, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29053,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);

          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29882, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29883, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3759, v_project_process_step_id);


        end if;
        if w.name = 'Obtain Builder Plot Plan' then

          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3760, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29065, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29066,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29067, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29068,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29069, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29070,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29071, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29072, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29073,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29074, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29075,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29884, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29886, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3760, v_project_process_step_id);
        end if;
        if w.name = 'Complete Design Package' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3761, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28977, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28978,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28979, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28980,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28981, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28982,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28983, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28984, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28985,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28986, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28987,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29887, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29889, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3761, v_project_process_step_id);
        end if;
        if w.name = 'Provide Stamping' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3762, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28977, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28978,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28979, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28980,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28981, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28982,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28983, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28984, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28985,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28986, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28987,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform brs.create_event_sub_tasks(w.project_task_id, 3762, v_project_process_step_id);
        end if;
        if w.name = 'Complete BOM' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3763, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28955, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28956,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28957, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28958,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28959, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28960,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28961, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28962, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28963,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28964, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28965,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);

          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29890, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29893, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3763, v_project_process_step_id);
        end if;
        if w.name = 'Preliminary IC Submission w/Utility' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3764, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29076, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29077,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29078, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29079,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29080, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29081,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29082, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29083, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29084,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29085, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29086,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29895, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29898, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3764, v_project_process_step_id);
        end if;
        if w.name = 'Upload Design' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3765, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29087, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29088,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29089, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29090,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29091, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29092,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29093, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29094, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29095,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29096, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29097,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29899, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29902, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3765, v_project_process_step_id);
        end if;
        if w.name = 'Apply for Permit' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3766, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28932, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28933,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28935, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28936,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28937, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28938,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28939, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28940, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28941,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28942, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28943,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29903, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29906, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3766, v_project_process_step_id);
        end if;
        if w.name = 'Designs Distributed' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3767, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29018, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29019,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29020, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29021,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29022, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29023,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29024, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29046, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29047,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29048, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29049,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29908, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29910, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3767, v_project_process_step_id);
        end if;
        if w.name = 'Permit Pickup' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3768, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29098, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29099,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29100, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29101,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29102, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29103,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29104, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29105, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29106,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29107, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29108,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29912, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29914, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3768, v_project_process_step_id);
        end if;
        if w.name = 'Complete Rough Wire' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3769, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28988, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28989,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28990, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28991,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28992, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28993,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28994, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28995, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28996,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29032, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29033,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29915, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29917, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3769, v_project_process_step_id);
        end if;
        if w.name = 'Complete Storage Rough' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3770, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28997, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28998,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28999, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29000,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29001, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29002,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29003, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29034, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29035,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29036, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29037,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29954, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29957, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3770, v_project_process_step_id);
        end if;
        if w.name = 'Obtain Builder WO' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3771, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29109, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29110,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29111, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29112,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29113, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29114,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29115, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29116, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29117,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29118, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29119,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29963, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29965, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3771, v_project_process_step_id);
        end if;
        if w.name = 'Create Material Lines & PO/SO' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3772, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29004, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29005,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29006, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29007,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29008, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29009,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29010, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29038, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29039,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29040, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29041,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29966, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29968, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3772, v_project_process_step_id);
        end if;
        if w.name = 'Preliminary IC Approval' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3773, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29120, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29121,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29122, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29123,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29124, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29125,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29126, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29127, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29128,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29129, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29130,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29969, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29971, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3773, v_project_process_step_id);
        end if;
        if w.name = 'Complete CF-2R in Registry' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3774, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28966, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28967,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28968, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28969,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28970, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28971,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28972, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28973, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28974,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28975, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28976,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29972, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29974, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3774, v_project_process_step_id);
        end if;
        if w.name = 'System Installation' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3775, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29131, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29132,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29133, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29134,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29135, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29136,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29137, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29138, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29139,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29140, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29141,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29975, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29977, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3775, v_project_process_step_id);
        end if;
        if w.name = 'Installation Checklist Uploaded' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3776, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29054, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29055,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29056, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29057,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29058, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29059,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29060, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29061, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29062,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29063, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29064,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29978, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29980, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3776, v_project_process_step_id);
        end if;
        if w.name = 'Storage Installation' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3777, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29142, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29143,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29144, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29145,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29146, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29147,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29148, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29149, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29150,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29151, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29152,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29981, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29983, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3777, v_project_process_step_id);
        end if;
        if w.name = 'Storage Checklist Completed' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3778, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29153, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29154,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29155, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29156,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29157, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29158,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29159, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29160, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29161,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29162, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29163,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29984, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29986, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3778, v_project_process_step_id);
        end if;
        if w.name = 'Affirm AHJ Inspection Complete' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3779, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28910, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28911,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28912, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28913,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28914, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28915,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28916, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28917, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28918,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28919, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28920,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29987, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29989, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3779, v_project_process_step_id);
        end if;
        if w.name = 'AHJ Storage Inspection' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3780, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28921, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28922,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28923, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28924,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28925, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28926,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28927, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28928, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28929,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28930, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28931,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29990, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29992, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3780, v_project_process_step_id);
        end if;
        if w.name = 'Closure of RevRec' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3781, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28944, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28945,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28946, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28947,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28948, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28949,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28950, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28951, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28952,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28953, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28954,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29994, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29996, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3781, v_project_process_step_id);
        end if;
        if w.name = 'Upload Final Building Permit' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3782, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29164, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29165,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29166, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29167,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29168, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29169,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29170, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29171, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29172,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29173, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29174,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29997, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29999, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3782, v_project_process_step_id);
        end if;
        if w.name = 'Invoice Packet Complete and Sent' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3783, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29175, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29176,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29177, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29178,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29179, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29180,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29181, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29182, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29183,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29184, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29185,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 30000, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 30002, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3783, v_project_process_step_id);
        end if;
        if w.name = 'Obtain HO Utility Information' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3784, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29186, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29187,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29188, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29189,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29190, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29191,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29192, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29193, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29194,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29195, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29196,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 30003, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 30005, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3784, v_project_process_step_id);
        end if;
        if w.name = 'Submit Documents for PTO' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3785, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29197, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29198,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29199, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29200,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29201, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29202,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29203, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29204, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29205,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29206, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29207,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 30006, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 30008, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3785, v_project_process_step_id);
        end if;
        if w.name = 'Receive PTO from Utility' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3786, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29208, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29209,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29210, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29211,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29212, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29213,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29214, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29215, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29216,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29217, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29218,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 30009, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 30011, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3786, v_project_process_step_id);
        end if;
        if w.name = 'Customer System Activation' then
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (w.community_project_id, 3787, null, case
                                                        when w.status_c = 'In Progress' then 1
                                                        when w.status_c = 'Blocked' then 1769
                                                        when w.status_c = 'Completed' then 2
                                                        else  1 end, null, now(), now(), 2384850, 2384850, false, true, null, null,
                  null, w.project_task_id)
          returning id into v_project_process_step_id;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29011, w.description_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29012,
                                             w.lov1_project_priority_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29013, w.comment_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29014,
                                             w.PROJECT_TASK_C_assigned_to_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29015, w.ip_owner_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29016,
                                             w.lov2_role_assignment_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29017, w.lov3_blocks_c_id::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29042, w.start_date_time_c::text,
                                             true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29043,
                                             w.first_complete_end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29044, w.end_date_time_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 29045,
                                             w.PROJECT_TASK_C_completed_by_c::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 30012, w.assigned_to_c_name::text, true);
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 30014, w.completed_by_c_name::text, true);

          perform brs.create_event_sub_tasks(w.project_task_id, 3787, v_project_process_step_id);
        end if;
    end loop;
    raise notice 'Residential Property Project Tasks END = %',clock_timestamp();
    raise notice 'Residential Property Project Tasks Total = %',v_total;
  end
$do$;
