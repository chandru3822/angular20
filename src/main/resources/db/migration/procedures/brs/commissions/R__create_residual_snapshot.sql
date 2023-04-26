drop function if exists brs.create_residual_snapshot(
  IN p_residual_id bigint,
  IN p_updated_by_id bigint);
CREATE OR REPLACE FUNCTION brs.create_residual_snapshot(
  IN p_residual_id bigint,
  IN p_updated_by_id bigint)
  RETURNS BOOLEAN
  LANGUAGE plpgsql AS
$BODY$
DECLARE
  d                           RECORD;
  x                           RECORD;
  v_snapshot_id               bigint;

BEGIN

  DELETE
  FROM brs.user_residual_snapshot urs
  WHERE urs.residual_id = p_residual_id;


  FOR d IN
    SELECT (brs.get_residual_account_details()).*, r.selected_user_ids
    FROM brs.residual r
    WHERE r.id = p_residual_id

    LOOP
      v_snapshot_id = null;
      INSERT INTO brs.user_residual_snapshot(residual_id,
                                             user_id,
                                             user_first_name,
                                             user_last_name,
                                             employee_id,
                                             region_name,
                                             office_name,
                                             office_state,
                                             user_position_name,
                                             user_status,
                                             hire_date,
                                             user_full_name,
                                             residual_start_date,
                                             residual_plan_name,
                                             lifetime_qualified_fds,
                                             qualified_fdc_in_period,
                                             fdc_not_qualified_in_period,
                                             required_fdc_per_month,
                                             residual_earned,
                                             percent_of_residual_earned,
                                             potential_residual,
                                             earned_residual,
                                             clawback,
                                             adjustment_override,
                                             residual_total,
                                             paid_in_period,
                                             date_created,
                                             created_by_id,
                                             date_modified,
                                             modified_by_id,
                                             existing_clawbacks,
                                             current_clawbacks_in_period)

      VALUES (p_residual_id,
              d.user_id,
              d.first_name,
              d.last_name,
              d.employee_id,
              d.region_name,
              d.office_name,
              d.office_state,
              d.user_position_name,
              d.user_status_type,
              d.hire_date,
              d.user_full_name,
              d.residual_start_date,
              d.residual_plan_name,
              d.lifetime_fdc,
              d.qualified_this_period_fdc,
              d.fds_not_qualified,
              d.required_fdc_per_month,
              d.residual_earned,
              d.percent_of_residual_earned,
              d.potential_residual,
              d.earned_residual,
              d.clawback,
              d.adjustment_override,
              d.total,
              case
                when d.user_id = any (d.selected_user_ids) then
                  true
                else
                  false end,
              now(),
              p_updated_by_id,
              now(),
              p_updated_by_id,
              (select sum(erc.amount) from  brs.get_existing_residual_clawbacks(d.user_id) erc),
              (select sum(crc.amount) from  brs.get_current_residual_clawbacks(d.user_id) crc))
      ON CONFLICT (user_id, residual_id) DO NOTHING
      RETURNING id INTO v_snapshot_id;

      insert into brs.user_residual_project_snapshot(user_residual_snapshot_id,
                                                     project_id,
                                                     user_residual_project_snapshot_type_id,
                                                     final_design_complete_date,
                                                     final_design_signed_date,
                                                     utility_bill_verified_date,
                                                     financial_agreement_signed_date,
                                                     proof_of_homeowners_insurance_required,
                                                     proof_of_homeowners_insurance_obtained_date,
                                                     state,
                                                     total_cash_down_payment,
                                                     first_cash_payment_amount,
                                                     substantial_completion_date,
                                                     cancelled_date,
                                                     on_hold_date,
                                                     total,
                                                     date_created,
                                                     created_by_id,
                                                     date_modified,
                                                     modified_by_id)
        (select v_snapshot_id,
                rqlf.project_id,
                (select id
                 from brs.user_residual_project_snapshot_type as urpst
                 where urpst.user_residual_project_snapshot_code = 'LIFETIME_QUALIFIED_FDS'),
                rqlf.final_design_complete_date,
                rqlf.final_design_signed_date,
                rqlf.utility_bill_verified_date,
                rqlf.financial_agreement_signed_date,
                rqlf.proof_of_homeowners_insurance_required,
                rqlf.proof_of_homeowners_insurance_obtained_date,
                rqlf.state,
                rqlf.total_cash_down_payment,
                rqlf.first_cash_payment_amount,
                rqlf.substantial_completion_date,
                rqlf.cancelled_date,
                rqlf.on_hold_date,
                ((select rp.total
                 from brs.user_residual as ur
                        inner join brs.residual_plan as rp on rp.id = ur.residual_plan_id
                 where ur.user_id = d.user_id)*(percent_of_residual_earned)),
                now(),
                p_updated_by_id,
                now(),
                p_updated_by_id
         from brs.get_residual_qualified_lifetime_fds(d.user_id) rqlf
         inner join brs.user_residual_snapshot as u on u.user_id = d.user_id and
                                                       u.paid_in_period is true and
                                                       u.residual_earned is true and
                                                       u.id = v_snapshot_id);

      insert into brs.user_residual_project_snapshot(user_residual_snapshot_id,
                                                     project_id,
                                                     user_residual_project_snapshot_type_id,
                                                     final_design_complete_date,
                                                     final_design_signed_date,
                                                     utility_bill_verified_date,
                                                     financial_agreement_signed_date,
                                                     proof_of_homeowners_insurance_required,
                                                     proof_of_homeowners_insurance_obtained_date,
                                                     state,
                                                     total_cash_down_payment,
                                                     first_cash_payment_amount,
                                                     substantial_completion_date,
                                                     cancelled_date,
                                                     on_hold_date,
                                                     date_created,
                                                     created_by_id,
                                                     date_modified,
                                                     modified_by_id)
        (select v_snapshot_id,
                rqlf.project_id,
                (select id
                 from brs.user_residual_project_snapshot_type as urpst
                 where urpst.user_residual_project_snapshot_code = 'FDS_NOT_QUALIFIED_THIS_PERIOD'),
                rqlf.final_design_complete_date,
                rqlf.final_design_signed_date,
                rqlf.utility_bill_verified_date,
                rqlf.financial_agreement_signed_date,
                rqlf.proof_of_homeowners_insurance_required,
                rqlf.proof_of_homeowners_insurance_obtained_date,
                rqlf.state,
                rqlf.total_cash_down_payment,
                rqlf.first_cash_payment_amount,
                rqlf.substantial_completion_date,
                rqlf.cancelled_date,
                rqlf.on_hold_date,
                now(),
                p_updated_by_id,
                now(),
                p_updated_by_id
         from brs.get_residual_fds_not_qualified_this_period(d.user_id) rqlf);

      for x in select *
               from brs.get_residual_fds_qualified_this_period(d.user_id,false)
        loop
          insert into brs.user_residual_project_snapshot(user_residual_snapshot_id,
                                                         project_id,
                                                         user_residual_project_snapshot_type_id,
                                                         final_design_complete_date,
                                                         final_design_signed_date,
                                                         utility_bill_verified_date,
                                                         financial_agreement_signed_date,
                                                         proof_of_homeowners_insurance_required,
                                                         proof_of_homeowners_insurance_obtained_date,
                                                         state,
                                                         total_cash_down_payment,
                                                         first_cash_payment_amount,
                                                         substantial_completion_date,
                                                         cancelled_date,
                                                         on_hold_date,
                                                         qualified_date,
                                                         total,
                                                         date_created,
                                                         created_by_id,
                                                         date_modified,
                                                         modified_by_id)
          values (v_snapshot_id,
                  x.project_id,
                  (select id
                   from brs.user_residual_project_snapshot_type as urpst
                   where urpst.user_residual_project_snapshot_code = 'FDS_QUALIFIED_THIS_PERIOD'),
                  x.final_design_complete_date,
                  x.final_design_signed_date,
                  x.utility_bill_verified_date,
                  x.financial_agreement_signed_date,
                  x.proof_of_homeowners_insurance_required,
                  x.proof_of_homeowners_insurance_obtained_date,
                  x.state,
                  x.total_cash_down_payment,
                  x.first_cash_payment_amount,
                  x.substantial_completion_date,
                  x.cancelled_date,
                  x.on_hold_date,
                  x.qualified_date,
                  (select rp.total
                   from brs.user_residual as ur
                          inner join brs.residual_plan as rp on rp.id = ur.residual_plan_id
                   where ur.user_id = d.user_id),
                  now(),
                  p_updated_by_id,
                  now(),
                  p_updated_by_id);
          insert into brs.residual_project_qualified_date(project_id, qualified_date, date_created, date_modified,
                                                          created_by_id, modified_by_id, residual_id)
          values (x.project_id, now(), now(), now(), p_updated_by_id, p_updated_by_id, p_residual_id);
        end loop;


      insert into brs.user_residual_project_snapshot(user_residual_snapshot_id,
                                                     project_id,
                                                     user_residual_project_snapshot_type_id,
                                                     total,
                                                     cancelled_date,
                                                     date_created,
                                                     created_by_id,
                                                     date_modified,
                                                     modified_by_id)
        (select v_snapshot_id,
                rqlf.project_id,
                (select id
                 from brs.user_residual_project_snapshot_type as urpst
                 where urpst.user_residual_project_snapshot_code = 'CLAWBACKS'),
                rqlf.amount,
                pd.cancelled_date,
                now(),
                p_updated_by_id,
                now(),
                p_updated_by_id
         from brs.get_current_residual_clawbacks(d.user_id) rqlf
         inner join brs.project_details as pd on pd.project_id = rqlf.project_id);

      insert into brs.residual_project_qualified_date(project_id, qualified_date, date_created, date_modified,
                                                      created_by_id, modified_by_id, residual_id, excluded_from_cancel)
        (select a.project_id,
                now(),
                now(),
                now(),
                p_updated_by_id,
                p_updated_by_id,
                p_residual_id,
                true
         from brs.get_residual_fds_qualified_this_period(d.user_id,
                                                         true) a);

    END LOOP;


  UPDATE brs.residual r2
  SET modified_by_id = p_updated_by_id,
      date_modified  = now()
  WHERE id = p_residual_id;

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS
    THEN
      RAISE NOTICE 'ERROR: %',SQLERRM;
      RETURN FALSE;
END;
$BODY$;
