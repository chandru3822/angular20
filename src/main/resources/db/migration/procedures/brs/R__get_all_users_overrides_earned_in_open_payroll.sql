CREATE OR REPLACE FUNCTION brs.get_all_users_overrides_earned_in_open_payroll(p_payroll_id integer)
    RETURNS TABLE
            (
                project_id         integer,
                closer             TEXT,
                customer_name      CHARACTER VARYING(200),
                system_size        NUMERIC(10, 2),
                overrides_earned   NUMERIC,
                prior_pay          NUMERIC,
                current_pay        NUMERIC,
                override_plan_name TEXT,
                user_allocation    NUMERIC(10, 2),
                milestone1_amount  NUMERIC(10, 2),
                milestone2_amount  NUMERIC(10, 2),
                plan_total         NUMERIC(10, 2)
            )

AS
$BODY$
BEGIN
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
                 select p.id as project_id,
                        u.first_name || ' ' || u.last_name as closer,
                        p.project_name as project_name,
                        pd.system_size as system_size,
                        opru1.m1_allocation + opru1.m2_allocation                 as user_allocation,
                        opru1.m1_allocation                                       as milestone1_amount,
                        opru1.m2_allocation                                       as milestone2_amount,
                        op.total                                                  as plan_total,

                        coalesce(brs.get_overrides_earned(array [p.id], u.id::integer), 0) as overrides_earned,
                        (select coalesce(sum(dcl.paid_to_date), 0)
                         from brs.project_commission_ledger dcl
                                  inner join flow.project d1 on d1.id = dcl.project_id
                         WHERE dcl.project_id = d1.id
                           and dcl.ledger_type_id = 3
                           and dcl.closer_id = u.id
                           and d1.id = p.id
                           and dcl.payroll_id < p_payroll_id)                        overrides_paid,
                        op.name as name
                 from brs.payroll p1
                          inner join flow.project p on p.id = any (p1.selected_project_ids)
                          inner join brs.project_details pd on pd.project_id = p.id
                          inner join brs.project_override po on po.project_id = p.id
                          inner join brs.override_plan op on op.id = po.override_plan_id
                          inner join brs.override_plan_receiving_user opru1
                                     on opru1.override_plan_id = po.override_plan_id
                          inner join flow.user u on u.id = opru1.user_id
                 where p1.id = p_payroll_id) as foo;

END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
