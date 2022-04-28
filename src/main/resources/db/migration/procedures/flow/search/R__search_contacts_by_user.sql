-- DROP FUNCTION flow.search_contacts(character varying, integer, boolean, boolean, integer, integer, integer);
CREATE OR REPLACE FUNCTION flow.search_contacts_by_user(p_searchterm character varying, p_company_id integer,
                                                        p_is_parent boolean, p_user_id integer,
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
BEGIN
    v_clean_name_search_term = lower(trim(translate(p_searchterm, '*,.&', '')));
    v_clean_phone_search_term = trim(translate(p_searchterm, '-(). ', ''));
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
    case when p_searchterm is null or p_searchterm = '' then
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
            FROM (
                     with user_position_ids as (
                         select array_agg(up.id) as user_position_ids
                         from flow.user_position up
                         where user_id = p_user_id
                     ),
                          contact_ids as (
                              select array_agg(contact_ids) as contact_ids
                              from (
                                       select c.id as contact_ids
                                       from flow.contact c
                                                inner join user_position_ids upi
                                                           on c.owner_user_position_id = any (user_position_ids)
                                       where c.archived is not true
                                       union
                                       select c.id as contact_ids
                                       from flow.contact c
                                                inner join flow.project p2 on p2.contact_id = c.id
                                                inner join user_position_ids upi on p2.user_position_id = any (user_position_ids)
                                       where c.archived is not true
                                         and p2.archived is not true
                                   ) as foo)
                     SELECT c.id,
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
                                        ))::jsonb                  as owner
                     FROM flow.contact c
                              inner join contact_ids ci on c.id = any (ci.contact_ids)
                              inner join flow.contact_type ct on ct.id = c.contact_type_id
                              left join flow.company_state cs on cs.id = c.company_state_id
                              left join flow.state s on s.id = cs.state_id
                              left join flow.user_position up on up.id = c.owner_user_position_id
                              left join flow."user" u on u.id = up.user_id
                     WHERE c.company_id = ANY (v_company_ids)
                       and c.archived is not true
                       and c.date_created is not null
                     order by c.date_created desc
                     limit p_limit
                     offset
                     p_offset
                 ) as limited_contacts;
        else
            RETURN QUERY
                with search_contacts as (
                    SELECT c.id, 1 as rank
                    FROM flow.contact c
                    WHERE c.company_id = ANY (v_company_ids)
                      and c.archived is not true
                      AND NOT v_clean_name_search_term ~ '^([0-9]+)$'
                      AND lower(translate(coalesce(c.first_name, ''), '*,.& ', '')) || ' ' ||
                          lower(translate(coalesce(c.last_name, ''), '*,.& ', '')) like
                          '%' || v_clean_name_search_term || '%'
                    union
                    SELECT c.id, 2 as rank
                    FROM flow.contact c
                    WHERE c.company_id = ANY (v_company_ids)
                      and c.archived is not true
                      AND c.id::text LIKE '%' || v_clean_id_search_term || '%'
                    union
                    SELECT c.id, 3 as rank
                    FROM flow.contact c
                    WHERE c.company_id = ANY (v_company_ids)
                      and c.archived is not true
                      AND lower(trim(c.email)) LIKE '%' || v_clean_email_search_term || '%'
                    union

                    SELECT c.id, 4 as rank
                    FROM flow.contact c
                    WHERE c.company_id = ANY (v_company_ids)
                        and c.archived is not true
                        and v_clean_phone_search_term ~ '^([0-9]+)$'
                        and (trim(translate(c.phone, '()-+. ', '')) LIKE '%' || v_clean_phone_search_term || '%')
                       or (trim(translate(c.mobile, '()-+. ', '')) LIKE '%' || v_clean_phone_search_term || '%')
                    union
                    SELECT c.id, 5 as rank
                    FROM flow.contact c
                    WHERE c.company_id = ANY (v_company_ids)
                      and c.archived is not true
                      AND lower(trim(translate(coalesce(c.street1, ''), '.,', ''))) || ' ' ||
                          lower(trim(translate(coalesce(c.street2, ''), '.,', '')))
                        like '%' || v_clean_address_search_term || '%'),
                     ranked_contacts as (
                         select sc.id,
                                sum(rank),
                                count(1)
                         from search_contacts sc
                         group by 1
                         order by count(1) desc, sum(rank)
                     ),
                     user_position_ids as (
                         select array_agg(up.id) as user_position_ids
                         from flow.user_position up
                         where user_id = p_user_id
                     ),
                     contact_ids as (
                         select array_agg(contact_ids) as contact_ids
                         from (
                                  select c.id as contact_ids
                                  from flow.contact c
                                           inner join user_position_ids upi
                                                      on c.owner_user_position_id = any (user_position_ids)
                                  where c.archived is not true
                                  union
                                  select c.id as contact_ids
                                  from flow.contact c
                                           inner join flow.project p2 on p2.contact_id = c.id
                                           inner join user_position_ids upi on p2.user_position_id = any (user_position_ids)
                                  where c.archived is not true
                                    and p2.archived is not true
                              ) as foo)
                select c.id,
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
                                   ))::jsonb                  as owner
                from ranked_contacts ranked
                         inner join flow.contact c on c.id = ranked.id
                         inner join contact_ids ci on c.id = any (ci.contact_ids)
                         inner join flow.contact_type ct on ct.id = c.contact_type_id
                         left join flow.company_state cs on cs.id = c.company_state_id
                         left join flow.state s on s.id = cs.state_id
                         left join flow.user_position up on up.id = c.owner_user_position_id
                         left join flow."user" u on u.id = up.user_id
                where c.archived is not true
            limit p_limit
                offset
                p_offset;
        end case;
END;
$function$
