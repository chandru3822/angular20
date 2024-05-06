alter table brs.proposal_log_history add column  if not exists storage_type_id bigint;
alter table brs.proposal_log_history add column  if not exists storage_brand_id bigint;
