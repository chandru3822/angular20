drop function if exists brs.get_total_overrides( p_payroll_id bigint,p_project_ids bigint[],p_user_id bigint,p_position_id bigint);
CREATE OR REPLACE FUNCTION brs.get_total_overrides( p_payroll_id bigint,p_project_ids bigint[],p_user_id bigint,p_position_id bigint)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total numeric;
  v_payroll_status_id bigint;
BEGIN
  begin
    select payroll_status_id
    into v_payroll_status_id
    from brs.payroll p
    where p.id = p_payroll_id
    group by payroll_status_id;
  END;


    select
      (
        select coalesce(sum(pcl.paid_to_date),0)
        from brs.project_commission_ledger pcl
          inner join flow.project p on p.id = pcl.project_id
        WHERE pcl.project_id = any(p_project_ids)  and
              pcl.ledger_type_id = 3
        and pcl.user_id = p_user_id
                   and  pcl.payroll_id < p_payroll_id
          and pcl.position_id = p_position_id

      --  group by dcl.closer_id
--         SELECT coalesce(sum(docs.total), 0)
--         FROM blueraven.deal_commission_snapshot dcs
--           inner join blueraven.deal d on d.id = dcs.deal_id
--           inner join blueraven.deal_override_commission_snapshot docs on docs.deal_commission_snapshot_id = dcs.id
--         WHERE d.id = any( p_deal_ids )
          --         and docs.user_id = p_user_id AND
--               case when v_payroll_status_id = 3 THEN
--                 dcs.payroll_id < p_payroll_id
--               else 1=1 end
          )
    into v_total;
  return v_total;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
