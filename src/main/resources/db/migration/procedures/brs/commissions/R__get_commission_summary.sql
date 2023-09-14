drop function if exists brs.get_commission_summary(p_position_id bigint, p_run_by_id bigint);
CREATE or replace function brs.get_commission_summary(p_position_id bigint, p_run_by_id bigint)
  RETURNS JSON AS
$BODY$
declare
  v_json json;
begin

  case
    when p_position_id = 1 then SELECT array_to_json(array_agg(row_to_json(sub_rows)))
                                FROM (with no_commission_users as materialized (select distinct opru.user_id as user_id
                                                                                from brs.payroll pay
                                                                                       inner join flow.project p on p.id = any (pay.selected_project_ids)
                                                                                       inner join brs.project_details pd
                                                                                                  on pd.project_id = p.id --and pd.closer_user_id = 2294153
                                                                                       inner join brs.financial_details f on f.project_id = pd.project_id
                                                                                       inner join brs.override_plan_receiving_user opru
                                                                                                  on opru.override_plan_id = f.override_plan_id
                                                                                where current is true
                                                                                  and pay.position_id = 1
                                                                                union
                                                                                select distinct l.user_id as user_id
                                                                                from brs.payroll pay
                                                                                       inner join flow.project p on p.id = any (pay.selected_project_ids)
                                                                                       inner join brs.project_details pd on pd.project_id = p.id
                                                                                       inner join brs.project_commission_ledger l
                                                                                                  on l.project_id =
                                                                                                     pd.project_id
                                                                                                    and
                                                                                                     l.ledger_type_id =
                                                                                                     3
                                                                                where current is true
                                                                                  and pay.position_id = 1
                                                                                except
                                                                                select distinct pd.closer_user_id as user_id
                                                                                from brs.payroll pay
                                                                                       inner join flow.project p on p.id = any (pay.selected_project_ids)
                                                                                       inner join brs.project_details pd on pd.project_id = p.id
                                                                                where current is true
                                                                                  and pay.position_id = 1)
                                      select *,
                                             foo5.total_commission + foo5.total_overrides +
                                             foo5.commission_adjustments as current_pay
                                      from (select closer_user_id,
                                                   closer_user,
                                                   total_commission total_commission,
                                                   coalesce((select round(sum(total1), 2)
                                                             from (select project_id,
                                                                          case
                                                                            when foo.m1_allocation is not null
                                                                              then overrides_earned1 - total_allocation
                                                                            else 0 - total_allocation end as total1
                                                                   from (select fd.project_id,
                                                                                opru.m1_allocation,
                                                                                case
                                                                                  when pd.cancelled_date is not null
                                                                                    then
                                                                                    0::numeric
                                                                                  when fd.commission_strategy =23610 and fd.substantial_completion_date is not null then
                                                                                    (opru.red_line_m1_allocation + opru.red_line_m2_allocation) * fd.total_commissions
                                                                                  when fd.commission_strategy =23610 and fd.substantial_completion_date is null then
                                                                                      (opru.red_line_m1_allocation) * fd.total_commissions
                                                                                  when fd.substantial_completion_date is not null
                                                                                    then
                                                                                    (opru.m1_allocation + opru.m2_allocation) * fd.system_size
                                                                                  else
                                                                                    opru.m1_allocation * fd.system_size
                                                                                  end       overrides_earned1,
                                                                                coalesce((select sum(pcl1.paid_to_date)
                                                                                          from brs.project_commission_ledger pcl1
                                                                                          where pcl1.project_id = fd.project_id
                                                                                            and pcl1.user_id = pd.closer_user_id
                                                                                            and pcl1.ledger_type_id = 3),
                                                                                         0) total_allocation
                                                                         from brs.payroll p
                                                                                inner join brs.project_details pd on pd.project_id = any (p.selected_project_ids)
                                                                                inner join brs.financial_details fd on fd.project_id = pd.project_id
                                                                                left join brs.override_plan op on op.id = fd.override_plan_id
                                                                                left join brs.override_plan_receiving_user opru
                                                                                          on opru.override_plan_id =
                                                                                             op.id and
                                                                                             opru.user_id =
                                                                                             foo1.closer_user_id
                                                                         where p.current is true
                                                                           and pd.closer_user_id = foo1.closer_user_id
                                                                         group by fd.project_id, opru.m1_allocation,
                                                                                  pd.cancelled_date,
                                                                                  fd.substantial_completion_date,
                                                                                  opru.m2_allocation, fd.system_size,
                                                                                  pd.closer_user_id,
                                                                                  fd.commission_strategy,
                                                                                  opru.red_line_m1_allocation,
                                                                                  opru.red_line_m2_allocation,
                                                                                  fd.total_commissions) as foo) as foo1),
                                                            0)   AS total_overrides,

                                                   (coalesce((select sum(amount)
                                                              from brs.payroll_adjustment pa
                                                              where foo1.closer_user_id = pa.user_id
                                                                and pa.payroll_id = foo1.payroll_id
                                                              group by pa.user_id),
                                                             0)) AS commission_adjustments
                                            from (SELECT d.closer_user_id,
                                                         d.closer_name             AS closer_user,
                                                         current_pay.amount_to_pay AS total_commission,
                                                         p2.id as payroll_id
                                                  FROM brs.project_details d
                                                         inner join brs.payroll p2
                                                                    on d.project_id = any (p2.selected_project_ids) and  p2.current is true
                                                         inner join brs.financial_details fd on fd.project_id = d.project_id
                                                         left join lateral brs.get_current_pay(
                                                    coalesce(fd.total_commissions, 0),
                                                    coalesce(fd.commissions_earned_m1, 0) + case
                                                                                              when fd.substantial_completion_date <= p2.period_end
                                                                                                then
                                                                                                coalesce(fd.commissions_earned_m2, 0)
                                                                                              else 0::numeric end,
                                                    coalesce(fd.total_commissions_paid_to_date, 0),
                                                    coalesce(d.commission_forfeited_by_closer, 0),
                                                    coalesce(fd.total_commissions_forfeited_paid_to_date, 0)) as current_pay on true) as foo1) as foo5
                                      union
                                      select *,
                                             foo5.total_commission + foo5.total_overrides +
                                             foo5.commission_adjustments as current_pay
                                      from (SELECT ncu.user_id,
                                                   concat(u.first_name, ' ', u.last_name) AS closer_user,
                                                   0::numeric                             AS total_commission,
                                                   coalesce((select round(sum(total1), 2)
                                                             from (select project_id,
                                                                          case
                                                                            when foo.m1_allocation is not null
                                                                              then overrides_earned1 - foo.total_allocation
                                                                            else 0 - total_allocation end as total1
                                                                   from (select fd.project_id,
                                                                                opru.m1_allocation,
                                                                                case
                                                                                  when pd.cancelled_date is not null
                                                                                    then
                                                                                    0::numeric
                                                                                  when fd.commission_strategy =23610 and fd.substantial_completion_date is not null then
                                                                                      (opru.red_line_m1_allocation + opru.red_line_m2_allocation) * fd.total_commissions
                                                                                  when fd.commission_strategy =23610 and fd.substantial_completion_date is null then
                                                                                      (opru.red_line_m1_allocation) * fd.total_commissions
                                                                                  when fd.substantial_completion_date is not null
                                                                                    then
                                                                                    (opru.m1_allocation + opru.m2_allocation) * fd.system_size
                                                                                  else
                                                                                    opru.m1_allocation * fd.system_size
                                                                                  end       overrides_earned1,
                                                                                coalesce((select sum(pcl1.paid_to_date)
                                                                                          from brs.project_commission_ledger pcl1
                                                                                          where pcl1.project_id = fd.project_id
                                                                                            and pcl1.user_id = ncu.user_id
                                                                                            and pcl1.ledger_type_id = 3),
                                                                                         0) total_allocation
                                                                         from brs.payroll p
                                                                                inner join brs.project_details pd on pd.project_id = any (p.selected_project_ids)
                                                                                inner join brs.financial_details fd on fd.project_id = pd.project_id
                                                                                left join brs.override_plan op on op.id = fd.override_plan_id
                                                                                left join brs.override_plan_receiving_user opru
                                                                                          on opru.override_plan_id =
                                                                                             op.id and
                                                                                             opru.user_id = ncu.user_id
                                                                         where p.current is true
                                                                         group by fd.system_size, fd.project_id,
                                                                                  opru.m1_allocation,
                                                                                  opru.m2_allocation,
                                                                                  pd.cancelled_date,
                                                                                  fd.substantial_completion_date,
                                                                                  fd.commission_strategy,
                                                                                  opru.red_line_m1_allocation,
                                                                                  opru.red_line_m2_allocation,
                                                                                  fd.total_commissions) as foo) as foo1),
                                                            0)                            AS total_overrides,

                                                   0::numeric                             AS commission_adjustments
                                            FROM no_commission_users ncu
                                                   inner join flow.user u on u.id = ncu.user_id
                                            GROUP BY ncu.user_id, u.first_name, u.last_name) as foo5)
                                       AS sub_rows
                                into v_json;
                                return v_json;
