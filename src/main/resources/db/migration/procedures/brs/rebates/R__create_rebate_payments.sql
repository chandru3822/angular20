drop function if exists brs.create_rebate_payments(
  p_project_id bigint,
  p_created_by_user_id bigint,
  p_total_promotion_amount numeric(12, 2),
  p_number_of_promotion_payments bigint);
CREATE OR REPLACE FUNCTION brs.create_rebate_payments(
  p_project_id bigint,
  p_created_by_user_id bigint,
  p_total_promotion_amount numeric(12, 2),
  p_number_of_promotion_payments bigint)
  RETURNS VOID AS
$BODY$
DECLARE
  v_payment_nbr                            bigint;
  v_utility_bill_uploaded_date             date;
  v_hoi_uploaded_date                      date;
  v_product                                integer;
  v_installation_agreement_signed_date     date;
  v_financial_agreement_signed_date        date;
  v_substantial_completion_date            date;
  v_proof_of_homeowners_insurance_required integer;
BEGIN

  select (min(date_created) at time zone 'US/Mountain')::date
  into v_utility_bill_uploaded_date
  from (select min(att.date_created) as date_created
        from flow.attachment att
               join flow.project_attachment pa on att.id = pa.attachment_id
          and att.attachment_type_id in (47)
          and att.archived is not true
        where pa.project_id = p_project_id
        UNION
        select min(att.date_created) as date_created
        from flow.attachment att
               join flow.project_process_step_attachment ppsa on att.id = ppsa.attachment_id
          and att.attachment_type_id in (47)
          and att.archived is not true
               join flow.project_process_step pps on ppsa.project_process_step_id = pps.id
        where pps.project_id = p_project_id) as ub;

  select (min(date_created) at time zone 'US/Mountain')::date
  into v_hoi_uploaded_date
  from (select min(att.date_created) as date_created
        from flow.attachment att
               join flow.project_attachment pa on att.id = pa.attachment_id
          and att.attachment_type_id in (942)
          and att.archived is not true
        where pa.project_id = p_project_id
        UNION

        select min(att.date_created) as date_created
        from flow.attachment att
               join flow.project_process_step_attachment ppsa on att.id = ppsa.attachment_id
          and att.attachment_type_id in (942)
          and att.archived is not true
               join flow.project_process_step pps on ppsa.project_process_step_id = pps.id
        where pps.project_id = p_project_id) as hoi;

  select product,
         installation_agreement_signed_date,
         financial_agreement_signed_date,
         substantial_completion_date,
         proof_of_homeowners_insurance_required
  into v_product,
    v_installation_agreement_signed_date,
    v_financial_agreement_signed_date,
    v_substantial_completion_date,
    v_proof_of_homeowners_insurance_required
  from brs.project_details pd
  where pd.project_id = p_project_id;

  if v_product = 293 and v_substantial_completion_date is not null and
     v_financial_agreement_signed_date <= (v_installation_agreement_signed_date + 3)::date and
     v_utility_bill_uploaded_date <= (v_installation_agreement_signed_date + 3)::date and
     (v_proof_of_homeowners_insurance_required = 305 and
      v_hoi_uploaded_date <= (v_installation_agreement_signed_date + 3)::date
       or (v_proof_of_homeowners_insurance_required = 306)) then
    p_number_of_promotion_payments = 1;
  end if;


  update flow.project_process_step_custom_field_value
  set numeric_value  = p_total_promotion_amount,
      modified_by_id = p_created_by_user_id,
      date_modified  = now()
  where id =
        (select ppscfv.id
         from flow.project_process_step pps
                inner join flow.project_process_step_custom_field_value ppscfv
                           on ppscfv.project_process_step_id = pps.id and
                              ppscfv.custom_field_group_assignment_id = 19462
         where project_id = p_project_id
           and pps.main is true);

  update flow.project_process_step_custom_field_value
  set int_value      = p_number_of_promotion_payments,
      modified_by_id = p_created_by_user_id,
      date_modified  = now()
  where id =
        (select ppscfv.id
         from flow.project_process_step pps
                inner join flow.project_process_step_custom_field_value ppscfv
                           on ppscfv.project_process_step_id = pps.id and
                              ppscfv.custom_field_group_assignment_id = 19459
         where project_id = p_project_id
           and pps.main is true);

--Create an audit record
  insert into brs.project_rebate_payment_audit(project_id, audit, changed_date, changed_by_user_id)
  values (p_project_id,
          'Payment schedule initial creation for project_id:' || p_project_id || ' total_promotion_amount: ' ||
          p_total_promotion_amount ||
          ' number_of_promotion_payments: ' || p_number_of_promotion_payments,
          (now() at time zone 'US/Mountain')::date, p_created_by_user_id);

  v_payment_nbr := 1;

--Loop through the number of payments (aka number of months) and create a payment record for each payment installment.
  FOR x in 1..p_number_of_promotion_payments
    LOOP

      INSERT INTO brs.project_rebate_payment (project_id, payment_amount, payment_nbr, created_by_user_id, created_date,
                                              project_rebate_payment_state_id)
      values (p_project_id, p_total_promotion_amount / p_number_of_promotion_payments, v_payment_nbr,
              p_created_by_user_id, (now() at time zone 'US/Mountain')::date, 1);
      v_payment_nbr := v_payment_nbr + 1;
    END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

