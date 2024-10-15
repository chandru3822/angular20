drop function if exists brs.create_event_sub_tasks(p_parent_task_c VARCHAR(18), p_process_step_id bigint,
                                                   p_project_process_step_id bigint);
CREATE OR REPLACE FUNCTION brs.create_event_sub_tasks(p_parent_task_c VARCHAR(18), p_process_step_id bigint,
                                                      p_project_process_step_id bigint)
  returns void AS
$BODY$
declare
  x                               record;
  v_pse_id                        bigint;
  v_project_process_step_event_id bigint;
BEGIN


  select pse.id
  into v_pse_id
  from flow.process_step_event pse
  where pse.event_id = 130
    and pse.process_step_id = p_process_step_id
    and pse.archived is false;

  for x in
    select *
    from brs.project_task_c ptc
    where ptc.parent_task_c = p_parent_task_c
      and ptc.record_type_id = '01234000000GHgIAAW'
      and ptc.is_deleted = false
    loop
      v_project_process_step_event_id = null;
      insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                  company_event_status_type_id, start_time, end_time,
                                                  date_created,
                                                  date_modified, created_by_id, modified_by_id, archived,
                                                  cancelled_date, completed_date, scheduled_date, save_version)
      values (p_project_process_step_id, v_pse_id, null, case
                                                           when x.status_c = 'Not Started' then 90
                                                           when x.status_c = 'In Progress' then 106
                                                           when x.status_c = 'Blocked' then 109
                                                           when x.status_c = 'Completed' then 3 end, null, null, now(),
              now(), 2384850, 2384850, false, null,
              null, null, 1)
      returning id into v_project_process_step_event_id;

      perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28896, x.name::text,true);
      perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28898, x.comment_c::text,true);
    --  perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28903, x.assigned_to_c::text,true);
      perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28899, x.start_date_time_c::text,true);
      perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28900, x.due_date_c::text,true);
      perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28905, x.ip_owner_c::text,true);
      perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28907, x.first_complete_end_date_time_c::text,true);
      perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28908, x.end_date_time_c::text,true);


      --perform flow.set_pps_event_cfv(v_project_process_step_event_id, 2384850, 28575, s.lease_incentive_fee_c::text,true);

    end loop;


END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
