drop function if exists brs.get_residual_qualified_lifetime_fds(p_closer_user_id bigint);
CREATE or replace function brs.get_residual_qualified_lifetime_fds(p_closer_user_id bigint)
  RETURNS table (project_id bigint,
                 final_design_complete_date date,
                 final_design_signed_date date,
                 utility_bill_verified_date date,
                 financial_agreement_signed_date date,
                 proof_of_homeowners_insurance_required bigint,
                 proof_of_homeowners_insurance_obtained_date date,
                 state varchar,
                 total_cash_down_payment numeric,
                 first_cash_payment_amount numeric,
                 substantial_completion_date date,
                 cancelled_date date,
                 on_hold_date date,
                 qualified_date date) AS
$BODY$
declare
v_period_end date;
v_grace_period_end date;
begin

  select grace_period_end ,period_end
  into v_grace_period_end,v_period_end
  from brs.residual r2
  where current is true;

  return query
  select pd.project_id ,
         pd.final_design_complete_date,
         pd.final_design_signed_date ,
         pd.utility_bill_verified_date ,
         pd.financial_agreement_signed_date ,
         pd.proof_of_homeowners_insurance_required ,
         pd.proof_of_homeowners_insurance_obtained_date ,
         pd.state ,
         pd.total_cash_down_payment ,
         pd.first_cash_payment_amount ,
         pd.substantial_completion_date ,
         pd.cancelled_date ,
         pd.on_hold_date,
         pd.qualified_date
         from
         brs.get_residual_qualified_lifetime_fds(p_closer_user_id,v_period_end,v_grace_period_end) pd;
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
