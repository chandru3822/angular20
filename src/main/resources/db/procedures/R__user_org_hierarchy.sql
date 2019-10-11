CREATE OR REPLACE FUNCTION flow.user_org_hierarchy(
p_org_id integer)
  RETURNS TABLE(org_id integer ,parent_org_id integer,org_name text,level integer) AS
$BODY$
declare

BEGIN
    return query
        WITH RECURSIVE subordinates(org_id,parent_org_id,org_name,level) AS (
            select o.id as org_id,o.parent_org_id,o.org_name,0
            from flow.org o
            where o.id = p_org_id
            UNION
            select o.id as org_id,o.parent_org_id,o.org_name,s.level + 1
            from flow.org o
                     INNER JOIN subordinates s ON s.parent_org_id = o.id
        ) SELECT
              s1.org_id,s1.parent_org_id,s1.org_name::text,s1.level
        FROM
            subordinates s1;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

