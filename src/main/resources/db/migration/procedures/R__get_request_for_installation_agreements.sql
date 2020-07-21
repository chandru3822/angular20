DROP FUNCTION IF EXISTS brs.get_request_for_installation_agreements(boolean, integer);

CREATE OR REPLACE FUNCTION brs.get_request_for_installation_agreements(
    p_view_all boolean,
    p_platform_user_id integer
)
    RETURNS TABLE(
                     project_id    INTEGER,
                     customer_name VARCHAR,
                     email         VARCHAR,
                     address       TEXT,
                     financier     VARCHAR
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
                c.street1 || ', ' || c.city || ', ' || c.state || ' ' || c.postal_code AS address,
                (select lov.name
                from flow.list_of_value lov
                where lov.id = pd.primary_financier) as financier
            FROM flow.project p
                     left join brs.project_details pd on pd.project_id = p.id
                     INNER JOIN flow.contact c ON c.id = p.contact_id
                     INNER JOIN brs.project_commission_snapshot pcs ON pcs.project_id = p.id
            where pcs.stage NOT IN ('Energized', 'Unqualified', 'Cancelled') and
                pcs.id = (select max(id) from brs.project_commission_snapshot pcs2 where pcs2.project_id = p.id);
        ELSE
            RETURN QUERY
                SELECT
                    p.id                                                             AS project_id,
                    p.project_name,
                    c.email,
                    c.street1 || ', ' || c.city || ', ' || c.state || ' ' || c.postal_code AS address,
                    (select lov.name
                         from flow.list_of_value lov
                         where lov.id = pd.primary_financier) as financier
                FROM flow.project p
                         left join brs.project_details pd on pd.project_id = p.id
                         INNER JOIN flow.contact c ON c.id = p.contact_id
                         INNER JOIN brs.project_commission_snapshot pcs ON pcs.project_id = p.id
                where pd.closer_user_id = p_platform_user_id
                  AND pcs.stage NOT IN ('Energized', 'Unqualified', 'Cancelled')
                  AND pcs.id = (select max(id) from brs.project_commission_snapshot pcs2 where pcs2.project_id = p.id);
        END CASE;
END
$function$
