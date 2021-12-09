alter table flow.contact_audit
  add column if not exists latitude double precision;
alter table flow.contact_audit
  add column if not exists longitude double precision;
alter table flow.project_audit
  add column if not exists latitude double precision;
alter table flow.project_audit
  add column if not exists longitude double precision;
