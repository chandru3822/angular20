DROP MATERIALIZED VIEW if EXISTS flow.user_positions_vw;
CREATE MATERIALIZED VIEW flow.user_positions_vw AS
select u.id as user_id,u.first_name,u.last_name,org_hierarchy.org_id,org_hierarchy.org_name,up.primary_flag,up.start_date,up.end_date,
       p.position,p.id as position_id,u.company_id,org_hierarchy.level
from flow."user" u
         inner join flow.user_position up on up.user_id = u.id
         inner join flow.position p on p.id = up.position_id
         inner join  flow.org o on o.id = up.org_id
         cross join flow.user_org_hierarchy(o.id) org_hierarchy
    WITH DATA;


