CREATE OR REPLACE FUNCTION flow.get_availability_time_slots(p_project_id integer,
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
        with user_ids as (
            select up.user_id,up.id
            from flow.project p
                     inner join flow.postal_code pc on pc.postal_code = p.postal_code
                     inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id
                     inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id
                     inner join flow.user_position up on up.id = pczu.user_position_id and primary_flag is true
                     inner join flow.position p1 on p1.id = up.position_id and p1.schedulable is true
            where p.id = p_project_id
        )
        select ui.user_id,ui.id, ppscfv.timestamp_value as start_time, ppscfv2.timestamp_value as end_time
        from flow.project p
                 inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 1
                 inner join flow.project_process_step_custom_field_value ppscfv
                            on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 5
                 inner join flow.project_process_step_custom_field_value ppscfv2
                            on ppscfv2.project_process_step_id = pps.id and ppscfv2.custom_field_group_assignment_id = 6
                 inner join flow.project_process_step_custom_field_value ppscfv1
                            on ppscfv1.project_process_step_id = pps.id and ppscfv1.custom_field_group_assignment_id = 7
                 inner join user_ids ui on ui.id = ppscfv1.int_value
        where ppscfv.timestamp_value >= p_start_time
          and ppscfv2.timestamp_value <= p_end_time
        union all
        select ra.user_id,null as id, ra.start_time as start_time, ra.end_time as end_time
        from flow.resource_appointment ra
                 inner join flow.user_position up on up.user_id = ra.user_id and up.primary_flag is true
                 inner join flow.postal_code_zone_user pczu on pczu.user_position_id  = up.id
                 inner join flow.postal_code_zone pcz on pcz.id = pczu.postal_code_zone_id
                 inner join flow.postal_code pc on pc.postal_code_zone_id = pcz.id
                 inner join flow.project p on p.postal_code = pc.postal_code
        where p.id = p_project_id
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
                                   select up.user_id,
                                          generate_series(
                                                  ($$'$$ || p_available_date || $$'$$ || rsa.start_time)::timestamp,
                                                  (case
                                                       when rsa.end_time > rsa.start_time
                                                           then $$'$$ || p_available_date || $$'$$
                                                       else $$'$$ || p_available_date + 1 || $$'$$ end ||
                                                   rsa.end_time)::timestamp, interval '30 min')  -(rsa.end_time - (default_appointment_length || ' minutes')::interval)  available_times,
                                          uc.default_appointment_length,
                                          (rsa.end_time - (default_appointment_length || ' minutes')::interval) closer_end_time
                                   from flow.project p
                                            inner join flow.postal_code pc on pc.postal_code = p.postal_code
                                            inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id
                                            inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id
                                            inner join flow.user_position up on up.id = pczu.user_position_id and primary_flag is true
                                            inner join flow.resource_schedule rs on rs.user_id = up.user_id
                                            inner join flow.resource_schedule_availability rsa
                                                       on rsa.resource_schedule_id = rs.id
                                                           and
                                                          rsa.day_of_week_id = extract(dow from p_available_date::date)
                                            inner join flow.user_company uc on uc.user_id = rs.user_id and uc.company_id = 3
                                   where p.id = p_project_id
                                     and case when rs.end_date is not null then
                                            p_available_date::date between rs.start_date and rs.end_date
                                         else
                                             p_available_date::date >= rs.start_date end) as foo) as foo1
                 where foo1.scheduled_start_time > now()  + interval '30 minutes') as foo2
        where foo2.available is true
        group by foo2.scheduled_start_time
        order by foo2.scheduled_start_time;

    drop table if exists excluded_appointments;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100
                     ROWS 1000;

