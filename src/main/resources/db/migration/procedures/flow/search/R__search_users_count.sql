DROP FUNCTION IF EXISTS flow.search_users_count(varchar, varchar, varchar, varchar, varchar, int8, bool, _int8, _int8, _int8);

CREATE OR REPLACE FUNCTION flow.search_users_count(p_searchterm character varying, p_first_name character varying, p_last_name character varying, p_email character varying, p_phone character varying, p_company_id bigint, p_primary_flag boolean, p_status_ids bigint[], p_position_ids bigint[], p_org_ids bigint[])
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_clean_name_search_term VARCHAR;
    v_clean_phone_search_term VARCHAR;
    v_clean_email_search_term VARCHAR;
    v_clean_phone_search_term1 VARCHAR;
    v_clean_email_search_term1 VARCHAR;
    result bigint;
BEGIN
    v_clean_name_search_term = lower(trim(translate(p_searchterm, '*,.&', '')));
    v_clean_phone_search_term = right(trim(translate(p_phone, '+-(). ', '')), 10);
    v_clean_email_search_term = lower(trim(p_email));
    v_clean_phone_search_term1 = right(trim(translate(p_searchterm, '+-(). ', '')), 10);
    v_clean_email_search_term1 = lower(trim(p_searchterm));

    SELECT COUNT(*) INTO result
    FROM (
        SELECT DISTINCT upv.user_id
        FROM flow.user_positions_vw upv
        INNER JOIN flow.user_status_type ust ON ust.id = upv.user_status_type_id
        WHERE upv.company_id = p_company_id
          AND upv.archived IS FALSE
          AND (
            (
              upv.full_name_search ILIKE '%' || v_clean_name_search_term || '%'
              OR upv.email_search ILIKE '%' || v_clean_email_search_term1 || '%'
              OR upv.phone_number_search ILIKE '%' || v_clean_phone_search_term1 || '%'
            )
            AND COALESCE(upv.email_search, '') ILIKE '%' || v_clean_email_search_term || '%'
            AND COALESCE(upv.phone_number_search, '') ILIKE '%' || v_clean_phone_search_term || '%'
            AND upv.first_name ILIKE '%' || p_first_name || '%'
            AND upv.last_name ILIKE '%' || p_last_name || '%'
          )
          AND CASE WHEN p_primary_flag IS TRUE THEN upv.primary_flag = TRUE ELSE 1 = 1 END
          AND CASE WHEN array_length(p_status_ids, 1) > 0 THEN upv.user_status_type_id = ANY(p_status_ids) ELSE 1 = 1 END
          AND CASE WHEN array_length(p_position_ids, 1) > 0 THEN upv.position_id = ANY(p_position_ids) ELSE 1 = 1 END
          AND CASE WHEN array_length(p_org_ids, 1) > 0 THEN upv.org_id = ANY(p_org_ids) ELSE 1 = 1 END

        UNION

        SELECT u.id
        FROM flow."user" u
        INNER JOIN flow.user_company uc ON u.id = uc.user_id
        INNER JOIN flow.user_status_type ust ON ust.company_id = uc.company_id
        INNER JOIN flow.company_user_status cus ON cus.user_id = u.id AND cus.user_status_type_id = ust.id
        WHERE uc.company_id = p_company_id
          AND NOT EXISTS (
            SELECT 1
            FROM flow.user_position up2
            INNER JOIN flow.position p ON p.id = up2.position_id
            WHERE up2.user_id = u.id
              AND p.company_id = uc.company_id
              AND up2.archived IS FALSE
          )
          AND CONCAT(u.first_name, ' ', u.last_name) ILIKE '%' || v_clean_name_search_term || '%'
          AND u.first_name ILIKE '%' || p_first_name || '%'
          AND u.last_name ILIKE '%' || p_last_name || '%'
          AND u.archived IS FALSE
          AND COALESCE(u.email, '') ILIKE '%' || v_clean_email_search_term || '%'
          AND COALESCE(u.phone_number, '') ILIKE '%' || v_clean_phone_search_term || '%'
          AND CASE WHEN array_length(p_position_ids, 1) > 0 THEN FALSE ELSE 1 = 1 END
          AND CASE WHEN array_length(p_org_ids, 1) > 0 THEN FALSE ELSE 1 = 1 END
          AND CASE WHEN array_length(p_status_ids, 1) > 0 THEN cus.user_status_type_id = ANY(p_status_ids) ELSE 1 = 1 END
    ) AS foo;

    RETURN result;
END;
$function$
;
