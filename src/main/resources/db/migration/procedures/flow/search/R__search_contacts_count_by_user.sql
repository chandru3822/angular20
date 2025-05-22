DROP FUNCTION IF EXISTS flow.search_contacts_count_by_user(varchar, int8, _int8, bool, int8, _int8);

CREATE OR REPLACE FUNCTION flow.search_contacts_count_by_user(p_searchterm character varying, p_company_id bigint, p_object_category_ids bigint[], p_is_parent boolean, p_user_id bigint, p_partner_ids bigint[] DEFAULT ARRAY[]::bigint[])
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_clean_name_search_term    VARCHAR;
  v_clean_phone_search_term   VARCHAR;
  v_clean_email_search_term   VARCHAR;
  v_clean_address_search_term VARCHAR;
  v_company_ids               bigint[];
  v_clean_id_search_term      varchar;
  v_position_ids              bigint[];
  v_count                     bigint;
BEGIN
  -- Prepare search strings
  v_clean_name_search_term    := lower(trim(translate(p_searchterm, '*,.&- ', '')));
  v_clean_phone_search_term   := right(trim(translate(p_searchterm, '+-(). ', '')), 10);
  v_clean_email_search_term   := lower(trim(p_searchterm));
  v_clean_address_search_term := trim(lower(translate(p_searchterm, '.,', '')));
  v_clean_id_search_term      := trim(p_searchterm);
  
  -- Determine company ids based on parent flag
  IF p_is_parent THEN
    SELECT array(SELECT f.id FROM flow.company_hierarchy_filter_down(p_company_id) f)
      INTO v_company_ids;
  ELSE
    SELECT array(SELECT p_company_id)
      INTO v_company_ids;
  END IF;
  
  -- Get the positions for the user
  SELECT array_agg(up.id)
    INTO v_position_ids
  FROM flow.user_position up
  WHERE up.user_id = p_user_id;
  
  -- Execute count query using the filtering rules
  IF p_searchterm IS NOT NULL AND p_searchterm <> '' THEN
    SELECT COUNT(*) INTO v_count
    FROM flow.contact c
         INNER JOIN flow.contact_type ct ON ct.id = c.contact_type_id
         LEFT JOIN flow.company_state cs ON cs.id = c.company_state_id
         LEFT JOIN flow.state s ON s.id = cs.state_id
         LEFT JOIN flow.user_position up ON up.id = c.owner_user_position_id
         LEFT JOIN flow."user" u ON u.id = up.user_id
         LEFT JOIN flow.contact_custom_field_value ccfv 
           ON ccfv.contact_id = c.id 
          AND ccfv.custom_field_group_assignment_id = 27973
    WHERE c.company_id = ANY (v_company_ids)
      AND c.archived IS NOT TRUE
      AND c.date_created IS NOT NULL
      AND (c.owner_position_ids && v_position_ids)
      AND (
            CASE 
              WHEN array_length(ARRAY[p_object_category_ids]::bigint[], 1) > 0 THEN
                c.object_category_id = ANY (p_object_category_ids)
              ELSE TRUE
            END
          )
      AND (
            CASE 
              WHEN array_length(p_partner_ids, 1) > 0 THEN
                ccfv.int_array_value && p_partner_ids
              ELSE TRUE
            END
          )
      AND (
            (c.id::text LIKE '%' || v_clean_name_search_term || '%')
         OR (c.contact_full_name_search LIKE '%' || v_clean_name_search_term || '%')
         OR (c.contact_street_search LIKE '%' || v_clean_address_search_term || '%')
         OR (c.contact_email_search LIKE '%' || v_clean_email_search_term || '%')
         OR (c.contact_mobile_search LIKE '%' || v_clean_phone_search_term || '%')
         OR (c.contact_phone_search LIKE '%' || v_clean_phone_search_term || '%')
          );
  ELSE
    SELECT COUNT(*) INTO v_count
    FROM flow.contact c
         INNER JOIN flow.contact_type ct ON ct.id = c.contact_type_id
         LEFT JOIN flow.company_state cs ON cs.id = c.company_state_id
         LEFT JOIN flow.state s ON s.id = cs.state_id
         LEFT JOIN flow.user_position up ON up.id = c.owner_user_position_id
         LEFT JOIN flow."user" u ON u.id = up.user_id
         LEFT JOIN flow.contact_custom_field_value ccfv 
           ON ccfv.contact_id = c.id 
          AND ccfv.custom_field_group_assignment_id = 27973
    WHERE c.company_id = ANY (v_company_ids)
      AND c.archived IS NOT TRUE
      AND c.date_created IS NOT NULL
      AND (c.owner_position_ids && v_position_ids)
      AND (
            CASE 
              WHEN array_length(ARRAY[p_object_category_ids]::bigint[], 1) > 0 THEN
                c.object_category_id = ANY (p_object_category_ids)
              ELSE TRUE
            END
          )
      AND (
            CASE 
              WHEN array_length(p_partner_ids, 1) > 0 THEN
                ccfv.int_array_value && p_partner_ids
              ELSE TRUE
            END
          );
  END IF;
  
  RETURN v_count;
END;
$function$
;
