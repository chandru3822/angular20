alter table brs.proposal_log_history add column  if not exists all_rebates jsonb;
alter table brs.proposal_log_history add column  if not exists net_system_cost numeric;
alter table brs.proposal_log_history add column  if not exists eto_rebate_amount numeric;
