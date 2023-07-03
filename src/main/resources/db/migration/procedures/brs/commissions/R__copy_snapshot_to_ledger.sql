drop function if exists brs.copy_snapshot_to_ledger(
  IN p_payroll_id bigint,
  IN p_updated_by_id bigint);
CREATE OR REPLACE FUNCTION brs.copy_snapshot_to_ledger(
    IN p_payroll_id bigint,
    IN p_updated_by_id bigint)
    RETURNS BOOLEAN
    LANGUAGE plpgsql AS
$BODY$
DECLARE
    d                   RECORD;
    v_total_commissions NUMERIC(10, 2);
    v_total_overrides   NUMERIC(10, 2);
    v_position_id       bigint;
v_forfeited_amount numeric;

BEGIN
    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Copy Snapshot to Ledger', 'p_payroll_id: ' || p_payroll_id ||
                                       ' p_updated_by_id: '|| p_updated_by_id,
            p_updated_by_id);

    select position_id
    into v_position_id
    from brs.payroll
    where id = p_payroll_id;

    if v_position_id = 1 then
        FOR d IN
            SELECT s.project_id,
                   s.override_plan_id,
                   s.sales_rep_id,
                   s.commissions_earned,
                   s.commission_adjustment,
                   s.override_adjustment,
                   s.commission_paid_to_date,
                   s.override_earned,
                   s.current_pay_commissions,
                   s.current_pay_overrides,
                   s.overrides_paid_to_date,
                   s.commission_forfeited_paid_to_date,
                   s.commission_forfeited_by_closer,
                   s.cancelled,
                   s.total_commissions
            FROM brs.project_commission_snapshot s
            WHERE payroll_id = p_payroll_id
            LOOP

              if coalesce(d.commission_forfeited_by_closer,0) > 0 and d.cancelled is not null then
                update brs.project_commission_ledger
                set amount = 0
                where ledger_type_id = 7 and
                      project_id = d.project_id;
              end if;

              v_forfeited_amount = 0.00::numeric;
              select forfeited_amount
              from brs.get_current_pay(coalesce(d.total_commissions, 0),
                                       coalesce(d.commissions_earned, 0),
                                       coalesce(d.commission_paid_to_date, 0),
                                       coalesce(d.commission_forfeited_by_closer, 0),
                                       coalesce(d.commission_forfeited_paid_to_date, 0))
              into v_forfeited_amount;

              if coalesce(v_forfeited_amount, 0) > 0 then
                INSERT INTO brs.project_commission_ledger (payroll_id,
                                                           project_id,
                                                           user_id,
                                                           ledger_type_id,
                                                           amount,
                                                           created_by,
                                                           created,
                                                           position_id)
                VALUES (p_payroll_id, d.project_id, d.sales_rep_id, 7,v_forfeited_amount ,
                        p_updated_by_id, now(),
                          1);
                  update brs.financial_details fd
                  set total_commissions_forfeited_paid_to_date = coalesce(total_commissions_forfeited_paid_to_date,0) + v_forfeited_amount
                  where project_id = d.project_id;
              end if;

--                 v_total_commissions := (coalesce(d.commissions_earned, 0) +
--                                         coalesce(d.commission_adjustment, 0) - coalesce(d.commission_paid_to_date, 0));

