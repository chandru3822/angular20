CREATE OR REPLACE FUNCTION flow.search_projects_with_down_line_count(p_searchterm character varying,
                                                                     p_company_id integer,
                                                                     p_user_id integer,
                                                                     p_is_parent boolean)
    RETURNS bigint
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
    v_count                     bigint;
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
        with user_position_ids as (
            with positions as (
                select up.org_id as parent_org_id
                from flow.user_position up
                where up.primary_flag is true
                  and user_id = p_user_id
            ),
                 org_ids as (
                     select t.id
                     from positions p
                              join lateral flow.org_hierarchy_filter_down_search(array [p.parent_org_id]) as t
                                   on true)
            select distinct array_agg(up2.id) as user_position_ids
            from org_ids o
                     inner join flow.user_position up2 on up2.org_id = o.id)
        select count(1)
        into v_count
        from flow.project p
                 inner join user_position_ids upi on p.user_position_id = any (upi.user_position_ids)
                 inner join flow.company_process cp on cp.id = p.company_process_id
                 inner join flow.process pr on pr.id = cp.process_id
                 inner join flow.status_type st on st.id = cp.status_type_id
                 inner join flow.company_project_status_type cpst
                            on cpst.id = p.company_project_status_type_id
                 inner join flow.contact c on c.id = p.contact_id
                 left join flow.company_state cs on cs.id = p.company_state_id
                 left join flow.state s on s.id = cs.state_id
        where cp.company_id = any (v_company_ids);

        else
            with search_projects as (
                SELECT p.id, 1 as rank
                FROM flow.project p
                         inner join flow.contact c on c.id = p.contact_id
                WHERE c.company_id = ANY (v_company_ids)
                  AND NOT v_clean_name_search_term ~ '^([0-9]+)$'
                  AND lower(translate(coalesce(p.project_name, ''), '*,.& ', '')) like
                      '%' || v_clean_name_search_term || '%'
                union
                SELECT p.id, 2 as rank
                FROM flow.project p
                         inner join flow.contact c on c.id = p.contact_id
                WHERE c.company_id = ANY (v_company_ids)
                  AND p.id::text LIKE '%' || v_clean_id_search_term || '%'
                union
                SELECT p.id, 3 as rank
                FROM flow.project p
                         inner join flow.contact c on c.id = p.contact_id
                WHERE c.company_id = ANY (v_company_ids)
                  AND lower(trim(c.email)) LIKE '%' || v_clean_email_search_term || '%'
                union
                SELECT p.id, 4 as rank
                FROM flow.project p
                         inner join flow.contact c on c.id = p.contact_id
                WHERE c.company_id = ANY (v_company_ids)
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
                 ),
                 user_position_ids as (
                     with positions as (
                         select up.org_id as parent_org_id
                         from flow.user_position up
                         where up.primary_flag is true
                           and user_id = p_user_id
                     ),
                          org_ids as (
                              select t.id
                              from positions p
                                       join lateral flow.org_hierarchy_filter_down_search(array [p.parent_org_id]) as t
                                            on true)
                     select distinct array_agg(up2.id) as user_position_ids
                     from org_ids o
                              inner join flow.user_position up2 on up2.org_id = o.id)
            select count(1)
            into v_count
            from ranked_projects rp
                     inner join flow.project p on p.id = rp.id
                     inner join user_position_ids upi on p.user_position_id = any (upi.user_position_ids)
                     inner join flow.company_process cp on cp.id = p.company_process_id
                     inner join flow.process pr on pr.id = cp.process_id
                     inner join flow.status_type st on st.id = cp.status_type_id
                     inner join flow.company_project_status_type cpst
                                on cpst.id = p.company_project_status_type_id
                     inner join flow.contact c on c.id = p.contact_id
                     left join flow.company_state cs on cs.id = p.company_state_id
                     left join flow.state s on s.id = cs.state_id
            where cp.company_id = any (v_company_ids);
        end case;
    return v_count;
END;
$function$
