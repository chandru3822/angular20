drop function if exists brs.get_all_users_overrides_earned_in_payroll_snapshot(p_payroll_id bigint, p_run_by_id bigint);
CREATE OR REPLACE FUNCTION brs.get_all_users_overrides_earned_in_payroll_snapshot(p_payroll_id bigint, p_run_by_id bigint)
    RETURNS TABLE
            (
                closer                TEXT,
                project_id            bigint,
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
    v_position_id     bigint;
BEGIN
    select period_end, position_id
    into v_period_end_date,v_position_id
    from brs.payroll
    where id = p_payroll_id;

    case when v_position_id = 1 then
        RETURN QUERY select results.closer,
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
                                     and pcl1.position_id = 1)            as prior_pay,
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
                                    inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id
                               and opru.user_id = u.id
                           where ledger_type_id = 3
                             and payroll_id = p_payroll_id
                             and pcl.position_id = 1
                           group by closer, p.id, p.project_name, pd.system_size, pcl.user_id, op.name,
                                    opru.m1_allocation, opru.m2_allocation, op.total
                           order by closer) as results
                     where results.overrides_earned - results.prior_pay != 0;
        when v_position_id = 4 then
            RETURN QUERY select results.closer,
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
                               group by closer, p.id, p.project_name, pd.system_size, pcl.user_id, op.name,
                                        opru.m1_allocation, opru.m2_allocation, op.total
                               order by closer) as results
                         where results.overrides_earned - results.prior_pay != 0;

        end case;

    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Get All Users Overrides Earned in Payroll Snapshot', 'p_payroll_id: ' || p_payroll_id ||
                                                                  ' p_run_by_id: ' || p_run_by_id,
            p_run_by_id);

END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
