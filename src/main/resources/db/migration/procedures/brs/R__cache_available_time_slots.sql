CREATE OR REPLACE FUNCTION flow.cache_available_time_slots()
    RETURNS void
AS
$BODY$

BEGIN

    truncate table brs.cached_appointment;
    insert into brs.cached_appointment(user_id,appointment_count)
    (
    select foo.user,count(1) as avail
    from (
             with active_users as (
                 select u.id,u.first_name,u.last_name,up.position_id,
                        date_trunc('day', now() AT TIME ZONE o.time_zone_abbreviation) AT TIME ZONE o.time_zone_abbreviation as start_time,
                        (date_trunc('day', now() AT TIME ZONE o,time_zone_abbreviation) AT TIME ZONE o.time_zone_abbreviation) + interval '1 day' - interval '1 second' as end_time
                 from flow.user u
                          inner join flow.user_position up on up.user_id = u.id
                          inner join flow.org o on o.id = up.org_id
                          inner join flow.company_user_status cus on cus.user_id = u.id
                          inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = o.company_id
                     and up.position_id in (1,2,3)
                     and up.end_date is null
                     and up.primary_flag is true
                     and up.archived is false
                     and ust.has_access is true
             )
             select unnest(users) as user, scheduled_start_time
             from active_users ap cross join generate_series(ap.start_time - interval '21 days',
                                                                ap.end_time, interval '1 day') as gs(d)
                                     join lateral flow.past_available_time_slots(
                     ap.id,
                     d::timestamp,
                     (d + interval '23 hours 59 minutes 59 seconds')::timestamp,
                     d::date) as t on true) as foo
    group by foo.user);
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
