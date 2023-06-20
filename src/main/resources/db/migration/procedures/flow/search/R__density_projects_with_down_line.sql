drop function if exists flow.density_projects_with_down_line(p_company_id bigint,
                                                             p_user_id bigint, p_is_parent boolean,
                                                             p_company_project_status_type_ids bigint[],
                                                             p_upper_bound_latitude numeric,
                                                             p_upper_bound_longitude numeric,
                                                             p_lower_bound_latitude numeric,
                                                             p_lower_bound_longitude numeric
);
create or replace function flow.density_projects_with_down_line(p_company_id bigint,
                                                               p_user_id bigint, p_is_parent boolean,
                                                               p_company_project_status_type_ids bigint[],
                                                                p_upper_bound_latitude numeric,
                                                                p_upper_bound_longitude numeric,
                                                                p_lower_bound_latitude numeric,
                                                                p_lower_bound_longitude numeric
                                                                )
  returns TABLE
          (
            id                             bigint,
            project_name                   character varying,
            contact_id                     bigint,
            date_created                   timestamp without time zone,
            street1                        character varying,
            street2                        character varying,
            city                           character varying,
            state                          character varying,
            state_abbreviation             character varying,
            postalcode                     character varying,
            latitude                       double precision,
            longitude                      double precision,
            company_project_status_type_id bigint,
            project_status_type            character varying
          )
  language plpgsql
as
$$
DECLARE
  v_company_ids               bigint[];
  v_org_ids                   bigint[];
  v_position_ids              bigint[];
BEGIN

  if p_is_parent then
    select array(select f.id from flow.company_hierarchy_filter_down(p_company_id) f)
    into v_company_ids;
  else
    select array(select p_company_id)
    into v_company_ids;
  end if;
  select array_agg(up.org_id)
  into v_org_ids
  from flow.user_position up
  where user_id = p_user_id
    and up.start_date <= now()
    and (up.end_date is null or up.end_date >= now());
  select array_agg(up.id)
  into v_position_ids
  from flow.user_position up
  where user_id = p_user_id;
      return query
      SELECT limited_projects.id::bigint,
                limited_projects.project_name,
                limited_projects.contact_id::bigint,
                limited_projects.date_created,
                limited_projects.street1,
                limited_projects.street2,
                limited_projects.city,
                limited_projects.state,
                limited_projects.state_abbreviation,
                limited_projects."postalCode",
                limited_projects.latitude,
                limited_projects.longitude,
                limited_projects.company_project_status_type_id::bigint,
                limited_projects.project_status_type
         FROM (select p.id::bigint,
                      p.project_name,
                      p.contact_id::bigint,
                      p.date_created,
                      p.street1,
                      p.street2,
                      p.city,
                      s.state,
                      s.abbreviation                           as state_abbreviation,
                      p.postal_code                            as "postalCode",
                      p.latitude,
                      p.longitude,
                      p.company_project_status_type_id::bigint,
                      cpst.project_status_type
               from flow.project p
                      inner join flow.company_project_status_type cpst
                                 on cpst.id = p.company_project_status_type_id
                      inner join flow.contact c on c.id = p.contact_id
                      left join flow.company_state cs on cs.id = p.company_state_id
                      left join flow.state s on s.id = cs.state_id
               where c.company_id = any (v_company_ids)
                 and p.archived is not true
                 and (c.owner_org_ids::bigint[] && v_org_ids or c.owner_position_ids::bigint[] && v_position_ids)
                 and case when array_length(p_company_project_status_type_ids, 1) > 0 then p.company_project_status_type_id  = any(  p_company_project_status_type_ids ) else 1=1 end
                 and st_makepoint(p.longitude, p.latitude)
                 && ST_MakeEnvelope (
                       p_upper_bound_longitude, p_upper_bound_latitude,
                       p_lower_bound_longitude, p_lower_bound_latitude,
                       4326)
               ) as limited_projects;
END ;
$$;
