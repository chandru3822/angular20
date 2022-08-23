DROP FUNCTION IF EXISTS brs.get_closer_availability(p_start_time timestamp, p_end_time timestamp,
                                                    p_postal_code_zone_user_ids bigint[])
CREATE OR REPLACE FUNCTION brs.get_closer_availability(p_start_time timestamp, p_end_time timestamp,
                                                       p_postal_code_zone_user_ids bigint[])
  RETURNS setof json AS
$$
BEGIN
  return query SELECT array_to_json(array_agg(row_to_json(sub_rows)))
               FROM (
                      --this portion is for personal appts
                      with dates as (
                        select p_start_time::date + d.date                   as date,
                               extract(dow from p_start_time::date + d.date) as day_of_week_id
                        from generate_series(0, 99) as d(date)
                        where p_start_time::date + d.date BETWEEN p_start_time::date and p_end_time::date - interval '1 day'
                      )
                      select pczu.id                   as "resourceId",
                             ra.start_time                                     as "start",
                             ra.end_time                                       as "end",
                             null::bigint                                         as "dayOfWeekId",
                             ra.all_day                                        as "allDay",
                             ra.title,
                             'background'                                      as rendering,
                             false as  "isSlotTime",
                             null  as "daylightSavings", -- personal appts don't need to do adjustments based on DST
                             case when ra.org_id is not null then 1 else 2 end as "systemListTypeId"
                      from flow.resource_appointment ra
                             inner join flow.postal_code_zone_user pczu on pczu.user_id = ra.user_id and pczu.postal_code_zone_user_type_id = 1 and pczu.archived is false
                      where (ra.start_time between p_start_time and p_end_time
                        or ra.end_time between p_start_time and p_end_time
                        or ra.start_time <= p_start_time and p_end_time <= ra.end_time)
                        and ra.archived is not true
                        and pczu.id = any (p_postal_code_zone_user_ids)

                      union all
                      --this portion is for slot schedules
                      select pczu.id                                                                 as "resourceId",
                             ((concat(d.date, ' ', rst.start_time))::timestamp at time zone t.timezone) as "start",
                             ((concat(d.date, ' ', rst.end_time))::timestamp at time zone t.timezone)   as "end",
                             rsa.day_of_week_id,
                             false                                                                      as "allDay",
                             null                                                                       as title,
                             'inverse-background'                                                       as rendering,
                             true as  "isSlotTime", --i had no way to tell this apart from a regular schedule on the frontend
                             null  as "daylightSavings", -- slot schedules don't need to do adjustments based on DST
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
                             inner join flow.postal_code_zone_user pczu on pczu.user_id = u.id and pczu.postal_code_zone_user_type_id = 1 and pczu.archived is false
                             inner join flow.postal_code_zone pcz on pczu.postal_code_zone_id = pcz.id
                             inner join flow.company_timezone ct on pcz.company_timezone_id = ct.id
                             inner join flow.timezone t on ct.timezone_id = t.id
                             left join flow.excluded_resource_slot_time erst on erst.resource_slot_time_id = rst.id and
                                                                                erst.resource_schedule_availability_id = rsa.id
                                                                                and erst.archived is false
                      where rs.archived is not true
                        and rsa.archived is not true
                        and rst.archived is not true
                        and erst.id is null
                        and up.primary_flag is true
                        and up.archived is false
                        and up.start_date <= now()
                        and (up.end_date is null or up.end_date >= now())
                        and pczu.id = any (p_postal_code_zone_user_ids)) as sub_rows;


END;
$$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
