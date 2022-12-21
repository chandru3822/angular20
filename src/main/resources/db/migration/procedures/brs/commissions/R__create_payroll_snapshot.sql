drop function if exists  brs.create_payroll_snapshot(
  IN p_payroll_id bigint,
  IN p_updated_by_id bigint);
CREATE OR REPLACE FUNCTION brs.create_payroll_snapshot(
    IN p_payroll_id bigint,
    IN p_updated_by_id bigint)
    RETURNS BOOLEAN
    LANGUAGE plpgsql AS
$BODY$
DECLARE
    d             RECORD;
    ou            RECORD;
    v_snapshot_id bigint;
    v_position_id bigint;
BEGIN
    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Create Payroll Snapshot', 'p_payroll_id: ' || p_payroll_id ||
                                       ' p_updated_by_id: '|| p_updated_by_id,
            p_updated_by_id);

    select position_id
    into v_position_id
    from brs.payroll
    where id = p_payroll_id;

    if v_position_id = 1 then
        DELETE
        FROM brs.project_commission_snapshot
        WHERE payroll_id = p_payroll_id;

        FOR d IN
            SELECT (brs.get_commission_account_details(
                    p_payroll_id, p.selected_project_ids, NULL, NULL, NULL, NULL, NULL, NULL)).*
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
                        d.user_id,
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
                        coalesce(d.commission_earned, 0),
                        coalesce(d.override_earned, 0),
                        d.override_plan_id,
                        d.override_plan,
                        coalesce(d.commission_adjustments, 0),
                        d.commission_paid_to_date,
                        d.remaining_value_commissions,
                        d.total_commissions,
                        d.current_pay_commissions,
                        d.override_adjustments,
                        d.overrides_paid_to_date,
                        d.remaining_value_overrides,
                        d.total_overrides,
                        d.current_pay_overrides,
                        coalesce(d.remaining_value, 0),
                        coalesce(d.current_pay, 0),
                        coalesce(d.project_total_value, 0),
                        now())
                ON CONFLICT (payroll_id,project_id) DO NOTHING
                RETURNING id INTO v_snapshot_id;

                --v_snaphot_id will be null if we already have the deal_commission_snapshot record in the database so no need to update these records
                IF v_snapshot_id IS NOT NULL
                THEN
                    FOR ou IN SELECT *
                              FROM json_to_recordset(d.overrides_per_user) AS overrides_per_user (id bigint,
                                                                                                  first_name VARCHAR,
                                                                                                  last_name VARCHAR,
                                                                                                  total NUMERIC(10, 2),
                                                                                                  milestone_id bigint)
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
    else
        DELETE
        FROM brs.project_commission_snapshot
        WHERE payroll_id = p_payroll_id;

        FOR d IN
            SELECT (brs.get_commission_account_details_for_setters(
                    p_payroll_id, p.selected_project_ids, NULL, NULL, NULL, NULL, NULL, NULL)).*
            FROM brs.payroll p
            WHERE p.id = p_payroll_id

            LOOP
                INSERT INTO brs.setter_project_commission_snapshot (payroll_id,
                                                                    project_id,
                                                                    project_name,
                                                                    sales_rep_id,
                                                                    sales_rep,
                                                                    source,
                                                                    cancelled,
                                                                    closer_appointment_start,
                                                                    closer_appointment_outcome,
                                                                    override_plan,
                                                                    override_plan_id,
                                                                    commission_plan_id,
                                                                    commission_plan,
                                                                    total_commissions,
                                                                    total_overrides,
                                                                    commissions_earned,
                                                                    override_earned,
                                                                    commission_adjustment,
                                                                    override_adjustment,
                                                                    commission_paid_to_date,
                                                                    overrides_paid_to_date,
                                                                    current_pay,
                                                                    current_pay_commissions,
                                                                    current_pay_overrides,
                                                                    remaining_value,
                                                                    remaining_value_commissions,
                                                                    remaining_value_overrides,
                                                                    project_total_value,
                                                                    updated)

                VALUES (p_payroll_id,
                        d.project_id,
                        d.project_name,
                        d.setter_user_id,
                        d.setter,
                        d.source_name,
                        d.cancelled_date,
                        d.closer_appointment_start,
                        d.closer_appointment_outcome,
                        d.override_plan,
                        d.override_plan_id,
                        d.commission_plan_id,
                        d.commission_plan,
                        d.total_commissions,
                        d.total_overrides,
                        d.commission_earned,
                        d.override_earned,
                        d.commission_adjustments,
                        d.override_adjustments,
                        d.commission_paid_to_date,
                        d.overrides_paid_to_date,
                        d.current_pay,
                        d.current_pay_commissions,
                        d.current_pay_overrides,
                        d.remaining_value,
                        d.remaining_value_commissions,
                        d.remaining_value_overrides,
                        d.project_total_value,
                        now())
                ON CONFLICT (payroll_id,project_id) DO NOTHING
                RETURNING id INTO v_snapshot_id;

                --v_snaphot_id will be null if we already have the deal_commission_snapshot record in the database so no need to update these records
                IF v_snapshot_id IS NOT NULL
                THEN
                    FOR ou IN SELECT *
                              FROM json_to_recordset(d.overrides_per_user) AS overrides_per_user (id bigint,
                                                                                                  first_name VARCHAR,
                                                                                                  last_name VARCHAR,
                                                                                                  total NUMERIC(10, 2),
                                                                                                  milestone_id bigint)
                        LOOP
                            --     this is so we have access to the override breakdown by user
                            INSERT INTO brs.setter_project_override_commission_snapshot (setter_project_commission_snapshot_id,
                                                                                         user_id,
                                                                                         milestone_type_id,
                                                                                         total)
                            VALUES (v_snapshot_id, ou.id, ou.milestone_id, ou.total)
                            ON CONFLICT (setter_project_commission_snapshot_id,user_id,milestone_type_id) DO NOTHING;
                        END LOOP;
                END IF;
            END LOOP;

        UPDATE brs.payroll
        SET updated_by = p_updated_by_id,
            updated    = now()
        WHERE id = p_payroll_id;

        RETURN TRUE;

    end if;

EXCEPTION
    WHEN OTHERS
        THEN
            RAISE NOTICE 'ERROR: %',SQLERRM;
            RETURN FALSE;
END;
$BODY$;
