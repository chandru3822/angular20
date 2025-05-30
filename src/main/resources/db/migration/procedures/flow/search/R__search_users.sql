DROP FUNCTION IF EXISTS flow.search_users(p_searchterm character varying,
                                          p_first_name character varying,
                                          p_last_name character varying,
                                          p_email character varying,
                                          p_phone character varying,
                                          p_company_id bigint,
                                          p_primary_flag boolean,
                                          p_status_ids bigint[],
                                          p_position_ids bigint[],
                                          p_org_ids bigint[],
                                          p_limit bigint,
                                          p_offset bigint,
                                          p_initials character varying);

CREATE OR REPLACE FUNCTION flow.search_users(p_searchterm character varying,
                                             p_first_name character varying,
                                             p_last_name character varying,
                                             p_email character varying,
                                             p_phone character varying,
                                             p_company_id bigint,
                                             p_primary_flag boolean,
                                             p_status_ids bigint[],
                                             p_position_ids bigint[],
                                             p_org_ids bigint[],
                                             p_limit bigint,
                                             p_offset bigint,
                                             p_initials character varying)
  RETURNS TABLE
          (
            id                  bigint,
            initials            text,
            first_name          character varying,
            last_name           character varying,
            company_id          bigint,
            full_name           text,
            email               character varying,
            primary_flag        boolean,
            start_date          date,
            end_date            date,
            "position"           character varying,
            position_id         bigint,
            user_position_id    bigint,
            phone_number        character varying,
            phone_extension     character varying,
            user_status_type_id bigint,
            user_status_type    character varying,
            has_access          boolean,
            hierarchy           jsonb
          )
  LANGUAGE plpgsql
AS
$function$
DECLARE
  v_clean_name_search_term    VARCHAR;
  v_clean_phone_search_term   VARCHAR;
  v_clean_email_search_term   VARCHAR;
  v_clean_phone_search_term1   VARCHAR;
  v_clean_email_search_term1   VARCHAR;
