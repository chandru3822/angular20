drop function if exists brs.rpt_closer_funnel_standard_event_based(date, date, bigint[], bigint[]);
CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_standard_event_based(p_custom_start_date date, p_custom_end_date date,
                                                                      p_user_position_ids bigint[],
                                                                      p_org_ids bigint[])
  RETURNS table
          (
            id                                 bigint,
            name                               character varying(100),
            display_order                      bigint,
            funnel_type_id                     bigint,
            today_count                        bigint,
            checked_in_today_count             bigint,
            week_to_date_count                 bigint,
            checked_in_week_to_date_count      bigint,
            custom_date_range_count            bigint,
            checked_in_custom_date_range_count bigint
          )
  LANGUAGE plpgsql
AS
$function$
declare
  v_whole_company boolean;
BEGIN
  --If p_user_position_ids has a -1 that means get data for the whole company
  select -1 = any (p_user_position_ids) into v_whole_company;

  RETURN QUERY
    with project_data as (
      select ppscfv1.int_value                                     as closer_appt_outcome_int_value,
             ppse.start_time,
             coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time
      from flow.project_process_step pps
             inner join brs.project_details pd on pd.project_id = pps.project_id
             inner join flow.user_position up on up.id = pd.closer_user_position_id
             inner join flow.org o on o.id = up.org_id
             inner join flow.project_process_step_event ppse on ppse.project_process_step_id = pps.id
             left join flow.project_process_step_event_action ppsea
                       on ppsea.project_process_step_event_id = ppse.id and
                          ppsea.process_step_event_action_id =
                          408 --408 = check in action on event stage/prod
             left join flow.project_process_step_event_custom_field_value ppscfv1
                       on ppse.id = ppscfv1.project_process_step_event_id and
                          ppscfv1.custom_field_group_assignment_id = 4 --outcome field
             left join flow.project_process_step_event_custom_field_value ppscfv2
                       on ppse.id = ppscfv2.project_process_step_event_id and
                          ppscfv2.custom_field_group_assignment_id = 1377 --checked in time (for old data)
      where pps.process_step_id = 1
        and pd.company_id = 3
        and (
          (((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain')::date between p_custom_start_date and p_custom_end_date)
          OR ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
            between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date)
        and case
              when v_whole_company is false then
                (up.id = any (p_user_position_ids)
                  and case
                        when array_length(p_org_ids, 1) > 0 then up.org_id = any (p_org_ids)
                        else 1 = 1 end)
              else true end),
         funnel_stats as (
           select f.id,
                  f.name,
                  f.display_order,
                  f.funnel_type_id,

                  count(1) filter (where
                      ((pd.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE =
                      (now() at time zone 'US/Mountain') :: DATE)                                                                                                                                   as today_count,
                  case
                    when f.show_checked_in_column then count(1) filter (where
                        pd.checked_in_time is not null and
                        ((pd.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE =
                        (now() at time zone 'US/Mountain') :: DATE) end                                                                                                                             as checked_in_today_count,
                  count(1)
                  filter (where ((pd.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                    between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date)                                                               as week_to_date_count,
                  case
                    when f.show_checked_in_column then count(1)
                                                       filter (where pd.checked_in_time is not null and
                                                                     ((pd.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                                       between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date) end        as checked_in_week_to_date_count,
                  count(1)
                  filter (where ((pd.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE between p_custom_start_date and p_custom_end_date)                                          as custom_date_range_count,
                  case
                    when f.show_checked_in_column then count(1)
                                                       filter (where pd.checked_in_time is not null and
                                                                     ((pd.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE between p_custom_start_date and p_custom_end_date) end as checked_in_custom_date_range_count

           from brs.funnel f
                  cross join project_data pd
           where f.archived is false
             and f.funnel_type_id = 1
             and case
             -- 24 = Non-dispositioned appointments
                   when f.id = 24 then (pd.closer_appt_outcome_int_value = any
                                        (f.closer_appt_outcome_int_values) or
                                        (pd.closer_appt_outcome_int_value is null and
                                         ((pd.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                         (now() at time zone 'US/Mountain')))
                   when array_length(f.closer_appt_outcome_int_values, 1) > 0 and
                        f.exclude_values is false then
                       pd.closer_appt_outcome_int_value = any
                       (f.closer_appt_outcome_int_values)
                   when array_length(f.closer_appt_outcome_int_values, 1) > 0 and
                        f.exclude_values is true then
                     (pd.closer_appt_outcome_int_value is null or
                      pd.closer_appt_outcome_int_value not in
                      (select unnest(f.closer_appt_outcome_int_values)))
                   else true end
             and case
                   when f.hide_future is true then
                       ((pd.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                       (now() AT TIME ZONE 'US/Mountain')
                   else true end
             and case
                   when f.only_future is true then
                       ((pd.start_time at time zone 'UTC') at time zone 'US/Mountain') >
                       (now() AT TIME ZONE 'US/Mountain')
                   else true end
           group by f.id, f.name, f.display_order, f.funnel_type_id
         )
    select coalesce(fs.id, f.id)                                           as id,
           coalesce(fs.name, f.name)                                       as name,
           coalesce(fs.display_order, f.display_order)                     as display_order,
           coalesce(fs.funnel_type_id, f.funnel_type_id)                   as funnel_type_id,
           coalesce(fs.today_count, 0)                                     as today_count,
           case
             when f.show_checked_in_column is true
               then coalesce(fs.checked_in_today_count, 0) end             as checked_in_today_count,
           coalesce(fs.week_to_date_count, 0)                              as week_to_date_count,
           case
             when f.show_checked_in_column
               then coalesce(fs.checked_in_week_to_date_count, 0) end      as checked_in_week_to_date_count,
           coalesce(fs.custom_date_range_count, 0)                         as custom_date_range_count,
           case
             when f.show_checked_in_column
               then coalesce(fs.checked_in_custom_date_range_count, 0) end as checked_in_custom_date_range_count
    from funnel_stats fs
           right outer join brs.funnel f on f.id = fs.id
    where f.archived is false
      and f.funnel_type_id = 1;


END
$function$
