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
            select up.user_id,up.id,(select array_agg(up2.id)
                                      from flow.user_position up2
                                      where user_id = up.user_id) as user_position_ids
            from flow.project p
                     inner join flow.postal_code pc on pc.postal_code = p.postal_code and pc.archived is false
                     inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id and pcz.archived is false
                     inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id and pczu.postal_code_zone_user_type_id = 1 and pczu.archived is false
                     inner join flow.user_position up on up.user_id = pczu.user_id and primary_flag is true
                     inner join flow.position p1 on p1.id = up.position_id and p1.schedulable is true
            where p.id = p_project_id
            group  by up.user_id,up.id
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
                 inner join user_ids ui on ppscfv1.int_value = any(ui.user_position_ids)
                 inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
                 inner join flow.process_step_status_type psst on psst.id = cpsst.process_step_status_type_id
            and psst.process_step_status_type in ('ACTIVE','COMPLETE')
                 inner join flow.company_project_status_type cpst3 on cpst3.id = p.company_project_status_type_id
                 inner join flow.project_status_type pst4 on cpst3.project_status_type_id = pst4.id
            and pst4.project_status_type in ('Active','Complete')
        where ppscfv.timestamp_value >= p_start_time
          and ppscfv2.timestamp_value <= p_end_time
        union all
        select ra.user_id,-1 as id, ra.start_time as start_time, ra.end_time as end_time
        from flow.resource_appointment ra
                 inner join flow.postal_code_zone_user pczu on pczu.user_id  = ra.user_id and pczu.postal_code_zone_user_type_id = 1 and pczu.archived is false
                 inner join flow.postal_code_zone pcz on pcz.id = pczu.postal_code_zone_id and pcz.archived is false
                 inner join flow.postal_code pc on pc.postal_code_zone_id = pcz.id and pc.archived is false
                 inner join flow.project p on p.postal_code = pc.postal_code
                 inner join user_ids ui2 on ui2.user_id = ra.user_id
        where p.id = p_project_id and ra.archived is false
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
                        (select count(1) > 0
                         from excluded_appointments ea
                         where ea.user_id = foo1.user_id
                           and id < 0
                           and (ea.end_time = foo1.scheduled_start_time
                               or ea.start_time = foo1.scheduled_end_time)) as personal_appointments,
                        (select count(1) < 1
                         from excluded_appointments
                         where excluded_appointments.user_id = foo1.user_id
                           and case when id > 0 then
                                        ((foo1.scheduled_start_time between excluded_appointments.start_time and excluded_appointments.end_time)
                                            or
                                         (foo1.scheduled_end_time between excluded_appointments.start_time and excluded_appointments.end_time))
                                    else ((excluded_appointments.start_time <foo1.scheduled_end_time
                                        and excluded_appointments.end_time > foo1.scheduled_start_time ))
                                        and ((foo1.scheduled_start_time between excluded_appointments.start_time and excluded_appointments.end_time)
                                            or
                                             (foo1.scheduled_end_time between excluded_appointments.start_time and excluded_appointments.end_time)) end) as available
                 from (
                          select user_id,
                                 available_times                                                          as scheduled_start_time,
                                 (available_times + (default_appointment_length || ' minutes')::interval) as scheduled_end_time,
                                 closer_end_time
                          from (
                                   select pczu.user_id,
                                          generate_series(
                                                  ($$'$$ || p_available_date || $$'$$ || rsa.start_time)::timestamp,
                                                  (case
                                                       when rsa.end_time > rsa.start_time
                                                           then $$'$$ || p_available_date::date || $$'$$
                                                       else $$'$$ || p_available_date::date + 1 || $$'$$ end ||
                                                   rsa.end_time)::timestamp --  - (default_appointment_length || ' minutes')::interval
                                              , interval '30 min')    available_times,
                                          uc.default_appointment_length,
                                          (rsa.end_time - (default_appointment_length || ' minutes')::interval) closer_end_time
                                   from flow.project p
                                            inner join flow.postal_code pc on pc.postal_code = p.postal_code and pc.archived is false
                                            inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id and pcz.archived is false
                                            inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id and pczu.postal_code_zone_user_type_id = 1 and pczu.archived is false
                                            inner join flow.resource_schedule rs on rs.user_id = pczu.user_id and rs.archived is false
                                                and p_available_date >= rs.start_date and case when rs.end_date is not null then
                                                                                                   p_available_date <= rs.end_date
                                                                                            else 1=1 end
                                            inner join flow.resource_schedule_availability rsa
                                                       on rsa.resource_schedule_id = rs.id
                                                           and rsa.archived is false
                                                           and rsa.day_of_week_id = extract(dow from p_available_date::date)
                                            inner join flow.user_company uc on uc.user_id = rs.user_id and uc.company_id = 3
                                   where p.id = p_project_id
                                     and case when rs.end_date is not null then
                                            p_available_date::date between rs.start_date and rs.end_date
                                         else
                                             p_available_date::date >= rs.start_date end) as foo) as foo1) as foo2
        where  foo2.available is true and
                foo2.scheduled_start_time > now()  + interval '30 minutes'
        group by foo2.scheduled_start_time
        order by foo2.scheduled_start_time;

    drop table if exists excluded_appointments;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100
                     ROWS 1000;