BEGIN
  v_clean_name_search_term = lower(trim(translate(p_searchterm, '*,.&', '')));
  v_clean_phone_search_term = right(trim(translate(p_phone, '+-(). ', '')),10);
  v_clean_email_search_term = lower(trim(p_email));
  v_clean_phone_search_term1 = right(trim(translate(p_searchterm, '+-(). ', '')),10);
  v_clean_email_search_term1 = lower(trim(p_searchterm));


      return query
    select *,(select uphv.hierarchy
      from flow.user_position_hierarchy_vw uphv
      where uphv.user_id = foo.id and uphv.position_id = foo.position_id and
      uphv.user_position_id = foo.user_position_id) as hierarchy
    from (

      select distinct upv.user_id                                       as id,
                      initials_data.text_value as initials,
                      upv.first_name,
                      upv.last_name,
                      upv.company_id,
                      concat(upv.first_name, ' ', upv.last_name)        AS full_name,
                      upv.email,
                      upv.primary_flag,
                      upv.start_date,
                      upv.end_date,
                      upv.position,
                      upv.position_id,
                      upv.user_position_id,
                      upv.phone_number,
                      upv.phone_extension,
                      upv.user_status_type_id,
                      ust.user_status_type,
                      upv.has_access
      from flow.user_positions_vw upv
             inner join flow.user_status_type ust on ust.id = upv.user_status_type_id
             LEFT JOIN (
                 SELECT DISTINCT ON (ucfv.user_id) ucfv.user_id, ucfv.text_value
                 FROM flow.user_custom_field_value ucfv
                 JOIN flow.custom_field_group_assignment cfga ON cfga.id = ucfv.custom_field_group_assignment_id
                 JOIN flow.custom_field cf ON cf.id = cfga.custom_field_id
                 WHERE cf.field_name = 'Initials'
             ) AS initials_data ON initials_data.user_id = upv.user_id
      where upv.company_id = p_company_id
        and upv.archived is false
         and (
                       (TRIM(p_initials) <> '' AND initials_data.text_value ILIKE '%' || p_initials || '%')
                       OR
                       (TRIM(p_initials) = '') AND (initials_data.text_value ILIKE '%' || p_initials || '%' OR initials_data.text_value IS NULL)
                     )
        and (((upv.full_name_search ilike '%' || v_clean_name_search_term || '%')
          or (upv.email_search ilike '%' || v_clean_email_search_term1 || '%' )
          or (upv.phone_number_search ilike '%' || v_clean_phone_search_term1 || '%' ))
        and (coalesce(upv.email_search,'') ilike '%' || v_clean_email_search_term || '%')
        and (coalesce(upv.phone_number_search,'') ilike '%' || v_clean_phone_search_term || '%')
        and (upv.first_name ilike '%' || p_first_name || '%')
        and  (upv.last_name ilike '%' || p_last_name || '%'))
        and case when p_primary_flag is true then upv.primary_flag = true else 1 = 1 end
        and case
              when array_length(p_status_ids, 1) > 0
                then upv.user_status_type_id = any (p_status_ids)
              else 1 = 1 end
        and case
              when array_length(p_position_ids , 1) > 0
                then upv.position_id = any (p_position_ids)
              else 1 = 1 end
        and case
              when array_length(p_org_ids , 1) > 0
                then upv.org_id = any (p_org_ids)
              else 1 = 1 end
      union
      select u.id,
             initials_data.text_value as initials,
             u.first_name,
             u.last_name,
             uc.company_id,
             concat(u.first_name, ' ', u.last_name) AS full_name,
             u.email,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             ust.id                                 as user_status_type_id,
             ust.user_status_type,
             ust.has_access
      from flow."user" u
             inner join flow.user_company uc on u.id = uc.user_id
             inner join flow.user_status_type ust on ust.company_id = uc.company_id
             inner join flow.company_user_status cus on cus.user_id = u.id and cus.user_status_type_id = ust.id
                LEFT JOIN (
          SELECT DISTINCT ON (ucfv.user_id) ucfv.user_id, ucfv.text_value
          FROM flow.user_custom_field_value ucfv
          JOIN flow.custom_field_group_assignment cfga ON cfga.id = ucfv.custom_field_group_assignment_id
          JOIN flow.custom_field cf ON cf.id = cfga.custom_field_id
          WHERE cf.field_name = 'Initials'
      ) AS initials_data ON initials_data.user_id = u.id
      where uc.company_id = p_company_id
      and (
                (TRIM(p_initials) <> '' AND initials_data.text_value ILIKE '%' || p_initials || '%')
                OR
                (TRIM(p_initials) = '') AND (initials_data.text_value ILIKE '%' || p_initials || '%' OR initials_data.text_value IS NULL)
              )
        and not exists (select up2.id
                        from flow.user_position up2
                               inner join flow.position p on p.id = up2.position_id
                        where up2.user_id = u.id
                          and p.company_id = uc.company_id
                          and up2.archived is false)
        and concat(u.first_name, ' ', u.last_name) Ilike '%' || v_clean_name_search_term || '%'
        and u.first_name ilike '%' || p_first_name || '%'
        and u.last_name ilike '%' || p_last_name || '%'
        and u.archived is false
        and coalesce(u.email, '') ilike '%' || v_clean_email_search_term || '%'
        and coalesce(u.phone_number, '') ilike '%' || v_clean_phone_search_term || '%'
        and case when array_length(p_position_ids , 1) > 0 then false else 1 = 1 end
        and case when array_length(p_org_ids , 1) > 0 then false else 1 = 1 end
        and case
              when array_length(ARRAY [ p_status_ids ]::bigint[], 1) > 0
                then cus.user_status_type_id = any (p_status_ids)
              else 1 = 1 end
      order by last_name, first_name, start_date desc
      limit p_limit offset p_offset) as foo;

END;
$function$


