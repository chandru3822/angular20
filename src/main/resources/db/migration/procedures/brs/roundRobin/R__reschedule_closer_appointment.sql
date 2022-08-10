-- drop function if exists brs.reschedule_closer_appointment(integer, integer);
CREATE OR REPLACE FUNCTION brs.reschedule_closer_appointment(p_pps_event_id integer,
                                                             p_current_user_id integer)
  RETURNS TABLE
          (
            success        boolean,
            lead_source_id integer,
            lead_source    text,
            fail_reason    text
          )
AS
$BODY$
declare
  v_timezone                      text;
  v_project_id                    integer;
  v_pps_id                        integer;
  v_process_step_event_id         integer;
  v_resource_id                   integer;
  v_event_start_time              timestamp;
  v_lead_source_id                int;
  v_lead_source                   text;
  v_closer_appt_outcome           int;
  v_available_date                date;
  v_search_start_time             timestamp;
  v_search_end_time               timestamp;
  v_failed                        boolean default true;
  v_appt_rescheduled              boolean default false;
  v_users_found                   integer array;
  v_new_pps_event_id              integer;
  v_pps_event_root_status_type_id integer;
BEGIN


  select pps.project_id,
         pps.id,
         ppse.start_time,
         lov.name,
         cfv.int_value,
         pd.closer_appointment_outcome,
         ppse.resource_id,
         ppse.process_step_event_id,
         cest.event_status_type_id
  into v_project_id, v_pps_id, v_event_start_time, v_lead_source,
    v_lead_source_id, v_closer_appt_outcome, v_resource_id,
    v_process_step_event_id, v_pps_event_root_status_type_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
         inner join brs.project_details pd on pd.project_id = pps.project_id
         inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
         left join flow.contact_custom_field_value cfv
                   on pd.contact_id = cfv.contact_id and cfv.custom_field_group_assignment_id = 395
         left join flow.list_of_value lov on lov.id = cfv.int_value
  where ppse.id = p_pps_event_id;

  --fail for the easy stuff
  --do not run this action if the calling event is not active
  if (v_pps_event_root_status_type_id != 1)
  then
    --dont reset event status here as we shouldn't have made it to here in this scenario
    return query select false, v_lead_source_id, v_lead_source, 'Calling event must be active';
    return;
    --start time must be at least 2 hours away
  elseif (v_event_start_time < (now() + interval '2 hours'))
  then
    --if failed to reschedule then set status to: Can Not Attend - Needs to be Rescheduled
    update flow.project_process_step_event set company_event_status_type_id = 27 where id = p_pps_event_id;
    return query select false,
                        v_lead_source_id,
                        v_lead_source,
                        'Event start time must be at least 2 hours in the future';
    return;
    -- lead source cannot be closer gen or referral
  elseif (v_lead_source_id in (523, 524)) --523 = closer gen, 524 = referral
  then
    --if failed to reschedule then set status to: Can Not Attend - Needs to be Rescheduled
    update flow.project_process_step_event set company_event_status_type_id = 27 where id = p_pps_event_id;
    return query select false, v_lead_source_id, v_lead_source, 'Source cannot be Closer Gen or Referral';
    return;
    -- must be a first appointment - requirement removed 4/12/22 per holly
