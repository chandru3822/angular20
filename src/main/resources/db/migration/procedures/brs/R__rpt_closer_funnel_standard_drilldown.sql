CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_standard_drilldown(p_start_date date, p_end_date date,
                                                                    p_funnel_id integer, p_user_ids integer[],
                                                                    p_org_ids integer[], p_is_checked_in_column boolean)
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
    --If p_user_ids has a -1 that means get the funnel for the whole company
    select -1 = any (p_user_ids) into v_whole_company;
    if v_whole_company then

        --Total Planned Appointments
        case when p_funnel_id = 14 then
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(funnel_rows)))
                from (
                         select concat(u.first_name, ' ', u.last_name) owner_name,
                                o.org_name                             office,
                                s.abbreviation                         state,
                                cpst.project_status_type as            status_type,
                                concat(c.first_name, ' ', c.last_name) customer_name,
                                c.id                                   contact_id,
                                pd.project_id,
                                pd.source_name,
                                pd.system_size,
                                pd.primary_financier_name              financier,
                                ppse.start_time                 appointment_date,
                                pd.cancelled_date
                         from brs.project_details pd
                                  inner join flow.project p on p.id = pd.project_id
                                  inner join flow.company_project_status_type cpst
                                             on cpst.id = p.company_project_status_type_id
                                  inner join flow.contact c on c.id = p.contact_id
                                  left outer join flow.user u on pd.closer_user_id = u.id
                                  inner join flow.user_position up on up.id = p.user_position_id
                                  inner join flow.org o on o.id = up.org_id
                                  left outer join flow.company_state cs on cs.id = p.company_state_id
                                  left outer join flow.state s on s.id = cs.state_id
                                  inner join flow.project_process_step pps
                                             on pps.project_id = pd.project_id and pps.process_step_id = 1
                                  inner join flow.project_process_step_event ppse
                                             on ppse.project_process_step_id = pps.id
                         where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                           and pd.company_id = v_company_id
                         order by owner_name, ppse.start_time
                     ) as funnel_rows;

            --Cancelled in advance
            when p_funnel_id = 15 then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      inner join flow.project_process_step_event ppse
                                                 on ppse.project_process_step_id = pps.id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 4 --Cancelled
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Ineligible for solar
            when p_funnel_id = 16 then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      inner join flow.project_process_step_event ppse
                                                 on ppse.project_process_step_id = pps.id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and ppscfv1.int_value in (59, 61, 16685) --(No Go, Low TSRF)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Total Eligible Planned Appointments
            when p_funnel_id = 17 then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      inner join flow.project_process_step_event ppse
                                                 on ppse.project_process_step_id = pps.id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and (ppscfv1.int_value is null or ppscfv1.int_value not in (4, 59, 61, 16685))
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Rescheduled
            when p_funnel_id = 25 then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from flow.project_process_step pps
                                      inner join flow.project_process_step_event ppse
                                                 on ppse.project_process_step_id = pps.id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                                      inner join brs.project_details pd on pd.project_id = pps.project_id
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where pps.process_step_id = 1
                               and ppscfv1.int_value = 15327 --Closer Appointment Details
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE between p_start_date and p_end_date
                               and pd.company_id = v_company_id
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Homeowner no show
            when p_funnel_id = 18 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      inner join flow.project_process_step_event_custom_field_value ppscfv
                                                 on pps.id = ppscfv.project_process_step_event_id and
                                                    ppscfv.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv.int_value
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                   (now() AT TIME ZONE 'US/Mountain')
                               and pps.process_step_id = 1
                               and ppscfv.int_value = 56 --Not Pitched: No Show
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Homeowner no show (checked-in)
            when p_funnel_id = 18 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 56 --Not Pitched: No Show
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Closer missed appointment
            when p_funnel_id = 19 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.process_step_event_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                   (now() AT TIME ZONE 'US/Mountain')
                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 3 --Missed
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Closer missed appointment (checked-in)
            when p_funnel_id = 19 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date

                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 3 --Missed
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Turned away at the door
            when p_funnel_id = 20 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                   (now() AT TIME ZONE 'US/Mountain')
                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 58 --Not Pitched: Other
                               and pd.company_id = v_company_id
                             order by owner_name,ppse.start_time
                         ) as funnel_rows;

            --Turned away at the door (checked-in)
            when p_funnel_id = 20 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date

                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 58 --Not Pitched: Other
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --No utility bill
            when p_funnel_id = 22 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                   (now() AT TIME ZONE 'US/Mountain')
                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 57 --Not Pitched: No Utility Bill
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --No utility bill (checked-in)
            when p_funnel_id = 22 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 57 --Not Pitched: No Utility Bill
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Non-dispositioned appointments
            when p_funnel_id = 24 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and (ppscfv1.int_value = 60 or (ppscfv1.int_value is null and
                                                               ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                                               (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Non-dispositioned appointments (checked-in)
            when p_funnel_id = 24 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and (ppscfv1.int_value = 60 or (ppscfv1.int_value is null and
                                                               ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                                               (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Yet to occur
            when p_funnel_id = 23 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and (ppscfv1.int_value is null or
                                    ppscfv1.int_value not in
                                    (4, 59, 61, 56, 3, 58, 57, 60, 2, 1139, 1140, 16685, 15327))
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') >
                                   (now() at time zone 'US/Mountain')
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Yet to occur (checked-in)
            when p_funnel_id = 23 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and (ppscfv1.int_value is null or
                                    ppscfv1.int_value not in
                                    (4, 59, 61, 56, 3, 58, 57, 60, 2, 1139, 1140, 16685, 15327))
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') >
                                   (now() at time zone 'US/Mountain')
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Pitched
            when p_funnel_id = 11 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and ppscfv1.int_value in (2, 1139, 1140) --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                               and pd.company_id = v_company_id
                             order by owner_name, pd.closer_appointment_start
                         ) as funnel_rows;

            --Pitched (checked-in)
            when p_funnel_id = 11 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and ppscfv1.int_value in (2, 1139, 1140) --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, pd.closer_appointment_start
                         ) as funnel_rows;

            --Credits run
            when p_funnel_id = 9 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.closer_appointment_outcome_name     appointment_outcome,
                                    pd.credit_decision_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where pd.credit_decision_date :: DATE between p_start_date and p_end_date
                               and pd.credit_decision_date is not null
                               and pd.company_id = v_company_id
                             order by owner_name, pd.credit_decision_date
                         ) as funnel_rows;

            --Credits run (checked-in)
--             when p_funnel_id = 9 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.closer_appointment_outcome_name     appointment_outcome,
--                                     pd.credit_decision_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where pd.credit_decision_date :: DATE between p_start_date and p_end_date
--                                and pd.credit_decision_date is not null
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.credit_decision_date
--                          ) as funnel_rows;

            --Credits passed
            when p_funnel_id = 3 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.closer_appointment_outcome_name     appointment_outcome,
                                    pd.credit_decision_date,
                                    pd.credit_check_name                   credit_check
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where pd.credit_decision_date :: DATE between p_start_date and p_end_date
                               and pd.credit_decision_date is not null
                               and pd.credit_check = 82 --Pass
                               and pd.company_id = v_company_id
                             order by owner_name, pd.credit_decision_date
                         ) as funnel_rows;

            --Credits passed (checked-in)
--             when p_funnel_id = 3 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.closer_appointment_outcome_name     appointment_outcome,
--                                     pd.credit_decision_date,
--                                     pd.credit_check_name                   credit_check
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where pd.credit_decision_date :: DATE between p_start_date and p_end_date
--                                and pd.credit_decision_date is not null
--                                and pd.credit_check = 82
--                                and --Pass
--                                  pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.credit_decision_date
--                          ) as funnel_rows;

            --Bookings Complete
            when p_funnel_id = 4 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.installation_agreement_signed_date,
                                    pd.site_survey_end_time                site_survey_completed_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where pd.installation_agreement_signed_date :: DATE between p_start_date and p_end_date
                               and pd.installation_agreement_signed_date is not null
                               and pd.company_id = v_company_id
                             order by owner_name, pd.installation_agreement_signed_date
                         ) as funnel_rows;

            --Bookings Complete (checked-in)
