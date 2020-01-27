
CREATE OR REPLACE FUNCTION flow.company_hierarchy_filter_up(
    p_company_id integer,
    p_include_top boolean default false)
  RETURNS TABLE(id integer ,parent_company_id integer,company_name text) AS
$BODY$
declare

BEGIN
    return query
        WITH RECURSIVE subordinates(id,parent_company_id,company_name) AS (
            select c.id,c.parent_company_id,c.company_name
            from flow.company c
            where c.id = p_company_id
            UNION
            select c.id,c.parent_company_id,c.company_name
            from flow.company c
                     INNER JOIN subordinates s ON s.parent_company_id = c.id
        ) SELECT
              s1.id,s1.parent_company_id,s1.company_name::text
        FROM
            subordinates s1
       where case when p_include_top is true then 1=1 else s1.parent_company_id is not null end;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

