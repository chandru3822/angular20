-- DROP FUNCTION IF EXISTS flow.user_org_hierarchy(bigint) cascade;
-- dont forget to add flow.user_positions_vw back after dropping this function
drop function if exists flow.org_hierarchy_filter_up_search(p_org_ids bigint[]);
CREATE OR REPLACE FUNCTION flow.org_hierarchy_filter_up_search(p_org_ids bigint[])
  RETURNS TABLE
          (
            id            bigint,
            parent_org_id bigint,
            org_name      text,
            org_level_id  bigint,
            active_flag   boolean,
            org_type_id   bigint,
            org_type      text
          )
AS
$BODY$
declare

BEGIN
  return query
    WITH RECURSIVE subordinates(id, parent_org_id, org_name, org_level_id, active_flag, org_type_id, org_type)
                     AS (select o.id,
                                o.parent_org_id,
                                o.org_name,
                                ot.org_level_id,
                                o.active_flag,
                                o.org_type_id,
                                ot.org_type
                         from flow.org o
                                inner join flow.org_type ot on ot.id = o.org_type_id
                         where o.id = any (p_org_ids)
                         UNION
                         select o.id,
                                o.parent_org_id,
                                o.org_name,
                                ot.org_level_id,
                                o.active_flag,
                                o.org_type_id,
                                ot.org_type
                         from flow.org o
                                inner join flow.org_type ot on ot.id = o.org_type_id
                                INNER JOIN subordinates s ON s.parent_org_id = o.id)
    SELECT s1.id::bigint,
           s1.parent_org_id::bigint,
           s1.org_name::text,
           s1.org_level_id::bigint,
           s1.active_flag,
           s1.org_type_id::bigint,
           s1.org_type::text
    FROM subordinates s1;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;

