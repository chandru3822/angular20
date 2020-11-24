CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_appt_date_cohort(p_custom_start_date date, p_custom_end_date date, p_user_ids integer[], p_org_ids integer[])
	RETURNS SETOF json
    LANGUAGE plpgsql
AS $function$
declare
	v_whole_company boolean;
BEGIN
	--If p_user_ids has a -1 that means get data for the whole company
	select p_user_ids <@ Array[-1] into v_whole_company;
	if v_whole_company then
        RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
                     from (
                              select id, name, display_order, checked_in_today_count, today_count, checked_in_week_to_date_count, week_to_date_count, checked_in_custom_date_range_count, custom_date_range_count
                              from (
                                       select id, name, display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE
                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE
                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 14 --Total Planned Appointments


                                       union all


                                       select id, name, display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.closer_appointment_outcome = 4 --Cancelled
                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.closer_appointment_outcome = 4 --Cancelled
                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.closer_appointment_outcome = 4 --Cancelled
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 15 --Cancelled in advance


                                       union all


                                       select id, name, display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.closer_appointment_outcome in (59,61) --(No Go, Low TSRF)
                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.closer_appointment_outcome in (59,61) --(No Go, Low TSRF)
                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.closer_appointment_outcome in (59,61) --(No Go, Low TSRF)
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 16 --Ineligible for solar


                                       union all


                                       select id, name, display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) --(Cancelled, No Go, Low TSRF)
                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) --(Cancelled, No Go, Low TSRF)
                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) --(Cancelled, No Go, Low TSRF)
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 17 --Total Eligible Planned Appointments


                                       union all


                                       select id, name, display_order,

                                              null::bigint as checked_in_today_count,

                                              (select count(1)
                                               from flow.project_process_step pps
                                                   inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
                                                   inner join flow.project p on p.id = pps.project_id
                                                   inner join brs.project_details pd on pd.project_id = pps.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   pps.process_step_id = 1 and --Closer Appointment Details
                                                   pps.main is false and
                                                   ppscfv.custom_field_group_assignment_id = 5 and
                                                   ppscfv.timestamp_value < pd.closer_appointment_start and
                                                   (ppscfv.timestamp_value - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE
                                              ) as today_count,

                                              null::bigint as checked_in_week_to_date_count,

                                              (select count(1)
                                               from flow.project_process_step pps
                                                   inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
                                                   inner join flow.project p on p.id = pps.project_id
                                                   inner join brs.project_details pd on pd.project_id = pps.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   pps.process_step_id = 1 and --Closer Appointment Details
                                                   pps.main is false and
                                                   ppscfv.custom_field_group_assignment_id = 5 and
                                                   ppscfv.timestamp_value < pd.closer_appointment_start and
                                                   (ppscfv.timestamp_value - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (ppscfv.timestamp_value - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE
                                              ) as week_to_date_count,

                                              null::bigint as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from flow.project_process_step pps
                                                   inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
                                                   inner join flow.project p on p.id = pps.project_id
                                                   inner join brs.project_details pd on pd.project_id = pps.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   pps.process_step_id = 1 and --Closer Appointment Details
                                                   pps.main is false and
                                                   ppscfv.custom_field_group_assignment_id = 5 and
                                                   ppscfv.timestamp_value < pd.closer_appointment_start and
                                                   (ppscfv.timestamp_value - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 25 --Rescheduled


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 56 and --Not Pitched: No Show
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 56 --Not Pitched: No Show
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 56 and --Not Pitched: No Show
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 56 --Not Pitched: No Show
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 56 and --Not Pitched: No Show
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 56 --Not Pitched: No Show
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 18 --Homeowner no show


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 3 and --Missed
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 3 --Missed
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 3 and --Missed
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 3 --Missed
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 3 and --Missed
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 3 --Missed
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 19 --Closer missed appointment


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 58 and --Not Pitched: Other
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 58 --Not Pitched: Other
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 58 and --Not Pitched: Other
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 58 --Not Pitched: Other
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 58 and --Not Pitched: Other
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 58 --Not Pitched: Other
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 20 --Turned away at the door


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 57 and --Not Pitched: No Utility Bill
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 57 --Not Pitched: No Utility Bill
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 57 and --Not Pitched: No Utility Bill
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 57 --Not Pitched: No Utility Bill
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 57 and --Not Pitched: No Utility Bill
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 57 --Not Pitched: No Utility Bill
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 22 --No utility bill


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain')
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain')
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain')
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 24 --Non-dispositioned appointments


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                                   (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                                   (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain')
                                              ) as today_count,


                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                                   (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                                   (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain')
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                                   (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                                   (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain')
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 23 --Yet to occur


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 2 and --Pitched
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 2 --Pitched
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 2 and --Pitched
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 2 --Pitched
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 2 and --Pitched
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                                   pd.closer_appointment_outcome = 2 --Pitched
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 11 --Pitched


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.credit_decision_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.credit_decision_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.credit_decision_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.credit_decision_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.credit_decision_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.credit_decision_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 9 --Credits run


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.credit_decision_date is not null and
                                                   pd.credit_check = 82 and --Pass
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.credit_decision_date is not null and
                                                   pd.credit_check = 82 and --Pass
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.credit_decision_date is not null and
                                                   pd.credit_check = 82 and --Pass
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.credit_decision_date is not null and
                                                   pd.credit_check = 82 and --Pass
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.credit_decision_date is not null and
                                                   pd.credit_check = 82 and --Pass
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.credit_decision_date is not null and
                                                   pd.credit_check = 82 and --Pass
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 3 --Credits passed


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.installation_agreement_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.installation_agreement_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.installation_agreement_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.installation_agreement_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.installation_agreement_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.installation_agreement_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 4 --Bookings Complete


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.site_survey_verified_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.site_survey_verified_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.site_survey_verified_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.site_survey_verified_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.site_survey_verified_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.site_survey_verified_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 5 --Site Surveys Verified


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.final_design_sent_to_homeowner_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.final_design_sent_to_homeowner_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.final_design_sent_to_homeowner_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.final_design_sent_to_homeowner_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.final_design_sent_to_homeowner_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.final_design_sent_to_homeowner_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 6 --Final Designs sent to Homeowner


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.final_design_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.final_design_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.final_design_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.final_design_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.final_design_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.final_design_signed_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 7 --Final Designs Approved


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   pd.final_design_signed_date is not null and
                                                   pd.financial_agreement_signed_date is not null and
                                                   ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                                     pd.proof_of_homeowners_insurance_obtained_date is not null)
                                                       or
                                                    (pd.proof_of_homeowners_insurance_required is null or
                                                     pd.proof_of_homeowners_insurance_required = 306)) and --No
                                                   pd.utility_bill_verified_date is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   case when pd.primary_financier = 721 --Cash
                                                       then pd.first_cash_payment_paid_date is not null else 1=1 end and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   pd.final_design_signed_date is not null and
                                                   pd.financial_agreement_signed_date is not null and
                                                   ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                                     pd.proof_of_homeowners_insurance_obtained_date is not null)
                                                       or
                                                    (pd.proof_of_homeowners_insurance_required is null or
                                                     pd.proof_of_homeowners_insurance_required = 306)) and --No
                                                   pd.utility_bill_verified_date is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   case when pd.primary_financier = 721 --Cash
                                                       then pd.first_cash_payment_paid_date is not null else 1=1 end
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   pd.final_design_signed_date is not null and
                                                   pd.financial_agreement_signed_date is not null and
                                                   ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                                     pd.proof_of_homeowners_insurance_obtained_date is not null)
                                                       or
                                                    (pd.proof_of_homeowners_insurance_required is null or
                                                     pd.proof_of_homeowners_insurance_required = 306)) and --No
                                                   pd.utility_bill_verified_date is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   case when pd.primary_financier = 721 --Cash
                                                       then pd.first_cash_payment_paid_date is not null else 1=1 end and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   pd.final_design_signed_date is not null and
                                                   pd.financial_agreement_signed_date is not null and
                                                   ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                                     pd.proof_of_homeowners_insurance_obtained_date is not null)
                                                       or
                                                    (pd.proof_of_homeowners_insurance_required is null or
                                                     pd.proof_of_homeowners_insurance_required = 306)) and --No
                                                   pd.utility_bill_verified_date is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   case when pd.primary_financier = 721 --Cash
                                                       then pd.first_cash_payment_paid_date is not null else 1=1 end
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   pd.final_design_signed_date is not null and
                                                   pd.financial_agreement_signed_date is not null and
                                                   ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                                     pd.proof_of_homeowners_insurance_obtained_date is not null)
                                                       or
                                                    (pd.proof_of_homeowners_insurance_required is null or
                                                     pd.proof_of_homeowners_insurance_required = 306)) and --No
                                                   pd.utility_bill_verified_date is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   case when pd.primary_financier = 721 --Cash
                                                       then pd.first_cash_payment_paid_date is not null else 1=1 end and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.closer_user_id is not null and
                                                   pd.final_design_signed_date is not null and
                                                   pd.financial_agreement_signed_date is not null and
                                                   ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                                     pd.proof_of_homeowners_insurance_obtained_date is not null)
                                                       or
                                                    (pd.proof_of_homeowners_insurance_required is null or
                                                     pd.proof_of_homeowners_insurance_required = 306)) and --No
                                                   pd.utility_bill_verified_date is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   case when pd.primary_financier = 721 --Cash
                                                       then pd.first_cash_payment_paid_date is not null else 1=1 end
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 21 --Final Designs Completed


                                       union all


                                       select id, name, display_order,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.substantial_completion_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                                   pd.substantial_completion_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as today_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.substantial_completion_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                                   pd.substantial_completion_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as week_to_date_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.substantial_completion_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                                                   pd.appointment_check_in is not null
                                              ) as checked_in_custom_date_range_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                               where pd.closer_user_id = any(p_user_ids) and
                                                   pd.closer_user_id is not null and
                                                   (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                                   pd.substantial_completion_date is not null and
                                                   pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                                              ) as custom_date_range_count

                                       from brs.funnel
                                       where id = 8 --Installations Completed

                                   ) as row_counts order by display_order
                          ) as funnel_rows;

    else
		RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
		    from (
                select id, name, display_order, checked_in_today_count, today_count, checked_in_week_to_date_count, week_to_date_count, checked_in_custom_date_range_count, custom_date_range_count
                from (
                    select id, name, display_order,

                           null::bigint as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE
                           ) as today_count,

                           null::bigint as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE
                           ) as week_to_date_count,

                           null::bigint as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 14 --Total Planned Appointments


                    union all


                    select id, name, display_order,

                           null::bigint as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where pd.closer_appointment_outcome = 4 and --(Cancelled)
                                (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE
                           ) as today_count,

                           null::bigint as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where pd.closer_appointment_outcome = 4 and --(Cancelled)
                                (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE
                           ) as week_to_date_count,

                           null::bigint as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where pd.closer_appointment_outcome = 4 and --(Cancelled)
                                (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 15 --Cancelled in advance


                    union all


                    select id, name, display_order,

                           null::bigint as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where pd.closer_appointment_outcome in (59,61) and --(No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE
                           ) as today_count,

                           null::bigint as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where pd.closer_appointment_outcome in (59,61) and --(No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE
                           ) as week_to_date_count,

                           null::bigint as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where pd.closer_appointment_outcome in (59,61) and --(No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 16 --Ineligible for solar


                    union all


                    select id, name, display_order,

                           null::bigint as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE
                           ) as today_count,

                           null::bigint as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE
                           ) as week_to_date_count,

                           null::bigint as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 17 --Total Eligible Planned Appointments


                    union all


                    select id, name, display_order,

                           null::bigint as checked_in_today_count,

                           (select count(1)
                            from flow.project_process_step pps
                                inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
                                inner join brs.project_details pd on pd.project_id = pps.project_id
                            where pps.process_step_id = 1 and --Closer Appointment Details
                                pps.main is false and
                                ppscfv.custom_field_group_assignment_id = 5 and
                                ppscfv.timestamp_value < pd.closer_appointment_start and
                                (ppscfv.timestamp_value - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE
                           ) as today_count,

                           null::bigint as checked_in_week_to_date_count,

                           (select count(1)
                            from flow.project_process_step pps
                                inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
                                inner join brs.project_details pd on pd.project_id = pps.project_id
                            where pps.process_step_id = 1 and --Closer Appointment Details
                                pps.main is false and
                                ppscfv.custom_field_group_assignment_id = 5 and
                                ppscfv.timestamp_value < pd.closer_appointment_start and
                                (ppscfv.timestamp_value - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (ppscfv.timestamp_value - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE
                           ) as week_to_date_count,

                           null::bigint as checked_in_custom_date_range_count,

                           (select count(1)
                            from flow.project_process_step pps
                                inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
                                inner join brs.project_details pd on pd.project_id = pps.project_id
                            where pps.process_step_id = 1 and --Closer Appointment Details
                                pps.main is false and
                                ppscfv.custom_field_group_assignment_id = 5 and
                                ppscfv.timestamp_value < pd.closer_appointment_start and
                                (ppscfv.timestamp_value - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 25 --Rescheduled


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 56 and --Not Pitched: No Show
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 56 --Not Pitched: No Show
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 56 and --Not Pitched: No Show
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 56 --Not Pitched: No Show
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 56 and --Not Pitched: No Show
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 56 --Not Pitched: No Show
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 18 --Homeowner no show


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 3 and --Missed
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 3 --Missed
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 3 and --Missed
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 3 --Missed
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 3 and --Missed
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 3 --Missed
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 19 --Closer missed appointment


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 58 and --Not Pitched: Other
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 58 --Not Pitched: Other
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 58 and --Not Pitched: Other
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 58 --Not Pitched: Other
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 58 and --Not Pitched: Other
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 58 --Not Pitched: Other
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 20 --Turned away at the door


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 57 and --Not Pitched: No Utility Bill
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 57 --Not Pitched: No Utility Bill
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 57 and --Not Pitched: No Utility Bill
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 57 --Not Pitched: No Utility Bill
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 57 and --Not Pitched: No Utility Bill
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 57 --Not Pitched: No Utility Bill
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 22 --No utility bill


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain')
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain')
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain')
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 24 --Non-dispositioned appointments


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain') and
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain')
                           ) as today_count,


                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain') and
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain')
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain') and
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                                (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain')
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 23 --Yet to occur


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 2 and --Pitched
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() AT TIME ZONE 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 2 --Pitched
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 2 and --Pitched
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 2 --Pitched
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 2 and --Pitched
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                                pd.closer_appointment_outcome = 2 --Pitched
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 11 --Pitched


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.credit_decision_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.credit_decision_date is not null
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.credit_decision_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.credit_decision_date is not null
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.credit_decision_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.credit_decision_date is not null
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 9 --Credits run


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.credit_decision_date is not null and
                                pd.credit_check = 82 and --Pass
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.credit_decision_date is not null and
                                pd.credit_check = 82 --Pass
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.credit_decision_date is not null and
                                pd.credit_check = 82 and --Pass
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.credit_decision_date is not null and
                                pd.credit_check = 82 --Pass
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.credit_decision_date is not null and
                                pd.credit_check = 82 and --Pass
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.credit_decision_date is not null and
                                pd.credit_check = 82 --Pass
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 3 --Credits passed


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.installation_agreement_signed_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.installation_agreement_signed_date is not null
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.installation_agreement_signed_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.installation_agreement_signed_date is not null
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.installation_agreement_signed_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.installation_agreement_signed_date is not null
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 4 --Bookings Complete


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.site_survey_verified_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.site_survey_verified_date is not null
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.site_survey_verified_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.site_survey_verified_date is not null
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.site_survey_verified_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.site_survey_verified_date is not null
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 5 --Site Surveys Verified


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.final_design_sent_to_homeowner_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.final_design_sent_to_homeowner_date is not null
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.final_design_sent_to_homeowner_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.final_design_sent_to_homeowner_date is not null
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.final_design_sent_to_homeowner_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.final_design_sent_to_homeowner_date is not null
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 6 --Final Designs sent to Homeowner


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.final_design_signed_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.final_design_signed_date is not null
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.final_design_signed_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.final_design_signed_date is not null
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.final_design_signed_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.final_design_signed_date is not null
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 7 --Final Designs Approved


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where pd.final_design_signed_date is not null and
                                pd.financial_agreement_signed_date is not null and
                                ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                  pd.proof_of_homeowners_insurance_obtained_date is not null)
                                    or
                                 (pd.proof_of_homeowners_insurance_required is null or
                                  pd.proof_of_homeowners_insurance_required = 306)) and --No
                                pd.utility_bill_verified_date is not null and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                case when pd.primary_financier = 721 --Cash
                                    then pd.first_cash_payment_paid_date is not null else 1=1 end and
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where pd.final_design_signed_date is not null and
                                pd.financial_agreement_signed_date is not null and
                                ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                  pd.proof_of_homeowners_insurance_obtained_date is not null)
                                    or
                                 (pd.proof_of_homeowners_insurance_required is null or
                                  pd.proof_of_homeowners_insurance_required = 306)) and --No
                                pd.utility_bill_verified_date is not null and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                case when pd.primary_financier = 721 --Cash
                                    then pd.first_cash_payment_paid_date is not null else 1=1 end
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where pd.final_design_signed_date is not null and
                                pd.financial_agreement_signed_date is not null and
                                ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                  pd.proof_of_homeowners_insurance_obtained_date is not null)
                                    or
                                  (pd.proof_of_homeowners_insurance_required is null or
                                   pd.proof_of_homeowners_insurance_required = 306)) and --No
                                pd.utility_bill_verified_date is not null and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                case when pd.primary_financier = 721 --Cash
                                    then pd.first_cash_payment_paid_date is not null else 1=1 end and
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where pd.final_design_signed_date is not null and
                                pd.financial_agreement_signed_date is not null and
                                ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                  pd.proof_of_homeowners_insurance_obtained_date is not null)
                                    or
                                  (pd.proof_of_homeowners_insurance_required is null or
                                   pd.proof_of_homeowners_insurance_required = 306)) and --No
                                pd.utility_bill_verified_date is not null and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                case when pd.primary_financier = 721 --Cash
                                    then pd.first_cash_payment_paid_date is not null else 1=1 end
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where pd.final_design_signed_date is not null and
                                pd.financial_agreement_signed_date is not null and
                                ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                  pd.proof_of_homeowners_insurance_obtained_date is not null)
                                    or
                                  (pd.proof_of_homeowners_insurance_required is null or
                                   pd.proof_of_homeowners_insurance_required = 306)) and --No
                                pd.utility_bill_verified_date is not null and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                case when pd.primary_financier = 721 --Cash
                                    then pd.first_cash_payment_paid_date is not null else 1=1 end and
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where pd.final_design_signed_date is not null and
                                pd.financial_agreement_signed_date is not null and
                                ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                                  pd.proof_of_homeowners_insurance_obtained_date is not null)
                                    or
                                  (pd.proof_of_homeowners_insurance_required is null or
                                   pd.proof_of_homeowners_insurance_required = 306)) and --No
                                pd.utility_bill_verified_date is not null and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                case when pd.primary_financier = 721 --Cash
                                    then pd.first_cash_payment_paid_date is not null else 1=1 end
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 21 --Final Designs Completed


                    union all


                    select id, name, display_order,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.substantial_completion_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE = (now() at time zone 'US/Mountain') :: DATE and
                                pd.substantial_completion_date is not null
                           ) as today_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.substantial_completion_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE >= ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and
                                (pd.closer_appointment_start - interval '6 hours') :: DATE <= (now() at time zone 'US/Mountain') :: DATE and
                                pd.substantial_completion_date is not null
                           ) as week_to_date_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.substantial_completion_date is not null and
                                pd.appointment_check_in is not null
                           ) as checked_in_custom_date_range_count,

                           (select count(1)
                            from brs.project_details pd
                            where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_custom_start_date and p_custom_end_date and
                                pd.substantial_completion_date is not null
                           ) as custom_date_range_count

                    from brs.funnel
                    where id = 8 --Installations Completed

                ) as row_counts order by display_order
            ) as funnel_rows;

    end if;

END
$function$
