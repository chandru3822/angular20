drop procedure if exists brs.cache_available_time_slots();
CREATE OR REPLACE procedure brs.cache_available_time_slots()
AS
$BODY$
declare
  v_user_id bigint;
  x         record;
BEGIN

  --truncate table brs.cached_appointment;
  for x in select u.id,
                  u.first_name,
                  u.last_name,
                  coalesce(t.timezone, t1.timezone) as timezone,
                  date_trunc('day', now()) at time zone 'UTC' AT TIME ZONE
                  coalesce(t.timezone, t1.timezone) as start_time,
                  (date_trunc('day', now()) at time zone 'UTC' AT TIME ZONE
                   coalesce(t.timezone, t1.timezone)) + interval '1 day' -
                  interval '1 second'               as end_time
           from flow.user u
                  inner join flow.round_robin_user rru
                             on rru.user_id = u.id and rru.archived is false and
                                rru.round_robin_user_type_id = 1
                  left join flow.company_timezone ct
                            on ct.id = rru.company_timezone_id and ct.archived is false
                  left join flow.timezone t on t.id = ct.timezone_id
                  inner join flow.round_robin as rr
                             on rr.id = rru.round_robin_id and rr.archived is false
                  left join flow.company_timezone ct1
                            on ct1.id = rr.company_timezone_id and ct1.archived is false
                  left join flow.timezone t1 on t1.id = ct1.timezone_id
        --where u.id in ( 2484306,2404974)
    loop

      insert into brs.cached_appointment(schedule_date, user_id, appointment_count)
        (select foo.scheduled_date::date, x.id, count(1) as avail
         from (select d::date as scheduled_date, scheduled_start_time
               from  generate_series(x.start_time - interval '90 days',
                                           x.end_time + interval '10 days', interval '1 day') as gs(d)
                      join lateral flow.past_available_time_slots(
                 x.id,
                 d::timestamp,
                 (d + interval '23 hours 59 minutes 59 seconds')::timestamp,
                 d::date, x.timezone) as t on true) as foo
         group by foo.scheduled_date::date) on conflict (user_id,schedule_date) do update
          set appointment_count = excluded.appointment_count;
      commit;

    end loop;
END
$BODY$
  LANGUAGE plpgsql;
