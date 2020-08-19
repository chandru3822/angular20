DROP FUNCTION IF EXISTS brs.get_request_for_installation_agreements(boolean, bigint);

CREATE OR REPLACE FUNCTION brs.get_request_for_installation_agreements(
    p_view_all boolean,
    p_platform_user_id bigint
)
    RETURNS TABLE(
                     project_id    INTEGER,
                     customer_name VARCHAR,
                     email         VARCHAR,
                     address       TEXT
                 )
    LANGUAGE plpgsql
AS $function$

--select * from  brs.get_request_for_installation_agreements(false, 2294513);

declare

BEGIN
    case when (p_view_all) THEN
        RETURN QUERY
            SELECT
                p.id                                                             AS project_id,
                p.project_name,
                c.email,
                p.street1 || ', ' || p.city || ', ' || s.state || ' ' || p.postal_code AS address
            FROM flow.project p
                     left join brs.project_details pd on pd.project_id = p.id
                     INNER JOIN flow.contact c ON c.id = p.contact_id
                     INNER JOIN flow.state s ON s.id = p.state_id
            WHERE pd.cancelled_date is null AND pd.energized_date is null;
        ELSE
            RETURN QUERY
                SELECT
                    p.id                                                             AS project_id,
                    p.project_name,
                    c.email,
                    p.street1 || ', ' || p.city || ', ' || s.state || ' ' || p.postal_code AS address
                FROM flow.project p
                         left join brs.project_details pd on pd.project_id = p.id
                         INNER JOIN flow.contact c ON c.id = p.contact_id
                         INNER JOIN flow.state s ON s.id = p.state_id
                where pd.closer_user_id = p_platform_user_id
                AND pd.cancelled_date is null
                AND pd.energized_date is null;
        END CASE;
END
$function$
