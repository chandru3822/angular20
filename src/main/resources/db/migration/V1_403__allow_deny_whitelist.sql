alter table flow.event
  add column if not exists start_time_read_only_allow boolean not null default true;
alter table flow.event
  add column if not exists start_time_hidden_allow boolean not null default true;
alter table flow.event
  add column if not exists end_time_read_only_allow boolean not null default true;
alter table flow.event
  add column if not exists end_time_hidden_allow boolean not null default true;
alter table flow.event
  add column if not exists resource_read_only_allow boolean not null default true;
alter table flow.event
  add column if not exists resource_hidden_allow boolean not null default true;
alter table flow.event
  add column if not exists hidden_allow boolean not null default true;
alter table flow.work_queue_type
  add column if not exists hidden_allow boolean not null default true;
alter table flow.work_queue_category
  add column if not exists hidden_allow boolean not null default true;
alter table flow.company_object_type
  add column if not exists owner_read_only_allow boolean not null default true;
alter table flow.company_object_type
  add column if not exists status_read_only_allow boolean not null default true;
alter table flow.custom_field_group_assignment
  add column if not exists read_only_allow boolean not null default true;
alter table flow.custom_field_group_assignment
  add column if not exists hidden_allow boolean not null default true;
alter table flow.process_step
  add column if not exists readonly_allow boolean not null default true;
alter table flow.process_step_event
  add column if not exists readonly_allow boolean not null default true;