--             when p_funnel_id = 4 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.installation_agreement_signed_date,
--                                     pd.site_survey_end_time                site_survey_completed_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where pd.installation_agreement_signed_date :: DATE between p_start_date and p_end_date
--                                and pd.installation_agreement_signed_date is not null
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.installation_agreement_signed_date
--                          ) as funnel_rows;

            --Site Surveys Verified
            when p_funnel_id = 5 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.site_survey_verified_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where pd.site_survey_verified_date :: DATE between p_start_date and p_end_date
                               and pd.site_survey_verified_date is not null
                               and pd.company_id = v_company_id
                             order by owner_name, pd.site_survey_verified_date
                         ) as funnel_rows;

            --Site Surveys Verified (checked-in)
--             when p_funnel_id = 5 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.site_survey_verified_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where pd.site_survey_verified_date :: DATE between p_start_date and p_end_date
--                                and pd.site_survey_verified_date is not null
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.site_survey_verified_date
--                          ) as funnel_rows;

            --Final Designs sent to Homeowner
            when p_funnel_id = 6 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.final_design_sent_to_homeowner_date,
                                    pd.final_design_signed_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where ((pd.final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                                    'US/Mountain') :: date between p_start_date and p_end_date
                               and pd.final_design_sent_to_homeowner_date is not null
                               and pd.company_id = v_company_id
                             order by owner_name, pd.final_design_sent_to_homeowner_date
                         ) as funnel_rows;

            --Final Designs sent to Homeowner (checked-in)
