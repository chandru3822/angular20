-- DROP FUNCTION flow.search_contacts(character varying, integer, boolean, boolean, integer, integer, integer);
CREATE OR REPLACE FUNCTION flow.search_contacts_with_down_line(p_searchterm character varying, p_company_id integer,
                                                                p_is_parent boolean, p_userid integer,
                                                                p_limit integer, p_offset integer)
  RETURNS TABLE
          (
            id               integer,
            first_name       character varying,
            last_name        character varying,
            full_name        text,
            email            character varying,
            phone            character varying,
            mobile           character varying,
            company_id       integer,
            contact_type_id  integer,
            contact_type     character varying,
            company_state_id integer,
            state            character varying,
            abbreviation     character varying,
            latitude         double precision,
            longitude        double precision,
            date_created     timestamp,
            owner            jsonb
          )
  LANGUAGE plpgsql
AS
$function$
DECLARE
  v_clean_name_search_term    VARCHAR;
  v_clean_phone_search_term   VARCHAR;
  v_clean_email_search_term   VARCHAR;
  v_clean_address_search_term VARCHAR;
  v_company_ids               INTEGER[];
  v_clean_id_search_term      varchar;
  v_org_ids                   integer[];
BEGIN
  v_clean_name_search_term = lower(trim(translate(p_searchterm, '*,.&', '')));
  v_clean_phone_search_term = right(trim(translate(p_searchterm, '+-(). ', '')), 10);
  v_clean_email_search_term = lower(trim(p_searchterm));
  v_clean_address_search_term = trim(lower(translate(p_searchterm, '.,', '')));
  v_clean_id_search_term = trim(p_searchterm);
  if p_is_parent then
    select array(select f.id from flow.company_hierarchy_filter_down(p_company_id) f)
    into v_company_ids;
  else
    select array(select p_company_id)
    into v_company_ids;
  end if;

  select array_agg(org_id)
  into v_org_ids
  from flow.user_position
  where user_id = p_userid;

  case
    when p_searchterm is not null then
      RETURN QUERY
      SELECT limited_contacts.id,
             limited_contacts.first_name,
             limited_contacts.last_name,
             limited_contacts.full_name,
             limited_contacts.email,
             limited_contacts.phone,
             limited_contacts.mobile,
             limited_contacts.company_id,
             limited_contacts.contact_type_id,
             limited_contacts.contact_type,
             limited_contacts.company_state_id,
             limited_contacts.state,
             limited_contacts.abbreviation,
             limited_contacts.latitude,
             limited_contacts.longitude,
             limited_contacts.date_created,
             limited_contacts.owner
      FROM (SELECT c.id,
                   c.first_name,
                   c.last_name,
                   concat(c.first_name, ' ', c.last_name) as full_name,
                   c.email,
                   c.phone,
                   c.mobile,
                   c.company_id,
                   c.contact_type_id,
                   ct.contact_type,
                   c.company_state_id,
                   s.state,
                   s.abbreviation,
                   c.latitude,
                   c.longitude,
                   c.date_created,
                   (select json_build_object(
                             'userId', u.id,
                             'firstName', u.first_name,
                             'lastName', u.last_name,
                             'fullName', concat(u.first_name, ' ', u.last_name)
                             ))::jsonb                    as owner
            FROM flow.contact c
                   inner join flow.contact_type ct on ct.id = c.contact_type_id
                   left join flow.company_state cs on cs.id = c.company_state_id
                   left join flow.state s on s.id = cs.state_id
                   left join flow.user_position up on up.id = c.owner_user_position_id
                   left join flow."user" u on u.id = up.user_id
            WHERE c.company_id = ANY (v_company_ids)
              and c.date_created is not null
              and c.archived is not true
              and (c.owner_org_ids && v_org_ids)
              and case
                    when p_searchterm is not null then
                      ((c.id::text like '%' || v_clean_name_search_term || '%') or
                       (c.contact_full_name_search like '%' || v_clean_name_search_term || '%') or
                       (c.contact_street_search like '%' || v_clean_address_search_term || '%') or
                       (c.contact_email_search like '%' || v_clean_email_search_term || '%') or
                       (c.contact_mobile_search like '%' || v_clean_phone_search_term || '%') or
                       (c.contact_phone_search like '%' || v_clean_phone_search_term || '%'))
              end
            order by c.date_created desc
            limit p_limit offset p_offset) as limited_contacts;
    else
      RETURN QUERY
      SELECT limited_contacts.id,
             limited_contacts.first_name,
             limited_contacts.last_name,
             limited_contacts.full_name,
             limited_contacts.email,
             limited_contacts.phone,
             limited_contacts.mobile,
             limited_contacts.company_id,
             limited_contacts.contact_type_id,
             limited_contacts.contact_type,
             limited_contacts.company_state_id,
             limited_contacts.state,
             limited_contacts.abbreviation,
             limited_contacts.latitude,
             limited_contacts.longitude,
             limited_contacts.date_created,
             limited_contacts.owner
      FROM (SELECT c.id,
                   c.first_name,
                   c.last_name,
                   concat(c.first_name, ' ', c.last_name) as full_name,
                   c.email,
                   c.phone,
                   c.mobile,
                   c.company_id,
                   c.contact_type_id,
                   ct.contact_type,
                   c.company_state_id,
                   s.state,
                   s.abbreviation,
                   c.latitude,
                   c.longitude,
                   c.date_created,
                   (select json_build_object(
                             'userId', u.id,
                             'firstName', u.first_name,
                             'lastName', u.last_name,
                             'fullName', concat(u.first_name, ' ', u.last_name)
                             ))::jsonb                    as owner
            FROM flow.contact c
                   inner join flow.contact_type ct on ct.id = c.contact_type_id
                   left join flow.company_state cs on cs.id = c.company_state_id
                   left join flow.state s on s.id = cs.state_id
                   left join flow.user_position up on up.id = c.owner_user_position_id
                   left join flow."user" u on u.id = up.user_id
            WHERE c.company_id = ANY (v_company_ids)
              and c.date_created is not null
              and c.archived is not true
              and (c.owner_org_ids && v_org_ids)
            order by c.date_created desc
            limit p_limit offset p_offset) as limited_contacts;
    end case;
END;
$function$
