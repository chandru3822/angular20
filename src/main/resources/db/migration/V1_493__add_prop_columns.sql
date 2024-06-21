alter table brs.proposal_log_history add column  if not exists panel_model text;
alter table brs.proposal_log_history add column  if not exists financed_pv_price_per_watt_to_customer numeric;
alter table brs.proposal_log_history add column  if not exists first_year_avoided_bill numeric;
alter table brs.proposal_log_history add column  if not exists battery_workmanship_warranty numeric;
alter table brs.proposal_log_history add column  if not exists battery_manufacturers_warranty numeric;