--             when p_funnel_id = 6 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.final_design_sent_to_homeowner_date,
--                                     pd.final_design_signed_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where ((pd.final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
--                                     'US/Mountain') :: date between p_start_date and p_end_date
--                                and pd.final_design_sent_to_homeowner_date is not null
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.final_design_sent_to_homeowner_date
--                          ) as funnel_rows;

            --Final Designs Approved
            when p_funnel_id = 7 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.final_design_signed_date,
                                    pd.financial_agreement_signed_date,
                                    pd.proof_of_homeowners_insurance_obtained_date,
                                    pd.first_cash_payment_paid_date        cash_down_payment,
                                    pd.utility_bill_verified_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where pd.final_design_signed_date :: DATE between p_start_date and p_end_date
                               and pd.final_design_signed_date is not null
                               and pd.company_id = v_company_id
                             order by owner_name, pd.final_design_signed_date
                         ) as funnel_rows;

            --Final Designs Approved (checked-in)
--             when p_funnel_id = 7 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.final_design_signed_date,
--                                     pd.financial_agreement_signed_date,
--                                     pd.proof_of_homeowners_insurance_obtained_date,
--                                     pd.first_cash_payment_paid_date        cash_down_payment,
--                                     pd.utility_bill_verified_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where pd.final_design_signed_date :: DATE between p_start_date and p_end_date
--                                and pd.final_design_signed_date is not null
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.final_design_signed_date
--                          ) as funnel_rows;

            --Final Designs Completed
            when p_funnel_id = 21 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.final_design_complete_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where pd.final_design_complete_date is not null
                               and pd.final_design_complete_date :: DATE between p_start_date and p_end_date
                               and pd.company_id = v_company_id
                             order by owner_name, pd.final_design_complete_date
                         ) as funnel_rows;

            --Final Designs Completed (checked-in)
