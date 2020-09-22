CREATE OR REPLACE FUNCTION brs.util_closer_office_selection(p_platform_user_id integer, p_region_ids json, p_permission_override boolean DEFAULT false)
    RETURNS SETOF json
    LANGUAGE plpgsql
AS $function$
DECLARE
    v_org_level_id integer;
BEGIN
    select min(ol.level)
    into v_org_level_id
    from flow.user_position up
        inner join flow.org o on o.id = up.org_id
        inner join flow.org_type ot on o.org_type_id = ot.id
        inner join flow.org_level ol on ol.id = ot.org_level_id
    where up.user_id = p_platform_user_id
        and end_date is null
        and primary_flag is true;

    -- org_level_id of 6 = Office
    case when (p_permission_override) OR (v_org_level_id < 6) OR (p_platform_user_id = 99999999) then ---- Corporate and Regional
        RETURN QUERY
            select array_to_json(array_agg(row_to_json(sub_rows)))
            from (
                select upmv.org_id, case when length(lov.name) > 0 then concat(upmv.org_name, ' - ', lov.name) else upmv.org_name end as org_name, o.active_flag as active
                from flow.user_positions_materialized_vw upmv
                    inner join flow.org o on o.id = upmv.org_id
                    left join flow.organization_custom_field_value ocfv ON ocfv.org_id = o.id
                    left join flow.list_of_value lov ON ocfv.int_value = lov.id
                where upmv.org_id is not null
                    and o.parent_org_id in (SELECT (elem ->> 'region_id') :: INTEGER
                                            FROM json_array_elements(p_region_ids) elem)
                group by upmv.org_id, upmv.org_name, lov.name, o.active_flag
                order by o.active_flag desc, upmv.org_name, lov.name
            ) as sub_rows;
    else
        RETURN QUERY
            select array_to_json(array_agg(row_to_json(sub_rows)))
            from (
                select upmv.org_id, case when length(lov.name) > 0 then concat(upmv.org_name, ' - ', lov.name) else upmv.org_name end as org_name, o.active_flag as active
                from flow.user_positions_materialized_vw upmv
                    inner join flow.org o on o.id = upmv.org_id
                    left join flow.organization_custom_field_value ocfv ON ocfv.org_id = o.id
                    left join flow.list_of_value lov ON ocfv.int_value = lov.id
                where upmv.org_id is not null
                    and o.parent_org_id in (SELECT (elem ->> 'region_id') :: INTEGER
                                            FROM json_array_elements(p_region_ids) elem)
                    and upmv.user_id = p_platform_user_id
                group by upmv.org_id, upmv.org_name, lov.name, o.active_flag
                order by o.active_flag desc, upmv.org_name, lov.name
            ) as sub_rows;

    end case;

END
$function$
