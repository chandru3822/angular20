CREATE OR REPLACE FUNCTION flow.search_projects_with_down_line(p_searchterm character varying, p_company_id integer,
                                                               p_user_id integer,
                                                               p_is_parent boolean,
                                                               p_limit integer,
                                                               p_offset integer,
                                                               p_company_project_status_type_id integer default null)
    RETURNS TABLE
            (
                id                             integer,
                project_name                   character varying,
                contact_id                     integer,
                date_created                   timestamp,
                street1                        character varying,
                street2                        character varying,
                city                           character varying,
                state                          character varying,
                state_abbreviation             character varying,
                postalCode                     character varying,
                status_type_id                 integer,
                company_project_status_type_id integer,
                status_type                    character varying,
                project_status_type            character varying,
                process_name                   character varying,
                contact                        jsonb
            )
    LANGUAGE plpgsql
AS
$function$
DECLARE
    v_clean_name_search_term    VARCHAR;
    v_clean_phone_search_term   VARCHAR;
    v_clean_email_search_term   VARCHAR;
    v_clean_id_search_term   VARCHAR;
    v_clean_address_search_term VARCHAR;
    v_company_ids               INTEGER[];
BEGIN
    v_clean_name_search_term = lower(trim(translate(p_searchterm, '*,.& ', '')));
    v_clean_phone_search_term = trim(translate(p_searchterm, '-(). ', ''));
    v_clean_email_search_term = lower(trim(p_searchterm));
    v_clean_id_search_term = trim(p_searchterm);
    v_clean_address_search_term = trim(lower(translate(p_searchterm, '.,', '')));
    if p_is_parent then
        select array(select f.id from flow.company_hierarchy_filter_down(p_company_id) f)
        into v_company_ids;
    else
        select array(select p_company_id)
        into v_company_ids;
    end if;
    case when p_searchterm is null or p_searchterm = '' then
        RETURN QUERY
            SELECT limited_projects.id,
                   limited_projects.project_name,
                   limited_projects.contact_id,
                   limited_projects.date_created,
                   limited_projects.street1,
                   limited_projects.street2,
                   limited_projects.city,
                   limited_projects.state,
                   limited_projects.state_abbreviation,
                   limited_projects."postalCode",
                   limited_projects.status_type_id,
                   limited_projects.company_project_status_type_id,
                   limited_projects.status_type,
                   limited_projects.project_status_type,
                   limited_projects.process_name,
                   limited_projects.contact
            FROM (
                     with project_ids as (
                         with positions as (
                             select up.org_id as parent_org_id,up.user_id as user_id
                             from flow.user_position up
                             where up.primary_flag is true
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
                             )as foo)
                     select p.id,
                            p.project_name,
                            p.contact_id,
                            p.date_created,
                            p.street1,
                            p.street2,
                            p.city,
                            s.state,
                            s.abbreviation           as state_abbreviation,
                            p.postal_code            as "postalCode",
                            cp.status_type_id,
                            st.status_type,
                            p.company_project_status_type_id,
                            cpst.project_status_type,
                            pr.process_name,
                            (select row_to_json(contact1)
                             from (
                                      select c.id,
                                             c.phone,
                                             c.mobile
                                  ) contact1)::jsonb as contact
                     from flow.project p
                              inner join project_ids pi on p.id = any (pi.project_ids)
                              inner join flow.company_process cp on cp.id = p.company_process_id
                              inner join flow.process pr on pr.id = cp.process_id
                              inner join flow.status_type st on st.id = cp.status_type_id
                              inner join flow.company_project_status_type cpst
                                         on cpst.id = p.company_project_status_type_id
                              inner join flow.contact c on c.id = p.contact_id
                              left join flow.company_state cs on cs.id = p.company_state_id
                              left join flow.state s on s.id = cs.state_id
                     where cp.company_id = any (v_company_ids)
                       and p.archived is not true
                     order by p.date_created desc
                     limit p_limit offset p_offset
                 ) as limited_projects;

        else
            RETURN QUERY
                SELECT limited_projects.id,
                       limited_projects.project_name,
                       limited_projects.contact_id,
                       limited_projects.date_created,
                       limited_projects.street1,
                       limited_projects.street2,
                       limited_projects.city,
                       limited_projects.state,
                       limited_projects.state_abbreviation,
                       limited_projects."postalCode",
                       limited_projects.status_type_id,
                       limited_projects.company_project_status_type_id,
                       limited_projects.status_type,
                       limited_projects.project_status_type,
                       limited_projects.process_name,
                       limited_projects.contact
                FROM (
                         with search_projects as (
                             SELECT p.id, 1 as rank
                             FROM flow.project p
                                      inner join flow.contact c on c.id = p.contact_id
                             WHERE c.company_id = ANY (v_company_ids)
                               and p.archived is not true
                               AND NOT v_clean_name_search_term ~ '^([0-9]+)$'
                               AND lower(translate(coalesce(p.project_name, ''), '*,.& ', '')) like
                                   '%' || v_clean_name_search_term || '%'
                             union
                             SELECT p.id, 2 as rank
                             FROM flow.project p
                                      inner join flow.contact c on c.id = p.contact_id
                             WHERE c.company_id = ANY (v_company_ids)
                               and p.archived is not true
                               AND p.id::text LIKE '%' || v_clean_id_search_term || '%'
                             union
                             SELECT p.id, 3 as rank
                             FROM flow.project p
                                      inner join flow.contact c on c.id = p.contact_id
                             WHERE c.company_id = ANY (v_company_ids)
                               and p.archived is not true
                               AND lower(trim(c.email)) LIKE '%' || v_clean_email_search_term || '%'
                             union
                             SELECT p.id, 4 as rank
                             FROM flow.project p
                                      inner join flow.contact c on c.id = p.contact_id
                             WHERE c.company_id = ANY (v_company_ids)
                                 and p.archived is not true
                                 and v_clean_phone_search_term ~ '^([0-9]+)$'
                                 and
                                   (trim(translate(c.phone, '()-+. ', '')) LIKE '%' || v_clean_phone_search_term || '%')
                                or (trim(translate(c.mobile, '()-+. ', '')) LIKE
                                    '%' || v_clean_phone_search_term || '%')
                             union
                             SELECT p.id, 5 as rank
                             FROM flow.project p
                                      inner join flow.contact c on c.id = p.contact_id
                             WHERE c.company_id = ANY (v_company_ids)
                               and p.archived is not true
                               AND lower(trim(translate(coalesce(p.street1, ''), '.,', ''))) || ' ' ||
                                   lower(trim(translate(coalesce(p.street2, ''), '.,', '')))
                                 like '%' || v_clean_address_search_term || '%'),
                              ranked_projects as (
                                  select sc.id,
                                         sum(rank),
                                         count(1)
                                  from search_projects sc
                                  group by 1
                                  order by count(1) desc, sum(rank)
                              --    limit p_limit offset p_offset
                              ),
                            project_ids as (
                         with positions as (
                             select up.org_id as parent_org_id,up.user_id as user_id
                             from flow.user_position up
                             where up.primary_flag is true
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
                         select array_agg(project_ids)as project_ids
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
                             )as foo)
                         select p.id,
                                p.project_name,
                                p.contact_id,
                                p.date_created,
                                p.street1,
                                p.street2,
                                p.city,
                                s.state,
                                s.abbreviation           as state_abbreviation,
                                p.postal_code            as "postalCode",
                                cp.status_type_id,
                                st.status_type,
                                p.company_project_status_type_id,
                                cpst.project_status_type,
                                pr.process_name,
                                (select row_to_json(contact1)
                                 from (
                                          select c.id,
                                                 c.phone,
                                                 c.mobile
                                      ) contact1)::jsonb as contact
                         from ranked_projects rp
                                  inner join flow.project p on p.id = rp.id
                                  inner join project_ids pi on p.id = any (pi.project_ids)
                                  inner join flow.company_process cp on cp.id = p.company_process_id
                                  inner join flow.process pr on pr.id = cp.process_id
                                  inner join flow.status_type st on st.id = cp.status_type_id
                                  inner join flow.company_project_status_type cpst
                                             on cpst.id = p.company_project_status_type_id
                                  inner join flow.contact c on c.id = p.contact_id
                                  left join flow.company_state cs on cs.id = p.company_state_id
                                  left join flow.state s on s.id = cs.state_id
                         where cp.company_id = any (v_company_ids)
                           and p.archived is not true
                         order by p.date_created desc
                         limit p_limit offset p_offset
                     ) as limited_projects;
        end case;
END;
$function$
