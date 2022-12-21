drop function if exists brs.update_rebate_payment(p_payment_id bigint,p_updated_by_user_id bigint, p_payment_amount numeric(12,2));
CREATE OR REPLACE FUNCTION brs.update_rebate_payment(p_payment_id bigint,p_updated_by_user_id bigint, p_payment_amount numeric(12,2))
  RETURNS VOID AS
$BODY$
DECLARE
v_old_payment_amount numeric(12,2);
v_project_id bigint;

BEGIN
--select brs.update_rebate_payment(23, 2350555, '2018-01-15', 200, 2);
--select brs.update_rebate_payment(24, 2350555, '2018-02-15', 200, 1);

    select payment_amount, project_id
      into v_old_payment_amount, v_project_id
      from brs.project_rebate_payment
     where id = p_payment_id;

    update brs.project_rebate_payment
      set
          payment_amount = p_payment_amount,
          updated_by_user_id = p_updated_by_user_id,
          updated_date = (now() at time zone 'US/Mountain')::date
    where id = p_payment_id;

insert into brs.project_rebate_payment_audit (project_id, audit, changed_date, changed_by_user_id) values (v_project_id, 'Updated payment_id: '||p_payment_id||' old payment_amount: '||v_old_payment_amount||
                                                                                                                      ' new payment_amount: '||p_payment_amount,
                                                                                                                      (now() at time zone 'US/Mountain')::date, p_updated_by_user_id);

insert into flow.company_function_log(function_name, parameters, run_by_id)
values ('Update Rebate Payments', 'p_payment_id: ' || p_payment_id ||
                                  ' p_updated_by_user_id: ' || p_updated_by_user_id ||
                                  ' p_payment_amount: ' || p_payment_amount,
        p_updated_by_user_id);

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