--                 v_total_overrides := (coalesce(d.override_earned, 0) - coalesce(d.overrides_paid_to_date, 0));

                --     create ledger records
                IF d.current_pay_commissions IS NOT NULL
                THEN
                    INSERT INTO brs.project_commission_ledger (payroll_id,
                                                               project_id,
                                                               user_id,
                                                               ledger_type_id,
                                                               amount,
                                                               created_by,
                                                               created,
                                                               position_id)
                    VALUES (p_payroll_id, d.project_id, d.sales_rep_id, 1, d.current_pay_commissions, p_updated_by_id, now(),
                            1);
                END IF;

              update brs.financial_details fd
              set total_commissions_paid_to_date = ( SELECT coalesce(sum(amount), 0)
                                                               FROM brs.project_commission_ledger pcl
                                                               WHERE pcl.project_id = d.project_id
                                                                 AND pcl.ledger_type_id = 1
                                                                 and pcl.position_id = 1)
              where project_id = d.project_id;

                IF d.commission_adjustment IS NOT NULL
                THEN
                    INSERT INTO brs.project_commission_ledger (payroll_id,
                                                               project_id,
                                                               user_id,
                                                               ledger_type_id,
                                                               amount,
                                                               created_by,
                                                               created,
                                                               position_id)
                    VALUES (p_payroll_id, d.project_id, d.sales_rep_id, 2, d.commission_adjustment, p_updated_by_id,
                            now(), 1);
                END IF;

              update brs.financial_details fd
              set total_commissions_adjustments_paid_to_date = ( SELECT coalesce(sum(amount), 0)
                                                               FROM brs.project_commission_ledger pcl
                                                               WHERE pcl.project_id = d.project_id
                                                                 AND pcl.ledger_type_id = 2
                                                                 and pcl.position_id = 1)
              where project_id = d.project_id;

                IF d.override_adjustment IS NOT NULL
                THEN
                    INSERT INTO brs.project_commission_ledger (payroll_id,
                                                               project_id,
                                                               user_id,
                                                               ledger_type_id,
                                                               amount,
                                                               created_by,
                                                               created,
                                                               position_id)
                    VALUES (p_payroll_id, d.project_id, d.sales_rep_id, 5, d.override_adjustment, p_updated_by_id,
                            now(), 1); --overrides
                END IF;


                if d.current_pay_overrides < 0
                then

                    with t as (select opru.user_id,
                                      round(((opru.m1_allocation + opru.m2_allocation) / op.total) * d.current_pay_overrides,
                                            2)                                 as total,
                                      round(((opru.m1_allocation + opru.m2_allocation) / op.total) *
                                            coalesce(d.override_earned, 0), 2) as overrides_earned
                               from brs.override_plan op
                                        inner join brs.override_plan_receiving_user opru on op.id = opru.override_plan_id

                               where op.id = d.override_plan_id)
                    insert
                    into brs.project_commission_ledger (payroll_id,
                                                        project_id,
                                                        user_id,
                                                        ledger_type_id,
                                                        amount,
                                                        paid_to_date,
                                                        created_by,
                                                        created,
                                                        position_id)
                    SELECT p_payroll_id,
                           d.project_id,
                           t.user_id,
                           3,
                           overrides_earned,
                           t.total,
                           p_updated_by_id,
                           now(),
                           1
                    from t;

                elsif d.current_pay_overrides > 0 then

                    WITH overrides AS (SELECT docs.user_id,
                                              dcs.project_id,
                                              sum(docs.total) AS total,
                                              coalesce((SELECT sum(paid_to_date)
                                                        FROM brs.project_commission_ledger dcl
                                                        WHERE ledger_type_id = 3
                                                          AND dcl.user_id = docs.user_id
                                                          and dcl.project_id = dcs.project_id
                                                          and dcl.position_id = 1),
                                                       0)     AS paid_to_date
                                       FROM brs.project_override_commission_snapshot docs
                                                INNER JOIN brs.project_commission_snapshot dcs
                                                           ON dcs.id = docs.project_commission_snapshot_id
                                       WHERE payroll_id = p_payroll_id
                                         and project_id = d.project_id
                                       GROUP BY docs.user_id, project_id)
                    INSERT
                    INTO brs.project_commission_ledger (payroll_id,
                                                        project_id,
                                                        user_id,
                                                        ledger_type_id,
                                                        amount,
                                                        paid_to_date,
                                                        created_by,
                                                        created,
                                                        position_id)
                    SELECT p_payroll_id,
                           a.project_id,
                           a.user_id,
                           3,
                           a.total,
                           a.total - a.paid_to_date,
                           p_updated_by_id,
                           now(),
                           1
                    FROM overrides a;

                end if;
              update brs.financial_details fd
              set total_overrides_paid_to_date = ( SELECT coalesce(sum(paid_to_date), 0)
                                                                 FROM brs.project_commission_ledger pcl
                                                                 WHERE pcl.project_id = d.project_id
                                                                   AND pcl.ledger_type_id = 3
                                                                   and pcl.position_id = 1)
              where project_id = d.project_id;

            END LOOP;

        --deal_override_commission_snapshot contains the amount that will be paid out for the specified payroll
        --deal_commission_ledger is the amount that has already been paid out
        --We get


        UPDATE brs.payroll
        SET updated_by = p_updated_by_id,
            updated    = now()
        WHERE id = p_payroll_id;

        RETURN TRUE;
    else
        FOR d IN
            SELECT s.project_id,
                   s.override_plan_id,
                   s.sales_rep_id,
                   s.commissions_earned,
                   s.commission_adjustment,
                   s.override_adjustment,
                   s.commission_paid_to_date,
                   s.override_earned,
                   s.overrides_paid_to_date
            FROM brs.setter_project_commission_snapshot s
            WHERE payroll_id = p_payroll_id
            LOOP

                v_total_commissions := (coalesce(d.commissions_earned, 0) +
                                        coalesce(d.commission_adjustment, 0) - coalesce(d.commission_paid_to_date, 0));

                v_total_overrides := (coalesce(d.override_earned, 0) - coalesce(d.overrides_paid_to_date, 0));

                --     create ledger records
                IF v_total_commissions IS NOT NULL
                THEN
                    INSERT INTO brs.project_commission_ledger (payroll_id,
                                                               project_id,
                                                               user_id,
                                                               ledger_type_id,
                                                               amount,
                                                               created_by,
                                                               created,
                                                               position_id)
                    VALUES (p_payroll_id, d.project_id, d.sales_rep_id, 1, v_total_commissions, p_updated_by_id, now(),
                            4);
                END IF;

                IF d.commission_adjustment IS NOT NULL
                THEN
                    INSERT INTO brs.project_commission_ledger (payroll_id,
                                                               project_id,
                                                               user_id,
                                                               ledger_type_id,
                                                               amount,
                                                               created_by,
                                                               created,
                                                               position_id)
                    VALUES (p_payroll_id, d.project_id, d.sales_rep_id, 2, d.commission_adjustment, p_updated_by_id,
                            now(), 4);
                END IF;


                IF d.override_adjustment IS NOT NULL
                THEN
                    INSERT INTO brs.project_commission_ledger (payroll_id,
                                                               project_id,
                                                               user_id,
                                                               ledger_type_id,
                                                               amount,
                                                               created_by,
                                                               created,
                                                               position_id)
                    VALUES (p_payroll_id, d.project_id, d.sales_rep_id, 5, d.override_adjustment, p_updated_by_id,
                            now(), 4); --overrides
                END IF;


                if v_total_overrides < 0
                then

                    with t as (select opru.user_id,
                                      round(((opru.m1_allocation + opru.m2_allocation) / op.total) * v_total_overrides,
                                            2)                                 as total,
                                      round(((opru.m1_allocation + opru.m2_allocation) / op.total) *
                                            coalesce(d.override_earned, 0), 2) as overrides_earned
                               from brs.override_plan op
                                        inner join brs.override_plan_receiving_user opru on op.id = opru.override_plan_id

                               where op.id = d.override_plan_id)
                    insert
                    into brs.project_commission_ledger (payroll_id,
                                                        project_id,
                                                        user_id,
                                                        ledger_type_id,
                                                        amount,
                                                        paid_to_date,
                                                        created_by,
                                                        created,
                                                        position_id)
                    SELECT p_payroll_id,
                           d.project_id,
                           t.user_id,
                           3,
                           overrides_earned,
                           t.total,
                           p_updated_by_id,
                           now(),
                           4
                    from t;

                else

                    WITH overrides AS (SELECT docs.user_id,
                                              dcs.project_id,
                                              sum(docs.total) AS total,
                                              coalesce((SELECT sum(paid_to_date)
                                                        FROM brs.project_commission_ledger dcl
                                                        WHERE ledger_type_id = 3
                                                          AND dcl.user_id = docs.user_id
                                                          and dcl.project_id = dcs.project_id
                                                          and dcl.position_id = 4),
                                                       0)     AS paid_to_date
                                       FROM brs.setter_project_override_commission_snapshot docs
                                                INNER JOIN brs.setter_project_commission_snapshot dcs
                                                           ON dcs.id = docs.setter_project_commission_snapshot_id
                                       WHERE dcs.payroll_id = p_payroll_id
                                         and dcs.project_id = d.project_id
                                       GROUP BY docs.user_id, project_id)
                    INSERT
                    INTO brs.project_commission_ledger (payroll_id,
                                                        project_id,
                                                        user_id,
                                                        ledger_type_id,
                                                        amount,
                                                        paid_to_date,
                                                        created_by,
                                                        created,
                                                        position_id)
                    SELECT p_payroll_id,
                           a.project_id,
                           a.user_id,
                           3,
                           a.total,
                           a.total - a.paid_to_date,
                           p_updated_by_id,
                           now(),
                           4
                    FROM overrides a;

                end if;


            END LOOP;

        --deal_override_commission_snapshot contains the amount that will be paid out for the specified payroll
        --deal_commission_ledger is the amount that has already been paid out
        --We get


        UPDATE brs.payroll
        SET updated_by = p_updated_by_id,
            updated    = now()
        WHERE id = p_payroll_id;

        RETURN TRUE;

    end if;
EXCEPTION
    WHEN OTHERS
        THEN
            RAISE NOTICE 'ERROR: %', SQLERRM;
            RETURN FALSE;
END;
$BODY$
