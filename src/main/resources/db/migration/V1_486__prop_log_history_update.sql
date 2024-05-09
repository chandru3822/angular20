alter table brs.proposal_log_history add column  if not exists product_id bigint;
alter table brs.proposal_log_history add column  if not exists site_survey_resource_type_id bigint;
alter table brs.proposal_log_history add column  if not exists loan_term_id bigint;
alter table brs.proposal_log_history add column  if not exists financier_id bigint;
alter table brs.proposal_log_history add column  if not exists financier text;
alter table brs.proposal_log_history add column  if not exists panel_id bigint;



