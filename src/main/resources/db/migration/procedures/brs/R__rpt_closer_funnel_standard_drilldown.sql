CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_standard_drilldown(p_start_date date, p_end_date date, p_funnel_id integer, p_user_ids integer[], p_org_ids integer[], p_is_checked_in_column boolean)
    RETURNS SETOF json
    LANGUAGE plpgsql
AS $function$
declare
    v_whole_company boolean;
BEGIN
    --If p_user_ids has a -1 that means get the funnel for the whole company
    select p_user_ids <@ Array[-1] into v_whole_company;
    if v_whole_company then

        --Total Planned Appointments
        case when p_funnel_id = 14 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Cancelled in advance
        when p_funnel_id = 15 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        pd.closer_appointment_outcome = 4 --Cancelled
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Ineligible for solar
        when p_funnel_id = 16 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        pd.closer_appointment_outcome in (59,61) --(No Go, Low TSRF)
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Total Eligible Planned Appointments
        when p_funnel_id = 17 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) --(Cancelled, No Go, Low TSRF)
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Rescheduled
        when p_funnel_id = 25 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (ppscfv.timestamp_value - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from flow.project_process_step pps
                        inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
                        inner join brs.project_details pd on pd.project_id = pps.project_id
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pps.process_step_id = 1 and --Closer Appointment Details
                        pps.main is false and
                        ppscfv.custom_field_group_assignment_id = 5 and
                        ppscfv.timestamp_value < pd.closer_appointment_start and
                        (ppscfv.timestamp_value - interval '6 hours') :: DATE between p_start_date and p_end_date
                    order by owner_name, (ppscfv.timestamp_value - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Homeowner no show
        when p_funnel_id = 18 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 56 --Not Pitched: No Show
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Homeowner no show (checked-in)
        when p_funnel_id = 18 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 56 and --Not Pitched: No Show
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Closer missed appointment
        when p_funnel_id = 19 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 3 --Missed
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Closer missed appointment (checked-in)
        when p_funnel_id = 19 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 3 and --Missed
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Turned away at the door
        when p_funnel_id = 20 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 58 --Not Pitched: Other
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Turned away at the door (checked-in)
        when p_funnel_id = 20 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 58 and --Not Pitched: Other
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --No utility bill
        when p_funnel_id = 22 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 57 --Not Pitched: No Utility Bill
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --No utility bill (checked-in)
        when p_funnel_id = 22 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 57 and --Not Pitched: No Utility Bill
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Non-dispositioned appointments
        when p_funnel_id = 24 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain')
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Non-dispositioned appointments (checked-in)
        when p_funnel_id = 24 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Yet to occur
        when p_funnel_id = 23 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                        (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain')
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Yet to occur (checked-in)
        when p_funnel_id = 23 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                        (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain') and
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Pitched
        when p_funnel_id = 11 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 2 --Pitched
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Pitched (checked-in)
        when p_funnel_id = 11 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 2 and --Pitched
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Credits run
        when p_funnel_id = 9 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome,
                           pd.credit_decision_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.credit_decision_date :: DATE between p_start_date and p_end_date and
                        pd.credit_decision_date is not null
                    order by owner_name, pd.credit_decision_date
                ) as funnel_rows;

        --Credits run (checked-in)
        when p_funnel_id = 9 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome,
                           pd.credit_decision_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.credit_decision_date :: DATE between p_start_date and p_end_date and
                        pd.credit_decision_date is not null and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.credit_decision_date
                ) as funnel_rows;

        --Credits passed
        when p_funnel_id = 3 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome,
                           pd.credit_decision_date,
                           pd.credit_check_name credit_check
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.credit_decision_date :: DATE between p_start_date and p_end_date and
                        pd.credit_decision_date is not null and
                        pd.credit_check = 82 --Pass
                    order by owner_name, pd.credit_decision_date
                ) as funnel_rows;

        --Credits passed (checked-in)
        when p_funnel_id = 3 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome,
                           pd.credit_decision_date,
                           pd.credit_check_name credit_check
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.credit_decision_date :: DATE between p_start_date and p_end_date and
                        pd.credit_decision_date is not null and
                        pd.credit_check = 82 and --Pass
                        pd.appointment_check_in is not null
                    order by owner_name, pd.credit_decision_date
                ) as funnel_rows;

        --Bookings Complete
        when p_funnel_id = 4 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.installation_agreement_signed_date,
                           pd.site_survey_end_time site_survey_completed_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.installation_agreement_signed_date :: DATE between p_start_date and p_end_date and
                        pd.installation_agreement_signed_date is not null
                    order by owner_name, pd.installation_agreement_signed_date
                ) as funnel_rows;

        --Bookings Complete (checked-in)
        when p_funnel_id = 4 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.installation_agreement_signed_date,
                           pd.site_survey_end_time site_survey_completed_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.installation_agreement_signed_date :: DATE between p_start_date and p_end_date and
                        pd.installation_agreement_signed_date is not null and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.installation_agreement_signed_date
                ) as funnel_rows;

        --Site Surveys Verified
        when p_funnel_id = 5 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.site_survey_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.site_survey_verified_date :: DATE between p_start_date and p_end_date and
                        pd.site_survey_verified_date is not null
                    order by owner_name, pd.site_survey_verified_date :: DATE
                ) as funnel_rows;

        --Site Surveys Verified (checked-in)
        when p_funnel_id = 5 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.site_survey_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.site_survey_verified_date :: DATE between p_start_date and p_end_date and
                        pd.site_survey_verified_date is not null and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.site_survey_verified_date :: DATE
                ) as funnel_rows;

        --Final Designs sent to Homeowner
        when p_funnel_id = 6 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_sent_to_homeowner_date,
                           pd.final_design_signed_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.final_design_sent_to_homeowner_date :: DATE between p_start_date and p_end_date and
                        pd.final_design_sent_to_homeowner_date is not null
                    order by owner_name, pd.final_design_sent_to_homeowner_date
                ) as funnel_rows;

        --Final Designs sent to Homeowner (checked-in)
        when p_funnel_id = 6 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_sent_to_homeowner_date,
                           pd.final_design_signed_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.final_design_sent_to_homeowner_date :: DATE between p_start_date and p_end_date and
                        pd.final_design_sent_to_homeowner_date is not null and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.final_design_sent_to_homeowner_date
                ) as funnel_rows;

        --Final Designs Approved
        when p_funnel_id = 7 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_signed_date,
                           pd.financial_agreement_signed_date,
                           pd.proof_of_homeowners_insurance_obtained_date,
                           pd.first_cash_payment_paid_date cash_down_payment,
                           pd.utility_bill_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.final_design_signed_date :: DATE between p_start_date and p_end_date and
                        pd.final_design_signed_date is not null
                    order by owner_name, pd.final_design_signed_date
                ) as funnel_rows;

        --Final Designs Approved (checked-in)
        when p_funnel_id = 7 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_signed_date,
                           pd.financial_agreement_signed_date,
                           pd.proof_of_homeowners_insurance_obtained_date,
                           pd.first_cash_payment_paid_date cash_down_payment,
                           pd.utility_bill_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.final_design_signed_date :: DATE between p_start_date and p_end_date and
                        pd.final_design_signed_date is not null and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.final_design_signed_date
                ) as funnel_rows;

        --Final Designs Completed
        when p_funnel_id = 21 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_signed_date,
                           pd.financial_agreement_signed_date,
                           pd.proof_of_homeowners_insurance_obtained_date,
                           pd.first_cash_payment_paid_date cash_down_payment,
                           pd.utility_bill_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.final_design_signed_date is not null and
                          pd.financial_agreement_signed_date is not null and
                          ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                            pd.proof_of_homeowners_insurance_obtained_date is not null)
                              or
                            (pd.proof_of_homeowners_insurance_required is null or
                             pd.proof_of_homeowners_insurance_required = 306)) and --No
                          pd.utility_bill_verified_date is not null and
                          case when pd.primary_financier = 721 --Cash
                              then pd.first_cash_payment_paid_date is not null and
                                  greatest(
                                      pd.first_cash_payment_paid_date :: DATE,
                                      pd.final_design_signed_date :: DATE,
                                      pd.financial_agreement_signed_date :: DATE,
                                      pd.proof_of_homeowners_insurance_obtained_date :: DATE,
                                      pd.utility_bill_verified_date :: DATE
                                  ) between p_start_date and p_end_date
                                  else greatest(
                                      pd.final_design_signed_date :: DATE,
                                      pd.financial_agreement_signed_date :: DATE,
                                      pd.proof_of_homeowners_insurance_obtained_date :: DATE,
                                      pd.utility_bill_verified_date :: DATE
                                  ) between p_start_date and p_end_date
                                  end
                    order by owner_name, pd.final_design_signed_date
                ) as funnel_rows;

        --Final Designs Completed (checked-in)
        when p_funnel_id = 21 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_signed_date,
                           pd.financial_agreement_signed_date,
                           pd.proof_of_homeowners_insurance_obtained_date,
                           pd.first_cash_payment_paid_date cash_down_payment,
                           pd.utility_bill_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.final_design_signed_date is not null and
                        pd.financial_agreement_signed_date is not null and
                        ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                          pd.proof_of_homeowners_insurance_obtained_date is not null)
                            or
                         (pd.proof_of_homeowners_insurance_required is null or
                          pd.proof_of_homeowners_insurance_required = 306)) and --No
                        pd.utility_bill_verified_date is not null and
                        case when pd.primary_financier = 721 --Cash
                            then pd.first_cash_payment_paid_date is not null and
                                greatest(
                                    pd.first_cash_payment_paid_date :: DATE,
                                    pd.final_design_signed_date :: DATE,
                                    pd.financial_agreement_signed_date :: DATE,
                                    pd.proof_of_homeowners_insurance_obtained_date :: DATE,
                                    pd.utility_bill_verified_date :: DATE
                                ) between p_start_date and p_end_date
                                else greatest(
                                    pd.final_design_signed_date :: DATE,
                                    pd.financial_agreement_signed_date :: DATE,
                                    pd.proof_of_homeowners_insurance_obtained_date :: DATE,
                                    pd.utility_bill_verified_date :: DATE
                                ) between p_start_date and p_end_date
                                end and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.final_design_signed_date
                ) as funnel_rows;

        --Installations Completed
        when p_funnel_id = 8 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.substantial_completion_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.substantial_completion_date :: DATE between p_start_date and p_end_date and
                        pd.substantial_completion_date is not null
                    order by owner_name, pd.substantial_completion_date
                ) as funnel_rows;

        end case;

    else

        --Total Planned Appointments
        case when p_funnel_id = 14 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Cancelled in advance
        when p_funnel_id = 15 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        pd.closer_appointment_outcome = 4 --Cancelled
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Ineligible for solar
        when p_funnel_id = 16 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        pd.closer_appointment_outcome in (59,61) --(No Go, Low TSRF)
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Total Eligible Planned Appointments
        when p_funnel_id = 17 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) --(Cancelled, No Go, Low TSRF)
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Rescheduled
        when p_funnel_id = 25 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from flow.project_process_step pps
                        inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
                        inner join brs.project_details pd on pd.project_id = pps.project_id
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pps.process_step_id = 1 and --Closer Appointment Details
                        pps.main is false and
                        ppscfv.custom_field_group_assignment_id = 5 and
                        ppscfv.timestamp_value < pd.closer_appointment_start and
                        (ppscfv.timestamp_value - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Homeowner no show
        when p_funnel_id = 18 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 56 --Not Pitched: No Show
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Homeowner no show (checked-in)
        when p_funnel_id = 18 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 56 and --Not Pitched: No Show
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Closer missed appointment
        when p_funnel_id = 19 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 3 --Missed
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Closer missed appointment (checked-in)
        when p_funnel_id = 19 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 3 and --Missed
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Turned away at the door
        when p_funnel_id = 20 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 58 --Not Pitched: Other
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Turned away at the door (checked-in)
        when p_funnel_id = 20 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 58 and --Not Pitched: Other
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --No utility bill
        when p_funnel_id = 22 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 57 --Not Pitched: No Utility Bill
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --No utility bill (checked-in)
        when p_funnel_id = 22 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 57 and --Not Pitched: No Utility Bill
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Non-dispositioned appointments
        when p_funnel_id = 24 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain')
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Non-dispositioned appointments (checked-in)
        when p_funnel_id = 24 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome = 60) and --Non-Dispositioned
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Yet to occur
        when p_funnel_id = 23 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                        (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain')
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Yet to occur (checked-in)
        when p_funnel_id = 23 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome not in (4,59,61)) and --(Cancelled, No Go, Low TSRF)
                        (pd.closer_appointment_start - interval '6 hours') >= (now() AT TIME ZONE 'US/Mountain') and
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Pitched
        when p_funnel_id = 11 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 2 --Pitched
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Pitched (checked-in)
        when p_funnel_id = 11 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        (pd.closer_appointment_start - interval '6 hours') :: DATE between p_start_date and p_end_date and
                        (pd.closer_appointment_start - interval '6 hours') < (now() AT TIME ZONE 'US/Mountain') and
                        pd.closer_appointment_outcome = 2 and --Pitched
                        pd.appointment_check_in is not null
                    order by owner_name, (pd.closer_appointment_start - interval '6 hours') :: DATE
                ) as funnel_rows;

        --Credits run
        when p_funnel_id = 9 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome,
                           pd.credit_decision_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.credit_decision_date :: DATE between p_start_date and p_end_date and
                        pd.credit_decision_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                    order by owner_name, pd.credit_decision_date
                ) as funnel_rows;

        --Credits run (checked-in)
        when p_funnel_id = 9 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome,
                           pd.credit_decision_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.credit_decision_date :: DATE between p_start_date and p_end_date and
                        pd.credit_decision_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.credit_decision_date
                ) as funnel_rows;

        --Credits passed
        when p_funnel_id = 3 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome,
                           pd.credit_decision_date,
                           pd.credit_check_name credit_check
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.credit_decision_date :: DATE between p_start_date and p_end_date and
                        pd.credit_decision_date is not null and
                        pd.credit_check = 82 and --Pass
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                    order by owner_name, pd.credit_decision_date
                ) as funnel_rows;

        --Credits passed (checked-in)
        when p_funnel_id = 3 and p_is_checked_in_column is true then
            RETURN QUERY

                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.closer_appointment_outcome_name appointment_outcome,
                           pd.credit_decision_date,
                           pd.credit_check_name credit_check
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.credit_decision_date :: DATE between p_start_date and p_end_date and
                        pd.credit_decision_date is not null and
                        pd.credit_check = 82 and --Pass
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.credit_decision_date
                ) as funnel_rows;

        --Bookings Complete
        when p_funnel_id = 4 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.installation_agreement_signed_date,
                           pd.site_survey_end_time site_survey_completed_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.installation_agreement_signed_date :: DATE between p_start_date and p_end_date and
                        pd.installation_agreement_signed_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                    order by owner_name, pd.installation_agreement_signed_date
                ) as funnel_rows;

        --Bookings Complete (checked-in)
        when p_funnel_id = 4 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.installation_agreement_signed_date,
                           pd.site_survey_end_time site_survey_completed_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.installation_agreement_signed_date :: DATE between p_start_date and p_end_date and
                        pd.installation_agreement_signed_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.installation_agreement_signed_date
                ) as funnel_rows;

        --Site Surveys Verified
        when p_funnel_id = 5 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.site_survey_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.site_survey_verified_date :: DATE between p_start_date and p_end_date and
                        pd.site_survey_verified_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                    order by owner_name, pd.site_survey_verified_date :: DATE
                ) as funnel_rows;

        --Site Surveys Verified (checked-in)
        when p_funnel_id = 5 and p_is_checked_in_column is true then
            RETURN QUERY

                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.site_survey_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.site_survey_verified_date :: DATE between p_start_date and p_end_date and
                        pd.site_survey_verified_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.site_survey_verified_date :: DATE
                ) as funnel_rows;

        --Final Designs sent to Homeowner
        when p_funnel_id = 6 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_sent_to_homeowner_date,
                           pd.final_design_signed_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.final_design_sent_to_homeowner_date :: DATE between p_start_date and p_end_date and
                        pd.final_design_sent_to_homeowner_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                    order by owner_name, pd.final_design_sent_to_homeowner_date
                ) as funnel_rows;

        --Final Designs sent to Homeowner (checked-in)
        when p_funnel_id = 6 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_sent_to_homeowner_date,
                           pd.final_design_signed_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.final_design_sent_to_homeowner_date :: DATE between p_start_date and p_end_date and
                        pd.final_design_sent_to_homeowner_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.final_design_sent_to_homeowner_date
                ) as funnel_rows;

        --Final Designs Approved
        when p_funnel_id = 7 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_signed_date,
                           pd.financial_agreement_signed_date,
                           pd.proof_of_homeowners_insurance_obtained_date,
                           pd.first_cash_payment_paid_date cash_down_payment,
                           pd.utility_bill_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.final_design_signed_date :: DATE between p_start_date and p_end_date and
                        pd.final_design_signed_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                    order by owner_name, pd.final_design_signed_date
                ) as funnel_rows;

        --Final Designs Approved (checked-in)
        when p_funnel_id = 7 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_signed_date,
                           pd.financial_agreement_signed_date,
                           pd.proof_of_homeowners_insurance_obtained_date,
                           pd.first_cash_payment_paid_date cash_down_payment,
                           pd.utility_bill_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.final_design_signed_date :: DATE between p_start_date and p_end_date and
                        pd.final_design_signed_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.final_design_signed_date
                ) as funnel_rows;

        --Final Designs Completed
        when p_funnel_id = 21 and p_is_checked_in_column is false then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_signed_date,
                           pd.financial_agreement_signed_date,
                           pd.proof_of_homeowners_insurance_obtained_date,
                           pd.first_cash_payment_paid_date cash_down_payment,
                           pd.utility_bill_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.final_design_signed_date is not null and
                        pd.financial_agreement_signed_date is not null and
                        ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                          pd.proof_of_homeowners_insurance_obtained_date is not null)
                            or
                          (pd.proof_of_homeowners_insurance_required is null or
                           pd.proof_of_homeowners_insurance_required = 306)) and --No
                        pd.utility_bill_verified_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        case when pd.primary_financier = 721 --Cash
                            then pd.first_cash_payment_paid_date is not null and
                                greatest(
                                    pd.first_cash_payment_paid_date :: DATE,
                                    pd.final_design_signed_date :: DATE,
                                    pd.financial_agreement_signed_date :: DATE,
                                    pd.proof_of_homeowners_insurance_obtained_date :: DATE,
                                    pd.utility_bill_verified_date :: DATE
                                ) between p_start_date and p_end_date
                                else greatest(
                                    pd.final_design_signed_date :: DATE,
                                    pd.financial_agreement_signed_date :: DATE,
                                    pd.proof_of_homeowners_insurance_obtained_date :: DATE,
                                    pd.utility_bill_verified_date :: DATE
                                ) between p_start_date and p_end_date
                                end
                    order by owner_name, pd.final_design_signed_date
                ) as funnel_rows;

        --Final Designs Completed (checked-in)
        when p_funnel_id = 21 and p_is_checked_in_column is true then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.final_design_signed_date,
                           pd.financial_agreement_signed_date,
                           pd.proof_of_homeowners_insurance_obtained_date,
                           pd.first_cash_payment_paid_date cash_down_payment,
                           pd.utility_bill_verified_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.final_design_signed_date is not null and
                        pd.financial_agreement_signed_date is not null and
                        ((pd.proof_of_homeowners_insurance_required = 305 and --Yes
                          pd.proof_of_homeowners_insurance_obtained_date is not null)
                            or
                          (pd.proof_of_homeowners_insurance_required is null or
                           pd.proof_of_homeowners_insurance_required = 306)) and --No
                        pd.utility_bill_verified_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE)) and
                        case when pd.primary_financier = 721 --Cash
                            then pd.first_cash_payment_paid_date is not null and
                                greatest(
                                    pd.first_cash_payment_paid_date :: DATE,
                                    pd.final_design_signed_date :: DATE,
                                    pd.financial_agreement_signed_date :: DATE,
                                    pd.proof_of_homeowners_insurance_obtained_date :: DATE,
                                    pd.utility_bill_verified_date :: DATE
                                ) between p_start_date and p_end_date
                                else greatest(
                                    pd.final_design_signed_date :: DATE,
                                    pd.financial_agreement_signed_date :: DATE,
                                    pd.proof_of_homeowners_insurance_obtained_date :: DATE,
                                    pd.utility_bill_verified_date :: DATE
                                ) between p_start_date and p_end_date
                                end and
                        pd.appointment_check_in is not null
                    order by owner_name, pd.final_design_signed_date
                ) as funnel_rows;

        --Installations Completed
        when p_funnel_id = 8 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                    select concat(u.first_name, ' ', u.last_name) owner_name,
                           employee_id.employee_id,
                           s.abbreviation state,
                           concat(c.first_name, ' ', c.last_name) customer_name,
                           c.id contact_id,
                           pd.project_id,
                           pd.source_name,
                           pd.system_size,
                           pd.primary_financier_name financier,
                           (pd.closer_appointment_start - interval '6 hours') :: DATE appointment_date,
                           pd.cancelled_date,
                           pd.substantial_completion_date
                    from brs.project_details pd
                        inner join flow.project p on p.id = pd.project_id
                        inner join flow.contact c on c.id = p.contact_id
                        left outer join flow.user u on pd.closer_user_id = u.id
                        left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                        left outer join flow.company_state cs on cs.id = p.company_state_id
                        left outer join flow.state s on s.id = cs.state_id
                    where pd.closer_user_id = any(p_user_ids) and
                        pd.closer_user_id is not null and
                        pd.substantial_completion_date :: DATE between p_start_date and p_end_date and
                        pd.substantial_completion_date is not null and
                        pd.closer_user_id = any(brs.limit_by_org_for_closers(Array[pd.closer_user_id], p_org_ids, p.date_created :: DATE))
                    order by owner_name, pd.substantial_completion_date
                ) as funnel_rows;

            end case;
    end if;

END
$function$
