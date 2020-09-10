-- Function: blueraven.get_commission_summary_from_snapshot(integer)

-- DROP FUNCTION blueraven.get_commission_summary_from_snapshot(integer);

CREATE OR REPLACE FUNCTION brs.get_commission_summary_from_snapshot(p_payroll_id INTEGER)
  RETURNS  JSON AS
$BODY$
declare
    v_json json;
BEGIN

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
                                            FROM brs.project_commission_ledger
                                            WHERE ledger_type_id = 3
                                              AND closer_id = u.id
                                              AND payroll_id = p_payroll_id
                                              AND project_id IN (SELECT project_id
                                                              FROM brs.project_commission_snapshot dcs
                                                              WHERE payroll_id = p_payroll_id)
                                              AND closer_id IN (SELECT sales_rep_id
                                                                FROM brs.project_commission_snapshot dcs
                                                                WHERE dcs.payroll_id = p_payroll_id)), 0)
                                    -
                                  coalesce((SELECT sum(paid_to_date)
                                            FROM brs.project_commission_ledger
                                            WHERE ledger_type_id = 3
                                              AND payroll_id < p_payroll_id
                                              AND closer_id = u.id
                                              AND project_id IN (SELECT project_id
                                                              FROM brs.project_commission_snapshot dcs
                                                              WHERE payroll_id = p_payroll_id)
                                              AND closer_id IN (SELECT sales_rep_id
                                                                FROM brs.project_commission_snapshot dcs
                                                                WHERE dcs.payroll_id = p_payroll_id)), 0)
                                                                              AS total_overrides,
                                  sum(coalesce(dcs.commission_adjustment, 0))    total_adjustments
                           FROM brs.project_commission_snapshot dcs
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
                                            FROM brs.project_commission_ledger
                                            WHERE ledger_type_id = 3
                                              AND payroll_id = p_payroll_id
                                              AND closer_id = u.id
                                              AND project_id IN (SELECT project_id
                                                              FROM brs.project_commission_snapshot dcs
                                                              WHERE payroll_id = p_payroll_id)
                                              AND closer_id NOT IN (SELECT sales_rep_id
                                                                    FROM brs.project_commission_snapshot
                                                                    WHERE payroll_id = p_payroll_id)), 0)
                                    -
                                  coalesce((SELECT sum(paid_to_date)
                                            FROM brs.project_commission_ledger
                                            WHERE ledger_type_id = 3
                                              AND closer_id = u.id
                                              AND payroll_id < p_payroll_id
                                              AND project_id IN (SELECT project_id
                                                              FROM brs.project_commission_snapshot dcs
                                                              WHERE payroll_id = p_payroll_id)
                                              AND closer_id NOT IN (SELECT sales_rep_id
                                                                    FROM brs.project_commission_snapshot
                                                                    WHERE payroll_id = p_payroll_id)), 0)
                                    AS total_overrides,
                                  0    total_adjustments
                           FROM brs.project_override_commission_snapshot docs
                                  INNER JOIN brs.project_commission_snapshot dcs
                                    ON dcs.id = docs.project_commission_snapshot_id
                                  INNER JOIN flow.user u ON u.id = docs.user_id
                                  INNER JOIN brs.project_commission_ledger dcl3 ON dcl3.project_id = dcs.project_id
--                                   left join lateral (select * from flow.get_value_for_custom_field(4 ,
--                                                                                                    58,
--                                                                                                    p.id,
--                                                                                                    4)as employee_id) as employee_id on true
                           WHERE dcs.payroll_id = p_payroll_id
                             AND docs.user_id NOT IN (SELECT sales_rep_id
                                                      FROM brs.project_commission_snapshot dcs1
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
                                               AND closer_id = u.id
                                               AND payroll_id = 0
                                               AND dcl5.project_id = d.id), 0))
                                    AS total_overrides,
                                  0    total_adjustments
                           FROM brs.project_commission_ledger dcl3
                                  INNER JOIN flow.project d ON d.id = dcl3.project_id
                                  INNER JOIN flow.user u ON u.id = dcl3.closer_id
--                                   left join lateral (select * from flow.get_value_for_custom_field(4 ,
--                                                                                                    58,
--                                                                                                    p.id,
--                                                                                                    4)as employee_id) as employee_id on true
                           WHERE dcl3.ledger_type_id = 3
                             AND dcl3.payroll_id = 0
                             AND ARRAY[d.id] <@ (SELECT selected_project_ids::integer[]
                                                            FROM brs.payroll
                                                            WHERE id = p_payroll_id)
                             AND dcl3.closer_id NOT IN (SELECT dcs1.closer_id
                                                        FROM brs.project_commission_ledger dcs1
                                                        WHERE dcs1.payroll_id = p_payroll_id
                                                          AND dcl3.ledger_type_id = 3)
                             AND u.id NOT IN (SELECT sales_rep_id
                                              FROM brs.project_commission_snapshot dcs1
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
