DROP MATERIALIZED VIEW if EXISTS flow.user_positions_vw;
CREATE MATERIALIZED VIEW flow.user_positions_vw AS
select u.id as user_id,u.first_name,u.last_name,
       org_hierarchy.org_id,org_hierarchy.org_name,org_hierarchy.org_level_id,org_hierarchy.position_level,
       up.primary_flag,up.start_date,up.end_date,
       p.position,p.id as position_id, up.id as user_position_id,
       u.company_id, u.email, u.phone_number,u.user_status_type_id, ust.user_status_type,
       (select json_agg( json_build_object(
               'orgId', h.org_id,
               'orgName', h.org_name,
               'positionLevel',h.position_level,
               'orgLevelId',h.org_level_id
           )order by h.org_level_id)::jsonb
        from flow.user_org_hierarchy(o.id) as h) as hierarchy
from flow."user" u
         inner join flow.user_status_type ust on ust.id = u.user_status_type_id
         inner join flow.user_position up on up.user_id = u.id
         inner join flow.position p on p.id = up.position_id
         inner join  flow.org o on o.id = up.org_id
         cross join flow.user_org_hierarchy(o.id) org_hierarchy
    WITH DATA;


