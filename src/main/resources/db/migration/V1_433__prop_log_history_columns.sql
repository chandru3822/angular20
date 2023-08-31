alter table brs.proposal_log_history add column  if not exists full_commission_discount_amount numeric;
alter table brs.proposal_log_history add column  if not exists closer_commission_forfeiture_amount numeric;
alter table brs.proposal_log_history add column  if not exists desired_commission_amount numeric;

