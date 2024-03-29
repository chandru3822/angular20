drop function if exists brs.get_total_commissions_by_project_status(p_closer_user_id bigint,p_company_project_status_type_id bigint);
CREATE or replace function brs.get_total_commissions_by_project_status(p_closer_user_id bigint,p_company_project_status_type_id bigint)
  RETURNS json AS
$BODY$
  declare
  v_commissions json;
  v_status_name text;
    x record;
begin

      select project_status_type
      into v_status_name
      from flow.company_project_status_type
      where id = p_company_project_status_type_id;

      create temp table commissions (
        total_by_status numeric,
        commission_at_fdc numeric,
        commission_at_substantial_completion numeric
      );

      for x in select coalesce(fd.total_commissions, 0)                                 as total_commissions,
                      coalesce(fd.total_commissions_paid_to_date, 0)                    as total_commissions_paid_to_date,
                      coalesce(pd.commission_forfeited_by_closer, 0)                    as commission_forfeited_by_closer,
                      coalesce(fd.commissions_earned_m1, 0)                             as commissions_earned_m1,
                      coalesce(fd.commissions_earned_m2, 0)                             as commissions_earned_m2,
                      round((SUM(coalesce(fd.total_commissions, 0)) OVER ()
                        - SUM(coalesce(fd.total_commissions_paid_to_date, 0)) OVER ()
                        - SUM(coalesce(pd.commission_forfeited_by_closer, 0)) OVER ())) as total_by_status
               from flow.project p
                      inner join brs.financial_details fd on fd.project_id = p.id
                      inner join brs.project_details pd on pd.project_id = fd.project_id
               where pd.company_project_status_type_id = p_company_project_status_type_id
                 and pd.closer_user_id = p_closer_user_id


      loop
        insert into commissions(total_by_status, commission_at_fdc, commission_at_substantial_completion)
        values (x.total_by_status,
                case
                  when x.commission_forfeited_by_closer > 0 and
                       x.commission_forfeited_by_closer > x.total_commissions - x.commissions_earned_m1 then
                    x.commissions_earned_m1 - x.total_commissions_paid_to_date -
                    (x.commission_forfeited_by_closer -
                     (x.total_commissions - x.commissions_earned_m1))
                  else x.commissions_earned_m1 - x.total_commissions_paid_to_date end,
        case when x.commissions_earned_m2 > 0 and
                  x.commissions_earned_m2 - x.commission_forfeited_by_closer > 0 then
          x.commissions_earned_m2 - x.commission_forfeited_by_closer
             else
               0
          end);

      end loop;

    select json_agg(row_to_json(commission))
    into v_commissions
    from (
      select v_status_name as "statusType",
             c.total_by_status as "totalByStatus",
             c.commission_at_fdc as "commissionAtFdc",
             c.commission_at_substantial_completion as "commissionAtSubstantialCompletion"
    from commissions c) as commission;

      drop table if exists  commissions;
    return coalesce(v_commissions, concat('{ "statusType": "' || v_status_name || '",
            "totalByStatus": 0.0,
            "commissionAtFdc": 0.0,
            "commissionAtSubstantialCompletion": 0.0 }')::json);
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
