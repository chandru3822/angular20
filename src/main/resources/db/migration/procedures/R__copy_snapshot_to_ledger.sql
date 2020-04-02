CREATE OR REPLACE FUNCTION brs.copy_snapshot_to_ledger(
  IN p_payroll_id    INTEGER,
  IN p_updated_by_id INTEGER)
  RETURNS BOOLEAN
LANGUAGE plpgsql AS
$BODY$
DECLARE
  d                   RECORD;
  v_total_commissions NUMERIC(10, 2);
  v_total_overrides   NUMERIC(10, 2);

BEGIN

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
  FROM brs.project_commission_snapshot s
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
                                                    closer_id,
                                                    ledger_type_id,
                                                    amount,
                                                    created_by,
                                                    created)
      VALUES (p_payroll_id, d.project_id, d.sales_rep_id, 1, v_total_commissions, p_updated_by_id, now());
    END IF;

    IF d.commission_adjustment IS NOT NULL
    THEN
      INSERT INTO brs.project_commission_ledger (payroll_id,
                                                    project_id,
                                                    closer_id,
                                                    ledger_type_id,
                                                    amount,
                                                    created_by,
                                                    created)
      VALUES (p_payroll_id, d.project_id, d.sales_rep_id, 2, d.commission_adjustment, p_updated_by_id, now());
    END IF;


    IF d.override_adjustment IS NOT NULL
    THEN
      INSERT INTO brs.project_commission_ledger (payroll_id,
                                                    project_id,
                                                    closer_id,
                                                    ledger_type_id,
                                                    amount,
                                                    created_by,
                                                    created)
      VALUES (p_payroll_id, d.project_id, d.sales_rep_id, 5, d.override_adjustment, p_updated_by_id, now()); --overrides
    END IF;


    if v_total_overrides < 0
    then

      with t as (select opru.user_id, round(((opru.m1_allocation + opru.m2_allocation) / op.total) * v_total_overrides, 2) as total,
                   round(((opru.m1_allocation + opru.m2_allocation) / op.total) * coalesce(d.override_earned,0),2) as overrides_earned
                 from blueraven.override_plan op
                        inner join brs.override_plan_receiving_user opru on op.id = opru.override_plan_id

                 where op.id = d.override_plan_id)
      insert into brs.project_commission_ledger (payroll_id,
                                                    project_id,
                                                    closer_id,
                                                    ledger_type_id,
                                                    amount,
                                                    paid_to_date,
                                                    created_by,
                                                    created)
      SELECT p_payroll_id, d.project_id, t.user_id, 3, overrides_earned, t.total, p_updated_by_id, now()
      from t;

    else

      WITH overrides AS (SELECT docs.user_id, dcs.project_id, sum(docs.total) AS total, coalesce((SELECT sum(paid_to_date)
                                                                                          FROM brs.project_commission_ledger dcl
                                                                                          WHERE ledger_type_id = 3
                                                                                            AND closer_id = user_id
                                                                                            and dcl.project_id = dcs.project_id),
                                                                                         0) AS paid_to_date
                         FROM brs.project_override_commission_snapshot docs
                                INNER JOIN brs.project_commission_snapshot dcs
                                  ON dcs.id = docs.project_commission_snapshot_id
                         WHERE payroll_id = p_payroll_id
                           and project_id = d.project_id
                         GROUP BY user_id, project_id)
      INSERT INTO brs.project_commission_ledger (payroll_id,
                                                    project_id,
                                                    closer_id,
                                                    ledger_type_id,
                                                    amount,
                                                    paid_to_date,
                                                    created_by,
                                                    created)
      SELECT p_payroll_id, a.project_id, a.user_id, 3, a.total, a.total - a.paid_to_date, p_updated_by_id, now()
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
  EXCEPTION WHEN OTHERS
  THEN
    RAISE NOTICE 'ERROR: %', SQLERRM;
    RETURN FALSE;
END;
$BODY$
