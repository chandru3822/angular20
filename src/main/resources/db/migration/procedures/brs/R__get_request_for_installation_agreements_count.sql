DROP FUNCTION IF EXISTS brs.get_request_for_installation_agreements_count(boolean, bigint, character varying);

CREATE OR REPLACE FUNCTION brs.get_request_for_installation_agreements_count(
    p_view_all boolean,
    p_platform_user_id bigint,
    p_company_id bigint,
    p_searchterm character varying
)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS $function$

declare
    p_agreement_count integer;
BEGIN
    case when (p_view_all) THEN
            SELECT count(*) into p_agreement_count
            FROM flow.project p
                     left join brs.project_details pd on pd.project_id = p.id
                     INNER JOIN flow.contact c ON c.id = p.contact_id
                     inner join flow.company_state cs on p.company_state_id = cs.id
                     INNER JOIN flow.state s ON s.id = cs.state_id
            WHERE pd.cancelled_date is null
                AND pd.energized_date is null
              and c.company_id = p_company_id
                AND p.project_name ILIKE '%' || p_searchterm || '%';
        ELSE
                SELECT count(*) into p_agreement_count
                FROM flow.project p
                         left join brs.project_details pd on pd.project_id = p.id
                         INNER JOIN flow.contact c ON c.id = p.contact_id
                         inner join flow.company_state cs on p.company_state_id = cs.id
                         INNER JOIN flow.state s ON s.id = cs.state_id
                where pd.closer_user_id = p_platform_user_id
                    AND pd.cancelled_date is null
                    AND pd.energized_date is null
                  and c.company_id = p_company_id
                    AND p.project_name ILIKE '%' || p_searchterm || '%';
        END CASE;
        return p_agreement_count;
END
$function$
