CREATE OR REPLACE FUNCTION brs.util_setter_rep_selection(p_platform_user_id integer, p_region_ids json, p_office_ids json)
    RETURNS SETOF json
LANGUAGE plpgsql
AS $function$
declare
    v_org_level_id integer;
    v_current_position_ids integer[];
BEGIN
    select array_agg(position_id) into v_current_position_ids
    from flow.user_position
    where user_id = p_platform_user_id and end_date is null;

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
    case when (v_org_level_id < 6) OR (v_current_position_ids && '{5}') OR (p_platform_user_id in (99999999)) then ---- Corporate and Regional
    RETURN QUERY
        select array_to_json(array_agg(row_to_json(sub_rows)))
        from (
            select distinct user_id, name, active
            from (
                select upmv.user_id, concat(upmv.first_name, ' ', upmv.last_name) as name, case when (upmv.end_date is null or upmv.end_date >= (now() at time zone 'US/Mountain')::date) then true else false end as active
                from flow.user_positions_materialized_vw upmv
                    inner join flow.org o on upmv.org_id = o.id
                where upmv.org_id is not null
                    and upmv.org_id in (SELECT (elem->>'office_id') :: INTEGER
                                        FROM json_array_elements(p_office_ids) elem)
                    and o.parent_org_id in (SELECT (elem->>'region_id') :: INTEGER
                                            FROM json_array_elements(p_region_ids) elem)
                    and upmv.user_status_type_id in (9,11,14) -- (Active, Terminated, Pending Termination)
            ) as users
            order by active desc, name
        ) as sub_rows;
    else
        RETURN QUERY
            select array_to_json(array_agg(row_to_json(sub_rows)))
            from (
                select distinct user_id, name, active
                from (
                    select distinct upmv.user_id, concat(upmv.first_name, ' ', upmv.last_name) as name, case when (upmv.end_date is null or upmv.end_date >= (now() at time zone 'US/Mountain')::date) then true else false end as active
                    from flow.user_positions_materialized_vw upmv
                        inner join flow.org o on upmv.org_id = o.id
                    where upmv.org_id is not null
                        and upmv.org_id in (select (elem->>'office_id')::integer from json_array_elements(p_office_ids) elem)
                        and o.parent_org_id in (select (elem->>'region_id')::integer from json_array_elements(p_region_ids) elem)
                        and upmv.user_id = p_platform_user_id
                        and upmv.user_status_type_id in (9,11,14) -- (Active, Terminated, Pending Termination)
                ) as users
                order by active desc, name
            ) as sub_rows;

    end case;

END
$function$
