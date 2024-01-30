alter table brs.proposal_log_history add column  if not exists virtual_sales_base_price numeric;
alter table brs.proposal_log_history add column  if not exists virtual_sales_price_adjustment numeric;