----This section is for setters
    when p_position_id = 4 then with all_project_ids as (select array_agg(DISTINCT pd.setter_user_id) as user_ids,
                                                                array_agg(DISTINCT p.id)                 v_all_projects,
                                                                pay.id
                                                         from brs.payroll pay
                                                                inner join flow.project p on p.id = any (pay.selected_project_ids)
                                                                inner join brs.project_details pd on pd.project_id = p.id
                                                         where current is true
                                                           and pay.position_id = 4
                                                         group by pay.id),
                                     users AS (SELECT opru1.user_id                               AS user_id,
                                                      array_agg(DISTINCT p2.id)                   AS project_ids,
                                                      p.id,
                                                      a.v_all_projects,
                                                      (select coalesce(
                                                                (SELECT case
                                                                          when pd.cancelled_date is not null then
                                                                            0::numeric
                                                                          else coalesce(
                                                                            (select sum(opru.m1_allocation)),
                                                                            0) end total
                                                                 FROM flow.project p1
                                                                        inner join brs.project_details pd on p1.id = pd.project_id
                                                                        inner join brs.project_override po on po.project_id = p1.id
                                                                        inner join brs.override_plan op
                                                                                   on op.id = po.override_plan_id and op.position_id = 4
                                                                        inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id
                                                                 WHERE p1.id = any (a.v_all_projects)
                                                                   and opru.user_id = opru1.user_id
                                                                 group by pd.cancelled_date), 0)) AS overrides_earned,

                                                      -- coalesce(brs.get_overrides_earned(a.v_all_projects,p.period_end, opru.user_id), 0) as overrides_earned,
                                                      coalesce(
                                                        brs.get_total_overrides(p.id, a.v_all_projects, opru1.user_id, 4),
                                                        0)                                        as total_overrides
                                               FROM brs.override_plan_receiving_user opru1
                                                      inner join brs.override_plan op1
                                                                 on op1.id = opru1.override_plan_id and op1.position_id = 4
                                                      inner join brs.project_override po1 on po1.override_plan_id = op1.id
                                                      INNER JOIN flow.project p2 ON p2.id = po1.project_id
                                                      inner join brs.project_details pd2 on pd2.project_id = p2.id
                                                      INNER JOIN brs.payroll p
                                                                 ON p2.id = any (p.selected_project_ids) and current is true
                                                      inner join all_project_ids a on a.id = p.id
                                               WHERE not (opru1.user_id = any (user_ids))
                                               GROUP BY opru1.user_id, p.id, a.v_all_projects),
                                     commission_users AS (SELECT array_agg(DISTINCT p.id) AS project_ids,
                                                                 pd.setter_user_id        AS user_id,
                                                                 pay.id,
                                                                 a.v_all_projects,
                                                                 coalesce(brs.get_commissions_earned_for_setters(
                                                                            array_agg(DISTINCT p.id), pay.period_end),
                                                                          0)              as commissions_earned,
                                                                 coalesce(
                                                                   brs.get_ledger_totals(pay.id, array_agg(DISTINCT p.id), 4, 4),
                                                                   0)                     as ledger_totals,
                                                                 (select coalesce(
                                                                           (SELECT sum(case
                                                                                         when pd1.cancelled_date is not null
                                                                                           then
                                                                                           0::numeric
                                                                                         else coalesce(
                                                                                           (select m1_allocation
                                                                                            from brs.override_plan_receiving_user opru
                                                                                            where opru.override_plan_id = op.id
                                                                                              and opru.user_id = opru2.user_id),
                                                                                           0) end) total
                                                                            FROM flow.project p1
                                                                                   inner join brs.project_details pd1 on p1.id = pd1.project_id
                                                                                   inner join brs.project_override po on po.project_id = p1.id
                                                                                   inner join brs.override_plan op
                                                                                              on op.id = po.override_plan_id and op.position_id = 4
                                                                                   inner join brs.override_plan_receiving_user opru2
                                                                                              on op.id =
                                                                                                 opru2.override_plan_id
                                                                                                and opru2.user_id =
                                                                                                    pd.setter_user_id
                                                                            WHERE p1.id = any (a.v_all_projects)),
                                                                           0))            AS overrides_earned,

                                                                 coalesce(
                                                                   brs.get_total_overrides(pay.id, a.v_all_projects,
                                                                                           pd.setter_user_id, 4),
                                                                   0)                     as total_overrides,

                                                                 coalesce(
                                                                   brs.get_ledger_adjustment_current_totals(pay.id,
                                                                                                            array_agg(DISTINCT p.id),
                                                                                                            1),
                                                                   0)                     as ledger_adjustments
                                                          FROM brs.payroll pay
                                                                 INNER JOIN flow.project p ON p.id = any (pay.selected_project_ids)
                                                                 inner join brs.project_details pd on pd.project_id = p.id
                                                                 inner join all_project_ids a on a.id = pay.id
                                                          WHERE pay.current is true
                                                          GROUP BY pd.setter_user_id, pay.id, a.v_all_projects)
                                SELECT array_to_json(array_agg(row_to_json(sub_rows)))
                                FROM (SELECT u3.id,
                                             u3.first_name || ' ' || u3.last_name     AS closer_user,
                                             cu.commissions_earned - cu.ledger_totals AS total_commission,
                                             cu.overrides_earned - cu.total_overrides AS total_overrides,
                                             cu.ledger_adjustments                    AS commission_adjustments,
                                             cu.commissions_earned +
                                             cu.overrides_earned +
                                             cu.ledger_adjustments -
                                             (cu.ledger_totals +
                                              cu.total_overrides)                     AS current_pay
                                      FROM commission_users cu
                                             INNER JOIN flow.user u3 ON u3.id = cu.user_id
                                      GROUP BY u3.id, project_ids, cu.id, cu.v_all_projects, cu.commissions_earned,
                                               cu.overrides_earned,
                                               cu.ledger_adjustments,
                                               cu.total_overrides, cu.ledger_totals
                                      UNION
                                      SELECT u1.id,
                                             u1.first_name || ' ' || u1.last_name   AS closer_user,
                                             0                                      AS total_commission,
                                             u.overrides_earned - u.total_overrides AS total_overrides,
                                             0                                      AS commission_adjustments,
                                             u.overrides_earned - u.total_overrides AS current_pay
                                      FROM flow.user u1
                                             INNER JOIN users u ON u.user_id = u1.id
                                      GROUP BY u1.id, project_ids, u.id, u.v_all_projects, u.overrides_earned,
                                               u.total_overrides
                                      into v_json) AS sub_rows;
                                return v_json;
    else return null;
    end case;
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
