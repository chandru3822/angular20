--DROP FUNCTION IF EXISTS flow.get_system_list_options(integer, integer, boolean, integer[]);
CREATE OR REPLACE FUNCTION flow.get_system_list_options(p_company_id INTEGER, p_company_system_list_id integer, p_sub_options BOOLEAN, p_system_list_option_ids integer[] default null)

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
            where o.company_id = p_company_id
            order by name;
    when v_system_list_id = 1 and p_sub_options is true then
        RETURN QUERY
            select distinct upv.user_id::integer as id,
                   upv.first_name || ' ' || upv.last_name::text as name
            from flow.user_positions_vw upv
              inner join flow.user_status_type ust on ust.id = upv.user_status_type_id
            where upv.company_id = p_company_id
              and ARRAY[upv.org_id] <@ ARRAY[ p_system_list_option_ids ]::INTEGER[]
              and ust.can_access
              and (upv.start_date <= now() and
                   (upv.end_date IS NULL OR upv.end_date > now()))
            order by name;
    -- 2 = users by position
    when v_system_list_id = 2 and p_sub_options is not true then
        RETURN QUERY
            select p.id,
                   p.position::text as name
            from flow.position p
            where p.company_id = p_company_id
            order by name;
    when v_system_list_id = 2 and p_sub_options is true then
        RETURN QUERY
            select distinct upv.user_id::integer as id,
                   upv.first_name || ' ' || upv.last_name::text as name
            from flow.user_positions_vw upv
              inner join flow.user_status_type ust on ust.id = upv.user_status_type_id
            where upv.company_id = p_company_id
              and ust.can_access
              and ARRAY[upv.position_id] <@ ARRAY[ p_system_list_option_ids ]::INTEGER[]
              and (upv.start_date <= now() and
                   (upv.end_date IS NULL OR upv.end_date > now()))
            order by name;
    -- 3 = orgs by org_type
    when v_system_list_id = 3 and p_sub_options is not true then
        RETURN QUERY
            select ot.id,
                   ot.org_type::text as name
            from flow.org_type ot
            where ot.company_id = p_company_id
              and ot.archived is not true
            order by name;
     when v_system_list_id = 3 and p_sub_options is true then
         RETURN QUERY
             select o.id,
                    o.org_name::text as name
             from flow.org o
             where o.company_id = 1
               and ARRAY[o.org_type_id] <@ ARRAY[ p_system_list_option_ids ]::INTEGER[]
             order by name;
    end case;

END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100
                     ROWS 1000;
