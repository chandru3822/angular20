-- These fields are being used in the public/epc API
alter table brs.proposal_log_history add column if not exists storage_package_name varchar(100) default null;
alter table brs.proposal_log_history add column if not exists smart_switch_name varchar(100) default null;
alter table brs.proposal_log_history add column if not exists smart_switch_part_number varchar(100) default null;
alter table brs.proposal_log_history add column if not exists storage_model varchar(100) default null;
alter table brs.proposal_log_history add column if not exists storage_part_number varchar(100) default null;
alter table brs.proposal_log_history add column if not exists estimated_backup_hours numeric default null;
alter table brs.proposal_log_history add column if not exists estimated_backup_hours_with_pv numeric default null;
alter table brs.proposal_log_history add column if not exists storage_size_kwh_per_battery numeric default null;