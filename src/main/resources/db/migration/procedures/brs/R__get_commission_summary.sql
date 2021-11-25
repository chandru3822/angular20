CREATE or replace function brs.get_commission_summary(p_position_id integer)
    RETURNS JSON AS
$BODY$
declare
    v_json json;
begin

    case when p_position_id = 1 then
        with all_project_ids as (
            select array_agg(DISTINCT pd.closer_user_id) as user_ids, array_agg(DISTINCT p.id) v_all_projects, pay.id
            from brs.payroll pay
                     inner join flow.project p on p.id = any (pay.selected_project_ids)
                     inner join brs.project_details pd on pd.project_id = p.id
            where current is true
              and pay.position_id = 1
            group by pay.id
        ),
             milestone_one_projects as (
                 select project_id, min(process_step_complete_date) milestone_one_complete_date
                 from flow.project_process_step pps
                          inner join flow.company_process_step_status_type cpsst
                                     on pps.company_process_step_status_type_id = cpsst.id
                          inner join flow.process_step_status_type psst
                                     on cpsst.process_step_status_type_id = psst.id and psst.id = 2
                          inner join all_project_ids api2 on pps.project_id = any(api2.v_all_projects)
                 where pps.process_step_id = 175
                 group by project_id
             ),
             milestone_two_projects as (
                 select coalesce(pps.project_id,pd.project_id) as project_id, coalesce(min(process_step_complete_date),pd.substantial_completion_date)::date milestone_two_complete_date
                 from brs.project_details pd
                          left join flow.project_process_step pps on pps.project_id = pd.project_id and pps.process_step_id = 3365
                          left join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
                          left join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id and psst.id = 2
                        inner join all_project_ids api2 on pps.project_id = any(api2.v_all_projects)
                 where pd.substantial_completion_date is not null or pps.process_step_complete_date is not null
                 group by pps.project_id,pd.project_id,pd.substantial_completion_date
             ),
             users AS (SELECT opru1.user_id                                                       AS user_id,
                              array_agg(DISTINCT p2.id)                                           AS project_ids,
                              p.id,
                              a.v_all_projects,
                              (select (select coalesce(sum(total), 0)
                                       from (SELECT case
                                                        when pd.cancelled_date is not null then
                                                            0::numeric
                                                        else coalesce(
                                                                round(pd.system_size::numeric * sum(opru.m1_allocation), 2),
                                                                0) end total
                                             FROM flow.project p1
                                                      inner join brs.project_details pd on pd.project_id = p1.id
                                                      inner join milestone_one_projects mop2
                                                                 on mop2.project_id = p1.id and
                                                                    mop2.milestone_one_complete_date::date <= p.period_end
                                                      inner join brs.project_override po on po.project_id = p1.id
                                                      inner join brs.override_plan op
                                                                 on op.id = po.override_plan_id and op.position_id = 1
                                                      inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id
                                             WHERE p1.id = any (a.v_all_projects)
                                               and opru.user_id = opru1.user_id
                                             group by pd.cancelled_date, system_size) as foo) +
                                      (select coalesce(sum(total), 0)
                                       from (SELECT case
                                                        when pd.cancelled_date is not null
                                                            then
                                                            0::numeric
                                                        else coalesce(round(
                                                                              pd.system_size::numeric * sum(opru.m2_allocation),
                                                                              2),
                                                                      0) end total
                                             FROM flow.project p1
                                                      inner join brs.project_details pd on pd.project_id = p1.id
                                                      inner join milestone_two_projects mtp2
                                                                 on mtp2.project_id = p1.id and
                                                                    mtp2.milestone_two_complete_date::date <= p.period_end
                                                      inner join brs.project_override po on po.project_id = p1.id
                                                      inner join brs.override_plan op
                                                                 on op.id = po.override_plan_id and op.position_id = 1
                                                      inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id

                                             WHERE p1.id = any (a.v_all_projects)
                                               and opru.user_id = opru1.user_id
                                             group by pd.cancelled_date, pd.system_size) as foo)) as overrides_earned,
                              -- coalesce(brs.get_overrides_earned(a.v_all_projects,p.period_end, opru.user_id), 0) as overrides_earned,
                              coalesce(brs.get_total_overrides(p.id, a.v_all_projects, opru1.user_id, 1),
                                       0)                                                         as total_overrides
                       FROM brs.override_plan_receiving_user opru1
                                inner join brs.override_plan op1
                                           on op1.id = opru1.override_plan_id and op1.position_id = 1
                                inner join brs.project_override po1 on po1.override_plan_id = op1.id
                                INNER JOIN flow.project p2 ON p2.id = po1.project_id
                                INNER JOIN brs.payroll p
                                           ON p2.id = any (p.selected_project_ids) and current is true
                                inner join all_project_ids a on a.id = p.id
                       WHERE not (opru1.user_id = any (user_ids))
                       GROUP BY opru1.user_id, p.id, a.v_all_projects
             ),
             commission_users AS (
               select *,
                      (select coalesce(
                                (SELECT sum(case
                                              when pd1.cancelled_date is not null then
                                                0::NUMERIC
                                              else coalesce(round(cpa.allocation * pd1.system_size::numeric - case
                                                                                                               when cpsa.milestone_id = 1
                                                                                                                 then
                                                                                                                 case
                                                                                                                   when cpsa.fee_type_id = 1
                                                                                                                     then coalesce(pd1.system_size::numeric * cpsa.fee_amount, 0)
                                                                                                                   else coalesce(cpsa.fee_amount, 0) end
                                                                                                               else 0 end,
                                                                  2),
                                                            0) end) total
                                 FROM flow.project p1
                                        inner join brs.project_details pd1 on pd1.project_id = p1.id
                                        inner join milestone_one_projects mop on mop.project_id = p1.id and mop.milestone_one_complete_date::date <= foo.period_end
                                        inner join brs.project_commission pc on pc.project_id = p1.id
                                        inner join brs.commission_plan cp on cp.id = pc.commission_plan_id and cp.position_id = 1
                                        inner join brs.commission_plan_allocation cpa
                                                   on cpa.commission_plan_id = cp.id and cpa.milestone_id = 1
                                        left join brs.commission_plan_source_allocation cpsa
                                                  on cpsa.commission_plan_id = cp.id and
                                                     cpsa.source_id = pd1.source and cpsa.milestone_id = 1
                                 WHERE p1.id = any(foo.project_ids)), 0)) as commissions_earned,
                      (select coalesce(
                                (SELECT sum(case
                                              when pd1.cancelled_date is not null then
                                                0::NUMERIC
                                              else coalesce(round(cpa.allocation * pd1.system_size::numeric - case
                                                                                                                when cpsa.milestone_id = 2
                                                                                                                  then
                                                                                                                  case
                                                                                                                    when cpsa.fee_type_id = 1
                                                                                                                      then coalesce(pd1.system_size::numeric * cpsa.fee_amount, 0)
                                                                                                                    else coalesce(cpsa.fee_amount, 0) end
                                                                                                                else 0 end,
                                                                  2),
                                                            0) end) total
                                 FROM flow.project p1
                                        inner join brs.project_details pd1 on pd1.project_id = p1.id
                                        inner join milestone_two_projects mop on mop.project_id = p1.id and mop.milestone_two_complete_date::date <= foo.period_end
                                        inner join brs.project_commission pc on pc.project_id = p1.id
                                        inner join brs.commission_plan cp on cp.id = pc.commission_plan_id and cp.position_id = 1
                                        inner join brs.commission_plan_allocation cpa
                                                   on cpa.commission_plan_id = cp.id and cpa.milestone_id = 2
                                        left join brs.commission_plan_source_allocation cpsa
                                                  on cpsa.commission_plan_id = cp.id and
                                                     cpsa.source_id = pd1.source and cpsa.milestone_id = 2
                                 WHERE p1.id = any(foo.project_ids)), 0)) as commissions_earned1,
                      coalesce(brs.get_ledger_totals(pay_id, foo.project_ids, 1, 1),
                                 0)                                                           as ledger_totals,
                         (select (select coalesce(sum(total), 0)
                                 from (SELECT case
                                                  when pd1.cancelled_date is not null then
                                                      0::numeric
                                                  else coalesce(
                                                          round(pd1.system_size::numeric * sum(opru.m1_allocation), 2),
                                                          0) end total
                                       FROM flow.project p1
                                                inner join brs.project_details pd1 on pd1.project_id = p1.id
                                                inner join milestone_one_projects mop2 on mop2.project_id = p1.id and
                                                                                          mop2.milestone_one_complete_date::date <= foo.period_end
                                                inner join brs.project_override po on po.project_id = p1.id
                                                inner join brs.override_plan op
                                                           on op.id = po.override_plan_id and op.position_id = 1
                                                inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id
                                       WHERE p1.id = any (foo.v_all_projects)
                                         and user_id = foo.user_id
                                         and pd1.project_id = p1.id
                                       group by pd1.cancelled_date, pd1.system_size) as foo) +
                                (select coalesce(sum(total), 0)
                                 from (SELECT case
                                                  when pd1.cancelled_date is not null
                                                      then
                                                      0::numeric
                                                  else coalesce(round(
                                                                        pd1.system_size::numeric * sum(opru.m2_allocation),
                                                                        2),
                                                                0) end total
                                       FROM flow.project p1
                                                inner join brs.project_details pd1 on pd1.project_id = p1.id
                                                inner join milestone_two_projects mtp2 on mtp2.project_id = p1.id and
                                                                                          mtp2.milestone_two_complete_date::date <= foo.period_end
                                                inner join brs.project_override po on po.project_id = p1.id
                                                inner join brs.override_plan op
                                                           on op.id = po.override_plan_id and op.position_id = 1
                                                inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id

                                       WHERE p1.id = any (foo.v_all_projects)
                                         and user_id = foo.user_id
                                         and pd1.project_id = p1.id
                                       group by pd1.cancelled_date, pd1.system_size) as foo)) as overrides_earned,
                      coalesce(brs.get_total_overrides(pay_id, foo.v_all_projects, foo.user_id, 1),
                                 0)                                                           as total_overrides,
                      coalesce(brs.get_ledger_adjustment_current_totals(pay_id, project_ids, 1),
                                 0)                                                           as ledger_adjustments
                  from (
                 SELECT array_agg(DISTINCT p.id)                                              AS project_ids,
                        pd.closer_user_id                                                     AS user_id,
                        pay.id as pay_id,
                        a.v_all_projects,
                        pay.period_end
                 FROM brs.commission_plan_user cpu
                        inner join brs.commission_plan cp on cpu.commission_plan_id = cp.id and cp.position_id =1
                        inner join brs.project_commission pc on pc.commission_plan_id = cp.id
                        INNER JOIN flow.project p ON p.id = pc.project_id
                        inner join brs.payroll pay on p.id = any (pay.selected_project_ids) and current is true
                        inner join all_project_ids a on a.id = pay.id
                          inner join brs.project_details pd on pd.project_id = p.id
                WHERE cpu.user_id = pd.closer_user_id
                 GROUP BY pd.closer_user_id, pay.id, a.v_all_projects
               ) as foo )
        SELECT array_to_json(array_agg(row_to_json(sub_rows)))
        FROM (
                 SELECT u3.id,
                        u3.first_name || ' ' || u3.last_name     AS closer_user,
                        cu.commissions_earned + cu.commissions_earned1 - cu.ledger_totals AS total_commission,
                        cu.overrides_earned - cu.total_overrides AS total_overrides,
                        cu.ledger_adjustments                    AS commission_adjustments,
                        cu.commissions_earned +  cu.commissions_earned1 +
                        cu.overrides_earned +
                        cu.ledger_adjustments -
                        (cu.ledger_totals +
                         cu.total_overrides)                     AS current_pay
                 FROM commission_users cu
                          INNER JOIN flow.user u3 ON u3.id = cu.user_id
                 GROUP BY u3.id, project_ids, cu.pay_id, cu.v_all_projects, cu.commissions_earned,cu.commissions_earned1, cu.overrides_earned,
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
                 GROUP BY u1.id, project_ids, u.id, u.v_all_projects, u.overrides_earned, u.total_overrides
                 into v_json
             ) AS sub_rows;
        return v_json;

        when p_position_id = 4 then
            with all_project_ids as (
                select array_agg(DISTINCT pd.setter_user_id) as user_ids,
                       array_agg(DISTINCT p.id)                 v_all_projects,
                       pay.id
                from brs.payroll pay
                         inner join flow.project p on p.id = any (pay.selected_project_ids)
                         inner join brs.project_details pd on pd.project_id = p.id
                where current is true
                  and pay.position_id = 4
                group by pay.id
            ),
                 users AS (SELECT opru1.user_id                                                       AS user_id,
                                  array_agg(DISTINCT p2.id)                                           AS project_ids,
                                  p.id,
                                  a.v_all_projects,
                                  (select coalesce(
                                           (SELECT case when pd.cancelled_date is not null then
                                                            0::numeric
                                                        else coalesce((select sum(opru.m1_allocation)
                                                                       ),0) end total
                                            FROM flow.project p1
                                                     inner join brs.project_details pd on p1.id = pd.project_id
                                                     inner join brs.project_override po on po.project_id = p1.id
                                                     inner join brs.override_plan op on op.id = po.override_plan_id and op.position_id = 4
                                                     inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id
                                            WHERE p1.id = any(a.v_all_projects)
                                                and opru.user_id = opru1.user_id
                                           group by pd.cancelled_date),0)) AS overrides_earned,

                                  -- coalesce(brs.get_overrides_earned(a.v_all_projects,p.period_end, opru.user_id), 0) as overrides_earned,
                                  coalesce(brs.get_total_overrides(p.id, a.v_all_projects, opru1.user_id, 4),
                                           0)                                                         as total_overrides
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
                           GROUP BY opru1.user_id,p.id, a.v_all_projects
                 ),
                 commission_users AS (
                     SELECT array_agg(DISTINCT p.id)                                              AS project_ids,
                            pd.setter_user_id                                                     AS user_id,
                            pay.id,
                            a.v_all_projects,
                            coalesce(brs.get_commissions_earned_for_setters(array_agg(DISTINCT p.id), pay.period_end),
                                     0)                                                           as commissions_earned,
                            coalesce(brs.get_ledger_totals(pay.id, array_agg(DISTINCT p.id), 4, 4),
                                     0)                                                           as ledger_totals,
                            (select coalesce(
                                            (SELECT sum(case when pd1.cancelled_date is not null then
                                                             0::numeric
                                                         else coalesce((select m1_allocation
                                                                        from brs.override_plan_receiving_user opru
                                                                        where opru.override_plan_id = op.id and opru.user_id = opru2.user_id),0) end) total
                                             FROM flow.project p1
                                                      inner join brs.project_details pd1 on p1.id = pd1.project_id
                                                      inner join brs.project_override po on po.project_id = p1.id
                                                      inner join brs.override_plan op on op.id = po.override_plan_id and op.position_id = 4
                                                      inner join brs.override_plan_receiving_user opru2  on op.id = opru2.override_plan_id
                                                                and opru2.user_id = pd.setter_user_id
                                             WHERE  p1.id = any(a.v_all_projects)),0)) AS overrides_earned,

                                              coalesce(brs.get_total_overrides(pay.id, a.v_all_projects, pd.setter_user_id, 4),
                                    0)                                                           as total_overrides,

                            coalesce(brs.get_ledger_adjustment_current_totals(pay.id, array_agg(DISTINCT p.id), 1),
                                     0)                                                           as ledger_adjustments
                     FROM brs.payroll pay
                              INNER JOIN flow.project p ON p.id = any (pay.selected_project_ids)
                              inner join brs.project_details pd on pd.project_id = p.id
                              inner join all_project_ids a on a.id = pay.id
                     WHERE pay.current is true
                     GROUP BY pd.setter_user_id, pay.id, a.v_all_projects
                 )
            SELECT array_to_json(array_agg(row_to_json(sub_rows)))
            FROM (
                     SELECT u3.id,
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
                     GROUP BY u3.id, project_ids, cu.id, cu.v_all_projects, cu.commissions_earned, cu.overrides_earned,
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
                     GROUP BY u1.id, project_ids, u.id, u.v_all_projects, u.overrides_earned, u.total_overrides
                     into v_json
                 ) AS sub_rows;
            return v_json;
        else return null;
        end case;
END
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    COST 100;
