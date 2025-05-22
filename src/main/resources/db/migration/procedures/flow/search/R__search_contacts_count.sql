DROP FUNCTION IF EXISTS flow.search_contacts_count(varchar, int8, _int8, bool, _int8);

CREATE OR REPLACE FUNCTION flow.search_contacts_count(p_searchterm character varying, p_company_id bigint, p_object_category_ids bigint[], p_is_parent boolean, p_partner_ids bigint[] DEFAULT ARRAY[]::bigint[])
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_clean_name_search_term    VARCHAR;
  v_clean_phone_search_term   VARCHAR;
  v_clean_email_search_term   VARCHAR;
  v_clean_address_search_term VARCHAR;
  v_company_ids               bigint[];
  v_count                     bigint;
BEGIN
  v_clean_name_search_term = lower(trim(translate(p_searchterm, '*,.&- ', '')));
  v_clean_phone_search_term = trim(translate(p_searchterm, '-(). ', ''));
  v_clean_email_search_term = lower(trim(p_searchterm));
  v_clean_address_search_term = trim(lower(translate(p_searchterm, '.,', '')));

  if p_is_parent then
    select array(select f.id from flow.company_hierarchy_filter_down(p_company_id) f)
    into v_company_ids;
  else
    select array(select p_company_id)
    into v_company_ids;
  end if;

  select count(*)
  into v_count
  from flow.contact c
       inner join flow.contact_type ct on ct.id = c.contact_type_id
       left join flow.company_state cs on cs.id = c.company_state_id
       left join flow.state s on s.id = cs.state_id
       left join flow.user_position up on up.id = c.owner_user_position_id
       left join flow."user" u on u.id = up.user_id
       left join flow.contact_custom_field_value ccfv on ccfv.contact_id = c.id and ccfv.custom_field_group_assignment_id = 27973
  WHERE c.company_id = ANY (v_company_ids)
    and c.date_created is not null
    and c.archived is not true
    and case
          when p_object_category_ids is not null and array_length(p_object_category_ids, 1) > 0
              then c.object_category_id = any (p_object_category_ids)
          else true end
    and case
          when array_length(p_partner_ids, 1) > 0 then
            ccfv.int_array_value && p_partner_ids
          else true
        end
    and ((c.id::text like '%' || v_clean_name_search_term || '%')
      or (c.contact_full_name_search like '%' || v_clean_name_search_term || '%')
      or (c.contact_street_search like '%' || v_clean_address_search_term || '%')
      or (c.contact_email_search like '%' || v_clean_email_search_term || '%')
      or (c.contact_mobile_search like '%' || v_clean_phone_search_term || '%')
      or (c.contact_phone_search like '%' || v_clean_phone_search_term || '%'));

  RETURN v_count;
END;
$function$
;
