drop function if exists brs.get_residual_fds_qualified_this_period(p_closer_user_id bigint,p_include_cancel boolean);
CREATE or replace function brs.get_residual_fds_qualified_this_period(p_closer_user_id bigint,p_include_cancel boolean default false)
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
  v_end_of_previous_month       date;
  v_beginning_of_previous_month date;
  v_fifteenth_previous_month    date;
  v_fifteenth_current_month     date;
  v_last_period_end_date        date;
  v_current_month               integer;
  v_current_month_of_paid_date integer;
begin


  select r.period_end
  into v_last_period_end_date
  from brs.residual r
  order by id desc limit 1;

  select to_char(now(), 'MM')::integer
  into v_current_month;

  select to_char(v_last_period_end_date, 'MM')::integer
  into v_current_month_of_paid_date;

  SELECT (date_trunc('month', v_last_period_end_date) + interval '1 month' - interval '1 day')::date
  into v_end_of_previous_month;

  select cast(date_trunc('month', v_last_period_end_date) as date)
  into v_beginning_of_previous_month;

  select cast(date_trunc('month', v_last_period_end_date ) as date) + 14
  into v_fifteenth_previous_month;

  if v_current_month = v_current_month_of_paid_date then
    select cast(date_trunc('month', v_last_period_end_date ) as date) + 14
    into v_fifteenth_current_month;
  else
    select cast(date_trunc('month', v_last_period_end_date + interval '1 month') as date) + 14
    into v_fifteenth_current_month;
  end if;

  return query
    select * from brs.get_residual_fds_qualified_this_period(p_closer_user_id,
                                                                     v_end_of_previous_month,
                                                                     v_beginning_of_previous_month,
                                                                     v_fifteenth_previous_month,
                                                                     v_fifteenth_current_month,
                                                                     p_include_cancel);


END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;




