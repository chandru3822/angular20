--DROP FUNCTION IF EXISTS flow.get_availability(integer, integer, boolean, integer[]);
CREATE OR REPLACE FUNCTION flow.get_availability(p_start_time timestamp, p_end_time timestamp, p_org_ids int[],
                                                 p_user_ids int[])
  RETURNS setof json AS
$$
DECLARE
  v_user_sluts     integer[];
  v_user_non_sluts integer[];
BEGIN
  select array_agg(distinct foo3.user_id)
  into v_user_sluts
  from (
         select foo2.user_id
         from (
                select foo.user_id
                from (
                       select *
                       from unnest(p_user_ids) as user_id) as foo) as foo2
                inner join flow.user_position up on up.user_id = foo2.user_id
                inner join flow.position p on p.id = up.position_id and p.use_slot_schedule is true) as foo3;

  select array_agg(distinct foo3.user_id)
  into v_user_non_sluts
  from (
         select foo2.user_id
         from (
                select foo.user_id
                from (
                       select *
                       from unnest(p_user_ids) as user_id) as foo) as foo2
                inner join flow.user_position up on up.user_id = foo2.user_id
                inner join flow.position p on p.id = up.position_id and p.use_slot_schedule is not true) as foo3;

  return query SELECT array_to_json(array_agg(row_to_json(sub_rows)))
               FROM (
                      with dates as (
                        select p_start_time::date + d.date                   as date,
                               extract(dow from p_start_time::date + d.date) as day_of_week_id
                        from generate_series(0, 99) as d(date)
                        where p_start_time::date + d.date BETWEEN p_start_time::date and p_end_time::date - interval '1 day'
                      )
                      select coalesce(rs.user_id, rs.org_id)                           as "resourceId",
                             (concat(d.date, ' ', rsa.start_time))::timestamp          as "start",
                             case
                               when (concat(d.date, ' ', rsa.start_time))::timestamp >
                                    (concat(d.date, ' ', rsa.end_time))::timestamp
                                 then (concat(d.date + interval '1 day', ' ', rsa.end_time))::timestamp
                               else (concat(d.date, ' ', rsa.end_time))::timestamp end as "end",
                             rsa.day_of_week_id                                        as "dayOfWeekId",
                             false                                                     as "allDay",
                             null                                                      as title,
                             'inverse-background'                                      as rendering,
                             case when rs.org_id is not null then 1 else 2 end         as "systemListTypeId"
                      from dates d
                             inner join flow.resource_schedule_availability rsa on rsa.day_of_week_id = d.day_of_week_id
                             inner join flow.resource_schedule rs on rs.id = rsa.resource_schedule_id and
                                                                     ((d.date between rs.start_date and rs.end_date) OR
                                                                      (d.date >= rs.start_date and rs.end_date is null))
                      where rs.archived is not true
                        and rsa.archived is not true
                        and (rs.org_id = any (p_org_ids)
                        OR rs.user_id = any (v_user_non_sluts))
                      union all
                      select coalesce(ra.user_id, ra.org_id)                   as "resourceId",
                             ra.start_time                                     as "start",
                             ra.end_time                                       as "end",
                             null::int                                         as "dayOfWeekId",
                             ra.all_day                                        as "allDay",
                             ra.title,
                             'background'                                      as rendering,
                             case when ra.org_id is not null then 1 else 2 end as "systemListTypeId"
                      from flow.resource_appointment ra
                      where (ra.start_time between p_start_time and p_end_time
                        or ra.end_time between p_start_time and p_end_time
                        or ra.start_time <= p_start_time and p_end_time <= ra.end_time)
                        and ra.archived is not true
                        and (ra.org_id = any (p_org_ids)
                        OR ra.user_id = any (p_user_ids))

                      union all
                      select rs.user_id                                                                 as "resourceId",
                             ((concat(d.date, ' ', rst.start_time))::timestamp at time zone t.timezone) as "start",
                             ((concat(d.date, ' ', rst.end_time))::timestamp at time zone t.timezone)   as "end",
                             rsa.day_of_week_id,
                             false                                                                      as "allDay",
                             null                                                                       as title,
                             'inverse-background'                                                       as rendering,
                             case when rs.org_id is not null then 1 else 2 end                          as "systemListTypeId"
                      from dates d
                             inner join flow.resource_schedule_availability rsa on rsa.day_of_week_id = d.day_of_week_id
                             inner join flow.resource_schedule rs on rs.id = rsa.resource_schedule_id and
                                                                     ((d.date between rs.start_date and rs.end_date) OR
                                                                      (d.date >= rs.start_date and rs.end_date is null))
                             inner join flow.resource_slot_schedule rss on rsa.resource_slot_schedule_id = rss.id
                             inner join flow.resource_slot_time rst on rss.id = rst.resource_slot_schedule_id
                             inner join flow."user" u on u.id = rs.user_id
                             inner join flow.user_position up on u.id = up.user_id
                             inner join flow.org o on o.id = up.org_id
                             inner join flow.company_timezone ct on o.company_timezone_id = ct.id
                             inner join flow.timezone t on ct.timezone_id = t.id
                             left join flow.excluded_resource_slot_time erst on erst.resource_slot_time_id = rst.id and
                                                                                erst.resource_schedule_availability_id = rsa.id
                                                                                and erst.archived is false
                      where rs.archived is not true
                        and rsa.archived is not true
                        and erst.id is null
                        and up.primary_flag is true
                        and up.archived is false
                        and up.start_date <= now()
                        and (up.end_date is null or up.end_date >= now())
                        and rs.user_id = any (v_user_sluts)) as sub_rows;


END;
$$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
