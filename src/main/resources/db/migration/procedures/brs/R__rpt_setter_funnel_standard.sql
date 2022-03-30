-- drop function if exists brs.rpt_setter_funnel_standard(date, date, numeric, integer[], integer[]);
-- drop function if exists brs.rpt_setter_funnel_standard(date, date, numeric, integer[], integer[], boolean);
CREATE OR REPLACE FUNCTION brs.rpt_setter_funnel_standard(p_custom_start_date date, p_custom_end_date date,
                                                                p_base_expectation numeric,
                                                                p_user_position_ids integer[],
                                                                p_org_ids integer[],
                                                                p_is_cohort boolean)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_whole_company boolean;
  v_company_id    integer;
BEGIN
  --doing this so it is easier to change to allow parameterizing later if needed
  select 3 into v_company_id;

  select -1 = any (p_user_position_ids) into v_whole_company;

  RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
               from (
                      with project_data as (
                        select pd.project_id,
                               pd.project_created_date,
                               pd.prioritized_closer_appointment_outcome,
                               coalesce(pd.prioritized_closer_appointment_outcome_date,
                                        pd.closer_appointment_start) as appointment_date
                        from brs.project_details pd
                               inner join flow.user_position up on up.id = pd.setter_user_position_id
                               inner join flow.org o on o.id = up.org_id
                        where (pd.prioritized_closer_appointment_outcome_date is not null or
                               (pd.prioritized_closer_appointment_outcome_date is null and
                                pd.closer_appointment_start is not null))
                          and pd.company_id = 3
                          and pd.source = 525
                          and pd.archived is false
                          and case
                                when v_whole_company is false then
                                  (up.id = any (p_user_position_ids)
                                    -- if this part is enabled it should probably be enabled for whole company as well or numbers dont match when select all reps vs click all reps
--                                     and (case
--                                            when up.end_date is not null then
--                                              pd.project_created_date between up.start_date and up.end_date
--                                            else pd.project_created_date >= up.start_date end)
                                    and (case
                                           when array_length(p_org_ids, 1) > 0 then org_id = any (p_org_ids)
                                           else 1 = 1 end)
                                    )
                                else true end
                          and (pd.prioritized_closer_appointment_outcome_date is not null or
                               (pd.prioritized_closer_appointment_outcome_date is null and
                                pd.closer_appointment_start is not null))
                          and (
                            ((((pd.project_created_date at time zone 'UTC') at time zone 'US/Mountain')::date between p_custom_start_date and p_custom_end_date)
                              OR ((pd.project_created_date at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                               between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date)
                            OR
                            ((((coalesce(pd.prioritized_closer_appointment_outcome_date,
                                         pd.closer_appointment_start) at time zone 'UTC') at time zone
                               'US/Mountain')::date between p_custom_start_date and p_custom_end_date)
                              OR ((coalesce(pd.prioritized_closer_appointment_outcome_date,
                                            pd.closer_appointment_start) at time zone 'UTC') at time zone
                                  'US/Mountain') :: DATE
                               between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date))
                      ),
                           funnel_data as (
                             select f.id,
                                    f.name,
                                    count(1) filter (where
                                          ((case
                                              when f.id = 27 then pd.project_created_date
                                              else pd.appointment_date end at time zone 'UTC') at time zone
                                           'US/Mountain')::DATE =
                                          (now() at time zone 'US/Mountain') :: DATE
                                        and case
                                              when array_length(f.closer_appt_outcome_int_values, 1) > 0 and
                                                   f.exclude_values is false
                                                then pd.prioritized_closer_appointment_outcome = any
                                                     (f.closer_appt_outcome_int_values)
                                              else true end
                                        and case
                                              when f.id = 28 then (
                                                  pd.prioritized_closer_appointment_outcome is null or
                                                  pd.prioritized_closer_appointment_outcome != 4)
                                              else true end
                                      )                    as today_day_count,
                                    count(1) filter (where
                                          ((case
                                              when f.id = 27 then pd.project_created_date
                                              else pd.appointment_date end at time zone 'UTC') at time zone
                                           'US/Mountain')::DATE =
                                          (now() at time zone 'US/Mountain') :: DATE - 1
                                        and case
                                              when array_length(f.closer_appt_outcome_int_values, 1) > 0 and
                                                   f.exclude_values is false
                                                then pd.prioritized_closer_appointment_outcome = any
                                                     (f.closer_appt_outcome_int_values)
                                              else true end
                                        and case
                                              when f.id = 28 then (
                                                  pd.prioritized_closer_appointment_outcome is null or
                                                  pd.prioritized_closer_appointment_outcome != 4)
                                              else true end
                                      )                    as yesterday_day_count,
                                    count(1)
                                    filter (where ((case
                                                      when f.id = 27 then pd.project_created_date
                                                      else pd.appointment_date end at time zone 'UTC') at time zone
                                                   'US/Mountain')::DATE
                                                    between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date
                                      and case
                                            when array_length(f.closer_appt_outcome_int_values, 1) > 0 and
                                                 f.exclude_values is false
                                              then pd.prioritized_closer_appointment_outcome = any
                                                   (f.closer_appt_outcome_int_values)
                                            else true end
                                      and case
                                            when f.id = 28 then (pd.prioritized_closer_appointment_outcome is null or
                                                                 pd.prioritized_closer_appointment_outcome != 4)
                                            else true end
                                      )                    as seven_day_count,
                                    count(1)
                                    filter (where ((case
                                                      when f.id = 27 then pd.project_created_date
                                                      else pd.appointment_date end at time zone 'UTC') at time zone
                                                   'US/Mountain')::DATE
                                                    between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7
                                      and case
                                            when array_length(f.closer_appt_outcome_int_values, 1) > 0 and
                                                 f.exclude_values is false
                                              then pd.prioritized_closer_appointment_outcome = any
                                                   (f.closer_appt_outcome_int_values)
                                            else true end
                                      and case
                                            when f.id = 28 then (pd.prioritized_closer_appointment_outcome is null or
                                                                 pd.prioritized_closer_appointment_outcome != 4)
                                            else true end
                                      )                    as prev_seven_day_count,
                                    count(1)
                                    filter (where ((case
                                                      when f.id = 27 then pd.project_created_date
                                                      else pd.appointment_date end at time zone 'UTC') at time zone
                                                   'US/Mountain')::DATE
                                                    between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date
                                      and case
                                            when array_length(f.closer_appt_outcome_int_values, 1) > 0 and
                                                 f.exclude_values is false
                                              then pd.prioritized_closer_appointment_outcome = any
                                                   (f.closer_appt_outcome_int_values)
                                            else true end
                                      and case
                                            when f.id = 28 then (pd.prioritized_closer_appointment_outcome is null or
                                                                 pd.prioritized_closer_appointment_outcome != 4)
                                            else true end
                                      )                    as thirty_day_count,
                                    count(1)
                                    filter (where ((case
                                                      when f.id = 27 then pd.project_created_date
                                                      else pd.appointment_date end at time zone 'UTC') at time zone
                                                   'US/Mountain')::DATE
                                                    between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date - 30
                                      and case
                                            when array_length(f.closer_appt_outcome_int_values, 1) > 0 and
                                                 f.exclude_values is false
                                              then pd.prioritized_closer_appointment_outcome = any
                                                   (f.closer_appt_outcome_int_values)
                                            else true end
                                      and case
                                            when f.id = 28 then (pd.prioritized_closer_appointment_outcome is null or
                                                                 pd.prioritized_closer_appointment_outcome != 4)
                                            else true end
                                      )                    as prev_thirty_day_count,
                                    count(1)
                                    filter (where ((case
                                                      when f.id = 27 then pd.project_created_date
                                                      else pd.appointment_date end at time zone 'UTC') at time zone
                                                   'US/Mountain')::DATE between p_custom_start_date and p_custom_end_date
                                      and case
                                            when array_length(f.closer_appt_outcome_int_values, 1) > 0 and
                                                 f.exclude_values is false
                                              then pd.prioritized_closer_appointment_outcome = any
                                                   (f.closer_appt_outcome_int_values)
                                            else true end
                                      and case
                                            when f.id = 28 then (pd.prioritized_closer_appointment_outcome is null or
                                                                 pd.prioritized_closer_appointment_outcome != 4)
                                            else true end) as custom_date_range_count
                             from brs.funnel f
                                    cross join project_data pd
                             where f.archived is false
                               and f.funnel_type_id = 4
                               and f.unique_behavior is false
                             group by f.id, f.name
                           ),
                           funnel_stats as (
                             select *,
                                    case
                                      when yesterday_day_count = 0 then 0
                                      else cast(cast(today_day_count - yesterday_day_count as numeric(10, 2)) /
                                                yesterday_day_count as numeric(10, 2)) * 100 end  as today_percent,
                                    case
                                      when prev_seven_day_count = 0 then 0
                                      else cast(cast(seven_day_count - prev_seven_day_count as numeric(10, 2)) /
                                                prev_seven_day_count as numeric(10, 2)) * 100 end as seven_percent,
                                    case
                                      when prev_thirty_day_count = 0 then 0
                                      else cast(cast(thirty_day_count - prev_thirty_day_count as numeric(10, 2)) /
                                                prev_thirty_day_count as numeric(10, 2)) *
                                           100 end                                                as thirty_day_percent
                             from funnel_data fd
                           )
                      select f.id,
                             f.name,
                             f.ratio,
                             case
                               when f.expectation is null then
                                   f.ratio * p_base_expectation
                               else f.expectation end              as expectation,
                             f.display_order,
                             f.funnel_type_id,
                             case
                               when f.id = 30 then
                                 case
                                   when (select today_day_count from funnel_stats fs2 where fs2.id = 28) = 0 then 0
                                   else cast(cast(
                                               (select today_day_count from funnel_stats fs2 where fs2.id = 29) as numeric(10, 2)) /
                                             cast(
                                               (select today_day_count from funnel_stats fs2 where fs2.id = 28) as numeric(10, 2)) as numeric(10, 2)) *
                                        100
                                   end
                               else fs.today_day_count end         as today_day_count,
                             fs.yesterday_day_count,
                             case
                               when f.id = 30 then
                                 case
                                   when (select seven_day_count from funnel_stats fs2 where fs2.id = 28) = 0 then 0
                                   else cast(cast(
                                               (select seven_day_count from funnel_stats fs2 where fs2.id = 29) as numeric(10, 2)) /
                                             cast(
                                               (select seven_day_count from funnel_stats fs2 where fs2.id = 28) as numeric(10, 2)) as numeric(10, 2)) *
                                        100
                                   end
                               else fs.seven_day_count end         as seven_day_count,
                             fs.prev_seven_day_count,
                             case
                               when f.id = 30 then
                                 case
                                   when (select thirty_day_count from funnel_stats fs2 where fs2.id = 28) = 0 then 0
                                   else cast(cast(
                                               (select thirty_day_count from funnel_stats fs2 where fs2.id = 29) as numeric(10, 2)) /
                                             cast(
                                               (select thirty_day_count from funnel_stats fs2 where fs2.id = 28) as numeric(10, 2)) as numeric(10, 2)) *
                                        100
                                   end
                               else fs.thirty_day_count end        as thirty_day_count,
                             fs.prev_thirty_day_count,
                             case
                               when f.id = 30 then
                                 case
                                   when (select custom_date_range_count from funnel_stats fs2 where fs2.id = 28) = 0
                                     then 0
                                   else cast(cast(
                                               (select custom_date_range_count from funnel_stats fs2 where fs2.id = 29) as numeric(10, 2)) /
                                             cast(
                                               (select custom_date_range_count from funnel_stats fs2 where fs2.id = 28) as numeric(10, 2)) as numeric(10, 2)) *
                                        100
                                   end
                               else fs.custom_date_range_count end as custom_date_range_count,
                             fs.today_percent,
                             fs.seven_percent,
                             fs.thirty_day_percent
                      from brs.funnel f
                             left join funnel_stats fs on fs.id = f.id
                      where f.archived is false
                        and f.funnel_type_id = 4
                        and case when p_is_cohort is false then f.unique_behavior is false else true end
                      order by f.display_order
                    ) as funnel_rows;

END
$function$
