CREATE or replace function brs.get_commission_summary()
 RETURNS JSON AS
$BODY$
declare
    v_json json;
begin
    with all_project_ids as (
        select array_agg(DISTINCT pd.closer_user_id) as user_ids,array_agg(DISTINCT p.id) v_all_projects,pay.id
        from brs.payroll pay
                 inner join flow.project p on p.id = any(pay.selected_project_ids)
                 inner join brs.project_details pd on pd.project_id = p.id
        where  current is true
        group by pay.id
    ),
         users AS (SELECT opru.user_id AS user_id, array_agg(DISTINCT p2.id) AS project_ids,p.id,a.v_all_projects,
                          coalesce(brs.get_overrides_earned(a.v_all_projects, opru.user_id), 0) as overrides_earned,
                          coalesce(brs.get_total_overrides(p.id, a.v_all_projects, opru.user_id), 0)as total_overrides
                   FROM brs.override_plan_receiving_user opru
                       inner join brs.override_plan op on op.id = opru.override_plan_id
                       inner join brs.project_override po on po.override_plan_id = op.id
                            INNER JOIN flow.project p2 ON p2.id = po.project_id
                            INNER JOIN brs.payroll p
                                       ON p2.id = any( p.selected_project_ids) and current is true
                            inner join all_project_ids a on a.id = p.id
                   WHERE  not (opru.user_id = any(user_ids))
                   GROUP BY opru.user_id,p.id,a.v_all_projects
         ),
         commission_users AS (
             SELECT array_agg(DISTINCT p.id) AS project_ids, pd.closer_user_id AS user_id,pay.id,a.v_all_projects,
                    coalesce(brs.get_commissions_earned(array_agg(DISTINCT p.id)), 0) as commissions_earned,
                    coalesce(brs.get_ledger_totals(pay.id, array_agg(DISTINCT p.id), 1), 0) as ledger_totals,
                    coalesce(brs.get_overrides_earned(a.v_all_projects,pd.closer_user_id), 0) as overrides_earned,
                    coalesce(brs.get_total_overrides(pay.id, a.v_all_projects, pd.closer_user_id),0) as total_overrides,
                    coalesce(brs.get_ledger_adjustment_current_totals(pay.id, array_agg(DISTINCT p.id), 1),0) as ledger_adjustments
             FROM brs.payroll pay
                      INNER JOIN flow.project p ON p.id = any(pay.selected_project_ids)
                      inner join brs.project_details pd on pd.project_id = p.id
                      inner join all_project_ids a on a.id = pay.id
             WHERE  pay.current is true
             GROUP BY pd.closer_user_id,pay.id,a.v_all_projects
         )select * from commission_users;
    SELECT array_to_json(array_agg(row_to_json(sub_rows)))
    FROM (
    SELECT u3.id,
           u3.first_name||' '||u3.last_name                                                       AS closer_user,
           cu.commissions_earned - cu.ledger_totals AS total_commission,
           cu.overrides_earned - cu.total_overrides  AS total_overrides,
           cu.ledger_adjustments                     AS commission_adjustments,
           cu.commissions_earned +
           cu.overrides_earned +
           cu.ledger_adjustments-
           (cu.ledger_totals +
           cu.total_overrides)  AS current_pay
    FROM commission_users cu
             INNER JOIN flow.user u3 ON u3.id = cu.user_id
    GROUP BY u3.id, project_ids,cu.id,cu.v_all_projects,cu.commissions_earned,cu.overrides_earned,cu.ledger_adjustments,
             cu.total_overrides,cu.ledger_totals
    UNION
    SELECT u1.id,
           u1.first_name||' '||u1.last_name                                             AS closer_user,
           0                                                                            AS total_commission,
           u.overrides_earned - u.total_overrides AS total_overrides,
           0                                                                            AS commission_adjustments,
           u.overrides_earned - u.total_overrides AS current_pay
    FROM flow.user u1
             INNER JOIN users u ON u.user_id = u1.id
    GROUP BY u1.id, project_ids,u.id,u.v_all_projects,u.overrides_earned,u.total_overrides
        into v_json
        )AS sub_rows;
    return v_json;
END
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    COST 100;
