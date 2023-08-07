drop function if exists brs.get_all_users_overrides_earned_in_payroll_snapshot(p_payroll_id bigint, p_run_by_id bigint);
CREATE OR REPLACE FUNCTION brs.get_all_users_overrides_earned_in_payroll_snapshot(p_payroll_id bigint, p_run_by_id bigint)
  RETURNS TABLE
          (
            closer                TEXT,
            project_id            bigint,
            customer_name         TEXT,
            system_size           NUMERIC(10, 2),
            override_earned       numeric,
            prior_pay             NUMERIC,
            current_pay           NUMERIC,
            override_plan_name    character varying,
            total_user_allocation NUMERIC(10, 2),
            milestone1_amount     NUMERIC(10, 2),
            milestone2_amount     NUMERIC(10, 2),
            plan_total            NUMERIC(10, 2)
          )

AS
$BODY$
declare
  v_period_end_date date;
  v_position_id     bigint;
BEGIN
  select period_end, position_id
  into v_period_end_date,v_position_id
  from brs.payroll
  where id = p_payroll_id;

  case
    when v_position_id = 1 then RETURN QUERY
      SELECT
        CONCAT(u.first_name, ' ', u.last_name) AS closer,
        pcl.project_id,
        pd.project_name,
        pcs.system_size,
        pcl.amount AS overrides_earned,
        (select sum(pcl1.paid_to_date)
         from brs.project_commission_ledger pcl1
         where pcl1.ledger_type_id = 3 and pcl1.payroll_id < p_payroll_id and
             pcl1.project_id = pcl.project_id ) AS prior_pay,
        (select sum(pcl2.paid_to_date)
         from brs.project_commission_ledger pcl2
         where pcl2.ledger_type_id = 3 and pcl2.payroll_id = p_payroll_id and
             pcl2.project_id = pcl.project_id) AS current_pay,
        pcs.override_plan,
        (COALESCE(opru.m1_allocation, 0) + COALESCE(opru.m2_allocation, 0)) AS user_allocation,
        COALESCE(opru.m1_allocation, 0) AS m1_allocation,
        COALESCE(opru.m2_allocation, 0) AS m2_allocation,
        op.total
      FROM brs.project_commission_ledger pcl
             INNER JOIN brs.project_details pd ON pd.project_id = pcl.project_id
        AND pcl.payroll_id = p_payroll_id
        AND pcl.ledger_type_id = 3
             INNER JOIN flow.user u ON pcl.user_id = u.id
             INNER JOIN (
        SELECT DISTINCT pcs2.project_id, pcs2.override_plan, pcs2.override_plan_id, pcs2.system_size,cancelled
        FROM brs.project_commission_snapshot pcs2
        WHERE pcs2.payroll_id = p_payroll_id
      ) AS pcs ON pcs.project_id = pcl.project_id
             INNER JOIN brs.payroll p ON pcl.payroll_id = p.id
             INNER JOIN brs.override_plan op ON pcs.override_plan_id = op.id
             LEFT JOIN brs.override_plan_receiving_user opru ON pcs.override_plan_id = opru.override_plan_id AND opru.user_id = pcl.user_id
      WHERE pcl.paid_to_date != 0
      group by 1,2,3,4,5,8,9,10,11,12;
    when v_position_id = 4 then RETURN QUERY select results.closer,
                                                    results.project_id::bigint,
                                                    results.customer_name,
                                                    results.system_size,
                                                    results.overrides_earned,
                                                    results.prior_pay,
                                                    results.overrides_earned - results.prior_pay as current_pay,
                                                    results.override_plan_name,
                                                    results.user_allocation,
                                                    results.milestone1_percentage,
                                                    results.milestone2_percentage,
                                                    results.plan_total
                                             from (select u.first_name || ' ' || u.last_name      as closer,
                                                          p.id                                    as project_id,
                                                          p.project_name                          as customer_name,
                                                          pd.system_size,
                                                          coalesce(sum(amount), 0)                   overrides_earned,
                                                          (select coalesce(sum(paid_to_date), 0) prior_pay
                                                           from brs.project_commission_ledger pcl1
                                                                  inner join flow.project p1
                                                                             on p1.id = pcl1.project_id
                                                                  inner join flow.user u1
                                                                             on u1.id = pcl1.user_id
                                                           where ledger_type_id = 3
                                                             and payroll_id < p_payroll_id
                                                             and p1.id = p.id
                                                             and pcl1.user_id = pcl.user_id
                                                             and pcl1.position_id = 4)            as prior_pay,
                                                          sum(amount) - sum(paid_to_date)         as current_pay,
                                                          op.name                                 as override_plan_name,
                                                          opru.m1_allocation + opru.m2_allocation as user_allocation,
                                                          opru.m1_allocation                      as milestone1_percentage,
                                                          opru.m2_allocation                      as milestone2_percentage,
                                                          op.total                                as plan_total
                                                   from brs.project_commission_ledger pcl
                                                          inner join flow.project p
                                                                     on p.id = pcl.project_id
                                                          inner join brs.project_details pd on pd.project_id = p.id
                                                          inner join brs.project_override po on po.project_id = p.id
                                                          inner join brs.override_plan op on op.id = po.override_plan_id
                                                          inner join flow.user u
                                                                     on u.id = pcl.user_id
                                                          inner join brs.override_plan_receiving_user opru
                                                                     on opru.override_plan_id = op.id
                                                                       and opru.user_id = u.id
                                                   where ledger_type_id = 3
                                                     and payroll_id = p_payroll_id
                                                     and pcl.position_id = 4
                                                   group by closer, p.id, p.project_name, pd.system_size, pcl.user_id,
                                                            op.name,
                                                            opru.m1_allocation, opru.m2_allocation, op.total
                                                   order by closer) as results
                                             where results.overrides_earned - results.prior_pay != 0;

    end case;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
