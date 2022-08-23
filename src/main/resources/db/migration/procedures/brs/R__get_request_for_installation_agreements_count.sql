DROP FUNCTION IF EXISTS brs.get_request_for_installation_agreements_count(boolean, boolean, bigint, boolean, bigint, bigint, character varying);

CREATE OR REPLACE FUNCTION brs.get_request_for_installation_agreements_count(
    p_view_all boolean,
    p_show_cancelled boolean,
    p_platform_user_id bigint,
    p_is_parent boolean,
    p_company_id bigint,
    p_parent_company_id bigint,
    p_searchterm character varying
)
    RETURNS bigint
    LANGUAGE plpgsql
AS $function$

declare
    p_agreement_count bigint;
BEGIN
    case when (p_view_all) THEN
            SELECT count(*) into p_agreement_count
            FROM flow.project p
                     left join brs.project_details pd on pd.project_id = p.id
                     INNER JOIN flow.contact c ON c.id = p.contact_id
                     inner join flow.company_state cs on p.company_state_id = cs.id
                     INNER JOIN flow.state s ON s.id = cs.state_id
            WHERE (pd.cancelled_date is null or p_show_cancelled is true)
                AND pd.energized_date is null
                AND p.archived is false
                AND case when p_is_parent
                             then c.company_id = any (select id from flow.company_hierarchy_filter_down(p_parent_company_id::bigint))
                    else c.company_id = p_company_id end
                AND p.project_name ILIKE '%' || p_searchterm || '%';
        ELSE
                SELECT count(*) into p_agreement_count
                FROM flow.project p
                         left join brs.project_details pd on pd.project_id = p.id
                         INNER JOIN flow.contact c ON c.id = p.contact_id
                         inner join flow.company_state cs on p.company_state_id = cs.id
                         INNER JOIN flow.state s ON s.id = cs.state_id
                where pd.closer_user_id = p_platform_user_id
                    AND (pd.cancelled_date is null or p_show_cancelled is true)
                    AND pd.energized_date is null
                    AND p.archived is false
                    AND case when p_is_parent
                                 then c.company_id = any (select id from flow.company_hierarchy_filter_down(p_parent_company_id::bigint))
                        else c.company_id = p_company_id end
                    AND p.project_name ILIKE '%' || p_searchterm || '%';
        END CASE;
        return p_agreement_count;
END
$function$
