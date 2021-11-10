CREATE OR REPLACE FUNCTION brs.delete_rebate_payment(
    p_payment_id integer,
    p_deleted_by_user_id integer)
  RETURNS void AS
$BODY$
DECLARE
v_project_id integer;
v_payment_amount numeric(12,2);
BEGIN

    select project_id, payment_amount
      into v_project_id, v_payment_amount
      from brs.project_rebate_payment
     where id = p_payment_id;

    delete from brs.project_rebate_payment
    where id = p_payment_id;

    update flow.project_process_step_custom_field_value
        set numeric_value = numeric_value-1, date_modified = now() where id =
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
    where cfga.custom_field_id = (select id from flow.custom_field where parent_custom_field_id=10324
                                    and company_id = (select company_id from brs.project_details where project_id = v_project_id))
      and p.id = v_project_id and pps.main = true);

    insert into brs.project_rebate_payment_audit (project_id, audit, changed_date, changed_by_user_id)
    values (v_project_id, 'Deleted payment_id: '||p_payment_id||' payment_amount: '||v_payment_amount, (now() at time zone 'US/Mountain')::date, p_deleted_by_user_id);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
