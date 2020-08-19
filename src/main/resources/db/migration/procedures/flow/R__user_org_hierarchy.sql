-- DROP FUNCTION IF EXISTS flow.user_org_hierarchy(integer) cascade;
-- dont forget to add flow.user_positions_vw back after dropping this function
CREATE OR REPLACE FUNCTION flow.user_org_hierarchy(
p_org_id integer)
  RETURNS TABLE(org_id integer ,parent_org_id integer,org_name text,position_level integer, org_level_id integer, level integer) AS
$BODY$
declare

BEGIN
    return query
        WITH RECURSIVE subordinates(org_id,parent_org_id,org_name,position_level) AS (
            select o.id as org_id,o.parent_org_id,o.org_name,0, ot.org_level_id, ol.level
            from flow.org o
                     inner join flow.org_type ot on ot.id = o.org_type_id
                     inner join flow.org_level ol on ol.id = ot.org_level_id
            where o.id = p_org_id
            UNION
            select o.id as org_id,o.parent_org_id,o.org_name,s.position_level + 1, ot.org_level_id, ol.level
            from flow.org o
                     inner join flow.org_type ot on ot.id = o.org_type_id
                     inner join flow.org_level ol on ol.id = ot.org_level_id
                     INNER JOIN subordinates s ON s.parent_org_id = o.id
        ) SELECT
              s1.org_id,s1.parent_org_id,s1.org_name::text,s1.position_level,s1.org_level_id,s1.level
        FROM
            subordinates s1;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

