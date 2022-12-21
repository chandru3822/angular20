drop function if exists flow.past_available_time_slots(p_user_id bigint,
                                                       p_start_time timestamp,
                                                       p_end_time timestamp,
                                                       p_available_date date,
                                                       p_time_zone text);
CREATE OR REPLACE FUNCTION flow.past_available_time_slots(p_user_id bigint,
                                                          p_start_time timestamp,
                                                          p_end_time timestamp,
                                                          p_available_date date,
                                                          p_time_zone text)
    RETURNS TABLE
            (
                users                bigint array,
                scheduled_start_time timestamp
            )
AS
$BODY$

BEGIN

    create temp table excluded_appointments as (
        select ra.user_id, ra.start_time as start_time, ra.end_time as end_time
        from flow.resource_appointment ra
                 inner join flow.user_position up on up.user_id = ra.user_id
            and up.primary_flag is true and up.archived is false
        where up.user_id = p_user_id and
            ra.archived is false
          and ((start_time between p_start_time and p_end_time
        or ra.end_time between p_start_time and p_end_time)
              or (ra.start_time < p_start_time and ra.end_time > p_end_time))
    );
-- raise notice 'start time %',p_start_time;
-- raise notice 'end time %',p_end_time;
-- raise notice 'p_available_date %',p_available_date;

    EXECUTE 'SET TIME ZONE ''' || p_time_zone || ''';';
    return query
        select array_agg(foo2.user_id)::bigint array as users, foo2.scheduled_start_time
        from (
                 select user_id,
                        foo1.scheduled_start_time,
                        scheduled_end_time,
                        (select count(1) < 1
                         from excluded_appointments
                         where excluded_appointments.user_id = foo1.user_id
                           and ((excluded_appointments.start_time <foo1.scheduled_end_time
                                        and excluded_appointments.end_time > foo1.scheduled_start_time ))
                                        and ((foo1.scheduled_start_time between excluded_appointments.start_time and excluded_appointments.end_time)
                                            or
                                             (foo1.scheduled_end_time between excluded_appointments.start_time and excluded_appointments.end_time)) ) as available
                 from (
                          select user_id,
                                 available_times                                                          as scheduled_start_time,
                                 (available_times + (default_appointment_length || ' minutes')::interval) as scheduled_end_time
                          from (
                                   select rs.user_id,
                                          ($$'$$ || p_available_date::date || $$'$$ || rst.start_time)::timestamp with time zone at time zone 'UTC' as available_times,
                                          90 as default_appointment_length
                                   from flow.resource_schedule rs
                                            inner join flow.resource_schedule_availability rsa
                                                       on rsa.resource_schedule_id = rs.id
                                                           and rsa.archived is false
                                                           and rsa.day_of_week_id = extract(dow from p_available_date::date)
                                            inner join flow.resource_slot_schedule rss on rss.id = rsa.resource_slot_schedule_id and rss.archived is false
                                            inner join flow.resource_slot_time rst on rss.id = rst.resource_slot_schedule_id and rst.archived is false
                                            inner join flow.user_company uc on uc.user_id = rs.user_id and uc.company_id = 3
                                            left join flow.excluded_resource_slot_time erst on erst.resource_slot_time_id = rst.id and
                                                                                               erst.resource_schedule_availability_id = rsa.id
                                       and erst.archived is false
                                   where rs.user_id = p_user_id and erst.id is null
                                     and p_available_date::date >= rs.start_date and
                                         case when rs.end_date is not null then p_available_date <=rs.end_date
                                        else 1=1 end) as foo) as foo1) as foo2
        where foo2.available is true
        group by foo2.scheduled_start_time
        order by foo2.scheduled_start_time;
    set TimeZone = 'UTC';
    drop table if exists excluded_appointments;

  insert into flow.company_function_log(function_name, parameters)
  values ('Past Available Time Slot', 'p_user_id: ' || p_user_id ||
                                      ' p_start_time: '|| p_start_time ||
                                      ' p_end_time: '|| p_end_time ||
                                      ' p_available_date: '|| p_available_date ||
                                      ' p_time_zone: '|| p_time_zone);

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100
                     ROWS 1000;
