drop function if exists brs.get_total_commissions_by_project_status(p_closer_user_id bigint,p_company_project_status_type_id bigint);
CREATE or replace function brs.get_total_commissions_by_project_status(p_closer_user_id bigint,p_company_project_status_type_id bigint)
  RETURNS json AS
$BODY$
  declare
  v_commissions json;
  v_status_name text;
begin

      select project_status_type
      into v_status_name
      from flow.company_project_status_type
      where id = p_company_project_status_type_id;

    select row_to_json(commission)
    into v_commissions
  from (
  select pd.company_project_status_type "statusType",
         round(sum(coalesce(fd.total_commissions,0)) - sum(coalesce(fd.total_commissions_paid_to_date,0))) "totalByStatus",
         round(sum(coalesce(fd.commissions_earned_m1,0)) - sum(coalesce(fd.total_commissions_paid_to_date,0))) as "commissionAtFdc",
         case when sum(coalesce(fd.commissions_earned_m2,0)) > 0 then
                round(sum(coalesce(fd.commissions_earned_m2,0)))
              else
                round(sum(coalesce(fd.total_commissions,0)) - sum(coalesce(fd.commissions_earned_m1,0)))
           end
                                                                                                        as "commissionAtSubstantialCompletion"
  from flow.project p
         inner join brs.financial_details fd on fd.project_id=p.id
         inner join brs.project_details pd on pd.project_id = fd.project_id
  where pd.company_project_status_type_id = p_company_project_status_type_id
    and pd.closer_user_id = p_closer_user_id
  group by pd.company_project_status_type) as commission;
    return coalesce(v_commissions, concat('{ "statusType": "' || v_status_name || '",
            "totalByStatus": 0.0,
            "commissionAtFdc": 0.0,
            "commissionAtSubstantialCompletion": 0.0 }')::json);
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
