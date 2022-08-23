drop function if exists flow.set_closer_appointment(p_project_id bigint,
                                                    p_current_user_id bigint,
                                                    p_project_process_step_id bigint,
                                                    p_project_process_step_event_id bigint,
                                                    p_appointment_start_time timestamp,
                                                    p_users bigint array,
                                                    p_remote boolean);
CREATE OR REPLACE FUNCTION flow.set_closer_appointment(p_project_id bigint,
                                                       p_current_user_id bigint,
                                                       p_project_process_step_id bigint,
                                                       p_project_process_step_event_id bigint,
                                                       p_appointment_start_time timestamp,
                                                       p_users bigint array,
                                                       p_remote boolean default false)
  RETURNS table
          (
            success                boolean,
            user_id                bigint,
            appointment_start_time timestamp,
            appointment_end_time   timestamp,
            user_full_name         text,
            user_email             text,
            user_position_id       bigint
          )
AS
$BODY$
declare
  v_user_id                                     bigint;
  v_user_full_name                              text;
  v_user_email                                  text;
  v_user_position_id                            bigint;
  v_process_step_id                             bigint;
  v_postal_code_zone_id                         bigint;
  v_user_already_assigned_to_another_project_id bigint;
  v_set_closer_appointment_audit_id             bigint;
