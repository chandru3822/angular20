alter table brs.installation_agreement_requests
  add column if not exists send_finance_docs boolean not null default false;
