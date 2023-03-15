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
            state                            varchar,
            total_cash_down_payment                     numeric,
            first_cash_payment_amount                   numeric,
            substantial_completion_date                 date,
            cancelled_date                              date,
            on_hold_date                                date
          )
AS
$BODY$
begin

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
    from (select pd.project_id,
                 pd.final_design_complete_date,
                 pd.final_design_signed_date,
                 pd.utility_bill_verified_date,
                 pd.financial_agreement_signed_date,
                 pd.proof_of_homeowners_insurance_required,
                 pd.proof_of_homeowners_insurance_obtained_date,
                 s.state,
                 pd.total_cash_down_payment,
                 pd.first_cash_payment_amount,
                 pd.substantial_completion_date,
                 pd.cancelled_date,
                 pd.on_hold_date,
                 (pd.proof_of_homeowners_insurance_required is not null and
                  pd.proof_of_homeowners_insurance_required = 305 and
                  pd.proof_of_homeowners_insurance_obtained_date is not null) or
                 (pd.proof_of_homeowners_insurance_required is not null and
                  pd.proof_of_homeowners_insurance_required != 305)                           as proof_of_homeowners_insurance,
                 (pd.total_cash_down_payment is not null and pd.total_cash_down_payment > 1::numeric
                    and (pd.project_state_id = 28  and
                         pd.first_cash_payment_amount >= 1000.00) or
                  ((pd.first_cash_payment_amount) /
                   greatest(pd.total_cash_down_payment,1) >= .49)) or
                 (pd.total_cash_down_payment is null or pd.total_cash_down_payment < 1::numeric) as first_cash_payment
          from brs.project_details pd
          inner join flow.project p on p.id = pd.project_id and p.company_process_id = 1
          left join flow.state s on s.id = pd.project_state_id
          where pd.closer_user_id = p_closer_user_id
            and pd.final_design_signed_date is not null
            and pd.cancelled_date is null
            and pd.on_hold_date is null) as foo
    where (foo.proof_of_homeowners_insurance is false or foo.first_cash_payment is false or
           foo.financial_agreement_signed_date is null or foo.utility_bill_verified_date is null)
      and foo.substantial_completion_date is null;

END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;


