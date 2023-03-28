drop function if exists brs.get_residual_fds_qualified_this_period(p_closer_user_id bigint,
                                                                   p_end_of_previous_month date,
                                                                   p_beginning_of_previous_month date,
                                                                   p_fifteenth_previous_month date,
                                                                   p_fifteenth_current_month date,
                                                                   p_include_cancel boolean);
CREATE or replace function brs.get_residual_fds_qualified_this_period(p_closer_user_id bigint,
                                                                      p_end_of_previous_month date,
                                                                      p_beginning_of_previous_month date,
                                                                      p_fifteenth_previous_month date,
                                                                      p_fifteenth_current_month date,
                                                                      p_include_cancel boolean default false)
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
  v_min_start_date timestamp;
begin

  select min(start_date)
  into v_min_start_date
  from flow.user_position up
  where user_id = p_closer_user_id
  and position_id in (1, 2, 3, 517);


--   raise notice 'p_current_month %',p_current_month;
--   raise notice 'p_current_month_of_paid_date %',p_current_month_of_paid_date;
--   raise notice 'p_end_of_previous_month %',p_end_of_previous_month;
--   raise notice 'p_beginning_of_previous_month %',p_beginning_of_previous_month;
--   raise notice 'p_fifteenth_previous_month %',p_fifteenth_previous_month;
--   raise notice 'p_fifteenth_current_month %',p_fifteenth_current_month;

  return query
  select foo.project_id ,
         foo.final_design_complete_date,
         foo.final_design_signed_date ,
         foo.utility_bill_verified_date ,
         foo.financial_agreement_signed_date ,
         foo.proof_of_homeowners_insurance_required ,
         foo.proof_of_homeowners_insurance_obtained_date ,
         foo.state ,
         foo.total_cash_down_payment ,
         foo.first_cash_payment_amount ,
         foo.substantial_completion_date ,
         foo.cancelled_date ,
         foo.on_hold_date,
         foo.final_design_complete_date1
  from (select pd.project_id ,
               pd.final_design_complete_date,
               pd.final_design_signed_date ,
               pd.utility_bill_verified_date ,
               pd.financial_agreement_signed_date ,
               pd.proof_of_homeowners_insurance_required ,
               pd.proof_of_homeowners_insurance_obtained_date ,
               s.state ,
               pd.total_cash_down_payment ,
               pd.first_cash_payment_amount ,
               pd.substantial_completion_date ,
               pd.cancelled_date ,
               pd.on_hold_date,
               coalesce(rpoqd.override_qualified_date,greatest(pd.financial_agreement_signed_date, pd.utility_bill_verified_date, case
                                                                                                                    when pd.proof_of_homeowners_insurance_required = 305
                                                                                                                      then
                                                                                                                      pd.proof_of_homeowners_insurance_obtained_date
                                                                                                                    else null end,
                        case
                          when pd.total_cash_down_payment is not null and pd.total_cash_down_payment > 1::numeric then
                            case
                              when (pd.project_state_id = 28 and
                                    pd.first_cash_payment_amount >= 1000.00) then
                                pd.first_cash_payment_paid_date
                              when (round((pd.first_cash_payment_amount /
                                    greatest(pd.total_cash_down_payment,1))::numeric,2) >= .49) then
                                pd.first_cash_payment_paid_date
                              else null end
                          else null end)) as final_design_complete_date1

        from brs.project_details pd
        inner join flow.project p on p.id = pd.project_id and p.company_process_id = 1
        left join flow.state s on s.id = pd.project_state_id
        left join brs.residual_project_override_qualified_date rpoqd on rpoqd.project_id = pd.project_id
        where pd.final_design_signed_date >= v_min_start_date and
              pd.exclude_from_residuals is not true and
              pd.closer_user_id = p_closer_user_id and
              case when p_include_cancel is false then
                pd.cancelled_date is null
              when p_include_cancel is true then
                pd.cancelled_date is not null end and
              ((pd.on_hold_date is null) or (pd.on_hold_date is not null and off_hold_date is not null)) and
              pd.final_design_signed_date is not null and
                pd.financial_agreement_signed_date is not null and
                pd.utility_bill_verified_date is not null and
                pd.proof_of_homeowners_insurance_required is not null and
               case
                 when pd.proof_of_homeowners_insurance_required = 305 then
                   pd.proof_of_homeowners_insurance_obtained_date is not null
                 else 1 = 1 end and
                case
                  when pd.total_cash_down_payment is not null and pd.total_cash_down_payment > 1.00::numeric then
                    case
                      when (pd.project_state_id = 28 and
                            pd.first_cash_payment_amount >= 1000.00) then
                        pd.first_cash_payment_paid_date is not null
                      when (round((pd.first_cash_payment_amount /
                            greatest(pd.total_cash_down_payment,1))::numeric,2) >= .49) then
                        pd.first_cash_payment_paid_date is not null end
                  else 1 = 1 end and
          not exists (select id from brs.residual_project_qualified_date rpqd
                      where rpqd.project_id = pd.project_id limit 1)) as foo
  where foo.final_design_signed_date <= p_end_of_previous_month
    and final_design_complete_date1 is not null
    and

    (case
       when foo.final_design_signed_date >= p_beginning_of_previous_month and foo.final_design_signed_date <= p_end_of_previous_month then ----beginning of the qualifying month
             foo.final_design_complete_date1 >= p_beginning_of_previous_month and ----- previous month end of qualifying month
             foo.final_design_complete_date1 <= p_fifteenth_current_month end or -- beginning of the qualifying month to the current months 15th day
     case
       when foo.final_design_signed_date < p_beginning_of_previous_month then ----beginning of the month
             foo.final_design_complete_date1 > p_fifteenth_previous_month   and --always the current month
             foo.final_design_complete_date1 <= p_fifteenth_current_month end); --15th of the qualifying month  to the 15th of the current month
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