--             when p_funnel_id = 21 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.final_design_complete_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where pd.final_design_complete_date is not null
--                                and pd.final_design_complete_date :: DATE between p_start_date and p_end_date
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.final_design_complete_date
--                          ) as funnel_rows;

            --Installations Completed
            when p_funnel_id = 8 then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.substantial_completion_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where pd.substantial_completion_date :: DATE between p_start_date and p_end_date
                               and pd.substantial_completion_date is not null
                               and pd.company_id = v_company_id
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
                                o.org_name                             office,
                                s.abbreviation                         state,
                                cpst.project_status_type as            status_type,
                                concat(c.first_name, ' ', c.last_name) customer_name,
                                c.id                                   contact_id,
                                pd.project_id,
                                pd.source_name,
                                pd.system_size,
                                pd.primary_financier_name              financier,
                                ppse2.start_time                 appointment_date,
                                pd.cancelled_date
                         from brs.project_details pd
                                  inner join flow.project p on p.id = pd.project_id
                                  inner join flow.company_project_status_type cpst
                                             on cpst.id = p.company_project_status_type_id
                                  inner join flow.user_position up on up.id = p.user_position_id
                                  inner join flow.org o on o.id = up.org_id
                                  inner join flow.contact c on c.id = p.contact_id
                                  left outer join flow.user u on pd.closer_user_id = u.id
                                  left outer join flow.company_state cs on cs.id = p.company_state_id
                                  left outer join flow.state s on s.id = cs.state_id
                                  inner join flow.project_process_step pps on pps.project_id = pd.project_id
                             and pps.process_step_id = 1
                                  inner join flow.project_process_step_event ppse2  on ppse2.project_process_step_id = pps.id
                         where pps.process_step_id = 1
                           and up.user_id = any (p_user_ids)
                           and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                           and ((ppse2.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                           and pd.company_id = v_company_id
                         order by owner_name, ppse2.start_time
                     ) as funnel_rows;

            --Cancelled in advance
            when p_funnel_id = 15 then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where up.user_id = any (p_user_ids)
                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 4 --Cancelled
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Ineligible for solar
            when p_funnel_id = 16 then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and ppscfv1.int_value in (59, 61, 16685) --(No Go, Low TSRF)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Total Eligible Planned Appointments
            when p_funnel_id = 17 then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id and
                                                   pps.process_step_id = 2
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and (ppscfv1.int_value is null or ppscfv1.int_value not in (4, 59, 61, 16685))
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Rescheduled
            when p_funnel_id = 25 then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where pps.process_step_id = 1
                               and ppscfv1.int_value = 15327 --Closer Appointment Details
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: DATE between p_start_date and p_end_date

                               and up.user_id = any (p_user_ids)
                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Homeowner no show
            when p_funnel_id = 18 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                   (now() AT TIME ZONE 'US/Mountain')
                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 56 --Not Pitched: No Show
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Homeowner no show (checked-in)
            when p_funnel_id = 18 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date

                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 56 --Not Pitched: No Show
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name,ppse.start_time
                         ) as funnel_rows;

            --Closer missed appointment
            when p_funnel_id = 19 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                   (now() AT TIME ZONE 'US/Mountain')
                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 3 --Missed
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Closer missed appointment (checked-in)
            when p_funnel_id = 19 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date

                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 3 --Missed
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Turned away at the door
            when p_funnel_id = 20 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                   (now() AT TIME ZONE 'US/Mountain')
                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 58 --Not Pitched: Other
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Turned away at the door (checked-in)
            when p_funnel_id = 20 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date

                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 58 --Not Pitched: Other
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --No utility bill
            when p_funnel_id = 22 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                   (now() AT TIME ZONE 'US/Mountain')
                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 57 --Not Pitched: No Utility Bill
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --No utility bill (checked-in)
            when p_funnel_id = 22 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date

                               and pps.process_step_id = 1
                               and ppscfv1.int_value = 57 --Not Pitched: No Utility Bill
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Non-dispositioned appointments
            when p_funnel_id = 24 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and (ppscfv1.int_value = 60 or (ppscfv1.int_value is null and
                                                               ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                                               (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Non-dispositioned appointments (checked-in)
            when p_funnel_id = 24 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and (ppscfv1.int_value = 60 or (ppscfv1.int_value is null and
                                                               ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') <
                                                               (now() at time zone 'US/Mountain'))) --Non-Dispositioned
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Yet to occur
            when p_funnel_id = 23 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and (ppscfv1.int_value is null or
                                    ppscfv1.int_value not in
                                    (4, 59, 61, 56, 3, 58, 57, 60, 2, 1139, 1140, 16685, 15327))
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') >
                                   (now() at time zone 'US/Mountain')
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Yet to occur (checked-in)
            when p_funnel_id = 23 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    ppse.start_time                 appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where up.user_id = any (p_user_ids)

                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and (ppscfv1.int_value is null or
                                    ppscfv1.int_value not in
                                    (4, 59, 61, 56, 3, 58, 57, 60, 2, 1139, 1140, 16685, 15327))
                               and ((ppscfv1.timestamp_value at time zone 'UTC') at time zone 'US/Mountain') >
                                   (now() at time zone 'US/Mountain')
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, ppse.start_time
                         ) as funnel_rows;

            --Pitched
            when p_funnel_id = 11 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                             where up.user_id = any (p_user_ids)
                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and ppscfv1.int_value in (2, 1139, 1140) --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                               and pd.company_id = v_company_id
                             order by owner_name, pd.closer_appointment_start
                         ) as funnel_rows;

            --Pitched (checked-in)
            when p_funnel_id = 11 and p_is_checked_in_column is true then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
                                    lov.name                               appointment_outcome
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                                      inner join flow.project_process_step pps on pps.project_id = pd.project_id
                                      left join flow.project_process_step_event ppse
                                                on pps.id = ppse.project_process_step_id
                                      left join flow.project_process_step_event_custom_field_value ppscfv1
                                                on ppse.id = ppscfv1.project_process_step_event_id and
                                                   ppscfv1.custom_field_group_assignment_id = 4
                                      left join flow.list_of_value lov on lov.id = ppscfv1.int_value
                                      left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and ppsea.process_step_event_action_id = 408 --408 = check in action on event
                                      left join flow.project_process_step_event_custom_field_value ppscfv2 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
                             where up.user_id = any (p_user_ids)
                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and ((ppse.start_time at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                               and pps.process_step_id = 1
                               and ppscfv1.int_value in (2, 1139, 1140) --(Pitched, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                               and (ppsea.date_created is not null OR ppscfv2.timestamp_value is not null)
                               and pd.company_id = v_company_id
                             order by owner_name, pd.closer_appointment_start
                         ) as funnel_rows;

            --Credits run
            when p_funnel_id = 9 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.closer_appointment_outcome_name     appointment_outcome,
                                    pd.credit_decision_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where up.user_id = any (p_user_ids)

                               and pd.credit_decision_date :: DATE between p_start_date and p_end_date
                               and pd.credit_decision_date is not null
                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and pd.company_id = v_company_id
                             order by owner_name, pd.credit_decision_date
                         ) as funnel_rows;

            --Credits run (checked-in)
--             when p_funnel_id = 9 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.closer_appointment_outcome_name     appointment_outcome,
--                                     pd.credit_decision_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where up.user_id = any (p_user_ids)
--
--                                and pd.credit_decision_date :: DATE between p_start_date and p_end_date
--                                and pd.credit_decision_date is not null
--                                and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.credit_decision_date
--                          ) as funnel_rows;

            --Credits passed
            when p_funnel_id = 3 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.closer_appointment_outcome_name     appointment_outcome,
                                    pd.credit_decision_date,
                                    pd.credit_check_name                   credit_check
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where up.user_id = any (p_user_ids)

                               and pd.credit_decision_date :: DATE between p_start_date and p_end_date
                               and pd.credit_decision_date is not null
                               and pd.credit_check = 82
                               and --Pass
                                 o.id = any (p_org_ids)
                               and pd.company_id = v_company_id
                             order by owner_name, pd.credit_decision_date
                         ) as funnel_rows;

            --Credits passed (checked-in)