--   elseif (v_closer_appt_outcome is not null)
--   then
--     return query select false, v_lead_source_id, v_lead_source, 'Appointment is not a first appointment.';
--     return;
  end if;

  --get project timezone the same way that the availability timeslots does
  select coalesce(t.timezone, p.time_zone)
  into v_timezone
  from flow.project p
         inner join flow.postal_code_zone_postal_code pc on pc.postal_code = substr(
    trim(both ',' from trim(both ' ' from trim(both '	' from p.postal_code))), 1, 5) and pc.archived is false
         inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id and pcz.archived is false
         left join flow.company_timezone ct on pcz.company_timezone_id = ct.id
         left join flow.timezone t on ct.timezone_id = t.id
  where p.id = v_project_id;

  --fail if no timezone
  if (v_timezone is not null) then
    --set available date
    select ((v_event_start_time at time zone 'UTC') at time zone v_timezone) into v_available_date;
    --search params should be midnight to 11:59:59 in local (v_timezone) time i.e. mountain should be 06:00:00 - 5:59:59 (the next day)
    select v_available_date::timestamp at time zone v_timezone into v_search_start_time;
    select ((v_available_date::timestamp + interval '1 day') - interval '1 second')::timestamp at time zone v_timezone
    into v_search_end_time;

    if (v_available_date is not null and v_search_start_time is not null and v_search_end_time is not null)
    then
      --get all available users at that same time
      select users
      into v_users_found
      from flow.get_availability_time_slots(v_project_id,
                                            v_search_start_time, v_search_end_time, v_available_date, false)
      where scheduled_start_time = v_event_start_time;

      --remove the current user from the result set
      v_users_found = array_remove(v_users_found, v_resource_id);

      --if there is a slot still available then continue
      if (v_users_found is not null and array_length(v_users_found, 1) > 0)
      then
        --add the new pps
        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id,
                                                    company_event_status_type_id, created_by_id, save_version)
        values (v_pps_id, v_process_step_event_id, (select initial_company_event_status_type_id
                                                    from flow.process_step_event
                                                    where id = v_process_step_event_id), p_current_user_id, 1)
        returning id into v_new_pps_event_id;

        if (v_new_pps_event_id is not null)
        then
          --schedule the new pps event
          select sca.success
          into v_appt_rescheduled
          from flow.set_closer_appointment(v_project_id, p_current_user_id,
                                           v_pps_id, v_new_pps_event_id,
                                           v_event_start_time, v_users_found,
                                           false) as sca;

          --if we were able to reschedule then return success
          if (v_appt_rescheduled)
          then
            v_failed = false;
            --if we did reschedule then set the closer appt outcome to Closer Cannot Attend: Reassign on the old pps event
            perform flow.set_pps_event_cfv(p_pps_event_id, 99999999, 4::integer, 15327::text);

            --if we did reschedule then set the status of the current ppsEvent to Can Not Attend - Rescheduled
            update flow.project_process_step_event set company_event_status_type_id = 24 where id = p_pps_event_id;

            -- due to order of operations for the triggers, we have to update the new one last.  This is a hack.
            update flow.project_process_step_event set id = id where id = v_new_pps_event_id;

            --if we did reshcedule then send a text to the new closer
            perform brs.send_text_to_closer(v_project_id, p_current_user_id, 1);

            --return success
            return query select true, v_lead_source_id, v_lead_source, null;
            return;
          else
            --if failed to reschedule then set status to: Can Not Attend - Needs to be Rescheduled
            update flow.project_process_step_event set company_event_status_type_id = 27 where id = p_pps_event_id;
            return query select false,
                                v_lead_source_id,
                                v_lead_source,
                                'Set Closer Appointment failed to save for unknown reasons.';
            return;
          end if;
        else
          --if failed to reschedule then set status to: Can Not Attend - Needs to be Rescheduled
          update flow.project_process_step_event set company_event_status_type_id = 27 where id = p_pps_event_id;
          return query select false, v_lead_source_id, v_lead_source, 'Failed to add new project process step event';
          return;
        end if;
      else
        --if failed to reschedule then set status to: Can Not Attend - Needs to be Rescheduled
        update flow.project_process_step_event set company_event_status_type_id = 27 where id = p_pps_event_id;
        return query select false, v_lead_source_id, v_lead_source, 'No users available at the selected time';
        return;
      end if;
      return;
    end if;
    return;
  end if;

  --failover for any unhandled errors
  if (v_failed) then
    --if failed to reschedule then set status to: Can Not Attend - Needs to be Rescheduled
    update flow.project_process_step_event set company_event_status_type_id = 27 where id = p_pps_event_id;
    return query select false, v_lead_source_id, v_lead_source, 'Unable to reschedule.';
    return;
  end if;


END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
