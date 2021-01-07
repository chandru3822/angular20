CREATE OR REPLACE FUNCTION brs.util_closer_rep_selection(p_platform_user_id integer, p_region_ids json, p_office_ids json)
    RETURNS SETOF json
    LANGUAGE plpgsql
AS $function$
DECLARE
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
        and up.end_date is null
        and up.primary_flag is true;

    -- org_level_id of 6 = Office
    case when (v_org_level_id < 6) OR (2 = any(v_current_position_ids)) OR (p_platform_user_id = 99999999) then ---- Corporate and Regional
    RETURN QUERY
        select array_to_json(array_agg(row_to_json(sub_rows)))
        from (
            select distinct user_id, name, active
            from (
                select u.id user_id,
                       concat(u.first_name, ' ', u.last_name) as name,
                       (case when (upv.end_date is null or upv.end_date >= (now() at time zone 'US/Mountain')::date)
                             then true
                             else false
                             end) as active
                from flow.user_positions_vw upv
                    inner join flow.user u on u.id = upv.user_id
                    inner join flow.org o on o.id = upv.org_id
                where upv.org_id is not null
                    and upv.org_id in (SELECT (elem ->> 'office_id') :: INTEGER
                                       FROM json_array_elements(p_office_ids) elem)
                    and o.parent_org_id in (SELECT (elem ->> 'region_id') :: INTEGER
                                            FROM json_array_elements(p_region_ids) elem)
            ) as users
            order by active desc, name
        ) as sub_rows;
    else
        RETURN QUERY
            select array_to_json(array_agg(row_to_json(sub_rows)))
            from (
                select distinct user_id, name, active
                from (
                    select u.id user_id,
                           concat(u.first_name, ' ', u.last_name) as name,
                           (case when (upv.end_date is null or upv.end_date >= (now() at time zone 'US/Mountain')::date)
                                then true
                                else false
                                end) as active
                    from flow.user_positions_vw upv
                        inner join flow.user u on u.id = upv.user_id
                        inner join flow.org o on o.id = upv.org_id
                    where upv.org_id is not null
                        and upv.org_id in (SELECT (elem ->> 'office_id') :: INTEGER
                                           FROM json_array_elements(p_office_ids) elem)
                        and o.parent_org_id in (SELECT (elem ->> 'region_id') :: INTEGER
                                                FROM json_array_elements(p_region_ids) elem)
                        and u.id = p_platform_user_id
                ) as users
                order by active desc, name
            ) as sub_rows;

    end case;

END
$function$
