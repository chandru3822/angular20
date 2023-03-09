alter table brs.proposal_log_history
  add column if not exists number_of_batteries varchar(100);

alter table brs.proposal_log_history
  add column if not exists estimated_backup_days varchar(100);

alter table brs.proposal_log_history
  add column if not exists solar_rebate_for_hic varchar(100);

alter table brs.proposal_log_history
  add column if not exists include_soft_start_device varchar(100);
