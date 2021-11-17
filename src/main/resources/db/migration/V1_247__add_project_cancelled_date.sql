alter table flow.project
  add column if not exists cancelled_date timestamp;

alter table flow.project_audit
  add column if not exists cancelled_date timestamp;
