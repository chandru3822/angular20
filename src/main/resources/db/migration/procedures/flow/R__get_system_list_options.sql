--DROP FUNCTION IF EXISTS flow.get_system_list_options(integer, integer, boolean, integer[]);
CREATE OR REPLACE FUNCTION flow.get_system_list_options(p_company_id INTEGER, p_company_system_list_id integer, p_sub_options BOOLEAN, p_system_list_option_ids integer[] default null, p_int_value int default null)

RETURNS TABLE(id int, name text) AS

$BODY$
DECLARE
    v_system_list_id integer;
BEGIN
    --select * from blueraven.card_queue_drill_down(7)
    SELECT csl.system_list_id
    INTO v_system_list_id
    FROM flow.company_system_list csl
    WHERE csl.id = p_company_system_list_id;

    -- 1 = users by org
    case when v_system_list_id = 1 and p_sub_options is not true then
        RETURN QUERY
            select o.id,
                   o.org_name::text as name
            from flow.org o
            where ( o.company_id = p_company_id OR
                  ( o.company_id = (select parent_company_id
                                    from flow.company c
                                    where c.id = p_company_id) AND o.available_to_children is true) )
                and o.archived is not true
                and o.active_flag is true
            order by name;
    when v_system_list_id = 1 and p_sub_options is true then
        RETURN QUERY
--             select distinct upv.user_id::integer as id,
--                             concat(upv.first_name,' ',upv.last_name::text) as name
            select distinct upv.user_position_id::integer as id,
                    case when  ARRAY_LENGTH( array[ p_system_list_option_ids ]::INTEGER[], 1 ) > 1
                             then concat(upv.first_name,' ',upv.last_name::text,' - ',upv.org_name)
                         else concat(upv.first_name,' ',upv.last_name::text) end as name
            from flow.user_positions_vw upv
            where ( upv.company_id = p_company_id OR upv.company_id = (select parent_company_id
                                                                       from flow.company c
                                                                       where c.id = p_company_id) )
              and ARRAY[upv.org_id] <@ ARRAY[ p_system_list_option_ids ]::INTEGER[]
              and upv.has_access is true
              and (upv.start_date <= now() and
                   (upv.end_date IS NULL OR upv.end_date > now()))
            union
                select upv.user_position_id::integer as id,
                       concat(upv.first_name,' ',upv.last_name::text) as name
                from flow.user_positions_vw upv
                where upv.user_position_id = p_int_value
            order by name;
    -- 2 = users by position
    when v_system_list_id = 2 and p_sub_options is not true then
        RETURN QUERY
            select p.id,
                   p.position::text as name
            from flow.position p
            where ( p.company_id = p_company_id OR
                    ( p.company_id = (select parent_company_id
                                      from flow.company c
                                      where c.id = p_company_id) AND p.available_to_children is true) )
              and p.archived is not true
              and p.active is true
            order by name;
    when v_system_list_id = 2 and p_sub_options is true then
        RETURN QUERY
--             select distinct upv.user_id::integer as id,
--                             concat(upv.first_name,' ',upv.last_name::text) as name
            select distinct upv.user_position_id::integer as id,
                case when ARRAY_LENGTH( array[ p_system_list_option_ids ]::INTEGER[], 1 ) > 1
                         then concat(upv.first_name,' ',upv.last_name::text,' - ', upv.position)
                         else concat(upv.first_name,' ',upv.last_name::text) end as name
            from flow.user_positions_vw upv
            where ( upv.company_id = p_company_id OR upv.company_id = (select parent_company_id
                                                                     from flow.company c
                                                                     where c.id = p_company_id) )
              and upv.has_access is true
              and ARRAY[upv.position_id] <@ ARRAY[ p_system_list_option_ids ]::INTEGER[]
              and (upv.start_date <= now() and
                   (upv.end_date IS NULL OR upv.end_date > now()))
            union
                select upv.user_position_id,
                       concat(upv.first_name,' ', upv.last_name::text) as name
                from flow.user_positions_vw upv
                where user_position_id = p_int_value
            order by name;
    -- 3 = orgs by org_type
    when v_system_list_id = 3 and p_sub_options is not true then
        RETURN QUERY
            select ot.id,
                   ot.org_type::text as name
            from flow.org_type ot
            where ( ot.company_id = p_company_id OR
                  ( ot.company_id = (select parent_company_id
                                    from flow.company c
                                    where c.id = p_company_id) AND ot.available_to_children is true) )
              and ot.archived is not true
            order by name;
     when v_system_list_id = 3 and p_sub_options is true then
         -- this doesn't require that the orgs be made available to children because the entire type was made available to the child in the step above
         -- org.make_available is only used for system_list_id = 1
         RETURN QUERY
             select o.id,
                    o.org_name::text as name
             from flow.org o
             where ( o.company_id = p_company_id OR o.company_id = (select parent_company_id
                                                                      from flow.company c
                                                                      where c.id = p_company_id) )
               and ARRAY[o.org_type_id] <@ ARRAY[ p_system_list_option_ids ]::INTEGER[]
               and o.active_flag is true
             union
                select o.id,
                       o.org_name::text as name
                from flow.org o
                where o.id = p_int_value
             order by name;
     -- = All users
     when v_system_list_id = 4 then
         RETURN QUERY
             select distinct upv.user_id::integer as id,
                             concat(upv.first_name,' ',upv.last_name::text) as name
             from flow.user_positions_vw upv
             where upv.company_id = p_company_id
               and upv.has_access is true
               and (upv.start_date <= now() and
                    (upv.end_date IS NULL OR upv.end_date > now()))
             union
                select upv.user_id::integer as id,
                       concat(upv.first_name,' ',upv.last_name::text) as name
                from flow.user_positions_vw upv
                where upv.user_id = p_int_value
             order by name;
    end case;

END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100
                     ROWS 1000;