BEGIN

  select process_step_id
  into v_process_step_id
  from flow.project_process_step pps
  where id = p_project_process_step_id;

  if v_process_step_id != 1 then
    insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                       date_created, created_by_id)
    values (327, 'Process Step ID does not equal 1 for  ' || p_project_id || '.', 1, now(),
            99999999);
    raise exception 'Unable to schedule closer appointment.  Call support to complete.';
  end if;

    select pcz.id
    into v_postal_code_zone_id
    from flow.project p
             inner join flow.postal_code_zone_postal_code pc on pc.postal_code = substr(
            trim(both ',' from trim(both ' ' from trim(both '	' from p.postal_code))), 1, 5) and pc.archived is false
             inner join flow.postal_code_zone pcz
                        on pcz.id = pc.postal_code_zone_id and pcz.archived is false
             inner join flow.postal_code_zone_user pczu
                        on pczu.postal_code_zone_id = pcz.id and pczu.postal_code_zone_user_type_id = 1 and
                           pczu.archived is false
    where p.id = p_project_id;


  if array_length(p_users, 1) < 2 then
    select p_users[1]
    into v_user_id;
    insert into brs.set_closer_appointment_audit(project_id, user_id, project_process_step_id,
                                                 distance_from_actual_to_target, appointment_start_date,
                                                 is_only_user_available,
                                                 created_date, available_users, created_by_id,closer_selected,
                                                 project_process_step_event_id)
    values (p_project_id, v_user_id, p_project_process_step_id, 0, p_appointment_start_time, true, now(), p_users,
            p_current_user_id,true,p_project_process_step_event_id);
  else
    --   select p_users[1]
    --   into v_user_id;
    insert into brs.set_closer_appointment_audit(project_id, user_id, project_process_step_id,
                                                 distance_from_actual_to_target, appointment_start_date,
                                                 total_lead_allocation, actual_lead_allocation, score,
                                                 lead_gen_num, lead_gen_den, self_gen, total_avail,
                                                 appointment_count_with_interval, appointment_count, created_date,
                                                 available_users, created_by_id, manual_allocation,
                                                 project_process_step_event_id)
      (
        select p_project_id,
               t.user_id,
               p_project_process_step_id,
               t.distance_from_actual_to_target,
               p_appointment_start_time,
               t.total_lead_allocation,
               t.actual_lead_allocation,
               t.score,
               t.lead_gen_num,
               t.lead_gen_den,
               t.self_gen,
               t.avail,
               t.appointment_count_with_interval,
               t.appointment_count,
               now(),
               p_users,
               p_current_user_id,
               t.manual_allocation,
               p_project_process_step_event_id
        from brs.get_total_lead_allocation(v_postal_code_zone_id, true,p_remote) as t
      );

    select scau.user_id,scau.id
    into v_user_id,v_set_closer_appointment_audit_id
    from brs.set_closer_appointment_audit scau
    where project_process_step_id = p_project_process_step_id
      and scau.user_id = any (p_users)
    order by distance_from_actual_to_target
    limit 1;
  end if;

  if v_user_id is not null then

    select first_name || ' ' || last_name,
           email
    into v_user_full_name, v_user_email
    from flow."user"
    where id = v_user_id;

    select up.id
    into v_user_position_id
    from flow.user_position up
           inner join flow.position p on up.position_id = p.id
           inner join flow.custom_field cf
                      on up.position_id = any (cf.system_list_option_ids) and cf.parent_custom_field_id = 9959 and
                         p.company_id = cf.company_id
    where up.user_id = v_user_id
      and up.primary_flag is true
      and up.archived is false
      and cf.archived is false;

    select count(1)
    into v_user_already_assigned_to_another_project_id
    from flow.project p
           inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 1 and pps.archived is false
           inner join flow.project_process_step_event ppse on pps.id = ppse.project_process_step_id and ppse.archived is false
           inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
           inner join flow.event_status_type est on cest.event_status_type_id = est.id and est.id in (1,2)
           inner join flow.company_process_step_status_type cpsst
                      on cpsst.id = pps.company_process_step_status_type_id
           inner join flow.process_step_status_type psst on psst.id = cpsst.process_step_status_type_id
      and psst.id in (1, 2)
           inner join flow.company_project_status_type cpst3 on cpst3.id = p.company_project_status_type_id
           inner join flow.project_status_type pst4 on cpst3.project_status_type_id = pst4.id
      and pst4.id in (1, 4)
    where (ppse.start_time,  ppse.end_time) overlaps ( p_appointment_start_time,(p_appointment_start_time + (case when p_remote is true then 60 else 90 end || 'minutes')::interval)::timestamp)
      and ppse.resource_id = v_user_position_id;

    if  v_user_already_assigned_to_another_project_id < 1 then

      update flow.project_process_step_event
        set project_process_step_id = p_project_process_step_id,
            process_step_event_id = (select pse.id
                                     from flow.process_step_event pse
                                     where pse.unique_behavior_type_id = 1),
            resource_id = v_user_position_id,
            start_time = p_appointment_start_time,
            end_time = (p_appointment_start_time +
                        (case when p_remote is false then 90 else 60 end || 'minutes')::interval)::timestamp
            where id = p_project_process_step_event_id;


      update brs.set_closer_appointment_audit
      set closer_selected = true
      where id = v_set_closer_appointment_audit_id;
      --set the proposal due date on the process step to the start time
      perform flow.set_pps_cfv(p_project_id, p_current_user_id, 22680::bigint, p_appointment_start_time::text);
      --change the status of the event to pending
      update flow.project_process_step_event
        set company_event_status_type_id = 7
      where id = p_project_process_step_event_id;
      --change the status of the project process step to Pending Event
      update flow.project_process_step
      set company_process_step_status_type_id = 76
      where id = p_project_process_step_id;
      --change the status of the project to appointment scheduled
      update flow.project
        set company_project_status_type_id = 61
      where id = p_project_id;

      --then return
             return query select true::boolean,
                          v_user_id::bigint,
                          p_appointment_start_time::timestamp,
                          (p_appointment_start_time +
                           (case when p_remote is false then 90 else 60 end || 'minutes')::interval)::timestamp,
                          v_user_full_name,
                          v_user_email,
                          v_user_position_id;
    elsif v_user_already_assigned_to_another_project_id > 0 and array_length(p_users, 1) > 1 then
      p_users = array_remove(p_users, v_user_id);
      -- raise notice 'i am here';
      return query select *
                   from flow.set_closer_appointment(p_project_id,
                                                    p_current_user_id,
                                                    p_project_process_step_id,
                                                    p_project_process_step_event_id,
                                                    p_appointment_start_time,
                                                    p_users,
                                                    p_remote);
    else
      return query select false::boolean, null::bigint, null::timestamp, null::timestamp, null::text, null::text,null::bigint;
    end if;

  else
    return query select false::boolean, null::bigint, null::timestamp, null::timestamp, null::text, null::text,null::bigint;
  end if;


END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
