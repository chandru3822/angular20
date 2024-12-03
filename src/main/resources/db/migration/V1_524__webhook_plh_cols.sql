alter table brs.proposal_log_history add column if not exists financial_agreement_signed timestamp;
alter table brs.proposal_log_history add column if not exists countersigned timestamp;
alter table brs.proposal_log_history add column if not exists goodleap_application_created_date timestamp;
