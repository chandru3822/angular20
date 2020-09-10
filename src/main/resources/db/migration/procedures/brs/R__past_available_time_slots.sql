CREATE OR REPLACE FUNCTION flow.past_available_time_slots(p_user_id bigint,
                                                          p_start_time timestamp,
                                                          p_end_time timestamp,
                                                          p_available_date date)
    RETURNS TABLE
            (
                users                integer array,
                scheduled_start_time timestamp
            )
AS
$BODY$

BEGIN

    create temp table excluded_appointments as (
        select ra.user_id, ra.start_time as start_time, ra.end_time as end_time
        from flow.resource_appointment ra
                 inner join flow.postal_code_zone_user pczu on pczu.user_id = ra.user_id
                 inner join flow.postal_code_zone pcz on pcz.id = pczu.postal_code_zone_id
                 inner join flow.postal_code pc on pc.postal_code_zone_id = pcz.id
                 inner join flow.project p on p.postal_code = pc.postal_code
        where pczu.user_id = p_user_id
          and start_time >= p_start_time
          and end_time <= p_end_time
    );

    return query
        select array_agg(foo2.user_id)::integer array as users, foo2.scheduled_start_time
        from (
                 select user_id,
                        foo1.scheduled_start_time,
                        scheduled_end_time,
                        closer_end_time,
                        (select count(1) < 1
                         from excluded_appointments
                         where excluded_appointments.user_id = foo1.user_id
                           and ((foo1.scheduled_start_time between excluded_appointments.start_time and excluded_appointments.end_time)
                             or
                                (foo1.scheduled_end_time between excluded_appointments.start_time and excluded_appointments.end_time))) as available
                 from (
                          select user_id,
                                 available_times                                                          as scheduled_start_time,
                                 (available_times + (default_appointment_length || ' minutes')::interval) as scheduled_end_time,
                                 closer_end_time
                          from (
                                   select rs.user_id,
                                          generate_series(
                                                  ($$'$$ || p_available_date || $$'$$ || rsa.start_time)::timestamp,
                                                  (case
                                                       when rsa.end_time > rsa.start_time
                                                           then $$'$$ || p_available_date || $$'$$
                                                       else $$'$$ || p_available_date + 1 || $$'$$ end ||
                                                   rsa.end_time)::timestamp, interval '30 min')                 available_times,
                                          uc.default_appointment_length,
                                          (rsa.end_time - (default_appointment_length || ' minutes')::interval) closer_end_time
                                   from flow.resource_schedule rs
                                            inner join flow.resource_schedule_availability rsa
                                                       on rsa.resource_schedule_id = rs.id
                                                           and
                                                          rsa.day_of_week_id = extract(dow from p_available_date::date)
                                            inner join flow.user_company uc on uc.user_id = rs.user_id and uc.company_id = 3
                                   where rs.user_id = p_user_id
                                     and p_available_date::date between rs.start_date and rs.end_date) as foo) as foo1
                 where foo1.scheduled_start_time::time <= foo1.scheduled_end_time::time) as foo2
        where foo2.available is true
        group by foo2.scheduled_start_time
        order by foo2.scheduled_start_time;

    drop table if exists excluded_appointments;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100
                     ROWS 1000;
