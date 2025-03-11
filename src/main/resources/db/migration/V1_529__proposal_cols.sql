alter table brs.proposal add column if not exists proposal_details json;
alter table brs.proposal add column if not exists is_external boolean not null default false;

alter table brs.proposal_log_history add column if not exists is_external boolean;
