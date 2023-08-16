drop function if exists brs.get_residual_qualified_lifetime_fds(p_closer_user_id bigint, p_end_of_period_date date,p_grace_period_end date);
CREATE or replace function brs.get_residual_qualified_lifetime_fds(p_closer_user_id bigint, p_end_of_period_date date,p_grace_period_end date)
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
  v_min_start_date timestamp;
begin
  select min(start_date)
    into v_min_start_date
  from flow.user_position up
  where user_id = p_closer_user_id
  and up.position_id in (1, 2, 3, 517);
  return query
    select pd.project_id,
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
           coalesce(rpoqd.override_qualified_date,
                    greatest(pd.financial_agreement_signed_date, pd.utility_bill_verified_date, case
                                                                                                  when pd.proof_of_homeowners_insurance_required = 305
                                                                                                    then
                                                                                                    pd.proof_of_homeowners_insurance_obtained_date
                                                                                                  else null end,
                             case
                               when pd.total_cash_down_payment is not null and pd.total_cash_down_payment > 1::numeric
                                 then
                                 case
                                   when pd.third_party_financing is true then
                                     pd.first_cash_payment_paid_date
                                   when (pd.project_state_id = 28 and
                                         pd.first_cash_payment_amount >= 1000.00) then
                                     pd.first_cash_payment_paid_date
                                   when (round((pd.first_cash_payment_amount) /
                                         greatest(pd.total_cash_down_payment, 1)::numeric,2) >= .49) then
                                     pd.first_cash_payment_paid_date
                                   else null end
                               else null end)) as final_design_complete_date1
    from brs.project_details pd
           inner join flow.project p on p.id = pd.project_id and p.company_process_id = 1
           left join flow.state s on s.id = pd.project_state_id
           left join brs.residual_project_override_qualified_date rpoqd on rpoqd.project_id = pd.project_id
    where pd.closer_user_id = p_closer_user_id
        and  pd.exclude_from_residuals is not true
        and pd.cancelled_date is null
        and ((pd.on_hold_date is null) or (pd.on_hold_date is not null and off_hold_date is not null))
        and  ((pd.final_design_signed_date >= v_min_start_date and
          pd.final_design_signed_date >= '2017-01-01'::date
      and pd.final_design_signed_date is not null
      and pd.final_design_signed_date <= p_end_of_period_date
      and ((pd.utility_bill_verified_date is not null
      and pd.financial_agreement_signed_date is not null
      and case
            when pd.proof_of_homeowners_insurance_required = 305 then
              pd.proof_of_homeowners_insurance_obtained_date is not null
            else 1 = 1 end
      and case
            when pd.total_cash_down_payment is not null and pd.total_cash_down_payment > 1.00::numeric then
              case
                when pd.third_party_financing is true then
                  pd.first_cash_payment_paid_date is not null
                when (pd.project_state_id = 28 and
                      pd.first_cash_payment_amount >= 1000.00) then
                  pd.first_cash_payment_paid_date is not null
                when (round(pd.first_cash_payment_amount /
                      greatest(pd.total_cash_down_payment, 1)::numeric,2) >= .49) then
                  pd.first_cash_payment_paid_date is not null end
            else 1 = 1 end and
            coalesce(rpoqd.override_qualified_date,
                     greatest(pd.financial_agreement_signed_date, pd.utility_bill_verified_date, case
                                                                                                   when pd.proof_of_homeowners_insurance_required = 305
                                                                                                     then
                                                                                                     pd.proof_of_homeowners_insurance_obtained_date
                                                                                                   else null end,
                              case
                                when pd.total_cash_down_payment is not null and pd.total_cash_down_payment > 1::numeric
                                  then
                                  case
                                    when pd.third_party_financing is true then
                                      pd.first_cash_payment_paid_date
                                    when (pd.project_state_id = 28 and
                                          pd.first_cash_payment_amount >= 1000.00) then
                                      pd.first_cash_payment_paid_date
                                    when (round((pd.first_cash_payment_amount) /
                                          greatest(pd.total_cash_down_payment, 1)::numeric,2) >= .49) then
                                      pd.first_cash_payment_paid_date
                                    else null end
                                else null end)) <= p_grace_period_end) or
          ((pd.substantial_completion_date is not null and pd.substantial_completion_date <=p_grace_period_end ) or rpoqd.project_id is not null))) or
              (exists (select id from brs.residual_project_qualified_date rpqd
                                where pd.project_id = rpqd.project_id)));
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
