drop function if exists brs.first_cash_payment_greater_49_of_down_payment(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.first_cash_payment_greater_49_of_down_payment(p_project_id bigint)
    returns boolean AS
$BODY$
declare
    v_first_cash_payment_amount numeric;
    v_total_cash_down_payment numeric;

BEGIN

    select ppscfv.numeric_value
    into v_first_cash_payment_amount
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 874
    where pps.project_id = p_project_id  and pps.main is true and pps.process_step_id = 57;

    select ppscfv.numeric_value
    into v_total_cash_down_payment
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 19467
    where pps.project_id = p_project_id  and pps.main is true and pps.process_step_id = 3355;

    if v_total_cash_down_payment = 0 then
      return false;
    end if;

    return (v_first_cash_payment_amount / v_total_cash_down_payment) > .49;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
