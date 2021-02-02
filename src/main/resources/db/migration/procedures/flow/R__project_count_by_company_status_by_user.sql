CREATE OR REPLACE FUNCTION flow.project_count_by_company_status_by_user( p_company_id integer,
                                                               p_user_id integer,
                                                               p_is_down_line boolean)
    RETURNS TABLE
            (
                company_project_status_type_id integer,
                company_project_status         character varying,
                project_status_count           bigint
            )
    LANGUAGE plpgsql
AS
$function$

BEGIN

    case when p_is_down_line is true  then
        RETURN QUERY
            SELECT limited_projects.company_project_status_type_id,
                   limited_projects.company_project_status,
                   limited_projects.project_status_count
            FROM (
                     with project_ids as (
                         with positions as (
                             select up.org_id as parent_org_id,up.user_id as user_id
                             from flow.user_position up
                             where up.primary_flag is true
                               and up.archived is not true
                               and user_id = p_user_id
                         ),
                              org_ids as (
                                  select t.id
                                  from positions p
                                           join lateral flow.org_hierarchy_filter_down_search(array [p.parent_org_id]) as t
                                                on true),
                         all_positions as(
                                select array_agg(up4.id) as user_position_ids
                                from flow.user_position up4
                                inner join positions p4 on p4.user_id = up4.user_id
                             )
                         select array_agg(project_ids) as project_ids
                         from (
                         select distinct p.id as project_ids
                         from org_ids o
                                  inner join flow.user_position up2 on up2.org_id = o.id
                                inner join flow.project p on p.user_position_id = up2.id
                         where p.archived is not true
                         union
                         select distinct p.id as project_ids
                         from org_ids o
                                  inner join flow.user_position up2 on up2.org_id = o.id
                                  inner join flow.contact c on c.owner_user_position_id = up2.id
                                  inner join flow.project p on p.contact_id = c.id
                         where p.archived is not true
                         union
                         select  distinct p3.id as project_ids
                         from all_positions p5
                                  inner join flow.contact c on c.owner_user_position_id = any(p5.user_position_ids)
                                  inner join flow.project p3 on p3.contact_id = c.id
                         where p3.archived is not true

                        union
                            select  distinct p3.id as project_ids
                             from all_positions p5
                              inner join flow.project p3 on p3.user_position_id = any(p5.user_position_ids)
                            where p3.archived is not true
                             )as foo),
                    counts as (
                        select cpst.id as company_project_status_type_id,
                               cpst.project_status_type as company_project_status,
                               count(p.id) as project_status_count,
                               cpst.display_order
                        from flow.company_project_status_type cpst
                                 inner join flow.project p
                                            on cpst.id = p.company_project_status_type_id
                                                and  p.archived is not true
                                 inner join project_ids pi on p.id = any (pi.project_ids)
                                 inner join flow.company_process cp on cp.id = p.company_process_id
                            and cp.company_id = p_company_id
                        where cpst.company_id = p_company_id
                              and cpst.archived is false
                        group by cpst.id,cpst.project_status_type
                    )
                     select c.company_project_status_type_id,
                                     c.company_project_status,
                                     c.project_status_count,
                            c.display_order
                     from counts c
                     union
                     select  cpst.id as company_project_status_type_id,
                                     cpst.project_status_type  company_project_status,
                                     0 as project_status_count,
                                    cpst.display_order
                     from flow.company_project_status_type cpst
                     where cpst.company_id = p_company_id
                       and cpst.archived is false
                       and not exists (select c2.company_project_status_type_id from counts c2
                                       where c2.company_project_status_type_id = cpst.id)
                order by 4
                 ) as limited_projects;

        else
            RETURN QUERY
                SELECT limited_projects.company_project_status_type_id,
                       limited_projects.company_project_status,
                       limited_projects.project_status_count
                FROM (
                         with user_position_ids as (
                             select array_agg(up.id) as user_position_ids
                             from flow.user_position up
                             where user_id = p_user_id
                         ),
                              project_ids as (
                                  select array_agg(project_ids) as project_ids
                                  from (
                                           select p.id as project_ids
                                           from flow.project p
                                                    inner join user_position_ids upi on p.user_position_id = any (user_position_ids)
                                           where p.archived is not true
                                           union
                                           select p2.id as project_ids
                                           from flow.contact c
                                                    inner join flow.project p2 on p2.contact_id = c.id
                                                    inner join user_position_ids upi
                                                               on c.owner_user_position_id = any (user_position_ids)
                                           where p2.archived is not true
                                       ) as foo),
                              counts as (
                                  select cpst.id as company_project_status_type_id,
                                         cpst.project_status_type as company_project_status,
                                         count(p.id) as project_status_count,
                                         cpst.display_order
                                  from flow.company_project_status_type cpst
                                           inner join flow.project p on cpst.id = p.company_project_status_type_id
                                      and  p.archived is not true
                                           inner join project_ids pi on p.id = any (pi.project_ids)
                                           inner join flow.company_process cp on cp.id = p.company_process_id
                                      and cp.company_id = p_company_id
                                  where cpst.company_id = p_company_id
                                    and cpst.archived is false
                                  group by cpst.id,cpst.project_status_type
                              )
                         select c.company_project_status_type_id,
                            c.company_project_status,
                            c.project_status_count,
                            c.display_order
                         from counts c
                        union
                         select cpst.id as company_project_status_type_id,
                                cpst.project_status_type  company_project_status,
                                0 as project_status_count,
                                cpst.display_order
                         from flow.company_project_status_type cpst
                         where cpst.company_id = p_company_id
                           and cpst.archived is false
                        and not exists (select c2.company_project_status_type_id from counts c2
                                                where c2.company_project_status_type_id = cpst.id)
                        order by display_order
                     ) as limited_projects;
        end case;
END;
$function$
