DROP FUNCTION IF EXISTS brs.get_request_for_installation_agreements(boolean, bigint, boolean, bigint, bigint, character varying, integer, bigint);

CREATE OR REPLACE FUNCTION brs.get_request_for_installation_agreements(
    p_view_all boolean,
    p_platform_user_id bigint,
    p_is_parent boolean,
    p_company_id bigint,
    p_parent_company_id bigint,
    p_searchterm character varying,
    p_limit integer,
    p_offset bigint
)
    RETURNS TABLE(
                     project_id    INTEGER,
                     customer_name VARCHAR,
                     email         VARCHAR,
                     address       TEXT,
                     creditLastCheckedBySunpower BOOLEAN
                 )
    LANGUAGE plpgsql
AS $function$

declare

BEGIN
    case when (p_view_all) THEN
        RETURN QUERY
            SELECT
                p.id                                                             AS project_id,
                p.project_name,
                c.email,
                concat(p.street1, ', ', p.city, ', ' ,s.state, ' ', p.postal_code) AS address,
                case when pd.credit_last_checked_by = 'Sunpower' then true else false end as "creditLastCheckedBySunpower"
            FROM flow.project p
                     left join brs.project_details pd on pd.project_id = p.id
                     INNER JOIN flow.contact c ON c.id = p.contact_id
                     inner join flow.company_state cs on p.company_state_id = cs.id
                     INNER JOIN flow.state s ON s.id = cs.state_id
            WHERE pd.cancelled_date is null AND pd.energized_date is null
                AND p.project_name ILIKE '%' || p_searchterm || '%'
                AND case when p_is_parent
                             then c.company_id = any (select id from flow.company_hierarchy_filter_down(p_parent_company_id::int))
                  else c.company_id = p_company_id end
            limit p_limit
            offset p_offset;
        ELSE
            RETURN QUERY
                SELECT
                    p.id                                                             AS project_id,
                    p.project_name,
                    c.email,
                    concat(p.street1, ', ' ,p.city, ', ', s.state, ' ' ,p.postal_code) AS address,
                    case when pd.credit_last_checked_by = 'Sunpower' then true else false end as  "creditLastCheckedBySunpower"
                FROM flow.project p
                         left join brs.project_details pd on pd.project_id = p.id
                         INNER JOIN flow.contact c ON c.id = p.contact_id
                         inner join flow.company_state cs on p.company_state_id = cs.id
                         INNER JOIN flow.state s ON s.id = cs.state_id
                where pd.closer_user_id = p_platform_user_id
                    AND pd.cancelled_date is null
                    AND pd.energized_date is null
                    AND case when p_is_parent
                                 then c.company_id = any (select id from flow.company_hierarchy_filter_down(p_parent_company_id::int))
                      else c.company_id = p_company_id end
                    AND p.project_name ILIKE '%' || p_searchterm || '%'
                limit p_limit
                offset p_offset;
        END CASE;
END
$function$
