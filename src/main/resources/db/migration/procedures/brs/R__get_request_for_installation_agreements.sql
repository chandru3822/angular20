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
SELECT p.id::bigint                                                       AS project_id,
  p.project_name,
       c.email,
       concat(p.street1, ', ', p.city, ', ', s.state, ' ', p.postal_code) AS address,
       (case
          when (select count(*)
                from brs.proposal_log_history plh
                where plh.project_id = p.id and plh.sunpower_url is not null) > 0 then true
          else false end)
FROM flow.project p
       left join brs.project_details pd on pd.project_id = p.id
       INNER JOIN flow.contact c ON c.id = p.contact_id
       inner join flow.company_state cs on p.company_state_id = cs.id
       INNER JOIN flow.state s ON s.id = cs.state_id
WHERE case
        when p_view_all is false then
            pd.closer_user_id = p_platform_user_id
        else 1 = 1 end
  and (pd.cancelled_date is null or p_show_cancelled is true)
  AND p.archived is false
  AND (p.project_name ILIKE '%' || p_searchterm || '%'
        OR CAST(p.id AS TEXT) ILIKE '%' || p_searchterm || '%')
  and c.company_id = p_company_id
  limit p_limit offset p_offset;

END
$function$
