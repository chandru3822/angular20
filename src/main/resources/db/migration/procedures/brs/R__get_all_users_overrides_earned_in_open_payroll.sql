CREATE OR REPLACE FUNCTION brs.get_all_users_overrides_earned_in_open_payroll(p_payroll_id integer)
    RETURNS TABLE
            (
                project_id            integer,
                closer                TEXT,
                customer_name         CHARACTER VARYING(200),
                system_size           NUMERIC(10, 2),
                overrides_earned      NUMERIC,
                prior_pay             NUMERIC,
                current_pay           NUMERIC,
                override_plan_name    TEXT,
                user_allocation       NUMERIC(10, 2),
                milestone1_percentage NUMERIC(10, 2),
                milestone2_percentage NUMERIC(10, 2),
                plan_total            NUMERIC(10, 2)
            )

AS
$BODY$
declare
    v_period_end_date date;
    v_position_id     integer;
BEGIN

    select period_end, position_id
    into v_period_end_date,v_position_id
    from brs.payroll
    where id = p_payroll_id;

    case when v_position_id = 1 then
        RETURN QUERY
            select foo.project_id,
                   foo.closer,
                   foo.project_name,
                   foo.system_size,
                   foo.overrides_earned,
                   foo.overrides_paid                        as prior_pay,
                   foo.overrides_earned - foo.overrides_paid as current_pay,
                   foo.name                                  as override_plan_name,
                   foo.user_allocation,
                   foo.milestone1_amount,
                   foo.milestone2_amount,
                   foo.plan_total                            as plan_total
            from (
                     with milestone_one_projects as (
                         select pps.project_id, min(process_step_complete_date) milestone_one_complete_date
                         from flow.project_process_step pps
                                  inner join flow.company_process_step_status_type cpsst
                                             on pps.company_process_step_status_type_id = cpsst.id
                                  inner join flow.process_step_status_type psst
                                             on cpsst.process_step_status_type_id = psst.id and psst.id = 2
                         where pps.process_step_id = 175
                         group by pps.project_id
                     ),
                          milestone_two_projects as (
                              select coalesce(pps.project_id,pd.project_id) as project_id, coalesce(min(process_step_complete_date),pd.substantial_completion_date)::date milestone_two_complete_date
                              from brs.project_details pd
                                       left join flow.project_process_step pps on pps.project_id = pd.project_id and pps.process_step_id = 3365
                                       left join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
                                       left join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id and psst.id = 2
                              group by pps.project_id,pd.project_id,pd.substantial_completion_date
                          )
                     select p.id                                              as project_id,
                            u.first_name || ' ' || u.last_name                as closer,
                            p.project_name                                    as project_name,
                            pd.system_size                                    as system_size,
                            opru1.m1_allocation + opru1.m2_allocation         as user_allocation,
                            opru1.m1_allocation                               as milestone1_amount,
                            opru1.m2_allocation                               as milestone2_amount,
                            op.total                                          as plan_total,

                            coalesce(
                                    (SELECT case
                                                when pd.cancelled_date is not null then
                                                    0::numeric
                                                else coalesce(round(pd.system_size::numeric * (select sum(m1_allocation)
                                                                                               from brs.override_plan_receiving_user opru
                                                                                               where opru.override_plan_id = op1.id
                                                                                                 and opru.user_id = opru2.user_id),
                                                                    2), 0) end total
                                     FROM flow.project p2
                                              inner join milestone_one_projects mop2 on mop2.project_id = p2.id and
                                                                                        mop2.milestone_one_complete_date::date <= v_period_end_date
                                              inner join brs.project_override po1 on po1.project_id = p2.id
                                              inner join brs.override_plan op1
                                                         on op1.id = po1.override_plan_id and op1.position_id = 1
                                              inner join brs.override_plan_receiving_user opru2
                                                         on opru2.override_plan_id = op1.id
                                     WHERE p2.id = p.id
                                       and opru2.user_id = opru1.user_id), 0) + coalesce(
                                    (SELECT case
                                                when pd.cancelled_date is not null then
                                                    0::NUMERIC
                                                else coalesce(round(pd.system_size::numeric * (select sum(m2_allocation)
                                                                                               from brs.override_plan_receiving_user opru
                                                                                               where opru.override_plan_id = op1.id
                                                                                                 and opru.user_id = opru2.user_id),
                                                                    2), 0) end total
                                     FROM flow.project p2
                                              inner join milestone_two_projects mtp2 on mtp2.project_id = p2.id and
                                                                                        mtp2.milestone_two_complete_date::date <= v_period_end_date
                                              inner join brs.project_override po1 on po1.project_id = p2.id
                                              inner join brs.override_plan op1
                                                         on op1.id = po1.override_plan_id and op1.position_id = 1
                                              inner join brs.override_plan_receiving_user opru2
                                                         on opru2.override_plan_id = op1.id
                                     WHERE p2.id = p.id
                                       and opru2.user_id = opru1.user_id), 0) AS overrides_earned,
                            (select coalesce(sum(dcl.paid_to_date), 0)
                             from brs.project_commission_ledger dcl
                                      inner join flow.project d1 on d1.id = dcl.project_id
                             WHERE dcl.project_id = d1.id
                               and dcl.ledger_type_id = 3
                               and dcl.user_id = u.id
                               and d1.id = p.id
                               and dcl.position_id = 1)                          overrides_paid,
                            op.name                                           as name
                     from brs.payroll p1
                              inner join flow.project p on p.id = any (p1.selected_project_ids)
                              inner join brs.project_details pd on pd.project_id = p.id
                              inner join brs.project_override po on po.project_id = p.id
                              inner join brs.override_plan op on op.id = po.override_plan_id
                              inner join brs.override_plan_receiving_user opru1
                                         on opru1.override_plan_id = po.override_plan_id
                              inner join flow.user u on u.id = opru1.user_id
                     where p1.id = p_payroll_id
                       and op.position_id = 1) as foo;

        when v_position_id = 4 then
            RETURN QUERY
                select foo.project_id,
                       foo.closer,
                       foo.project_name,
                       foo.system_size,
                       foo.overrides_earned,
                       foo.overrides_paid                        as prior_pay,
                       foo.overrides_earned - foo.overrides_paid as current_pay,
                       foo.name                                  as override_plan_name,
                       foo.user_allocation,
                       foo.milestone1_amount,
                       foo.milestone2_amount,
                       foo.plan_total                            as plan_total
                from (
                         select p.id                                                                            as project_id,
                                u.first_name || ' ' || u.last_name                                              as closer,
                                p.project_name                                                                  as project_name,
                                pd.system_size                                                                  as system_size,
                                opru1.m1_allocation + opru1.m2_allocation                                       as user_allocation,
                                opru1.m1_allocation                                                             as milestone1_amount,
                                opru1.m2_allocation                                                             as milestone2_amount,
                                op.total                                                                        as plan_total,

                                (select coalesce(
                                                (SELECT sum(case
                                                            when pd1.cancelled_date is not null then
                                                                0::numeric
                                                            else coalesce((select m1_allocation
                                                                           from brs.override_plan_receiving_user opru
                                                                           where opru.override_plan_id = op.id
                                                                            and opru.user_id = u.id),
                                                                          0) end) total
                                                 FROM flow.project p1
                                                          inner join brs.project_details pd1 on p1.id = pd1.project_id
                                                          inner join brs.project_override po on po.project_id = p1.id
                                                          inner join brs.override_plan op
                                                                     on op.id = po.override_plan_id and op.position_id = 4
                                                          inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id
                                                 WHERE p1.id = p.id
                                                   and opru.user_id = u.id ),
                                                0))                                                             AS overrides_earned,
                                (select coalesce(sum(dcl.paid_to_date), 0)
                                 from brs.project_commission_ledger dcl
                                          inner join flow.project d1 on d1.id = dcl.project_id
                                 WHERE dcl.ledger_type_id = 3
                                   and dcl.user_id = u.id
                                   and d1.id = p.id
                                   and dcl.position_id = 4)                                                        overrides_paid,
                                op.name                                                                         as name
                         from brs.payroll p1
                                  inner join flow.project p on p.id = any (p1.selected_project_ids)
                                  inner join brs.project_details pd on pd.project_id = p.id
                                  inner join brs.project_override po on po.project_id = p.id
                                  inner join brs.override_plan op on op.id = po.override_plan_id
                                  inner join brs.override_plan_receiving_user opru1
                                             on opru1.override_plan_id = po.override_plan_id
                                  inner join flow.user u on u.id = opru1.user_id
                         where p1.id = p_payroll_id
                           and op.position_id = 4) as foo;

        end case;

END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
