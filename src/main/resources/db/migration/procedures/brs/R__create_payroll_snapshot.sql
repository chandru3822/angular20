CREATE OR REPLACE FUNCTION brs.create_payroll_snapshot(
  IN p_payroll_id    integer,
  IN p_updated_by_id integer)
  RETURNS BOOLEAN
LANGUAGE plpgsql AS
$BODY$
DECLARE
  d             RECORD;
  ou            RECORD;
  v_snapshot_id INT;
BEGIN

  DELETE
  FROM brs.project_commission_snapshot
  WHERE payroll_id = p_payroll_id;

  FOR d IN
  SELECT (brs.get_commission_account_details(
      p_payroll_id, p.selected_project_ids,NULL,NULL,NULL,NULL,NULL,NULL)).*
  FROM brs.payroll p
  WHERE p.id = p_payroll_id

  LOOP
    INSERT INTO brs.project_commission_snapshot (payroll_id,
                                                    project_id,
                                                    customer_name,
                                                    system_size,
                                                    sales_rep_id,
                                                    sales_rep,
                                                    source,
                                                    cancelled,
                                                    commission_plan_id,
                                                    commission_plan,
                                                    install_agreement_signed,
                                                    final_design_signed,
                                                    financial_agreement_sent,
                                                    deposit,
                                                    percent_of_cash_deposit,
                                                    hoi,
                                                    sc,
                                                    commissions_earned,
                                                    override_earned,
                                                    override_plan_id,
                                                    override_plan,
                                                    commission_adjustment,
                                                    commission_paid_to_date,
                                                    remaining_value_commissions,
                                                    total_commissions,
                                                    current_pay_commissions,
                                                    override_adjustment,
                                                    overrides_paid_to_date,
                                                    remaining_value_overrides,
                                                    total_overrides,
                                                    current_pay_overrides,
                                                    remaining_value,
                                                    current_pay,
                                                    project_total_value,
                                                    updated)

    VALUES (p_payroll_id,
            d.project_id,
            d.customer_name,
            d.system_size,
            d.closer_user_id,
            d.closer,
            d.source_name,
            d.cancelled_date,
            d.commission_plan_id,
            d.commission_plan,
            d.installation_agreement_signed_date,
            d.final_design_signed_date,
            d.agreement_signed_date,
            d.first_cash_payment_paid_date,
            d.percent_of_cash_deposit,
            d.proof_of_homeowners_insurance_obtained_date,
            d.substantial_completion_date,
            coalesce(d.commission_earned,0),
            coalesce(d.override_earned,0),
            d.override_plan_id,
            d.override_plan,
            coalesce(d.commission_adjustments,0),
            d.commission_paid_to_date,
            d.remaining_value_commissions,
            d.total_commissions,
            d.current_pay_commissions,
            d.override_adjustments,
            d.overrides_paid_to_date,
            d.remaining_value_overrides,
            d.total_overrides,
            d.current_pay_overrides,
            coalesce(d.remaining_value,0),
            coalesce(d.current_pay,0),
            coalesce(d.project_total_value,0),
            now())
    ON CONFLICT (payroll_id,project_id) DO NOTHING
        RETURNING id
          INTO v_snapshot_id;

    --v_snaphot_id will be null if we already have the deal_commission_snapshot record in the database so no need to update these records
    IF v_snapshot_id IS NOT NULL
    THEN
      FOR ou IN SELECT *
                FROM json_to_recordset(d.overrides_per_user) AS
                         overrides_per_user (id INT,first_name VARCHAR,last_name VARCHAR,total NUMERIC(10,2),milestone_id INT)
      LOOP
        --     this is so we have access to the override breakdown by user
        INSERT INTO brs.project_override_commission_snapshot (project_commission_snapshot_id,
                                                                 user_id,
                                                                 milestone_type_id,
                                                                 total)
        VALUES (v_snapshot_id, ou.id, ou.milestone_id, ou.total)
        ON CONFLICT (project_commission_snapshot_id,user_id,milestone_type_id) DO NOTHING;
      END LOOP;
    END IF;
  END LOOP;

  UPDATE brs.payroll
  SET updated_by = p_updated_by_id,
      updated    = now()
  WHERE id = p_payroll_id;

  RETURN TRUE;
  EXCEPTION WHEN OTHERS
  THEN
    RAISE NOTICE 'ERROR: %',SQLERRM;
    RETURN FALSE;
END;
$BODY$;
