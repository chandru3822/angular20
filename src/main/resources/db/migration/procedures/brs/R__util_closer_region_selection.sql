CREATE OR REPLACE FUNCTION brs.util_closer_region_selection(p_platform_user_id integer, p_district_ids json, p_permission_override boolean DEFAULT false)
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
        and up.end_date is null
        and up.archived is not true
        and up.primary_flag is true;

    -- org_level_id of 5 = Region
    case when (p_permission_override) OR (v_org_level_id < 5) then
        RETURN QUERY
            select array_to_json(array_agg(row_to_json(sub_rows)))
            from (
                select upv.org_id,
                       (case when length(lov.name) > 0 then concat(o.org_name, ' - ', lov.name)
                            else o.org_name
                            end) as org_name,
                       o.active_flag as active
                from flow.user_positions_vw upv
                    inner join flow.org o on o.id = upv.org_id
                    inner join flow.org_type ot on o.org_type_id = ot.id and ot.id = 2
                    left join flow.organization_custom_field_value ocfv ON ocfv.org_id = o.id
                    left join flow.list_of_value lov ON ocfv.int_value = lov.id
                where upv.org_id is not null
                  and upv.archived is not true
                    and  case when p_district_ids::text != '[]'::text then
                                o.parent_org_id in (SELECT (elem ->> 'district_id') :: INTEGER
                                            FROM json_array_elements(p_district_ids) elem)
                        else 1= 1 end
                group by upv.org_id, o.org_name, lov.name, o.active_flag
                order by o.active_flag desc, o.org_name, lov.name
            ) as sub_rows;
    else
        RETURN QUERY
            select array_to_json(array_agg(row_to_json(sub_rows)))
            from (
                select upv.org_id,
                       (case when length(lov.name) > 0 then concat(o.org_name, ' - ', lov.name)
                            else o.org_name
                            end) as org_name,
                       o.active_flag as active
                from flow.user_positions_vw upv
                    inner join flow.org o on o.id = upv.org_id
                    inner join flow.org_type ot on o.org_type_id = ot.id and ot.id = 2
                    left join flow.organization_custom_field_value ocfv ON ocfv.org_id = o.id
                    left join flow.list_of_value lov ON ocfv.int_value = lov.id
                where upv.org_id is not null
                  and upv.archived is not true
                    and  case when p_district_ids::text != '[]'::text then
                                      o.parent_org_id in (SELECT (elem ->> 'district_id') :: INTEGER
                                                          FROM json_array_elements(p_district_ids) elem)
                              else 1= 1 end
                    and upv.user_id = p_platform_user_id
                group by upv.org_id, o.org_name, lov.name, o.active_flag
                order by o.active_flag desc, o.org_name, lov.name
            ) as sub_rows;

    end case;

END
$function$
