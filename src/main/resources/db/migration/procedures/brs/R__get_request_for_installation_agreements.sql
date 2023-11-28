DROP FUNCTION IF EXISTS brs.get_request_for_installation_agreements(boolean, boolean, bigint, bigint, character varying, bigint, bigint);

CREATE OR REPLACE FUNCTION brs.get_request_for_installation_agreements(
  p_view_all boolean,
  p_show_cancelled boolean,
  p_platform_user_id bigint,
  p_company_id bigint,
  p_searchterm character varying,
  p_limit bigint,
  p_offset bigint
)
  RETURNS TABLE
          (
            project_id          bigint,
            customer_name       VARCHAR,
            email               VARCHAR,
            address             TEXT,
            sunpower_url_exists BOOLEAN
          )
  LANGUAGE plpgsql
AS
$function$

declare

BEGIN

  RETURN QUERY
SELECT pd.project_id::bigint                                                       AS project_id,
       pd.project_name,
       pd.contact_email as email,
       concat(pd.project_street1, ', ', pd.project_city, ', ', s.state, ' ', pd.project_postal_code) AS address,
       (case
          when (select count(*)
                from brs.proposal_log_history plh
                where plh.project_id = pd.project_id and plh.sunpower_url is not null) > 0 then true
          else false end)
FROM brs.project_details pd
       inner join flow.company_state cs on pd.project_company_state_id = cs.id
       INNER JOIN flow.state s ON s.id = cs.state_id
WHERE case
        when p_view_all is false then
            pd.closer_user_id = p_platform_user_id
        else 1 = 1 end
  and (pd.cancelled_date is null or p_show_cancelled is true)
  AND pd.archived is false
  AND (pd.project_name ILIKE '%' || p_searchterm || '%'
        OR CAST(pd.project_id AS TEXT) ILIKE '%' || p_searchterm || '%')
  and pd.company_id = p_company_id
  limit p_limit offset p_offset;

END
$function$
