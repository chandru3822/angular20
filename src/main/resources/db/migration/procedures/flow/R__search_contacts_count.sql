CREATE OR REPLACE FUNCTION flow.search_contacts_count(p_searchterm character varying, p_company_id integer,
                                                      p_is_parent boolean, p_is_viewall boolean, p_userid integer)
    RETURNS TABLE
            (
                count bigint
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
    v_clean_name_search_term = lower(trim(translate(p_searchterm, '*,.& ', '')));
    v_clean_phone_search_term = trim(translate(p_searchterm, '-(). ', ''));
    v_clean_email_search_term = lower(trim(p_searchterm));
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
            SELECT count(1) as count
            FROM flow.contact c
                     inner join flow.contact_type ct on ct.id = c.contact_type_id
                     left join flow.company_state cs on cs.id = c.company_state_id
                     left join flow.state s on s.id = cs.state_id
                     left join flow.user_position up on up.id = c.owner_user_position_id
                     left join flow."user" u on u.id = up.user_id
            WHERE c.company_id = ANY (v_company_ids)
              and c.date_created is not null
              and case when p_is_viewall is not true then u.id = p_userid else 1 = 1 end;
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
                      and trim(translate(c.phone, '()-+. ', '')) LIKE '%' || v_clean_phone_search_term || '%'
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
                     )
                select count(1) as count
                from ranked_contacts ranked
                         inner join flow.contact c on c.id = ranked.id
                         inner join flow.contact_type ct on ct.id = c.contact_type_id
                         left join flow.company_state cs on cs.id = c.company_state_id
                         left join flow.state s on s.id = cs.state_id
                         left join flow.user_position up on up.id = c.owner_user_position_id
                         left join flow."user" u on u.id = up.user_id
                where case when p_is_viewall is not true then u.id = p_userid else 1 = 1 end;
        end case;
END;
$function$
