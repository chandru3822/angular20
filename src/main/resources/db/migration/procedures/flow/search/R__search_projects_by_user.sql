create or replace function flow.search_projects_by_user(p_searchterm character varying, p_company_id integer,
                                                         p_user_id integer, p_is_parent boolean,
                                                         p_limit integer DEFAULT NULL::integer,
                                                         p_offset integer DEFAULT NULL::integer,
                                                         p_company_project_status_type_id integer DEFAULT NULL::integer,
                                                         p_sort_column character varying DEFAULT NULL::character varying,
                                                         p_sort_direction character varying DEFAULT NULL::character varying)
  returns TABLE
          (
            id                             integer,
            project_name                   character varying,
            contact_id                     integer,
            date_created                   timestamp without time zone,
            street1                        character varying,
            street2                        character varying,
            city                           character varying,
            state                          character varying,
            state_abbreviation             character varying,
            postalcode                     character varying,
            latitude                       double precision,
            longitude                      double precision,
            company_project_status_type_id integer,
            project_status_type            character varying,
            contact                        jsonb
          )
  language plpgsql
as
$$
DECLARE
  v_clean_name_search_term    VARCHAR;
  v_clean_id_search_term      VARCHAR;
  v_clean_phone_search_term   VARCHAR;
  v_clean_email_search_term   VARCHAR;
  v_clean_address_search_term VARCHAR;
  v_company_ids               INTEGER[];
  v_position_ids              integer[];
BEGIN
  v_clean_name_search_term = lower(trim(translate(p_searchterm, '*,.& ', '')));
  v_clean_phone_search_term = right(trim(translate(p_searchterm, '+-(). ', '')), 10);
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

  select array_agg(up.id)
  into v_position_ids
  from flow.user_position up
  where user_id = p_user_id;
  case
    when p_searchterm is not null and p_searchterm != '' then
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
             limited_projects.company_project_status_type_id,
             limited_projects.project_status_type,
             limited_projects.contact
      FROM (select *
            from (select p.id,
                         p.project_name,
                         p.contact_id,
                         p.date_created,
                         p.street1,
                         p.street2,
                         p.city,
                         s.state,
                         s.abbreviation                           as state_abbreviation,
                         p.postal_code                            as "postalCode",
                         p.latitude,
                         p.longitude,
                         p.company_project_status_type_id,
                         cpst.project_status_type,
                         (select row_to_json(contact1)
                          from (select c.id,
                                       c.phone,
                                       c.mobile) contact1)::jsonb as contact
                  from flow.project p
                         inner join flow.company_project_status_type cpst
                                    on cpst.id = p.company_project_status_type_id
                         inner join flow.contact c on p.contact_id = c.id
                         left join flow.company_state cs on cs.id = p.company_state_id
                         left join flow.state s on s.id = cs.state_id
                  where c.company_id = any (v_company_ids)
                    and p.archived is not true
                    and (c.owner_position_ids && v_position_ids)
                    and
                        ((p.id::text like '%' || v_clean_name_search_term || '%')
                     or (p.project_name_search like '%' || v_clean_name_search_term || '%')
                     or (p.project_street_search like '%' || v_clean_address_search_term || '%'))
                    and case
                          when p_company_project_status_type_id is not null then
                            cpst.id = p_company_project_status_type_id
                          else 1 = 1 end
                  union
                  select p.id,
                         p.project_name,
                         p.contact_id,
                         p.date_created,
                         p.street1,
                         p.street2,
                         p.city,
                         s.state,
                         s.abbreviation                           as state_abbreviation,
                         p.postal_code                            as "postalCode",
                         p.latitude,
                         p.longitude,
                         p.company_project_status_type_id,
                         cpst.project_status_type,
                         (select row_to_json(contact1)
                          from (select c.id,
                                       c.phone,
                                       c.mobile) contact1)::jsonb as contact
                  from flow.project p
                         inner join flow.company_project_status_type cpst
                                    on cpst.id = p.company_project_status_type_id
                         inner join flow.contact c on p.contact_id = c.id
                         left join flow.company_state cs on cs.id = p.company_state_id
                         left join flow.state s on s.id = cs.state_id
                  where c.company_id = any (v_company_ids)
                    and p.archived is not true
                    and (c.owner_position_ids && v_position_ids)
                    and
                        ((c.contact_email_search like '%' || v_clean_email_search_term || '%')
                     or (c.contact_mobile_search like '%' || v_clean_phone_search_term || '%')
                     or (c.contact_phone_search like '%' || v_clean_phone_search_term || '%'))
                    and case
                          when p_company_project_status_type_id is not null then
                            cpst.id = p_company_project_status_type_id
                          else 1 = 1 end) as foo
            ORDER BY (case when p_sort_column is null OR p_sort_direction is null then foo.date_created end) desc,
                     (case
                        when lower(p_sort_column) = 'project_name' and lower(p_sort_direction) = 'asc'
                          then foo.project_name end) asc nulls last,
                     (case
                        when lower(p_sort_column) = 'project_name' and lower(p_sort_direction) = 'desc'
                          then foo.project_name end) desc nulls last,
                     (case
                        when lower(p_sort_column) = 'date_created' and lower(p_sort_direction) = 'asc'
                          then foo.date_created end) asc,
                     (case
                        when lower(p_sort_column) = 'date_created' and lower(p_sort_direction) = 'desc'
                          then foo.date_created end) desc
            limit p_limit offset p_offset) as limited_projects;
    else
      return query
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
                limited_projects.company_project_status_type_id,
                limited_projects.project_status_type,
                limited_projects.contact
         FROM (select p.id,
                      p.project_name,
                      p.contact_id,
                      p.date_created,
                      p.street1,
                      p.street2,
                      p.city,
                      s.state,
                      s.abbreviation                           as state_abbreviation,
                      p.postal_code                            as "postalCode",
                      p.latitude,
                      p.longitude,
                      p.company_project_status_type_id,
                      cpst.project_status_type,
                      (select row_to_json(contact1)
                       from (select c.id,
                                    c.phone,
                                    c.mobile) contact1)::jsonb as contact
               from flow.project p
                      inner join flow.company_project_status_type cpst
                                 on cpst.id = p.company_project_status_type_id
                      inner join flow.contact c on p.contact_id = c.id
                      left join flow.company_state cs on cs.id = p.company_state_id
                      left join flow.state s on s.id = cs.state_id
               where c.company_id = any (v_company_ids)
                 and p.archived is not true
                 and (c.owner_position_ids && v_position_ids)
                 and
                     case
                       when p_company_project_status_type_id is not null then
                         cpst.id = p_company_project_status_type_id
                       else 1 = 1 end
               ORDER BY (case when p_sort_column is null OR p_sort_direction is null then p.date_created end) desc,
                        (case
                           when lower(p_sort_column) = 'project_name' and lower(p_sort_direction) = 'asc'
                             then p.project_name end) asc nulls last,
                        (case
                           when lower(p_sort_column) = 'project_name' and lower(p_sort_direction) = 'desc'
                             then p.project_name end) desc nulls last,
                        (case
                           when lower(p_sort_column) = 'date_created' and lower(p_sort_direction) = 'asc'
                             then p.date_created end) asc,
                        (case
                           when lower(p_sort_column) = 'date_created' and lower(p_sort_direction) = 'desc'
                             then p.date_created end) desc
               limit p_limit offset p_offset) as limited_projects;
    end case;

END;
$$;
