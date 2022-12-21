drop function if exists brs.get_commission_summary_from_snapshot_for_setters(p_payroll_id bigint, p_run_by_id bigint);
CREATE OR REPLACE FUNCTION brs.get_commission_summary_from_snapshot_for_setters(p_payroll_id bigint, p_run_by_id bigint)
  RETURNS  JSON AS
$BODY$
declare
    v_json json;
BEGIN
    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Get Commission Summary from Snapshot for Setters', 'p_payroll_id: ' || p_payroll_id ||
                                                                ' p_run_by_id: ' || p_run_by_id,
            p_run_by_id);

   SELECT array_to_json(array_agg(row_to_json(sub_rows)))
               FROM (SELECT id,
                            --'1234' as employee_id,
                            concat(first_name, ' ', last_name) as closer_user,
                            total_commissions              AS total_commission,
                            total_overrides                AS total_overrides,
                            total_adjustments              AS commission_adjustments,
                            (coalesce(total_commissions, 0) + coalesce(total_adjustments, 0) +
                             coalesce(total_overrides, 0)) AS current_pay
                     FROM (SELECT u.id,
                                  u.first_name,
                                  u.last_name,
                                 -- employee_id.employee_id,
                                  (sum(coalesce(commissions_earned, 0)) -
                                   sum(coalesce(commission_paid_to_date, 0))) AS total_commissions,
                                  coalesce((SELECT sum(amount)
                                            FROM brs.project_commission_ledger pcl
                                            WHERE ledger_type_id = 3
                                              AND pcl.user_id = u.id
                                              and pcl.position_id = 4
                                              AND payroll_id = p_payroll_id
                                              AND project_id IN (SELECT project_id
                                                              FROM brs.setter_project_commission_snapshot dcs
                                                              WHERE payroll_id = p_payroll_id)
                                              AND pcl.user_id IN (SELECT sales_rep_id
                                                                FROM brs.setter_project_commission_snapshot dcs
                                                                WHERE dcs.payroll_id = p_payroll_id)), 0)
                                    -
                                  coalesce((SELECT sum(paid_to_date)
                                            FROM brs.project_commission_ledger pcl2
                                            WHERE ledger_type_id = 3
                                              AND payroll_id < p_payroll_id
                                              AND pcl2.user_id = u.id
                                              and pcl2.position_id = 4
                                              AND project_id IN (SELECT project_id
                                                              FROM brs.setter_project_commission_snapshot dcs
                                                              WHERE payroll_id = p_payroll_id)
                                              AND pcl2.user_id IN (SELECT sales_rep_id
                                                                FROM brs.setter_project_commission_snapshot dcs
                                                                WHERE dcs.payroll_id = p_payroll_id)), 0)
                                                                              AS total_overrides,
                                  sum(coalesce(dcs.commission_adjustment, 0))    total_adjustments
                           FROM brs.setter_project_commission_snapshot dcs
                                  INNER JOIN flow.user u ON u.id = dcs.sales_rep_id
--                                   left join lateral (select * from flow.get_value_for_custom_field(4 ,
--                                                                                                    58,
--                                                                                                    p.id,
--                                                                                                    4)as employee_id) as employee_id on true
                           WHERE dcs.payroll_id = p_payroll_id
                           GROUP BY u.id, u.first_name, u.last_name--, employee_id.employee_id
                           ORDER BY first_name) AS foo
                     UNION
                     SELECT id,
                           -- employee_id,
                            concat(first_name, ' ', last_name) as closer_user,
                            total_commissions,
                            total_overrides,
                            total_adjustments,
                            (total_commissions + total_adjustments + total_overrides) AS current_pay
                     FROM (SELECT u.id,
                                  u.first_name,
                                  u.last_name,
                                 -- employee_id.employee_id,
                                  0 AS total_commissions,
                                  coalesce((SELECT sum(amount)
                                            FROM brs.project_commission_ledger pcl3
                                            WHERE ledger_type_id = 3
                                              AND payroll_id = p_payroll_id
                                              AND pcl3.user_id = u.id
                                              and pcl3.position_id = 4
                                              AND project_id IN (SELECT project_id
                                                              FROM brs.setter_project_commission_snapshot dcs
                                                              WHERE payroll_id = p_payroll_id)
                                              AND pcl3.user_id NOT IN (SELECT sales_rep_id
                                                                    FROM brs.setter_project_commission_snapshot
                                                                    WHERE payroll_id = p_payroll_id)), 0)
                                    -
                                  coalesce((SELECT sum(paid_to_date)
                                            FROM brs.project_commission_ledger pcl4
                                            WHERE ledger_type_id = 3
                                              AND pcl4.user_id = u.id
                                              and pcl4.position_id = 4
                                              AND payroll_id < p_payroll_id
                                              AND project_id IN (SELECT project_id
                                                              FROM brs.setter_project_commission_snapshot dcs
                                                              WHERE payroll_id = p_payroll_id)
                                              AND pcl4.user_id NOT IN (SELECT sales_rep_id
                                                                    FROM brs.setter_project_commission_snapshot
                                                                    WHERE payroll_id = p_payroll_id)), 0)
                                    AS total_overrides,
                                  0    total_adjustments
                           FROM brs.setter_project_override_commission_snapshot docs
                                  INNER JOIN brs.setter_project_commission_snapshot dcs
                                    ON dcs.id = docs.setter_project_commission_snapshot_id
                                  INNER JOIN flow.user u ON u.id = docs.user_id
                                  INNER JOIN brs.project_commission_ledger dcl3 ON dcl3.project_id = dcs.project_id
--                                   left join lateral (select * from flow.get_value_for_custom_field(4 ,
--                                                                                                    58,
--                                                                                                    p.id,
--                                                                                                    4)as employee_id) as employee_id on true
                           WHERE dcs.payroll_id = p_payroll_id
                             AND docs.user_id NOT IN (SELECT sales_rep_id
                                                      FROM brs.setter_project_commission_snapshot dcs1
                                                      WHERE dcs1.payroll_id = p_payroll_id)
                         --                              AND dcs.deal_id IN (SELECT deal_id
                         --                                                  FROM blueraven.deal_commission_snapshot dcs1
                         --                                                  WHERE dcs1.payroll_id = p_payroll_id)
                           GROUP BY u.id, u.first_name, u.last_name--, employee_id.employee_id
                            ) AS poo
                     UNION
                     SELECT id,
                            --employee_id,
                            concat(first_name, ' ', last_name) as closer_user,
                            total_commissions,
                            total_overrides,
                            total_adjustments,
                            (total_commissions + total_adjustments + total_overrides) AS current_pay
                     FROM (SELECT u.id,
                                  u.first_name,
                                  u.last_name,
                                --  employee_id.employee_id,
                                  0 AS total_commissions,
                                  0 :: NUMERIC
                                    -
                                  (coalesce((SELECT sum(paid_to_date)
                                             FROM brs.project_commission_ledger dcl5
                                                    INNER JOIN flow.project d5 ON d5.id = dcl5.project_id
                                             WHERE ledger_type_id = 3
                                               AND dcl5.user_id = u.id
                                               and dcl5.position_id = 4
                                               AND payroll_id = 0
                                               AND dcl5.project_id = d.id), 0))
                                    AS total_overrides,
                                  0    total_adjustments
                           FROM brs.project_commission_ledger dcl3
                                  INNER JOIN flow.project d ON d.id = dcl3.project_id
                                  INNER JOIN flow.user u ON u.id = dcl3.user_id
                                  inner join brs.payroll p  on p.id = dcl3.payroll_id
                           WHERE dcl3.ledger_type_id = 3
                             and dcl3.position_id = 4
                             AND dcl3.payroll_id = 0
                             AND d.id = any(p.selected_project_ids)
                             AND dcl3.user_id NOT IN (SELECT dcs1.user_id
                                                        FROM brs.project_commission_ledger dcs1
                                                        WHERE dcs1.payroll_id = p_payroll_id
                                                          AND dcs1.ledger_type_id = 3
                                                          and dcs1.position_id = 4)
                             AND u.id NOT IN (SELECT sales_rep_id
                                              FROM brs.setter_project_commission_snapshot dcs1
                                              WHERE dcs1.payroll_id = p_payroll_id)
                           GROUP BY u.id, u.first_name, u.last_name--, employee_id.employee_id
                          , d.id
                            )AS zoo
                     ORDER BY closer_user) AS sub_rows
       into v_json;
       return v_json;
END
$BODY$
LANGUAGE plpgsql
VOLATILE
COST 100;
