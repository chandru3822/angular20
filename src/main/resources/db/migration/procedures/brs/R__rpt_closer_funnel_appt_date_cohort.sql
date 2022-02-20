CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_appt_date_cohort(p_custom_start_date date, p_custom_end_date date,
                                                                  p_user_ids integer[], p_org_ids integer[])
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
    --If p_user_ids has a -1 that means get data for the whole company
    select -1 = any (p_user_ids) into v_whole_company;
    if v_whole_company then
        RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
                     from (
                              select id,
                                     name,
                                     display_order,
                                     checked_in_today_count,
                                     today_count,
                                     checked_in_week_to_date_count,
                                     week_to_date_count,
                                     checked_in_custom_date_range_count,
                                     custom_date_range_count
                              from (
                                       with project_data as(
                                           select ppscfv1.int_value,ppse.start_time,ppscfv2.timestamp_value as checked_in_time
                                           from flow.project_process_step pps
                                                    left join flow.project_process_step_event ppse on pps.id = ppse.project_process_step_id
                                                    left join flow.project_process_step_event_custom_field_value ppscfv1 on ppse.id = ppscfv1.project_process_step_event_id and ppscfv1.custom_field_group_assignment_id = 4
                                                    left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                                                    inner join brs.project_details pd on pd.project_id = pps.project_id
                                           where pps.process_step_id = 1
                                             and pd.company_id = v_company_id
                                             and (((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain')::date between p_custom_start_date and p_custom_end_date)
                                              OR ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                             between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date)
                                       select id,
                                              name,
                                              display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                         between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 14 --Total Planned Appointments


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value = 4 --(Cancelled)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 4 --(Cancelled)
                                                 and ((start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 4 --(Cancelled)
                                                 and ((start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 15 --Cancelled in advance


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value in (59, 61, 16685) --(No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value in (59, 61, 16685) --(No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value in (59, 61, 16685) --(No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 16 --Ineligible for solar


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value is null or ppscfv.int_value not in (4, 59, 61, 16685))
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  (ppscfv.int_value is null or ppscfv.int_value not in (4, 59, 61, 16685))
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value is null or ppscfv.int_value not in (4, 59, 61, 16685))
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 17 --Total Eligible Planned Appointments


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 15327
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 15327
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 15327
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 25 --Rescheduled


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value = 56 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 56 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 56 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value = 56 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 56 --Not Pitched: No Show
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value = 56 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 18 --Homeowner no show


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 3 --Missed
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value = 3 --Missed
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 3 --Missed
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 3 --Missed
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 3 --Not Pitched: No Show
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 3 --Missed
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 19 --Closer missed appointment


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 58 -- Not Pitched: Other
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 58 -- Not Pitched: Other
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 58 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 58 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value = 58 --Not Pitched: No Show
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 58 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 20 --Turned away at the door


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 22 --No utility bill


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  <
                                                                                (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  <
                                                                                (now() at time zone 'US/Mountain')))
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')   <
                                                                                (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  <
                                                                                (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  <
                                                                                (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                 ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')   <
                                                                                 (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 24 --Non-dispositioned appointments


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value is null or
                                                      ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  >
                                                     (now() at time zone 'US/Mountain')
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  (ppscfv.int_value is null or
                                                       ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  >
                                                     (now() at time zone 'US/Mountain')

                                              ) as today_count,


                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value is null or
                                                      ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  >
                                                     (now() at time zone 'US/Mountain')
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value is null or
                                                      ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  >
                                                     (now() at time zone 'US/Mountain')

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value is null or
                                                      ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,2, 1139, 1140,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  >
                                                     (now() at time zone 'US/Mountain')
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where (ppscfv.int_value is null or
                                                      ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  >
                                                     (now() at time zone 'US/Mountain')

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 23 --Yet to occur


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value in (2, 1139, 1140)  --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value in (2, 1139, 1140)  --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where ppscfv.int_value in (2, 1139, 1140)  --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value in (2, 1139, 1140)  --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value in (2, 1139, 1140) --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.int_value in (2, 1139, 1140) --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 11 --Pitched


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.credit_decision_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.credit_decision_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 9 --Credits run


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82
                                                 and --Pass
                                                   pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82 --Pass
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82
                                                 and --Pass
                                                   pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82 --Pass
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82
                                                 and --Pass
                                                   pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82 --Pass
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 3 --Credits passed


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.installation_agreement_signed_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.installation_agreement_signed_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.installation_agreement_signed_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.installation_agreement_signed_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.installation_agreement_signed_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.installation_agreement_signed_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 4 --Bookings Complete


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.site_survey_verified_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.site_survey_verified_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.site_survey_verified_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.site_survey_verified_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.site_survey_verified_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.site_survey_verified_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 5 --Site Surveys Verified


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 6 --Final Designs sent to Homeowner


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_signed_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_signed_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_signed_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_signed_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.final_design_signed_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.final_design_signed_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 7 --Final Designs Approved


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                               where pd.final_design_complete_date is not null
                                                 and pd.company_id = v_company_id
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where pd.final_design_complete_date is not null
                                                 and pd.company_id = v_company_id
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where pd.final_design_complete_date is not null
                                                 and pd.company_id = v_company_id
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where pd.final_design_complete_date is not null
                                                 and pd.company_id = v_company_id
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where pd.final_design_complete_date is not null
                                                 and pd.company_id = v_company_id
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where pd.final_design_complete_date is not null
                                                 and pd.company_id = v_company_id
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 21 --Final Designs Completed


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.substantial_completion_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.substantial_completion_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.substantial_completion_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.substantial_completion_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.substantial_completion_date is not null
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.substantial_completion_date is not null
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 8 --Installations Completed

                                   ) as row_counts
                              order by display_order
                          ) as funnel_rows;

    else
        RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
                     from (
                              with project_data as(
                                  select ppscfv1.int_value,ppse.start_time,ppscfv2.timestamp_value as checked_in_time,o.id as org_id,up.user_id
                                  from flow.project_process_step pps
                                           inner join flow.project p on p.id = pps.project_id
                                           inner join flow.user_position up on up.id = p.user_position_id
                                           inner join flow.org o on o.id = up.org_id
                                           inner join flow.project_process_step_event ppse on pps.id = ppse.project_process_step_id
                                           left join flow.project_process_step_event_custom_field_value ppscfv1 on ppse.id = ppscfv1.project_process_step_event_id and ppscfv1.custom_field_group_assignment_id = 4
                                           left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                                           inner join brs.project_details pd on pd.project_id = pps.project_id
                                  where pps.process_step_id = 1
                                    and pd.company_id = v_company_id
                                    and (((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain')::date between p_custom_start_date and p_custom_end_date)
                                     OR ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                    between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date)
                              select id,
                                     name,
                                     display_order,
                                     checked_in_today_count,
                                     today_count,
                                     checked_in_week_to_date_count,
                                     week_to_date_count,
                                     checked_in_custom_date_range_count,
                                     custom_date_range_count
                              from (
                                       select id,
                                              name,
                                              display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                              )          as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from  project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                              )              as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE between p_custom_start_date and p_custom_end_date
                                              )            as custom_date_range_count

                                       from brs.funnel
                                       where id = 14 --Total Planned Appointments


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 4 --(Cancelled)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 4 --(Cancelled)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 4 --(Cancelled)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 15 --Cancelled in advance


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value in (59, 61, 16685) --(No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value in (59, 61, 16685) --(No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value in (59, 61, 16685) --(No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 16 --Ineligible for solar


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value is null or ppscfv.int_value not in (4, 59, 61, 16685))
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value is null or ppscfv.int_value not in (4, 59, 61, 16685))
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value is null or ppscfv.int_value not in (4, 59, 61, 16685))
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 17 --Total Eligible Planned Appointments


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 15327
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 15327
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 15327
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 25 --Rescheduled


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 56 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 56 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 56 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 56 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 56  --Not Pitched: No Show
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 56 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 18 --Homeowner no show


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 3 --Missed
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 3 --Missed
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 3 --Missed
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 3 --Missed
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 3 --Missed
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 3 --Missed
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 19 --Closer missed appointment


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 58 --Not Pitched: Other
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 58 --Not Pitched: Other
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 58 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 58 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 58 --Not Pitched: No Show
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 58 --Not Pitched: No Show
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 20 --Turned away at the door


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value = 57 --Not Pitched: No Utility Bill
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 22 --No utility bill


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                                                   ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  <
                                                                                                                   (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                                                   ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  <
                                                                                                                   (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                                                   ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  <
                                                                                                                   (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                                                   ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  <
                                                                                                                   (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                                                   ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  <
                                                                                                                   (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value = 60 or (ppscfv.int_value is null and
                                                                                                                   ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  <
                                                                                                                   (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 24 --Non-dispositioned appointments


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value is null or
                                                                                         ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  >
                                                     (now() at time zone 'US/Mountain')
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value is null or
                                                                                         ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  >
                                                     (now() at time zone 'US/Mountain')

                                              ) as today_count,


                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value is null or
                                                                                         ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  >
                                                     (now() at time zone 'US/Mountain')
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value is null or
                                                                                         ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  >
                                                     (now() at time zone 'US/Mountain')

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and (ppscfv.int_value is null or
                                                                                         ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  > (now() at time zone 'US/Mountain')

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end and (ppscfv.int_value is null or
                                                                                        ppscfv.int_value not in (4,59,61,56,3,58,57,60,2,1139,1140,16685,15327)) --(Cancelled, No Go, Low TSRF)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain')  > (now() at time zone 'US/Mountain')

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 23 --Yet to occur


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value in (2, 1139, 1140)  --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value in (2, 1139, 1140)  --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date  =
                                                     (now() at time zone 'US/Mountain') :: DATE

                                              ) as today_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value in (2, 1139, 1140)  --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date
                                                 and ppscfv.checked_in_time is not null

                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value in (2, 1139, 1140)  --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE
                                                   between date_trunc('week', now() at time zone 'US/Mountain')::date and (now() at time zone 'US/Mountain') ::date

                                              ) as week_to_date_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value in (2, 1139, 1140)  --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ppscfv.checked_in_time is not null
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from project_data ppscfv
                                               where  ppscfv.user_id = any (p_user_ids)
                                                 and case when array_length(p_org_ids, 1) > 0 then ppscfv.org_id = any(p_org_ids) else 1 = 1 end  and ppscfv.int_value in (2, 1139, 1140)  --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                 and ((ppscfv.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date

                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 11 --Pitched


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)

                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.credit_decision_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.credit_decision_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 9 --Credits run


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)

                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.credit_decision_date is not null
                                                 and pd.credit_check = 82
                                                  and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 3 --Credits passed


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.installation_agreement_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.installation_agreement_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.installation_agreement_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.installation_agreement_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.installation_agreement_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.installation_agreement_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 4 --Bookings Complete


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.site_survey_verified_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.site_survey_verified_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.site_survey_verified_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.site_survey_verified_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.site_survey_verified_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.site_survey_verified_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 5 --Site Surveys Verified


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.final_design_sent_to_homeowner_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 6 --Final Designs sent to Homeowner


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.final_design_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.final_design_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.final_design_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.final_design_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.final_design_signed_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 7 --Final Designs Approved


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and pd.company_id = v_company_id
                                                 and o.id = any(p_org_ids)
                                                 and pd.final_design_complete_date is not null

                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and pd.company_id = v_company_id
                                                 and o.id = any(p_org_ids)

                                                 and pd.final_design_complete_date is not null

                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and pd.company_id = v_company_id
                                                 and o.id = any(p_org_ids)

                                                 and pd.final_design_complete_date is not null

                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and pd.company_id = v_company_id
                                                 and o.id = any(p_org_ids)

                                                 and pd.final_design_complete_date is not null

                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and pd.company_id = v_company_id
                                                 and o.id = any(p_org_ids)

                                                 and pd.final_design_complete_date is not null

                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and pd.company_id = v_company_id
                                                 and o.id = any(p_org_ids)

                                                 and pd.final_design_complete_date is not null

                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 21 --Final Designs Completed


                                       union all


                                       select id,
                                              name,
                                              display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.substantial_completion_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() AT TIME ZONE 'US/Mountain') :: DATE
                                                 and pd.substantial_completion_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.substantial_completion_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain') :: DATE
                                                 and pd.substantial_completion_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.substantial_completion_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.appointment_check_in is not null
                                                 and pd.company_id = v_company_id
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up on up.id = p.user_position_id
                                                        inner join flow.org o on o.id = up.org_id
                                               where up.user_id = any (p_user_ids)
                                                 and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.substantial_completion_date is not null
                                                 and o.id = any(p_org_ids)
                                                 and pd.company_id = v_company_id
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 8 --Installations Completed

                                   ) as row_counts
                              order by display_order
                          ) as funnel_rows;

    end if;

END
$function$
