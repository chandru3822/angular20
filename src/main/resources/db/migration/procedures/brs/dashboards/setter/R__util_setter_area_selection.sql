CREATE OR REPLACE FUNCTION brs.util_setter_area_selection(p_platform_user_id integer)
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

    -- org_level_id of 4 = Area
	  case when (v_org_level_id < 4) then
	      RETURN QUERY
		        select array_to_json(array_agg(row_to_json(sub_rows)))
		        from (
                select upv.org_id,
                       (case when length(lov.name) > 0 then concat(o.org_name, ' - ', lov.name)
                            else o.org_name
                            end) as org_name,
                       o.active_flag as active
                from flow.user_positions_vw upv
                    inner join flow.org o on o.id = upv.org_id and o.org_type_id = 20
--                     inner join flow.org_type ot on o.org_type_id = ot.id and ot.id = 20
                    left join flow.organization_custom_field_value ocfv ON ocfv.org_id = o.id and ocfv.custom_field_group_assignment_id = 19097
                    left join flow.list_of_value lov ON ocfv.int_value = lov.id
                where upv.org_id is not null
                  and upv.archived is not true
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
                    inner join flow.org_type ot on o.org_type_id = ot.id and ot.id = 20
                    left join flow.organization_custom_field_value ocfv ON ocfv.org_id = o.id and ocfv.custom_field_group_assignment_id = 19097
                    left join flow.list_of_value lov ON ocfv.int_value = lov.id
                where upv.org_id is not null
                  and upv.archived is not true
                    and upv.user_id = p_platform_user_id
                group by upv.org_id, o.org_name, lov.name, o.active_flag
                order by o.active_flag desc, o.org_name, lov.name
            ) as sub_rows;

    end case;

END
$function$