--             when p_funnel_id = 3 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.closer_appointment_outcome_name     appointment_outcome,
--                                     pd.credit_decision_date,
--                                     pd.credit_check_name                   credit_check
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where up.user_id = any (p_user_ids)
--
--                                and pd.credit_decision_date :: DATE between p_start_date and p_end_date
--                                and pd.credit_decision_date is not null
--                                and pd.credit_check = 82
--                                and --Pass
--                                  o.id = any (p_org_ids)
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.credit_decision_date
--                          ) as funnel_rows;

            --Bookings Complete
            when p_funnel_id = 4 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.installation_agreement_signed_date,
                                    pd.site_survey_end_time                site_survey_completed_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where up.user_id = any (p_user_ids)

                               and pd.installation_agreement_signed_date :: DATE between p_start_date and p_end_date
                               and pd.installation_agreement_signed_date is not null
                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and pd.company_id = v_company_id
                             order by owner_name, pd.installation_agreement_signed_date
                         ) as funnel_rows;

            --Bookings Complete (checked-in)
--             when p_funnel_id = 4 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.installation_agreement_signed_date,
--                                     pd.site_survey_end_time                site_survey_completed_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where up.user_id = any (p_user_ids)
--
--                                and pd.installation_agreement_signed_date :: DATE between p_start_date and p_end_date
--                                and pd.installation_agreement_signed_date is not null
--                                and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.installation_agreement_signed_date
--                          ) as funnel_rows;

            --Site Surveys Verified
            when p_funnel_id = 5 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.site_survey_verified_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where up.user_id = any (p_user_ids)

                               and pd.site_survey_verified_date :: DATE between p_start_date and p_end_date
                               and pd.site_survey_verified_date is not null
                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and pd.company_id = v_company_id
                             order by owner_name, pd.site_survey_verified_date
                         ) as funnel_rows;

            --Site Surveys Verified (checked-in)
