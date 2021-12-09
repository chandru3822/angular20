ALTER TABLE IF EXISTS flow.emails_sent
RENAME TO email_queue;

alter table if exists  flow.email_queue
add column if not exists processed boolean not null default false;

alter table if exists  flow.email_queue
  add column if not exists date_processed timestamp;

alter table if exists  flow.email_queue
  add column if not exists from_display_name varchar(255);

update flow.email_queue
set processed = true;

ALTER TABLE flow.action_param_dynamic_value
  ALTER COLUMN dynamic_value TYPE text;
