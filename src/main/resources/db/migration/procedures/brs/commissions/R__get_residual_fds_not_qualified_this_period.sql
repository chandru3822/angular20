drop function if exists brs.get_residual_fds_not_qualified_this_period(p_closer_user_id bigint, p_start_date date,
                                                                       p_end_date date, p_grace_period_end_date date);
CREATE or replace function brs.get_residual_fds_not_qualified_this_period(p_closer_user_id bigint, p_start_date date,
                                                                          p_end_date date, p_grace_period_end_date date)
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
  v_min_start_date date;
begin

  select min(start_date)
    into v_min_start_date
  from flow.user_position up
  where user_id = p_closer_user_id
  and position_id in (1, 2, 3, 517);

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
                 pd.off_hold_date,
                 (pd.proof_of_homeowners_insurance_required = 305 and
                  pd.proof_of_homeowners_insurance_obtained_date is not null) or
                 (pd.proof_of_homeowners_insurance_required is not null and
                  pd.proof_of_homeowners_insurance_required != 305)                                as proof_of_homeowners_insurance,
                 (pd.total_cash_down_payment is not null and pd.total_cash_down_payment > 1::numeric
                    and (
                      (pd.third_party_financing is true and
                       pd.first_cash_payment_paid_date is not null) or
                      (pd.project_state_id = 28 and pd.first_cash_payment_amount >= 1000.00 and
                       pd.first_cash_payment_paid_date is not null) or
                      ((round((pd.first_cash_payment_amount / greatest(pd.total_cash_down_payment, 1))::numeric,2) >= .49) and
                       pd.first_cash_payment_paid_date is not null)
                    ) or
                  (pd.total_cash_down_payment is null or pd.total_cash_down_payment <
                                                         1::numeric))                              as first_cash_payment,
                 pd.first_cash_payment_paid_date
          from brs.project_details pd
                 inner join flow.project p on p.id = pd.project_id and p.company_process_id = 1
                 left join flow.state s on s.id = pd.project_state_id
          where pd.final_design_signed_date >= v_min_start_date and
                pd.exclude_from_residuals is not true
            and pd.closer_user_id = p_closer_user_id
            and pd.final_design_signed_date is not null
            and pd.final_design_signed_date >= p_start_date
            and pd.final_design_signed_date <= p_end_date
           -- and pd.cancelled_date is null
           --and pd.on_hold_date is null
         ) as foo
    where ((foo.proof_of_homeowners_insurance is false or
            foo.proof_of_homeowners_insurance_obtained_date > p_grace_period_end_date) or
           (foo.first_cash_payment is false or (foo.total_cash_down_payment > 1 and foo.first_cash_payment_paid_date > p_grace_period_end_date)) or
           (foo.financial_agreement_signed_date is null or
            foo.financial_agreement_signed_date > p_grace_period_end_date) or
           (foo.utility_bill_verified_date is null or foo.utility_bill_verified_date > p_grace_period_end_date) or
           (foo.cancelled_date is not null) or (foo.on_hold_date is not null and foo.off_hold_date is null))
      and (foo.substantial_completion_date is null or foo.substantial_completion_date > p_grace_period_end_date)
      and foo.final_design_signed_date >= p_start_date
      and foo.final_design_signed_date <= p_end_date;

END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;


