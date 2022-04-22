CREATE OR REPLACE FUNCTION brs.util_closer_office_selection(p_platform_user_id integer, p_area_ids json, p_region_ids json, p_district_ids json, p_permission_override boolean DEFAULT false)
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

    -- org_level_id of 7 = Office
    case when (p_permission_override) OR (v_org_level_id < 7) then ---- Corporate and Regional
        RETURN QUERY
            select array_to_json(array_agg(row_to_json(sub_rows)))
            from (
                select upv.org_id,
                       (case when length(lov.name) > 0 then concat(o.org_name, ' - ', lov.name)
                           else o.org_name
                           end) as org_name,
                       o.active_flag as active
                from flow.user_positions_vw upv
                    inner join flow.org o on o.id = upv.org_id and o.org_type_id = 3
--                     inner join flow.org_type ot on o.org_type_id = ot.id and ot.id = 3

                    inner join flow.org o2 on o2.id = o.parent_org_id and o2.org_type_id = 117 -- district
--                     inner join flow.org_type ot1 on ot1.id = o2.org_type_id and ot1.id = 117 --district
                    inner join flow.org o3 on o3.id = o2.parent_org_id and o3.org_type_id = 2 -- region
--                     inner join flow.org_type ot2 on ot2.id = o3.org_type_id and ot2.id = 2 --region
                    inner join flow.org o4 on o4.id = o3.parent_org_id and o4.org_type_id = 21 -- area
--                     inner join flow.org_type ot3 on ot3.id = o4.org_type_id and ot3.id = 21 --area

--                     inner join flow.org o2 on o2.id = o.parent_org_id  -- region
--                     inner join flow.org_type ot1 on ot1.id = o2.org_type_id and ot1.id = 2 --region
--                     inner join flow.org o3 on o3.id = o2.parent_org_id  -- district
--                     inner join flow.org_type ot2 on ot2.id = o3.org_type_id and ot2.id = 21 --district
                    left join flow.organization_custom_field_value ocfv ON ocfv.org_id = o.id
                    left join flow.list_of_value lov ON ocfv.int_value = lov.id
                where upv.org_id is not null
                  and upv.archived is not true
                    and case when p_area_ids::text != '[]'::text then
                                   o4.id in (SELECT (elem ->> 'area_id') :: INTEGER
                                             FROM json_array_elements(p_area_ids) elem)
                           else 1=1 end
                    and case when p_region_ids::text != '[]'::text then
                                o3.id in (SELECT (elem ->> 'region_id') :: INTEGER
                                            FROM json_array_elements(p_region_ids) elem)
                        else 1=1 end
                    and case when p_district_ids::text != '[]'::text then
                                 o2.id in (SELECT (elem ->> 'district_id') :: INTEGER
                                           FROM json_array_elements(p_district_ids) elem)
                         else 1=1 end
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
                    inner join flow.org o on o.id = upv.org_id and o.org_type_id = 3
--                     inner join flow.org_type ot on o.org_type_id = ot.id and ot.id = 3

                    inner join flow.org o2 on o2.id = o.parent_org_id and o2.org_type_id = 117 -- district
--                     inner join flow.org_type ot1 on ot1.id = o2.org_type_id and ot1.id = 117 --district
                    inner join flow.org o3 on o3.id = o2.parent_org_id and o3.org_type_id = 2 -- region
--                     inner join flow.org_type ot2 on ot2.id = o3.org_type_id and ot2.id = 2 --region
                    inner join flow.org o4 on o4.id = o3.parent_org_id and o4.org_type_id = 21 -- area
--                     inner join flow.org_type ot3 on ot3.id = o4.org_type_id and ot3.id = 21 --area

--                     inner join flow.org o2 on o2.id = o.parent_org_id  -- region
--                     inner join flow.org_type ot1 on ot1.id = o2.org_type_id and ot1.id = 2 --region
--                     inner join flow.org o3 on o3.id = o2.parent_org_id  -- district
--                     inner join flow.org_type ot2 on ot2.id = o3.org_type_id and ot2.id = 21 --district
                    left join flow.organization_custom_field_value ocfv ON ocfv.org_id = o.id
                    left join flow.list_of_value lov ON ocfv.int_value = lov.id
                where upv.org_id is not null
                  and upv.archived is not true
                  and case when p_area_ids::text != '[]'::text then
                                   o4.id in (SELECT (elem ->> 'area_id') :: INTEGER
                                             FROM json_array_elements(p_area_ids) elem)
                           else 1=1 end
                  and case when p_region_ids::text != '[]'::text then
                                   o3.id in (SELECT (elem ->> 'region_id') :: INTEGER
                                             FROM json_array_elements(p_region_ids) elem)
                           else 1=1 end
                  and case when p_district_ids::text != '[]'::text then
                                   o2.id in (SELECT (elem ->> 'district_id') :: INTEGER
                                             FROM json_array_elements(p_district_ids) elem)
                           else 1=1 end
                    and upv.user_id = p_platform_user_id
                group by upv.org_id, o.org_name, lov.name, o.active_flag
                order by o.active_flag desc, o.org_name, lov.name
            ) as sub_rows;

    end case;

END
$function$
