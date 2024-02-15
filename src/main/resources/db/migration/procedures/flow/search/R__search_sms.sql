DROP FUNCTION IF EXISTS flow.search_contacts(p_searchterm character varying, p_company_id bigint,
                                             p_is_parent boolean,
                                             p_limit bigint, p_offset bigint);

CREATE OR REPLACE FUNCTION flow.search_sms(p_searchterm character varying,
                                               p_sms_team_id bigint[],
                                                p_owner_ids bigint[],
                                                p_unassigned boolean,
                                                p_show_in_box boolean)
  RETURNS TABLE
          (
            id               bigint,
            first_name       character varying,
            last_name        character varying,
            full_name        text,
            email            character varying,
            phone            character varying,
            mobile           character varying,
            company_id       bigint,
            contact_type_id  bigint,
            contact_type     character varying,
            company_state_id bigint,
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
  v_clean_id_search_term      varchar;
BEGIN
  v_clean_name_search_term = lower(trim(translate(p_searchterm, '*,.&', '')));
  v_clean_id_search_term = trim(p_searchterm);

  case
    when p_searchterm is not null and p_searchterm != '' then
      RETURN QUERY
        with projects as (select distinct on (p.id) p.id                                   as project_id,
                                                    p.contact_id,
                                                    p.project_name,
                                                    c.search_phones                        as mobile,
                                                    s.abbreviation                         as state,
                                                    concat(u.first_name, ' ', u.last_name) as "name"
                          from flow.project p
                                 inner join flow.contact c ON c.id = p.contact_id
                                 left outer join flow.company_state cs on p.company_state_id = cs.id
                                 left outer join flow.state s ON s.id = cs.state_id
                                 inner join flow.project_message_properties pmp on pmp.project_id = p.id
                                 left join flow.project_message_team pmt on pmt.project_id = p.id and pmt.archived is false
                                 left join flow.project_message_owner pmo2
                                           on pmo2.sms_team_id = pmt.sms_team_id and pmo2.project_id = p.id and pmo2.archived is false
                                 left join flow.user u on pmo2.user_id = u.id
                          where
                                    (p.project_name_search like '%' || :v_clean_name_search_term || '%') or
                                    (p.id::text like '%' || v_clean_name_search_term || '%')  or
                                    (u.user_full_name_search like '%' || :v_clean_name_search_term || '%')

                            and case when array_length(p_sms_team_id,1) > 0 then
                                       pmo2.user_id = any ( array [ :ownerIds ]::bigint[]  and
                                        pmo2.sms_team_id = any (array [ :smsTeamIds ]::bigint[])

                                    (pmt.sms_team_id = any (array [ :smsTeamIds ]::bigint[]) and
                                 (exists(select id
                                         from flow.project_message_owner pmo3
                                         where case
                                                 when array_length( array [ :ownerIds ]::bigint[], 1) > 0 then
                                                   (pmo3.user_id = any ( array [ :ownerIds ]::bigint[] )) and
                                                   pmo3.sms_team_id = any (array [ :smsTeamIds ]::bigint[])
                                                     and pmo3.project_id = p.id and pmo3.archived is false
                                                 end) or
                                  case
                                    when :unassigned is true then
                                      pmo2.id is null end)
                            )
        ),







      SELECT limited_contacts.id::bigint,
             limited_contacts.first_name,
             limited_contacts.last_name,
             limited_contacts.full_name,
             limited_contacts.email,
             limited_contacts.phone,
             limited_contacts.mobile,
             limited_contacts.company_id::bigint,
             limited_contacts.contact_type_id::bigint,
             limited_contacts.contact_type,
             limited_contacts.company_state_id::bigint,
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
              and ((c.id::text like '%' || v_clean_name_search_term || '%')
              or (c.contact_full_name_search like '%' || v_clean_name_search_term || '%')
              or (c.contact_street_search like '%' || v_clean_address_search_term || '%')
              or (c.contact_email_search like '%' || v_clean_email_search_term || '%')
              or (c.contact_mobile_search like '%' || v_clean_phone_search_term || '%')
              or (c.contact_phone_search like '%' || v_clean_phone_search_term || '%'))
            order by c.date_created desc
            limit p_limit offset p_offset) as limited_contacts;
    else RETURN QUERY
      SELECT limited_contacts.id::bigint,
             limited_contacts.first_name,
             limited_contacts.last_name,
             limited_contacts.full_name,
             limited_contacts.email,
             limited_contacts.phone,
             limited_contacts.mobile,
             limited_contacts.company_id::bigint,
             limited_contacts.contact_type_id::bigint,
             limited_contacts.contact_type,
             limited_contacts.company_state_id::bigint,
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
            order by c.date_created desc
            limit p_limit offset p_offset) as limited_contacts;

    end case;
END;
$function$
