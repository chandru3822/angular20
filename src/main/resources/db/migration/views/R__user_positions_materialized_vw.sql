DROP MATERIALIZED VIEW if EXISTS flow.user_positions_materialized_vw;
CREATE MATERIALIZED VIEW flow.user_positions_materialized_vw AS
select u.id                                      as user_id,
       u.first_name,
       u.last_name,
       org_hierarchy.org_id,
       org_hierarchy.org_name,
       org_hierarchy.org_level_id,
       org_hierarchy.position_level,
       up.primary_flag,
       up.start_date,
       up.end_date,
       up.archived,
       cs.state_id,
       u.archived                                as user_archived,
       p.schedulable                             as position_schedulable,
       p.position,
       p.id                                      as position_id,
       up.id                                     as user_position_id,
       p.company_id as company_id,
       u.email,
       u.phone_number,
       p.available_to_children,
       (select  ust.id
        from flow.company_user_status cus
          inner join flow.user_status_type ust on ust.id = cus.user_status_type_id
        where ust.company_id = p.company_id
          and cus.user_id = u.id
          and cus.archived is not true) as user_status_type_id,
    (select  ust.has_access
     from flow.company_user_status cus
              inner join flow.user_status_type ust on ust.id = cus.user_status_type_id
            where ust.company_id = p.company_id
              and cus.user_id = u.id
              and cus.archived is not true) as has_access,
       p.scheduler                             as position_scheduler
from flow."user" u
         left join flow.user_position up on up.user_id = u.id
         left join flow.position p on p.id = up.position_id
         left join flow.org o on o.id = up.org_id and o.company_id = p.company_id
         left join flow.company_state cs on o.company_state_id = cs.id
         cross join flow.user_org_hierarchy(o.id) org_hierarchy
WITH DATA;


CREATE INDEX upmv_user_position_id_idx
    ON flow.user_positions_materialized_vw (user_position_id);

CREATE INDEX upmv_user_id_idx
    ON flow.user_positions_materialized_vw (user_id);

CREATE INDEX upmv_position_id_idx
    ON flow.user_positions_materialized_vw (position_id);

CREATE INDEX upmv_company_id_idx
    ON flow.user_positions_materialized_vw (company_id);

CREATE INDEX upmv_start_date_idx
    ON flow.user_positions_materialized_vw (start_date);

CREATE INDEX upmv_end_date_idx
    ON flow.user_positions_materialized_vw (end_date);