--             when p_funnel_id = 5 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.site_survey_verified_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where up.user_id = any (p_user_ids)
--
--                                and pd.site_survey_verified_date :: DATE between p_start_date and p_end_date
--                                and pd.site_survey_verified_date is not null
--                                and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.site_survey_verified_date
--                          ) as funnel_rows;

            --Final Designs sent to Homeowner
            when p_funnel_id = 6 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.final_design_sent_to_homeowner_date,
                                    pd.final_design_signed_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where up.user_id = any (p_user_ids)

                               and ((pd.final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                                    'US/Mountain') :: date between p_start_date and p_end_date
                               and pd.final_design_sent_to_homeowner_date is not null
                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and pd.company_id = v_company_id
                             order by owner_name, pd.final_design_sent_to_homeowner_date
                         ) as funnel_rows;

            --Final Designs sent to Homeowner (checked-in)
--             when p_funnel_id = 6 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.final_design_sent_to_homeowner_date,
--                                     pd.final_design_signed_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where up.user_id = any (p_user_ids)
--
--                                and ((pd.final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
--                                     'US/Mountain') :: date between p_start_date and p_end_date
--                                and pd.final_design_sent_to_homeowner_date is not null
--                                and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.final_design_sent_to_homeowner_date
--                          ) as funnel_rows;

            --Final Designs Approved
            when p_funnel_id = 7 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.final_design_signed_date,
                                    pd.financial_agreement_signed_date,
                                    pd.proof_of_homeowners_insurance_obtained_date,
                                    pd.first_cash_payment_paid_date        cash_down_payment,
                                    pd.utility_bill_verified_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where up.user_id = any (p_user_ids)

                               and pd.final_design_signed_date :: DATE between p_start_date and p_end_date
                               and pd.final_design_signed_date is not null
                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and pd.company_id = v_company_id
                             order by owner_name, pd.final_design_signed_date
                         ) as funnel_rows;

            --Final Designs Approved (checked-in)
