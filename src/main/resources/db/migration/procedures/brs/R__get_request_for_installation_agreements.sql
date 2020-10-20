DROP FUNCTION IF EXISTS brs.get_request_for_installation_agreements(boolean, bigint, character varying, integer, bigint);

CREATE OR REPLACE FUNCTION brs.get_request_for_installation_agreements(
    p_view_all boolean,
    p_platform_user_id bigint,
    p_searchterm character varying,
    p_limit integer,
    p_offset bigint
)
    RETURNS TABLE(
                     project_id    INTEGER,
                     customer_name VARCHAR,
                     email         VARCHAR,
                     address       TEXT
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
                concat(p.street1, ', ', p.city, ', ' ,s.state, ' ', p.postal_code) AS address
            FROM flow.project p
                     left join brs.project_details pd on pd.project_id = p.id
                     INNER JOIN flow.contact c ON c.id = p.contact_id
                     inner join flow.company_state cs on p.company_state_id = cs.id
                     INNER JOIN flow.state s ON s.id = cs.state_id
            WHERE pd.cancelled_date is null AND pd.energized_date is null
                AND p.project_name ILIKE '%' || p_searchterm || '%'
            limit p_limit
            offset p_offset;
        ELSE
            RETURN QUERY
                SELECT
                    p.id                                                             AS project_id,
                    p.project_name,
                    c.email,
                       concat(p.street1, ', ' ,p.city, ', ', s.state, ' ' ,p.postal_code) AS address
                FROM flow.project p
                         left join brs.project_details pd on pd.project_id = p.id
                         INNER JOIN flow.contact c ON c.id = p.contact_id
                         inner join flow.company_state cs on p.company_state_id = cs.id
                         INNER JOIN flow.state s ON s.id = cs.state_id
                where pd.closer_user_id = p_platform_user_id
                    AND pd.cancelled_date is null
                    AND pd.energized_date is null
                    AND p.project_name ILIKE '%' || p_searchterm || '%'
                limit p_limit
                offset p_offset;
        END CASE;
END
$function$
