DROP FUNCTION IF EXISTS brs.get_request_for_installation_agreements_count(boolean, boolean, bigint, bigint, character varying);

CREATE OR REPLACE FUNCTION brs.get_request_for_installation_agreements_count(
  p_view_all boolean,
  p_show_cancelled boolean,
  p_platform_user_id bigint,
  p_company_id bigint,
  p_searchterm character varying
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
  WHERE case
          when p_view_all is false then
            pd.closer_user_id = p_platform_user_id
          else 1 = 1
    end
    and (pd.cancelled_date is null or p_show_cancelled is true)
    AND pd.archived is false
    AND pd.company_id = p_company_id
    AND (pd.project_name ILIKE '%' || p_searchterm || '%'
        OR CAST(pd.project_id AS TEXT) ILIKE '%' || p_searchterm || '%');
  return p_agreement_count;
END
$function$
