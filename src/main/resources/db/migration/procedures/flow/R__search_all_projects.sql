-- drop function if exists flow.search_all_projects(character varying, integer, boolean, integer, integer, integer, character varying, character varying);
CREATE OR REPLACE FUNCTION flow.search_all_projects(p_searchterm character varying, p_company_id integer,
                                                    p_is_parent boolean,
                                                    p_limit integer default null, p_offset integer default null,
                                                    p_company_project_status_type_id integer default null,
                                                    p_sort_column character varying default null,
                                                    p_sort_direction character varying default null)
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
                latitude                       double precision,
                longitude                      double precision,
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
    v_company_ids               INTEGER[];
BEGIN
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
                   limited_projects.latitude,
                   limited_projects.longitude,
                   limited_projects.status_type_id,
                   limited_projects.company_project_status_type_id,
                   limited_projects.status_type,
                   limited_projects.project_status_type,
                   limited_projects.process_name,
                   limited_projects.contact
            FROM (
                     select p.id,
                            p.project_name,
                            p.contact_id,
                            p.date_created,
                            p.street1,
                            p.street2,
                            p.city,
                            s.state,
                            s.abbreviation   as state_abbreviation,
                            p.postal_code    as "postalCode",
                            p.latitude,
                            p.longitude,
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
                       and case when p_company_project_status_type_id is not null then
                            cpst.id = p_company_project_status_type_id
                            else 1=1 end
                     ORDER BY (case when p_sort_column is null OR p_sort_direction is null then p.date_created end) desc,
                              (case when lower(p_sort_column) = 'project_name' and lower(p_sort_direction) = 'asc' then p.project_name end) asc nulls last,
                              (case when lower(p_sort_column) = 'project_name' and lower(p_sort_direction) = 'desc' then p.project_name end) desc nulls last,
                              (case when lower(p_sort_column) = 'date_created' and lower(p_sort_direction) = 'asc' then p.date_created end) asc,
                              (case when lower(p_sort_column) = 'date_created' and lower(p_sort_direction) = 'desc' then p.date_created end) desc
                     limit p_limit offset p_offset
                 ) as limited_projects;
        else
          p_searchterm = lower(trim(translate(p_searchterm, '*,.& ', '')))||':*';
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
                       limited_projects.latitude,
                       limited_projects.longitude,
                       limited_projects.status_type_id,
                       limited_projects.company_project_status_type_id,
                       limited_projects.status_type,
                       limited_projects.project_status_type,
                       limited_projects.process_name,
                       limited_projects.contact
                FROM (
                       with search as (
                              select p.id,
                                     ts_rank(p.search_ts, to_tsquery('english', p_searchterm)) as rank
                              from flow.project p
                                     inner join flow.contact c on p.contact_id = c.id
                              where c.company_id = any (v_company_ids)
                                and p.search_ts @@ to_tsquery('english', p_searchterm)
                                and p.archived is false
                                and case
                                      when p_company_project_status_type_id is not null then
                                          p.company_project_status_type_id = p_company_project_status_type_id
                                      else 1 = 1 end
                              union
                              select p.id,
                                     ts_rank(c.search_ts, to_tsquery('english', p_searchterm)) as rank
                              from flow.project p
                                     inner join flow.contact c on p.contact_id = c.id
                              where c.company_id = any (v_company_ids)
                                and c.search_ts @@ to_tsquery('english', p_searchterm)
                                and c.archived is false
                                and case
                                      when p_company_project_status_type_id is not null then
                                          p.company_project_status_type_id = p_company_project_status_type_id
                                      else 1 = 1 end
                              order by rank desc
                              limit 100),
                            limited as (
                              select distinct s.id
                              from search s
                            )
                         select p.id,
                                p.project_name,
                                p.contact_id,
                                p.date_created,
                                p.street1,
                                p.street2,
                                p.city,
                                s.state,
                                s.abbreviation   as state_abbreviation,
                                p.postal_code    as "postalCode",
                                p.latitude,
                                p.longitude,
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
                         from limited l
                                  inner join flow.project p on p.id = l.id
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
                           and case when p_company_project_status_type_id is not null then
                                            cpst.id = p_company_project_status_type_id
                                    else 1=1 end
                         ORDER BY (case when p_sort_column is null OR p_sort_direction is null then p.date_created end) desc,
                                  (case when lower(p_sort_column) = 'project_name' and lower(p_sort_direction) = 'asc' then p.project_name end) asc nulls last,
                                  (case when lower(p_sort_column) = 'project_name' and lower(p_sort_direction) = 'desc' then p.project_name end) desc nulls last,
                                  (case when lower(p_sort_column) = 'date_created' and lower(p_sort_direction) = 'asc' then p.date_created end) asc,
                                  (case when lower(p_sort_column) = 'date_created' and lower(p_sort_direction) = 'desc' then p.date_created end) desc
                         limit p_limit offset p_offset
                     ) as limited_projects;
        end case;
END;
$function$