--             when p_funnel_id = 7 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.final_design_signed_date,
--                                     pd.financial_agreement_signed_date,
--                                     pd.proof_of_homeowners_insurance_obtained_date,
--                                     pd.first_cash_payment_paid_date        cash_down_payment,
--                                     pd.utility_bill_verified_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where up.user_id = any (p_user_ids)
--
--                                and pd.final_design_signed_date :: DATE between p_start_date and p_end_date
--                                and pd.final_design_signed_date is not null
--                                and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.final_design_signed_date
--                          ) as funnel_rows;

            --Final Designs Completed
            when p_funnel_id = 21 and p_is_checked_in_column is false then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.final_design_complete_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where up.user_id = any (p_user_ids)

                               and pd.final_design_complete_date is not null
                               and pd.final_design_complete_date :: DATE between p_start_date and p_end_date
                               and pd.company_id = v_company_id
                             order by owner_name, pd.final_design_complete_date
                         ) as funnel_rows;

            --Final Designs Completed (checked-in)
--             when p_funnel_id = 21 and p_is_checked_in_column is true then
--                 RETURN QUERY
--                     select array_to_json(array_agg(row_to_json(funnel_rows)))
--                     from (
--                              select concat(u.first_name, ' ', u.last_name) owner_name,
--                                     o.org_name                             office,
--                                     s.abbreviation                         state,
--                                     cpst.project_status_type as            status_type,
--                                     concat(c.first_name, ' ', c.last_name) customer_name,
--                                     c.id                                   contact_id,
--                                     pd.project_id,
--                                     pd.source_name,
--                                     pd.system_size,
--                                     pd.primary_financier_name              financier,
--                                     pd.closer_appointment_start            appointment_date,
--                                     pd.cancelled_date,
--                                     pd.final_design_complete_date
--                              from brs.project_details pd
--                                       inner join flow.project p on p.id = pd.project_id
--                                       inner join flow.company_project_status_type cpst
--                                                  on cpst.id = p.company_project_status_type_id
--                                       inner join flow.user_position up on up.id = p.user_position_id
--                                       inner join flow.org o on o.id = up.org_id
--                                       inner join flow.contact c on c.id = p.contact_id
--                                       left outer join flow.user u on pd.closer_user_id = u.id
--                                       left outer join flow.company_state cs on cs.id = p.company_state_id
--                                       left outer join flow.state s on s.id = cs.state_id
--                              where up.user_id = any (p_user_ids)
--
--                                and pd.final_design_complete_date is not null
--                                and pd.final_design_complete_date :: DATE between p_start_date and p_end_date
--                                and pd.appointment_check_in is not null
--                                and pd.company_id = v_company_id
--                              order by owner_name, pd.final_design_complete_date
--                          ) as funnel_rows;

            --Installations Completed
            when p_funnel_id = 8 then
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(funnel_rows)))
                    from (
                             select concat(u.first_name, ' ', u.last_name) owner_name,
                                    o.org_name                             office,
                                    s.abbreviation                         state,
                                    cpst.project_status_type as            status_type,
                                    concat(c.first_name, ' ', c.last_name) customer_name,
                                    c.id                                   contact_id,
                                    pd.project_id,
                                    pd.source_name,
                                    pd.system_size,
                                    pd.primary_financier_name              financier,
                                    pd.closer_appointment_start            appointment_date,
                                    pd.cancelled_date,
                                    pd.substantial_completion_date
                             from brs.project_details pd
                                      inner join flow.project p on p.id = pd.project_id
                                      inner join flow.company_project_status_type cpst
                                                 on cpst.id = p.company_project_status_type_id
                                      inner join flow.user_position up on up.id = p.user_position_id
                                      inner join flow.org o on o.id = up.org_id
                                      inner join flow.contact c on c.id = p.contact_id
                                      left outer join flow.user u on pd.closer_user_id = u.id
                                      left outer join flow.company_state cs on cs.id = p.company_state_id
                                      left outer join flow.state s on s.id = cs.state_id
                             where up.user_id = any (p_user_ids)

                               and pd.substantial_completion_date :: DATE between p_start_date and p_end_date
                               and pd.substantial_completion_date is not null
                               and case when array_length(p_org_ids, 1) > 0 then o.id = any (p_org_ids) else 1 = 1 end
                               and pd.company_id = v_company_id
                             order by owner_name, pd.substantial_completion_date
                         ) as funnel_rows;

            end case;
    end if;

END
$function$
