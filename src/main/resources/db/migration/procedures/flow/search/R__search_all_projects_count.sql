DROP FUNCTION IF EXISTS flow.search_all_projects_count(varchar, int8, bool, int8, varchar, _int8);

CREATE OR REPLACE FUNCTION flow.search_all_projects_count(p_searchterm character varying, p_company_id bigint, p_is_parent boolean, p_company_project_status_type_id bigint DEFAULT NULL::bigint, p_search_column character varying DEFAULT NULL::character varying, p_partner_ids bigint[] DEFAULT ARRAY[]::bigint[])
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_clean_name_search_term VARCHAR;
    v_clean_id_search_term VARCHAR;
    v_clean_phone_search_term VARCHAR;
    v_clean_email_search_term VARCHAR;
    v_clean_address_search_term VARCHAR;
    v_clean_permit_term varchar;
    v_company_ids bigint[];
    v_clean_status_term VARCHAR;
    v_clean_street_term VARCHAR;
    v_clean_city_term VARCHAR;
    v_clean_zip_term VARCHAR;
    v_clean_state_abbreviation VARCHAR;
    v_clean_date_created_term VARCHAR;
    result bigint;
BEGIN
    v_clean_name_search_term = lower(trim(translate(p_searchterm, '*,.& ', '')));
    v_clean_phone_search_term = trim(translate(p_searchterm, '-().+ ', ''));
    v_clean_email_search_term = lower(trim(p_searchterm));
    v_clean_state_abbreviation = lower(trim(p_searchterm));
    v_clean_id_search_term = trim(p_searchterm);
    v_clean_address_search_term = trim(lower(translate(p_searchterm, '.,', '')));
    v_clean_permit_term = (trim(lower(translate(p_searchterm, E'/()_.,-:\\n\\r\\t ', ''))));
    v_clean_status_term = trim(lower(translate(p_searchterm, '*,.&', '')));
    v_clean_street_term = trim(lower(translate(p_searchterm, '*,.&', '')));
    v_clean_city_term = trim(lower(translate(p_searchterm, '*,.-& ', '')));
    v_clean_zip_term = trim(lower(translate(p_searchterm, '*,.&', '')));
    v_clean_date_created_term = p_searchterm;

    IF p_is_parent THEN
        SELECT array(SELECT f.id FROM flow.company_hierarchy_filter_down(p_company_id) f)
        INTO v_company_ids;
    ELSE
        SELECT array[p_company_id]
        INTO v_company_ids;
    END IF;

    SELECT COUNT(*) INTO result
    FROM flow.project p
    INNER JOIN flow.company_project_status_type cpst ON cpst.id = p.company_project_status_type_id
    INNER JOIN flow.project_status_type pst ON pst.id = cpst.project_status_type_id
    INNER JOIN flow.contact c ON c.id = p.contact_id
    LEFT JOIN flow.company_state cs ON cs.id = p.company_state_id
    LEFT JOIN flow.state s ON s.id = cs.state_id
    LEFT JOIN flow.project_custom_field_value pcfv ON pcfv.project_id = p.id AND pcfv.custom_field_group_assignment_id = 27972
    WHERE c.company_id = ANY (v_company_ids)
      AND p.archived IS NOT TRUE
      AND (
        p_searchterm IS NULL OR p_searchterm = '' OR
        (
          (p_search_column = 'id' AND p.id::text LIKE v_clean_id_search_term || '%') OR
          (p_search_column = 'projectName' AND p.project_name_search LIKE '%' || v_clean_name_search_term || '%') OR
          (p_search_column = 'stateAbbreviation' AND trim(lower(s.abbreviation)) LIKE '%' || v_clean_state_abbreviation || '%') OR
          (p_search_column = 'projectStatusType' AND trim(lower(translate(cpst.project_status_type, '*,.&', ''))) LIKE '%' || v_clean_status_term || '%') OR
          (p_search_column = 'street1' AND p.project_street_search LIKE '%' || v_clean_street_term || '%') OR
          (p_search_column = 'city' AND p.search_city LIKE '%' || v_clean_city_term || '%') OR
          (p_search_column = 'postalCode' AND p.search_postal_code LIKE '%' || v_clean_zip_term || '%') OR
          (p_search_column = 'contact.phone' AND c.contact_phone_search LIKE '%' || v_clean_phone_search_term || '%') OR
          (p_search_column = 'contact.email' AND c.contact_email_search LIKE '%' || v_clean_email_search_term || '%') OR
          (p_search_column = 'dateCreated' AND p.search_date_created LIKE '%' || v_clean_date_created_term || '%')
        )
      )
      AND (
        p_company_project_status_type_id IS NULL OR cpst.id = p_company_project_status_type_id
      )
      AND (
        array_length(p_partner_ids, 1) IS NULL OR pcfv.int_array_value && p_partner_ids
      );

    RETURN result;
END;
$function$
;
