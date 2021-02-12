CREATE OR REPLACE FUNCTION brs.util_setter_district_selection(p_platform_user_id integer)
    RETURNS SETOF json
    LANGUAGE plpgsql
AS
$function$
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
      and up.archived is not true
      and up.end_date is null
      and up.primary_flag is true;

    -- org_level_id of 4 = District
    case when (v_org_level_id < 4) then
        RETURN QUERY
            select array_to_json(array_agg(row_to_json(sub_rows)))
            from (
                     select upv.org_id,
                            concat(o.org_name, ' - ', ot.org_type) as org_name,
                            o.active_flag                          as active
                     from flow.user_positions_vw upv
                              inner join flow.org o on o.id = upv.org_id
                              inner join flow.org_type ot on ot.id = o.org_type_id
                     where upv.org_id is not null
                       and upv.archived is not true
                       and o.parent_org_id = 222
                     group by upv.org_id, o.org_name, ot.org_type, o.active_flag
                     order by o.active_flag desc, o.org_name, ot.org_type
                 ) as sub_rows;
        else
            RETURN QUERY
                select array_to_json(array_agg(row_to_json(sub_rows)))
                from (
                         select upv.org_id,
                                concat(o.org_name, ' - ', ot.org_type) as org_name,
                                o.active_flag                          as active
                         from flow.user_positions_vw upv
                                  inner join flow.org o on o.id = upv.org_id
                                  inner join flow.org_type ot on ot.id = o.org_type_id
                         where upv.org_id is not null
                           and upv.archived is not true
                           and upv.user_id = p_platform_user_id
                           and o.parent_org_id = 222
                         group by upv.org_id, o.org_name, ot.org_type, o.active_flag
                         order by o.active_flag desc, o.org_name, ot.org_type
                     ) as sub_rows;

        end case;

END
$function$
