CREATE OR REPLACE FUNCTION brs.rpt_setter_funnel_standard_drilldown(p_start_date date, p_end_date date, p_funnel_id integer, p_user_ids integer[], p_org_ids integer[])
    RETURNS SETOF json
    LANGUAGE plpgsql
AS $function$
declare
    v_whole_company boolean;
BEGIN
    --If p_user_ids has a -1 that means get the funnel for the whole company
    select -1 = any(p_user_ids)  into v_whole_company;
    if v_whole_company then
        --Appointments Created
        case when p_funnel_id = 3 then
            RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(su.first_name, ' ', su.last_name) as setter_name,
                       employee_id.employee_id,
                       concat(c.first_name, ' ', c.last_name) as customer_name,
                       pd.project_id,
                       pd.closer_appointment_start as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       pd.closer_appointment_outcome_name as appointment_outcome,
                       p.date_created,
                       s.abbreviation as state,
                       o.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    inner join flow.user su on su.id = pd.setter_user_id
                    inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                    inner join flow.org o on o.id = up.org_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 525 --Setter Gen
                    and pd.closer_appointment_start is not null
                    and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                order by setter_name, project_id
            ) as funnel_rows;

        --Appointments Occurred
        when p_funnel_id = 1 then
            RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(su.first_name, ' ', su.last_name) as setter_name,
                       employee_id.employee_id,
                       concat(c.first_name, ' ', c.last_name) as customer_name,
                       pd.project_id,
                       pd.closer_appointment_start as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       pd.closer_appointment_outcome_name as appointment_outcome,
                       p.date_created,
                       s.abbreviation as state,
                       o.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    inner join flow.user su on su.id = pd.setter_user_id
                    inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                    inner join flow.org o on o.id = up.org_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 525 --Setter Gen
                    and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                    and pd.closer_appointment_start is not null
                    and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                order by setter_name, appointment_date
            ) as funnel_rows;

        --Appointments Pitched
        when p_funnel_id = 2 then
            RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(su.first_name, ' ', su.last_name) as setter_name,
                       employee_id.employee_id,
                       concat(c.first_name, ' ', c.last_name) as customer_name,
                       pd.project_id,
                       pd.closer_appointment_start as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       pd.closer_appointment_outcome_name as appointment_outcome,
                       p.date_created,
                       s.abbreviation as state,
                       o.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    inner join flow.user su on su.id = pd.setter_user_id
                    inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                    inner join flow.org o on o.id = up.org_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 525 --Setter Gen
                    and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                    and pd.closer_appointment_start is not null
                    and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                order by setter_name, appointment_date
            ) as funnel_rows;
        end case;
    else
        --Appointments Created
        case when p_funnel_id = 3 then
            RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(su.first_name, ' ', su.last_name) as setter_name,
                       employee_id.employee_id,
                       concat(c.first_name, ' ', c.last_name) as customer_name,
                       pd.project_id,
                       pd.closer_appointment_start as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       pd.closer_appointment_outcome_name as appointment_outcome,
                       p.date_created,
                       s.abbreviation as state,
                       o.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    inner join flow.user su on su.id = pd.setter_user_id
                    inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                    inner join flow.org o on o.id = up.org_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 525 --Setter Gen
                    and pd.closer_appointment_start is not null
                    and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                    and pd.setter_user_id = any(p_user_ids)
                    and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))
                order by setter_name, project_id
            ) as funnel_rows;

        --Appointments Occurred
        when p_funnel_id = 1 then
            RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(su.first_name, ' ', su.last_name) as setter_name,
                       employee_id.employee_id,
                       concat(c.first_name, ' ', c.last_name) as customer_name,
                       pd.project_id,
                       pd.closer_appointment_start as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       pd.closer_appointment_outcome_name as appointment_outcome,
                       p.date_created,
                       s.abbreviation as state,
                       o.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    inner join flow.user su on su.id = pd.setter_user_id
                    inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                    inner join flow.org o on o.id = up.org_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 525 --Setter Gen
                    and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                    and pd.closer_appointment_start is not null
                    and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                    and pd.setter_user_id = any(p_user_ids)
                    and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))
                order by setter_name, appointment_date
            ) as funnel_rows;

        --Appointments Pitched
        when p_funnel_id = 2 then
            RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(su.first_name, ' ', su.last_name) as setter_name,
                       employee_id.employee_id,
                       concat(c.first_name, ' ', c.last_name) as customer_name,
                       pd.project_id,
                       pd.closer_appointment_start as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       pd.closer_appointment_outcome_name as appointment_outcome,
                       p.date_created,
                       s.abbreviation as state,
                       o.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    inner join flow.user su on su.id = pd.setter_user_id
                    inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                    inner join flow.org o on o.id = up.org_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 525 --Setter Gen
                    and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                    and pd.closer_appointment_start is not null
                    and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                    and pd.setter_user_id = any(p_user_ids)
                    and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))
                order by setter_name, appointment_date
            ) as funnel_rows;

        end case;

  end if;

END
$function$
