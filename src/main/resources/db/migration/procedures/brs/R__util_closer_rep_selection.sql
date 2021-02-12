CREATE OR REPLACE FUNCTION brs.util_closer_rep_selection(p_platform_user_id integer,p_district_ids json, p_region_ids json, p_office_ids json)
    RETURNS SETOF json
    LANGUAGE plpgsql
AS $function$
DECLARE
    v_org_level_id integer;
    v_current_position_ids integer[];
BEGIN
    select array_agg(position_id) into v_current_position_ids
    from flow.user_position
    where user_id = p_platform_user_id
      and archived is not true
      and end_date is null;

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

    -- org_level_id of 6 = Office
    case when (v_org_level_id < 6) OR (326 = any(v_current_position_ids)) OR (2 = any(v_current_position_ids)) then ---- Corporate and Regional
        RETURN QUERY

        select array_to_json(array_agg(row_to_json(sub_rows)))
        from (
            select  user_id, name, active,user_position_id
            from (
                select u.id user_id,
                       concat(u.first_name, ' ', u.last_name,' - ',o.org_name) as name,
                       (case when (upv.end_date is null or upv.end_date >= (now() at time zone 'US/Mountain')::date)
                             then true
                             else false
                             end) as active,
                       upv.user_position_id
                from flow.user_positions_vw upv
                    inner join flow.user u on u.id = upv.user_id
                    inner join flow.org o on o.id = upv.org_id
                    inner join flow.org_type ot on o.org_type_id = ot.id and ot.id = 3
                    inner join flow.org o2 on o2.id = o.parent_org_id  -- region
                    inner join flow.org_type ot1 on ot1.id = o2.org_type_id and ot1.id = 2 --region
                    inner join flow.org o3 on o3.id = o2.parent_org_id  -- district
                    inner join flow.org_type ot2 on ot2.id = o3.org_type_id and ot2.id = 21 --district
                where upv.org_id is not null
                  and upv.archived is not true
                    and case when p_office_ids::text != '[]'::text then
                        o.id in (SELECT (elem ->> 'office_id') :: INTEGER
                                       FROM json_array_elements(p_office_ids) elem)
                        else 1=1 end
                    and case when p_region_ids::text != '[]'::text then
                        o2.id in (SELECT (elem ->> 'region_id') :: INTEGER
                                            FROM json_array_elements(p_region_ids) elem)
                        else 1=1 end
                    and case when p_district_ids::text != '[]'::text then
                        o3.id in (SELECT (elem ->> 'district_id') :: INTEGER
                                FROM json_array_elements(p_district_ids) elem)
                             else 1=1 end
            ) as users
            order by active desc, name
        ) as sub_rows;
    else
        RETURN QUERY
            select array_to_json(array_agg(row_to_json(sub_rows)))
            from (
                select  user_id, name, active,users.user_position_id
                from (
                    select u.id user_id,
                           concat(u.first_name, ' ', u.last_name,' - ',o.org_name) as name,

                           (case when (upv.end_date is null or upv.end_date >= (now() at time zone 'US/Mountain')::date)
                                then true
                                else false
                                end) as active,
                           upv.user_position_id
                    from flow.user_positions_vw upv
                        inner join flow.user u on u.id = upv.user_id
                        inner join flow.org o on o.id = upv.org_id
                        inner join flow.org_type ot on o.org_type_id = ot.id and ot.id = 3
                        inner join flow.org o2 on o2.id = o.parent_org_id  -- region
                        inner join flow.org_type ot1 on ot1.id = o2.org_type_id and ot1.id = 2 --region
                        inner join flow.org o3 on o3.id = o2.parent_org_id  -- district
                        inner join flow.org_type ot2 on ot2.id = o3.org_type_id and ot2.id = 21 --district
                    where upv.org_id is not null
                      and upv.archived is not true
                      and case when p_office_ids::text != '[]'::text then
                                       o.id in (SELECT (elem ->> 'office_id') :: INTEGER
                                                FROM json_array_elements(p_office_ids) elem)
                               else 1=1 end
                      and case when p_region_ids::text != '[]'::text then
                                       o2.id in (SELECT (elem ->> 'region_id') :: INTEGER
                                                 FROM json_array_elements(p_region_ids) elem)
                               else 1=1 end
                      and case when p_district_ids::text != '[]'::text then
                                       o3.id in (SELECT (elem ->> 'district_id') :: INTEGER
                                                 FROM json_array_elements(p_district_ids) elem)
                               else 1=1 end
                        and u.id = p_platform_user_id
                ) as users
                order by active desc, name
            ) as sub_rows;

    end case;

END
$function$
