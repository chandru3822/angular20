CREATE OR REPLACE FUNCTION brs.util_closer_rep_selection(p_platform_user_id integer, p_area_ids json, p_region_ids json,
                                                         p_district_ids json, p_office_ids json)
    RETURNS SETOF json
    LANGUAGE plpgsql
AS
$function$
DECLARE
    v_org_level_id         integer;
    v_current_position_ids integer[];
    v_org_ids integer[];
BEGIN
    select array_agg(position_id)
    into v_current_position_ids
    from flow.user_position
    where user_id = p_platform_user_id
      and archived is not true
      and end_date is null
      and start_date <= (now() at time zone 'US/Mountain')::date;

    select min(ol.level)
    into v_org_level_id
    from flow.user_position up
             inner join flow.org o on o.id = up.org_id
             inner join flow.org_type ot on o.org_type_id = ot.id
             inner join flow.org_level ol on ol.id = ot.org_level_id
    where up.user_id = p_platform_user_id
      and up.end_date is null
      and up.start_date <= (now() at time zone 'US/Mountain')::date
      and up.archived is not true
      and up.primary_flag is true;


    if p_office_ids::text != '[]'::text then
        raise notice '1';
        select array_agg(elem)
        into v_org_ids
        from (
        SELECT (elem ->> 'office_id') :: INTEGER as elem

        FROM json_array_elements(p_office_ids::JSON) elem)as elem;
    elsif p_district_ids::text != '[]'::text then
        raise notice '2';
        select array_agg(elem)
        into v_org_ids
        from (
        SELECT (elem ->> 'district_id') :: INTEGER as elem
        FROM json_array_elements(p_district_ids::JSON) elem)as elem;
    elsif p_region_ids::text != '[]'::text then
        raise notice '3';
        select array_agg(elem)
        into v_org_ids
        from (
        SELECT (elem ->> 'region_id') :: INTEGER as elem
        FROM json_array_elements(p_region_ids::JSON) elem)as elem;
    elsif p_area_ids::text != '[]'::text then
        raise notice '4';
        select array_agg(elem)
        from (
        SELECT (elem ->> 'area_id') :: INTEGER as elem
        into v_org_ids
        FROM json_array_elements(p_area_ids::JSON) elem)as elem;
    end if;
    raise notice 'v_org_ids,%',v_org_ids;
    -- org_level_id of 7 = Office
    case when p_area_ids::text = '[]'::text and p_region_ids::text = '[]'::text and
              p_district_ids::text = '[]'::text and p_office_ids::text = '[]'::text then
                  raise notice 'not here please';
        RETURN QUERY
        select array_to_json(array_agg(row_to_json(sub_rows)))
        from (
                 select distinct user_id, name, active, user_position_id
                 from (
                          select u.id                                                         user_id,
                                 concat(u.first_name, ' ', u.last_name, ' - ', o.org_name) as name,
                                 (case
                                      when upv.start_date is not null and
                                           upv.start_date <= (now() at time zone 'US/Mountain')::date and
                                           (upv.end_date is null or
                                            upv.end_date >= (now() at time zone 'US/Mountain')::date)
                                          then true
                                      else false
                                     end)                                                  as active,
                                 upv.user_position_id
                          from flow.user_positions_vw upv
                                   inner join flow.user u on u.id = upv.user_id
                                   inner join flow.user_position up on u.id = up.user_id and up.position_id in (1,2,3,133,237,517)
                                                                 and up.archived is not true and up.id = upv.user_position_id
                                   inner join flow.org o on o.id = up.org_id
                                   inner join flow.user_status_type ust on ust.id = upv.user_status_type_id
                            where ust.user_status_type == 'Active'
                      ) as sub_rows  order by active desc, name) as sub_rows;
        else
            case when (v_org_level_id < 7) OR (326 = any (v_current_position_ids)) OR
                      (2 = any (v_current_position_ids)) then ---- Corporate and Regional
                RETURN QUERY
                    select array_to_json(array_agg(row_to_json(sub_rows)))
                    from (
                             select user_id, name, active, user_position_id
                             from (
                                      select upv.user_id                                                         user_id,
                                             concat(upv.first_name, ' ', upv.last_name, ' - ', upv.org_name) as name,
                                             (case
                                                  when upv.start_date is not null and
                                                       upv.start_date <= (now() at time zone 'US/Mountain')::date and
                                                       (upv.end_date is null or
                                                        upv.end_date >= (now() at time zone 'US/Mountain')::date)
                                                      then true
                                                  else false
                                                 end)                                                  as active,
                                             upv.user_position_id
                                      from flow.user_positions_vw upv
                                        inner join flow.user_status_type ust on ust.id = upv.user_status_type_id
                                      where upv.org_id is not null and upv.org_id = any(v_org_ids)
                                        and upv.archived is not true
                                        and ust.user_status_type != 'Expired'
                                  ) as users
                             order by active desc, name
                         ) as sub_rows;
                else
                    RETURN QUERY
                        select array_to_json(array_agg(row_to_json(sub_rows)))
                        from (
                                 select user_id, name, active, users.user_position_id
                                 from (
                                          select upv.user_id                                                         user_id,
                                                 concat(upv.first_name, ' ', upv.last_name, ' - ', upv.org_name) as name,

                                                 (case
                                                      when upv.start_date is not null and
                                                           upv.start_date <= (now() at time zone 'US/Mountain')::date and
                                                           (upv.end_date is null or
                                                            upv.end_date >= (now() at time zone 'US/Mountain')::date)
                                                          then true
                                                      else false
                                                     end)                                                  as active,
                                                 upv.user_position_id
                                          from flow.user_positions_vw upv
                                            inner join flow.user_status_type ust on ust.id = upv.user_status_type_id
                                          where upv.org_id is not null and upv.org_id = any(v_org_ids)
                                            and upv.archived is not true
                                             and upv.user_id = p_platform_user_id
                                             and ust.user_status_type != 'Expired'
                                    ) as users
                                 order by active desc, name
                             ) as sub_rows;

                end case;
            end case;
        END
$function$
