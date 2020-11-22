CREATE OR REPLACE FUNCTION brs.rpt_setter_funnel_standard_drilldown(p_start_date date, p_end_date date, p_funnel_id integer, p_user_ids integer[], p_org_ids integer[])
    RETURNS SETOF json
LANGUAGE plpgsql
AS $function$
declare
    v_whole_company boolean;
BEGIN
    --If p_user_ids has a -1 that means get the funnel for the whole company
    select p_user_ids <@ Array[-1] into v_whole_company;
    if v_whole_company then
        --Appointments Occurred
        case when p_funnel_id = 1 then
            RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(su.first_name, ' ', su.last_name) as setter_name,
                       employee_id.employee_id,
                       concat(c.first_name, ' ', c.last_name) as customer_name,
                       pd.project_id,
                       pd.closer_appointment_start::date as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       lov.name as appointment_outcome,
                       p.date_created::date,
                       s.abbreviation as state,
                       upv.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    left join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id and upv.primary_flag is true
                    left join flow.user su on su.id = upv.user_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left join flow.list_of_value lov on lov.id = pd.closer_appointment_outcome
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 6 --Setter Gen
                    and pd.closer_appointment_start is not null
                    and pd.closer_appointment_start::date between p_start_date and p_end_date
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
                       pd.closer_appointment_start::date as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       lov.name as appointment_outcome,
                       p.date_created::date,
                       s.abbreviation as state,
                       upv.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    left join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id and upv.primary_flag is true
                    left join flow.user su on su.id = upv.user_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left join flow.list_of_value lov on lov.id = pd.closer_appointment_outcome
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 6 --Setter Gen
                    and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
                    and pd.closer_appointment_start is not null
                    and pd.closer_appointment_start::date between p_start_date and p_end_date
                order by setter_name, appointment_date
            ) as funnel_rows;

        --Appointments Created
        when p_funnel_id = 3 then
            RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(su.first_name, ' ', su.last_name) as setter_name,
                       employee_id.employee_id,
                       concat(c.first_name, ' ', c.last_name) as customer_name,
                       pd.project_id,
                       pd.closer_appointment_start::date as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       lov.name as appointment_outcome,
                       p.date_created::date,
                       s.abbreviation as state,
                       upv.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    left join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id and upv.primary_flag is true
                    left join flow.user su on su.id = upv.user_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left join flow.list_of_value lov on lov.id = pd.closer_appointment_outcome
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 6 --Setter Gen
                    and p.date_created::date between p_start_date and p_end_date
                order by setter_name, project_id
            ) as funnel_rows;
        end case;
    else
        --Appointments Occurred
        case when p_funnel_id = 1 then
            RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(su.first_name, ' ', su.last_name) as setter_name,
                       employee_id.employee_id,
                       concat(c.first_name, ' ', c.last_name) as customer_name,
                       pd.project_id,
                       pd.closer_appointment_start::date as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       lov.name as appointment_outcome,
                       p.date_created::date,
                       s.abbreviation as state,
                       upv.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    left join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id and upv.primary_flag is true
                    left join flow.user su on su.id = upv.user_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left join flow.list_of_value lov on lov.id = pd.closer_appointment_outcome
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 6 --Setter Gen
                    and pd.closer_appointment_start is not null
                    and pd.closer_appointment_start::date between p_start_date and p_end_date
                    and su.id is not null
                    and Array[su.id]::integer[] && p_user_ids
                    and Array[su.id]::integer[] && brs.limit_by_org_for_setters(Array[su.id]::integer[],p_org_ids,p.date_created::date)
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
                       pd.closer_appointment_start::date as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       lov.name as appointment_outcome,
                       p.date_created::date,
                       s.abbreviation as state,
                       upv.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    left join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id and upv.primary_flag is true
                    left join flow.user su on su.id = upv.user_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left join flow.list_of_value lov on lov.id = pd.closer_appointment_outcome
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 6 --Setter Gen
                    and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
                    and pd.closer_appointment_start is not null
                    and pd.closer_appointment_start::date between p_start_date and p_end_date
                    and su.id is not null
                    and Array[su.id]::integer[] <@ p_user_ids
                    and Array[su.id]::integer[] <@ brs.limit_by_org_for_setters(Array[su.id]::integer[],p_org_ids,p.date_created::date)
                order by setter_name, appointment_date
            ) as funnel_rows;

        --Appointments Created
        when p_funnel_id = 3 then
            RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(su.first_name, ' ', su.last_name) as setter_name,
                       employee_id.employee_id,
                       concat(c.first_name, ' ', c.last_name) as customer_name,
                       pd.project_id,
                       pd.closer_appointment_start::date as appointment_date,
                       concat(cu.first_name, ' ', cu.last_name) as owner_name,
                       pd.verified_setter_lead,
                       pd.verified_usage,
                       lov.name as appointment_outcome,
                       p.date_created::date,
                       s.abbreviation as state,
                       upv.org_name as office
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    left join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id and upv.primary_flag is true
                    left join flow.user su on su.id = upv.user_id
                    left join flow.user cu on cu.id = pd.closer_user_id
                    left join flow.list_of_value lov on lov.id = pd.closer_appointment_outcome
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                where pd.source = 6 --Setter Gen
                    and p.date_created::date between p_start_date and p_end_date
                    and su.id is not null
                    and Array[su.id]::integer[] && p_user_ids
                    and Array[su.id]::integer[] && brs.limit_by_org_for_setters(Array[su.id]::integer[],p_org_ids,p.date_created::date)
                order by setter_name, project_id
            ) as funnel_rows;

        end case;

  end if;

END
$function$
