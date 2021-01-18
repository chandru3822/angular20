CREATE OR REPLACE FUNCTION brs.project_rebate_payments_add_extra_payment(
    p_project_id integer,
    p_created_by_user_id integer,
    p_payment_amount numeric(12,2))
  RETURNS void AS
$BODY$
DECLARE
v_last_payment_nbr integer;
BEGIN

  select max(payment_nbr) + 1
    into v_last_payment_nbr
    from brs.project_rebate_payment
  where project_id = p_project_id;

  update flow.project_process_step_custom_field_value
    set numeric_value = numeric_value + 1 where id =
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
      and p.id = p_project_id);

  insert into brs.project_rebate_payment (project_id, payment_amount, payment_nbr, created_by_user_id, created_date, project_rebate_payment_state_id)
  values (p_project_id, p_payment_amount, v_last_payment_nbr, p_created_by_user_id, (now() at time zone 'US/Mountain')::date,1);


  insert into brs.project_rebate_payment_audit (project_id, audit, changed_date, changed_by_user_id) values (p_project_id, 'Added a new payment to project_id: '||p_project_id||' for payment_amount: '||p_payment_amount,
                                                                                                                      (now() at time zone 'US/Mountain')::date, p_created_by_user_id);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
