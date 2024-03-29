drop function if exists brs.get_commissions_by_project_status(p_company_project_status_type_id bigint,p_project_id bigint);
CREATE or replace function brs.get_commissions_by_project_status(p_company_project_status_type_id bigint,p_project_id bigint )
  RETURNS table (
                  company_project_status_type character varying,
                  commissions_outstanding numeric
                ) AS
$BODY$
declare
begin
  return query
  select pd.company_project_status_type,
         round(coalesce(fd.total_commissions,0) - coalesce(fd.total_commissions_paid_to_date,0) - coalesce(pd.commission_forfeited_by_closer,0)) as commissions_outstanding
  from flow.project p
         inner join brs.financial_details fd on fd.project_id=p.id
         inner join brs.project_details pd on pd.project_id = fd.project_id
  where pd.company_project_status_type_id = p_company_project_status_type_id
    and pd.project_id = p_project_id;
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
