CREATE OR REPLACE FUNCTION flow.search_contacts(p_searchterm character varying, p_company_id integer,
                                                p_is_parent boolean, p_is_viewall boolean, p_userid integer,
                                                p_limit integer, p_offset integer)
    RETURNS TABLE
            (
                id              integer,
                first_name      character varying,
                last_name       character varying,
                full_name       text,
                email           character varying,
                phone           character varying,
                company_id      integer,
                contact_type_id integer,
                contact_type    character varying,
                state_id        integer,
                state           character varying,
                abbreviation    character varying,
                date_created    timestamp,
                owner           jsonb
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
BEGIN
    v_clean_name_search_term = lower(
            trim(replace(replace(replace(replace(replace(p_searchterm, '*', ''), ',', ''), '.', ''), '&', ''), '  ',
                         ' ')));
    v_clean_phone_search_term = replace(replace(replace(replace(trim(p_searchterm), '-', ''), ')', ''), '(', ''), '.',
                                        '');
    v_clean_email_search_term = lower(trim(p_searchterm));
    v_clean_address_search_term = trim(lower(replace(replace(p_searchterm, '.', ''), ',', '')));
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
                   limited_contacts.company_id,
                   limited_contacts.contact_type_id,
                   limited_contacts.contact_type,
                   limited_contacts.state_id,
                   limited_contacts.state,
                   limited_contacts.abbreviation,
                   limited_contacts.date_created,
                   limited_contacts.owner
            FROM (
                     SELECT c.id,
                            c.first_name,
                            c.last_name,
                            c.first_name || ' ' || c.last_name as full_name,
                            c.email,
                            c.phone,
                            c.company_id,
                            c.contact_type_id,
                            ct.contact_type,
                            c.state_id,
                            s.state,
                            s.abbreviation,
                            c.date_created,
                            (select json_build_object(
                                            'userId', u.id,
                                            'firstName', u.first_name,
                                            'lastName', u.last_name,
                                            'fullName', u.first_name || ' ' || u.last_name
                                        ))::jsonb              as owner
                     FROM flow.contact c
                              inner join flow.contact_type ct on ct.id = c.contact_type_id
                              left join flow.state s on s.id = c.state_id
                              left join flow.user_position up on up.id = c.owner_user_position_id
                              left join flow."user" u on u.id = up.user_id
                     WHERE c.company_id = ANY (v_company_ids)
                       and c.date_created is not null
                       and case when p_is_viewall is not true then u.id = p_userid else 1 = 1 end
                     order by c.date_created desc
                     limit p_limit offset p_offset
                 ) as limited_contacts;
        else
            RETURN QUERY
                with search_contacts as (
                    SELECT c.id, 1 as rank
                    FROM flow.contact c
                    WHERE c.company_id = ANY (v_company_ids)
                      AND NOT v_clean_name_search_term ~ '^([0-9]+)$'
                      AND lower(translate(coalesce(c.first_name, ''), '*,.& ', '')) || ' ' ||
                          lower(translate(coalesce(c.last_name, ''), '*,.& ', '')) like
                          '%' || v_clean_name_search_term || '%'
                    union
                    SELECT c.id, 2 as rank
                    FROM flow.contact c
                    WHERE c.company_id = ANY (v_company_ids)
                      AND lower(trim(c.email)) LIKE '%' || v_clean_email_search_term || '%'
                    union
                    SELECT c.id, 3 as rank
                    FROM flow.contact c
                    WHERE c.company_id = ANY (v_company_ids)
                      and v_clean_phone_search_term ~ '^([0-9]+)$'
                      and trim(translate(c.phone, '()-+.', '')) LIKE '%' || v_clean_phone_search_term || '%'
                    union
                    SELECT c.id, 4 as rank
                    FROM flow.contact c
                    WHERE c.company_id = ANY (v_company_ids)
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
                         limit p_limit offset p_offset
                     )
                select c.id,
                       c.first_name,
                       c.last_name,
                       c.first_name || ' ' || c.last_name as full_name,
                       c.email,
                       c.phone,
                       c.company_id,
                       c.contact_type_id,
                       ct.contact_type,
                       c.state_id,
                       s.state,
                       s.abbreviation,
                       c.date_created,
                       (select json_build_object(
                                       'userId', u.id,
                                       'firstName', u.first_name,
                                       'lastName', u.last_name,
                                       'fullName', u.first_name || ' ' || u.last_name
                                   ))::jsonb              as owner
                from ranked_contacts ranked
                         inner join flow.contact c on c.id = ranked.id
                         inner join flow.contact_type ct on ct.id = c.contact_type_id
                         left join flow.state s on s.id = c.state_id
                         left join flow.user_position up on up.id = c.owner_user_position_id
                         left join flow."user" u on u.id = up.user_id
                where case when p_is_viewall is not true then u.id = p_userid else 1 = 1 end;
        end case;
END;
$function$
