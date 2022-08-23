drop function if exists flow.get_availability_time_slots(bigint,timestamp,timestamp,date,boolean);
CREATE OR REPLACE FUNCTION flow.get_availability_time_slots(p_project_id bigint,
                                                            p_start_time timestamp,
                                                            p_end_time timestamp,
                                                            p_available_date date,
                                                            p_remote boolean default false)
  RETURNS TABLE
          (
            success                boolean,
            users                bigint array,
            scheduled_start_time timestamp
          )
AS
$BODY$
declare
  v_timezone text;
BEGIN

  select coalesce(t.timezone, p.time_zone)
  into v_timezone
  from flow.project p
         inner join flow.postal_code_zone_postal_code pc on pc.postal_code = substr(
    trim(both ',' from trim(both ' ' from trim(both '	' from p.postal_code))), 1, 5) and pc.archived is false
         inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id and pcz.archived is false
         left join flow.company_timezone ct on pcz.company_timezone_id = ct.id
         left join flow.timezone t on ct.timezone_id = t.id
  where p.id = p_project_id;

  if p_remote is false and v_timezone is not null then
    create temp table excluded_appointments as (
      with user_ids as (
        select up.user_id,
               up.id,
               (select array_agg(up2.id)
                from flow.user_position up2
                where user_id = up.user_id) as user_position_ids
        from flow.project p
               inner join flow.postal_code_zone_postal_code pc on pc.postal_code = substr(
          trim(both ',' from trim(both ' ' from trim(both '	' from p.postal_code))), 1, 5) and pc.archived is false
               inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id and pcz.archived is false
               inner join flow.postal_code_zone_user pczu
                          on pczu.postal_code_zone_id = pcz.id and pczu.postal_code_zone_user_type_id = 1 and
                             pczu.archived is false
               inner join flow.user_position up
                          on up.user_id = pczu.user_id and primary_flag is true and up.archived is false
               inner join flow.position p1 on p1.id = up.position_id and p1.schedulable is true
        where p.id = p_project_id
        group by up.user_id, up.id
      )
      select ui.user_id, ui.id, ppse.start_time as start_time, ppse.end_time as end_time
      from flow.project p
             inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 1 and pps.archived is false
             inner join flow.project_process_step_event ppse on pps.id = ppse.project_process_step_id and ppse.archived is false
             inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
             inner join flow.event_status_type est on cest.event_status_type_id = est.id and (est.id in (1,2) or (p.id = p_project_id and cest.id = 24)) -- 24 = needs to be rescheduled, per judson we dont want a user to be available if they already have an appt in needs to be rescheduled
             inner join user_ids ui on ppse.resource_id = any (ui.user_position_ids)
             inner join flow.company_process_step_status_type cpsst
                        on cpsst.id = pps.company_process_step_status_type_id
             inner join flow.process_step_status_type psst on psst.id = cpsst.process_step_status_type_id
        and psst.id in (1, 2)
             inner join flow.company_project_status_type cpst3 on cpst3.id = p.company_project_status_type_id
             inner join flow.project_status_type pst4 on cpst3.project_status_type_id = pst4.id
        and pst4.id in (1, 4)
      where ppse.start_time >= p_start_time
        and ppse.end_time <= p_end_time
      union all
      select ra.user_id, -1 as id, ra.start_time as start_time, ra.end_time as end_time
      from flow.resource_appointment ra
             inner join flow.postal_code_zone_user pczu
                        on pczu.user_id = ra.user_id and pczu.postal_code_zone_user_type_id = 1 and
                           pczu.archived is false
             inner join flow.postal_code_zone pcz on pcz.id = pczu.postal_code_zone_id and pcz.archived is false
             inner join flow.postal_code_zone_postal_code pc on pc.postal_code_zone_id = pcz.id and pc.archived is false
             inner join flow.project p on p.postal_code = pc.postal_code
             inner join user_ids ui2 on ui2.user_id = ra.user_id
      where p.id = p_project_id
        and ra.archived is false
        and ((start_time between p_start_time and p_end_time
        or ra.end_time between p_start_time and p_end_time)
        or (ra.start_time < p_start_time and ra.end_time > p_end_time))
    );
  elsif p_remote is true then
    create temp table excluded_appointments as (
      with user_ids as (
        select up.user_id,
               up.id,
               (select array_agg(up2.id)
                from flow.user_position up2
                where user_id = up.user_id) as user_position_ids
        from flow.postal_code_zone pcz
               inner join flow.postal_code_zone_user pczu
                          on pczu.postal_code_zone_id = pcz.id and pczu.postal_code_zone_user_type_id = 1 and
                             pczu.archived is false
               inner join flow.user_position up
                          on up.user_id = pczu.user_id and primary_flag is true and up.archived is false
               inner join flow.position p1 on p1.id = up.position_id and p1.schedulable is true
        where pcz.remote is true  and pcz.archived is false
        group by up.user_id, up.id
      )
      select ui.user_id, ui.id, ppse.start_time as start_time, ppse.end_time as end_time
      from flow.project p
             inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 1 and pps.archived is false
             inner join flow.project_process_step_event ppse on pps.id = ppse.project_process_step_id and ppse.archived is false
             inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
             inner join flow.event_status_type est on cest.event_status_type_id = est.id and (est.id in (1,2) or (p.id = p_project_id and cest.id = 24)) -- 24 = needs to be rescheduled, per judson we dont want a user to be available if they already have an appt in needs to be rescheduled
             inner join user_ids ui on ppse.resource_id = any (ui.user_position_ids)
             inner join flow.company_process_step_status_type cpsst
                        on cpsst.id = pps.company_process_step_status_type_id
             inner join flow.process_step_status_type psst on psst.id = cpsst.process_step_status_type_id
        and psst.id in (1, 2)
             inner join flow.company_project_status_type cpst3 on cpst3.id = p.company_project_status_type_id
             inner join flow.project_status_type pst4 on cpst3.project_status_type_id = pst4.id
        and pst4.id in (1, 4)
      where ppse.start_time >= p_start_time
        and ppse.end_time <= p_end_time
      union all
      select ra.user_id, -1 as id, ra.start_time as start_time, ra.end_time as end_time
      from flow.resource_appointment ra
             inner join flow.postal_code_zone_user pczu
                        on pczu.user_id = ra.user_id and pczu.postal_code_zone_user_type_id = 1 and
                           pczu.archived is false
             inner join flow.postal_code_zone pcz on pcz.id = pczu.postal_code_zone_id and pcz.archived is false
             inner join user_ids ui2 on ui2.user_id = ra.user_id
      where pcz.remote is true
        and ra.archived is false
        and ((start_time between p_start_time and p_end_time
        or ra.end_time between p_start_time and p_end_time)
        or (ra.start_time < p_start_time and ra.end_time > p_end_time))
    );

  end if;


  if p_remote is false and v_timezone is not null then
    EXECUTE 'SET TIME ZONE ''' || v_timezone || ''';';

    return query
      select true, array_agg(distinct foo2.user_id)::bigint array as users, foo2.scheduled_start_time
      from (
             select user_id,
                    foo1.scheduled_start_time,
                    scheduled_end_time,
                    (select count(1) < 1
                     from excluded_appointments
                     where excluded_appointments.user_id = foo1.user_id
                       and case
                             when id > 0 then
                               (((foo1.scheduled_start_time between excluded_appointments.start_time and excluded_appointments.end_time)
                                 or
                                 (foo1.scheduled_end_time between excluded_appointments.start_time and excluded_appointments.end_time))
                                 or
                                (excluded_appointments.start_time between foo1.scheduled_start_time and foo1.scheduled_end_time
                                  or
                                 excluded_appointments.end_time between foo1.scheduled_start_time and foo1.scheduled_end_time))
                             else ((excluded_appointments.start_time < foo1.scheduled_end_time
                               and excluded_appointments.end_time > foo1.scheduled_start_time))
                               and
                                  ((foo1.scheduled_start_time between excluded_appointments.start_time and excluded_appointments.end_time)
                                    or
                                   (foo1.scheduled_end_time between excluded_appointments.start_time and excluded_appointments.end_time)) end) as available
             from (
                    select user_id,
                           available_times                                                          as scheduled_start_time,
                           (available_times + (default_appointment_length || ' minutes')::interval) as scheduled_end_time
                    from (
                           select pczu.user_id,
                                  ($$'$$ || p_available_date::date || $$'$$ || rst.start_time)::timestamp with time zone at time zone
                                  'UTC' as available_times,
                                  90    as default_appointment_length
                           from flow.project p
                                  inner join flow.postal_code_zone_postal_code pc on pc.postal_code = substr(
                             trim(both ',' from trim(both ' ' from trim(both '	' from p.postal_code))), 1, 5) and
                                                                    pc.archived is false
                                  inner join flow.postal_code_zone pcz
                                             on pcz.id = pc.postal_code_zone_id and pcz.archived is false
                                  inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id and
                                                                                pczu.postal_code_zone_user_type_id =
                                                                                1 and pczu.archived is false
                                  inner join flow.resource_schedule rs
                                             on rs.user_id = pczu.user_id and rs.archived is false
                                  inner join flow.company_user_status cus on cus.user_id = pczu.user_id
                                  inner join flow.user_status_type ust
                                             on cus.user_status_type_id = ust.id and ust.has_access is true and ust.company_id = 3 and ust.archived is false
                                  inner join flow.user_position up
                                             on up.user_id = pczu.user_id and primary_flag is true and up.archived is false
                                  inner join flow.position p1 on p1.id = up.position_id and p1.schedulable is true
                                  inner join flow.resource_schedule_availability rsa
                                             on rsa.resource_schedule_id = rs.id
                                               and rsa.archived is false
                                               and rsa.day_of_week_id = extract(dow from p_available_date::date)
                                  inner join flow.resource_slot_schedule rss
                                             on rss.id = rsa.resource_slot_schedule_id and rss.archived is false
                                  inner join flow.resource_slot_time rst
                                             on rss.id = rst.resource_slot_schedule_id and rst.archived is false
                                  inner join flow.user_company uc on uc.user_id = rs.user_id and uc.company_id = 3 and uc.archived is false
                                  left join flow.excluded_resource_slot_time erst
                                            on erst.resource_slot_time_id = rst.id and
                                               erst.resource_schedule_availability_id = rsa.id
                                              and erst.archived is false
                           where p.id = p_project_id
                             and erst.id is null
                             and pcz.remote is false
                             and case
                                   when rs.end_date is not null then
                                     p_available_date::date between rs.start_date and rs.end_date
                                   else
                                       p_available_date::date >= rs.start_date end) as foo) as foo1) as foo2
      where foo2.available is true
        and foo2.scheduled_start_time at time zone 'UTC' at time zone v_timezone > now() + interval '30 minutes'
      group by foo2.scheduled_start_time
      order by foo2.scheduled_start_time;
  elsif p_remote is false and v_timezone is null then
    return query select false::boolean, array[]::bigint[], null::timestamp;
  else
    return query
      select true, array_agg(distinct foo2.user_id)::bigint array as users, foo2.scheduled_start_time
      from (
             select user_id,
                    foo1.scheduled_start_time,
                    scheduled_end_time,
                    (select count(1) < 1
                     from excluded_appointments
                     where excluded_appointments.user_id = foo1.user_id
                       and case
                             when id > 0 then
                               ((foo1.scheduled_start_time, foo1.scheduled_end_time) overlaps (excluded_appointments.start_time , excluded_appointments.end_time)
                                 or
                                (excluded_appointments.start_time , excluded_appointments.end_time) overlaps (foo1.scheduled_start_time, foo1.scheduled_end_time) )
                             else ((excluded_appointments.start_time < foo1.scheduled_end_time
                               and excluded_appointments.end_time > foo1.scheduled_start_time))
                               and
                                  ((foo1.scheduled_start_time, foo1.scheduled_end_time) overlaps (excluded_appointments.start_time , excluded_appointments.end_time)
                                    or
                                   (excluded_appointments.start_time , excluded_appointments.end_time) overlaps (foo1.scheduled_start_time, foo1.scheduled_end_time) ) end) as available,
                    pczu_timezone
             from (
                    select user_id,
                           available_times                                                          as scheduled_start_time,
                           (available_times + (default_appointment_length || ' minutes')::interval) as scheduled_end_time,
                           pczu_timezone
                    from (
                           select pczu.user_id,
                                  ((($$'$$ || p_available_date::date || $$'$$ || rst.start_time)::timestamp at time zone
                                    coalesce(t1.timezone, t.timezone))::timestamp with time zone at time zone
                                   'UTC')                           as available_times,
                                  60                                as default_appointment_length,
                                  coalesce(t1.timezone, t.timezone) as pczu_timezone
                           from flow.postal_code_zone pcz
                                  inner join flow.company_timezone ct on ct.id = pcz.company_timezone_id
                                  inner join flow.timezone t on t.id = ct.timezone_id
                                  inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id and
                                                                                pczu.postal_code_zone_user_type_id =
                                                                                1 and pczu.archived is false
                                  left join flow.company_timezone ct1 on ct1.id = pczu.company_timezone_id
                                  left join flow.timezone t1 on t1.id = ct1.timezone_id
                                  inner join flow.resource_schedule rs
                                             on rs.user_id = pczu.user_id and rs.archived is false
                                  inner join flow.company_user_status cus on cus.user_id = pczu.user_id
                                  inner join flow.user_status_type ust
                                             on cus.user_status_type_id = ust.id and ust.has_access is true and ust.company_id = 3 and ust.archived is false
                                  inner join flow.resource_schedule_availability rsa
                                             on rsa.resource_schedule_id = rs.id
                                               and rsa.archived is false
                                               and rsa.day_of_week_id = extract(dow from p_available_date::date)
                                  inner join flow.resource_slot_schedule rss
                                             on rss.id = rsa.resource_slot_schedule_id and rss.archived is false
                                  inner join flow.resource_slot_time rst
                                             on rss.id = rst.resource_slot_schedule_id and rst.archived is false
                                  inner join flow.user_company uc on uc.user_id = rs.user_id and uc.company_id = 3 and uc.archived is false
                                  left join flow.excluded_resource_slot_time erst
                                            on erst.resource_slot_time_id = rst.id and
                                               erst.resource_schedule_availability_id = rsa.id
                                              and erst.archived is false
                           where pcz.remote is true
                             and pcz.archived is false
                             and erst.id is null
                             and case
                                   when rs.end_date is not null then
                                     p_available_date::date between rs.start_date and rs.end_date
                                   else
                                       p_available_date::date >= rs.start_date end) as foo) as foo1) as foo2
      where foo2.available is true
        and foo2.scheduled_start_time at time zone 'UTC' at time zone pczu_timezone >
            now() at time zone pczu_timezone + interval '30 minutes'
      group by foo2.scheduled_start_time
      order by foo2.scheduled_start_time;

  end if;
  set TimeZone = 'UTC';
  drop table if exists excluded_appointments;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
