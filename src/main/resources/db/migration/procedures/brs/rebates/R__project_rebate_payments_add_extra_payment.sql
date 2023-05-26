drop function if exists brs.project_rebate_payments_add_extra_payment(
  p_project_id bigint,
  p_created_by_user_id bigint,
  p_payment_amount numeric(12, 2));
CREATE OR REPLACE FUNCTION brs.project_rebate_payments_add_extra_payment(
  p_project_id bigint,
  p_created_by_user_id bigint,
  p_payment_amount numeric(12, 2))
  RETURNS void AS
$BODY$
DECLARE
  v_last_payment_nbr bigint;
BEGIN

  select max(payment_nbr) + 1
  into v_last_payment_nbr
  from brs.project_rebate_payment
  where project_id = p_project_id;

  update flow.project_process_step_custom_field_value
  set numeric_value  = numeric_value + 1,
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

  insert into brs.project_rebate_payment (project_id, payment_amount, payment_nbr, created_by_user_id, created_date,
                                          project_rebate_payment_state_id)
  values (p_project_id, p_payment_amount, v_last_payment_nbr, p_created_by_user_id,
          (now() at time zone 'US/Mountain')::date, 1);


  insert into brs.project_rebate_payment_audit (project_id, audit, changed_date, changed_by_user_id)
  values (p_project_id,
          'Added a new payment to project_id: ' || p_project_id || ' for payment_amount: ' || p_payment_amount,
          (now() at time zone 'US/Mountain')::date, p_created_by_user_id);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
