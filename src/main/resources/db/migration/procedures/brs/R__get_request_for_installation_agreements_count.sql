DROP FUNCTION IF EXISTS brs.get_request_for_installation_agreements_count(boolean, boolean, bigint, bigint, character varying);
DROP FUNCTION IF EXISTS brs.get_request_for_installation_agreements_count(boolean, boolean, bigint, bigint, character varying, bigint[]);


-- todo: this query needs to die. Should return total row counts in brs.get_request_for_installation_agreements
CREATE OR REPLACE FUNCTION brs.get_request_for_installation_agreements_count(
  p_view_all boolean,
  p_show_cancelled boolean,
  p_platform_user_id bigint,
  p_company_id bigint,
  p_searchterm character varying,
  p_partner_ids bigint[] default array[]::bigint[]
)
  RETURNS bigint
  LANGUAGE plpgsql
AS
$function$

declare
  p_agreement_count bigint;
BEGIN
  SELECT count(*)
  into p_agreement_count
  FROM brs.project_details pd
         inner join flow.company_state cs on pd.project_company_state_id = cs.id
         INNER JOIN flow.state s ON s.id = cs.state_id
         -- potential perf issue, maybe add partner_ids to project_details
         left join flow.project_custom_field_value pcfv on pcfv.project_id = pd.project_id and
                                                           pcfv.custom_field_group_assignment_id = 27972
  WHERE case
          when p_view_all is false then
            pd.closer_user_id = p_platform_user_id
          else 1 = 1
    end
    and (pd.cancelled_date is null or p_show_cancelled is true)
    AND pd.archived is false
    AND pd.company_id = p_company_id
    AND (pd.project_name ILIKE '%' || p_searchterm || '%'
        OR CAST(pd.project_id AS TEXT) ILIKE '%' || p_searchterm || '%')
    and case
        when array_length(p_partner_ids, 1) > 0 then
          pcfv.int_array_value && p_partner_ids
        else true
      end;
  return p_agreement_count;
END
$function$
