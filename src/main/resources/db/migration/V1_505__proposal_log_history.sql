alter table brs.proposal_log_history add column  if not exists rete_itc_incentive_amount numeric;
alter table brs.proposal_log_history add column  if not exists rete_depreciation_incentive_amount numeric;
alter table brs.proposal_log_history add column  if not exists rete_incentive_applied boolean;
alter table brs.proposal_log_history add column  if not exists rete_reamortized_monthly_payment_all_credits_to_loan numeric;


