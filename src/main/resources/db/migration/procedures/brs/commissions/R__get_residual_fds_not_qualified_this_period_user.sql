drop function if exists brs.get_residual_fds_not_qualified_this_period(p_closer_user_id bigint);
CREATE or replace function brs.get_residual_fds_not_qualified_this_period(p_closer_user_id bigint)
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
            on_hold_date                                date
          )
AS
$BODY$
declare
  v_period_start date;
  v_period_end   date;
  v_grace_period_end date;
begin

  select r.period_end, r.period_start,r.grace_period_end
  into v_period_end,v_period_start,v_grace_period_end
  from brs.residual r
  where current is true;


  return query
    select foo.project_id,
           foo.final_design_complete_date,
           foo.final_design_signed_date,
           foo.utility_bill_verified_date,
           foo.financial_agreement_signed_date,
           foo.proof_of_homeowners_insurance_required,
           foo.proof_of_homeowners_insurance_obtained_date,
           foo.state,
           foo.total_cash_down_payment,
           foo.first_cash_payment_amount,
           foo.substantial_completion_date,
           foo.cancelled_date,
           foo.on_hold_date
    from brs.get_residual_fds_not_qualified_this_period(p_closer_user_id, v_period_start, v_period_end,v_grace_period_end) as foo;

END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;


