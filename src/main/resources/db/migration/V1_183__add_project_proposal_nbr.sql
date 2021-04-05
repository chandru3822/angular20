alter table brs.project_details add column if not exists proposal_nbr integer;

alter table brs.proposal_log_history add column if not exists sunlight_hash_id varchar(100);
