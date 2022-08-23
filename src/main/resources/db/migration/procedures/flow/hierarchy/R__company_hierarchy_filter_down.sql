drop function if exists flow.company_hierarchy_filter_down(
  p_company_id bigint);
CREATE OR REPLACE FUNCTION flow.company_hierarchy_filter_down(
    p_company_id bigint)
  RETURNS TABLE(id bigint ,parent_company_id bigint,company_name text, level bigint) AS
$BODY$
declare

BEGIN
    return query
        WITH RECURSIVE subordinates(id,parent_company_id,company_name, level) AS (
            select c.id,c.parent_company_id,c.company_name, c.level
            from flow.company c
            where c.id = p_company_id
              and c.archived is not true
            UNION
            select c.id,c.parent_company_id,c.company_name, c.level
            from flow.company c
                 INNER JOIN subordinates s ON s.id = c.parent_company_id
            where c.archived is not true
                and c.parent_company_id != 1
        ) SELECT
              s1.id,s1.parent_company_id,s1.company_name::text, s1.level
        FROM
            subordinates s1;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

