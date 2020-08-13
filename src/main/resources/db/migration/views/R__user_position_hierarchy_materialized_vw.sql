DROP MATERIALIZED VIEW if EXISTS flow.user_position_hierarchy_materialized_vw;
CREATE MATERIALIZED VIEW flow.user_position_hierarchy_materialized_vw AS
select up.user_id,
       up.org_id,
       up.id  as user_position_id,
       up.position_id,
       (select json_agg(json_build_object(
                                'orgId', h.org_id,
                                'orgName', h.org_name,
                                'positionLevel', h.position_level,
                                'parentOrgId', h.parent_org_id,
                                'orgLevelId', h.org_level_id,
                                'level', h.level
                            ) order by h.org_level_id)::jsonb
        from flow.user_org_hierarchy(up.org_id) as h) as hierarchy
from flow.user_position up
WITH DATA;


CREATE INDEX uphmv_user_position_id_idx
    ON flow.user_position_hierarchy_materialized_vw (user_position_id);

CREATE INDEX uphmv_user_id_idx
    ON flow.user_position_hierarchy_materialized_vw (user_id);

CREATE INDEX uphmv_position_id_idx
    ON flow.user_position_hierarchy_materialized_vw (position_id);

CREATE INDEX uphmv_org_id_idx
    ON flow.user_position_hierarchy_materialized_vw (org_id);
