CREATE OR REPLACE FUNCTION flow.update_user_org_user_position(p_user_ids integer[])
    RETURNS VOID AS
$BODY$
DECLARE
BEGIN

    delete from flow.user_positions_vw where user_id = any (p_user_ids);
    delete from flow.user_position_hierarchy_vw where user_id = any (p_user_ids);

    insert into flow.user_positions_vw(user_id, first_name, last_name,
                                       org_id, org_name, org_level_id, position_level,
                                       primary_flag, start_date, end_date, archived, state_id,
                                       user_archived, position_schedulable, position,
                                       position_id, user_position_id, company_id, email,
                                       phone_number, available_to_children,
                                       company_user_status_type_id, has_access)
        (select u.id                             as user_id,
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
                o.state_id,
                u.archived,
                p.schedulable,
                p.position,
                p.id,
                up.id,
                p.company_id                     as company_id,
                u.email,
                u.phone_number,
                p.available_to_children,
                (select cust.id
                 from flow.user_status_type ust
                          inner join flow.company_user_status_type cust on cust.id = ust.company_user_status_type_id
                 where cust.company_id = p.company_id
                   and ust.user_id = u.id
                   and ust.archived is not true) as company_user_status_type_id,
                (select cust.has_access
                 from flow.user_status_type ust
                          inner join flow.company_user_status_type cust on cust.id = ust.company_user_status_type_id
                 where cust.company_id = p.company_id
                   and ust.user_id = u.id
                   and ust.archived is not true) as has_access
         from flow."user" u
                  left join flow.user_position up on up.user_id = u.id
                  left join flow.position p on p.id = up.position_id
                  left join flow.org o on o.id = up.org_id and o.company_id = p.company_id
                  cross join flow.user_org_hierarchy(o.id) org_hierarchy
         where u.id = any (p_user_ids));

    insert into flow.user_position_hierarchy_vw(user_id, org_id, user_position_id, position_id, hierarchy)
        (select up.user_id,
                up.org_id,
                up.id                                          as user_position_id,
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
         where up.user_id = any (p_user_ids));
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
