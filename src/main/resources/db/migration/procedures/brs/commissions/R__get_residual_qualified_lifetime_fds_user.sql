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
                 qualified_date date,
                 system_size                                 numeric,
                 system_size_adjusted_for_source             numeric,
                 plan_name                               varchar,
                 expected_residual                           numeric,
                 is_system_size boolean) AS
$BODY$
declare
v_period_end date;
v_grace_period_end date;
v_lifetime_fds bigint;
v_count_qualified_fdc bigint;
  v_sum_system_size_qualified numeric;
begin

  select grace_period_end ,period_end
  into v_grace_period_end,v_period_end
  from brs.residual r2
  where current is true;

  select count(1)
  into v_lifetime_fds
  from brs.get_residual_qualified_lifetime_fds(p_closer_user_id,v_period_end,v_grace_period_end);

  select count(1),sum(ao.system_size_adjusted_for_source)
  into v_count_qualified_fdc,v_sum_system_size_qualified
  from brs.get_residual_fds_qualified_this_period(p_closer_user_id)ao;

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
         pd.qualified_date,
         pd.system_size,
         pd.system_size_adjusted_for_source,
         pd.plan_name,
         pd.expected_residual,
         pd.is_system_size
         from
         brs.get_residual_qualified_lifetime_fds(p_closer_user_id,v_period_end,v_grace_period_end,v_lifetime_fds,v_count_qualified_fdc,v_sum_system_size_qualified) pd;
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
