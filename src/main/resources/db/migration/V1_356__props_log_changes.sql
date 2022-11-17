alter table brs.proposal_log_history
add column if not exists factor_ee_into_new_usage varchar(100);

alter table brs.proposal_log_history
rename column eighteen_plus_payments_all_incentives to nineteen_plus_payments_all_incentives;

alter table brs.proposal_log_history
rename column solar_degradation to annual_degradation;

alter table brs.proposal_log_history
  rename column average_monthly_usage_before_solar to monthly_cost_today_before_solar;


