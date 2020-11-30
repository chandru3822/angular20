-- DROP FUNCTION IF EXISTS flow.user_org_hierarchy(integer) cascade;
-- dont forget to add flow.user_positions_vw back after dropping this function
CREATE OR REPLACE FUNCTION flow.org_hierarchy_filter_down(
    p_org_ids integer[])
  RETURNS TABLE(id integer ,parent_org_id integer,org_name text,org_level_id integer,active_flag boolean,
                org_type_id integer ,org_type text) AS
$BODY$
declare

BEGIN
    return query
        WITH RECURSIVE subordinates(id,parent_org_id,org_name,org_level_id,active_flag,org_type_id,org_type) AS (
            select o.id,o.parent_org_id,o.org_name,ot.org_level_id,o.active_flag,o.org_type_id,ot.org_type
            from flow.org o
                     inner join flow.org_type ot on ot.id = o.org_type_id
            where o.id = any (p_org_ids)
            UNION
            select o.id,o.parent_org_id,o.org_name, ot.org_level_id,o.active_flag,o.org_type_id,ot.org_type
            from flow.org o
                     inner join flow.org_type ot on ot.id = o.org_type_id
                     INNER JOIN subordinates s ON s.id = o.parent_org_id
        ) SELECT
              s1.id,s1.parent_org_id,s1.org_name::text,s1.org_level_id,s1.active_flag,s1.org_type_id,s1.org_type::text
        FROM
            subordinates s1
        where not s1.id = any(p_org_ids)
        order by org_level_id;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

