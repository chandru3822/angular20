drop function if exists brs.get_residual_fds_qualified_this_period(p_closer_user_id bigint,
                                                                   p_include_cancel boolean);
CREATE or replace function brs.get_residual_fds_qualified_this_period(p_closer_user_id bigint, p_include_cancel boolean default false)
  RETURNS table
          (
            project_id                                  bigint,
            final_design_complete_date                  date,
            final_design_signed_date                    date,
            utility_bill_verified_date                  date,
            financial_agreement_signed_date             date,
            proof_of_homeowners_insurance_required      bigint,
            proof_of_homeowners_insurance_obtained_date date,
            state                                       varchar,
            total_cash_down_payment                     numeric,
            first_cash_payment_amount                   numeric,
            substantial_completion_date                 date,
            cancelled_date                              date,
            on_hold_date                                date,
            qualified_date                              date
          )
AS
$BODY$
declare
  v_period_end                date;
  v_period_start              date;
  v_previous_grace_period_end date;
  v_grace_period_end          date;
begin


  select period_start, period_end, previous_grace_period_end, grace_period_end
  into v_period_start,v_period_end,v_previous_grace_period_end,v_grace_period_end
  from brs.residual r2
  where current is true;


  return query
    select ao.project_id,
           ao.final_design_complete_date,
           ao.final_design_signed_date,
           ao.utility_bill_verified_date,
           ao.financial_agreement_signed_date,
           ao.proof_of_homeowners_insurance_required,
           ao.proof_of_homeowners_insurance_obtained_date,
           ao.state,
           ao.total_cash_down_payment,
           ao.first_cash_payment_amount,
           ao.substantial_completion_date,
           ao.cancelled_date,
           ao.on_hold_date,
           ao.qualified_date
    from brs.get_residual_fds_qualified_this_period(p_closer_user_id,
                                                    v_period_end,
                                                    v_period_start,
                                                    v_previous_grace_period_end,
                                                    v_grace_period_end,
                                                    p_include_cancel) ao;
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
