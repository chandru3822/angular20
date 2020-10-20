CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_appts_created_pipeline_drilldown(p_start_date date, p_end_date date, p_funnel_id integer, p_source_ids integer[])
    RETURNS SETOF json
LANGUAGE plpgsql
AS $function$
BEGIN
    --BRS-provided appointments created
    case when p_funnel_id = 12 then
        RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(u.first_name, ' ', u.last_name) owner_name,
                       employee_id.employee_id,
                       s.abbreviation state,
                       concat(c.first_name, ' ', c.last_name) customer_name,
                       c.id contact_id,
                       pd.deal_id,
                       lov.name source_name,
                       pd.system_size,
                       lov2.name financier,
                       pd.closer_appointment_start,
                       pd.cancelled_date,
                       p.date_created
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    left outer join flow.user u on pd.closer_user_id = u.id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left outer join flow.list_of_value lov on lov.id = pd.source
                    left outer join flow.list_of_value lov2 on lov2.id = pd.primary_financier
                where p.date_created::date between p_start_date and p_end_date and
                    pd.closer_appointment_start is not null and
                    pd.source is not null and
                    Array[pd.source] <@ p_source_ids
                order by owner_name, p.date_created::date
            ) as funnel_rows;

    --Self-gen appointments created
    when p_funnel_id = 13 then
        RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(u.first_name, ' ', u.last_name) owner_name,
                       employee_id.employee_id,
                       s.abbreviation state,
                       concat(c.first_name, ' ', c.last_name) customer_name,
                       c.id contact_id,
                       pd.deal_id,
                       lov.name source_name,
                       pd.system_size,
                       lov2.name financier,
                       pd.closer_appointment_start,
                       pd.cancelled_date,
                       p.date_created
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    left outer join flow.user u on pd.closer_user_id = u.id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left outer join flow.list_of_value lov on lov.id = pd.source
                    left outer join flow.list_of_value lov2 on lov2.id = pd.primary_financier
                where p.date_created::date between p_start_date and p_end_date and
                    pd.closer_appointment_start is not null and
                    pd.source is not null and
                    Array[pd.source] <@ p_source_ids
                order by owner_name, p.date_created::date
            ) as funnel_rows;

    --Total Appointments Created
    when p_funnel_id = 10 then
        RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
            from (
                select concat(u.first_name, ' ', u.last_name) owner_name,
                       employee_id.employee_id,
                       s.abbreviation state,
                       concat(c.first_name, ' ', c.last_name) customer_name,
                       c.id contact_id,
                       pd.deal_id,
                       lov.name source_name,
                       pd.system_size,
                       lov2.name financier,
                       pd.closer_appointment_start,
                       pd.cancelled_date,
                       p.date_created
                from brs.project_details pd
                    inner join flow.project p on p.id = pd.project_id
                    inner join flow.contact c on c.id = p.contact_id
                    left outer join flow.user u on pd.closer_user_id = u.id
                    left join lateral (select * from flow.get_value_for_custom_field(3, 454, p.id, 0, false) as employee_id) employee_id on true
                    left outer join flow.company_state cs on cs.id = p.company_state_id
                    left outer join flow.state s on s.id = cs.state_id
                    left outer join flow.list_of_value lov on lov.id = pd.source
                    left outer join flow.list_of_value lov2 on lov2.id = pd.primary_financier
                where p.date_created::date between p_start_date and p_end_date and
                    pd.closer_appointment_start is not null and
                    pd.source is not null
                order by owner_name, p.date_created::date
            ) as funnel_rows;

    end case;

END
$function$
