CREATE OR REPLACE FUNCTION brs.create_rebate_payments(
    p_project_id integer,
    p_created_by_user_id integer,
    p_total_promotion_amount numeric(12,2),
    p_number_of_promotion_payments integer)
  RETURNS VOID AS
$BODY$
DECLARE
v_payment_nbr integer;
BEGIN

    update flow.project_process_step_custom_field_value
    set numeric_value = p_total_promotion_amount, date_modified = now()
    where id =
    (select pscfv.id
    from flow.project p
             inner join flow.project_process_step pps
                        on pps.project_id = p.id and pps.process_step_id = 4
             inner join flow.project_process_step_custom_field_value pscfv
                        on pps.id = pscfv.project_process_step_id
             inner join flow.custom_field_group_assignment cfga
                        on cfga.id = pscfv.custom_field_group_assignment_id
             inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
             inner join flow.custom_field cf on cf.id = cfga.custom_field_id
             inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
             inner join flow.data_type dt on dt.id = cdt.data_type_id
    where cfga.custom_field_id = (select id from flow.custom_field where parent_custom_field_id= 10430
                                    and company_id = (select company_id from brs.project_details where project_id = p_project_id))
      and p.id = p_project_id and pps.main = true);

    update flow.project_process_step_custom_field_value
    set numeric_value = p_total_promotion_amount, date_modified = now() where id =
    (select pscfv.id
    from flow.project p
             inner join flow.project_process_step pps
                        on pps.project_id = p.id and pps.process_step_id = 4
             inner join flow.project_process_step_custom_field_value pscfv
                        on pps.id = pscfv.project_process_step_id
             inner join flow.custom_field_group_assignment cfga
                        on cfga.id = pscfv.custom_field_group_assignment_id
             inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
             inner join flow.custom_field cf on cf.id = cfga.custom_field_id
             inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
             inner join flow.data_type dt on dt.id = cdt.data_type_id
    where cfga.custom_field_id = (select id from flow.custom_field where parent_custom_field_id= 10324
                                    and company_id = (select company_id from brs.project_details where project_id = p_project_id))
      and p.id = p_project_id and pps.main = true);

--Create an audit record
  insert into brs.project_rebate_payment_audit(project_id, audit, changed_date, changed_by_user_id) values
                                                 (p_project_id, 'Payment schedule initial creation for project_id:'||p_project_id||' total_promotion_amount: '||p_total_promotion_amount||
                                                             ' number_of_promotion_payments: '|| p_number_of_promotion_payments,
                                                             (now() at time zone 'US/Mountain')::date, p_created_by_user_id);

  v_payment_nbr := 1;

--Loop through the number of payments(aka number of months) and create a payment record for each payment installment.
  FOR x in 1..p_number_of_promotion_payments LOOP

     INSERT INTO brs.project_rebate_payment (project_id, payment_amount, payment_nbr, created_by_user_id, created_date, project_rebate_payment_state_id) values (p_project_id, p_total_promotion_amount/p_number_of_promotion_payments, v_payment_nbr, p_created_by_user_id,(now() at time zone 'US/Mountain')::date, 1);
    v_payment_nbr := v_payment_nbr + 1;
  END LOOP;

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

