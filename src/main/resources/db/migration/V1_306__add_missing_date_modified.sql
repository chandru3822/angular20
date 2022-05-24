alter table flow.project_note
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.work_queue_cycle
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.project_process_step_process_step_work_queue_type_note
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.attachment_source
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.email_queue
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.contact_note
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.user_company
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.user_feature_access_control
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.postal_code
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.position_feature_access_control
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.user_note
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.pps_event_process_step_event_work_queue_type_note
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.asset
  add column if not exists date_modified timestamptz default now() not null;

alter table flow.timezone
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.proposal_log_history
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.proposal_log
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.project_override_commission_snapshot
  add column if not exists date_modified timestamptz default now() not null;

--to match what is already in brs.design_log_history
alter table brs.design_log
  add column if not exists date_created timestamptz default now() not null;

alter table brs.birdeye_invitations
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.ahj_permit_checklist
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.override_plan_assigned_user
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.commission_plan_user
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.exclude_commission
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.override_plan_receiving_user
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.ahj_permit_contact
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.project_details_config
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.ahj_inspection_contact
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.ahj_inspection_note
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.ahj_permit_note
  add column if not exists date_modified timestamptz default now() not null;

alter table brs.ahj_inspection_checklist
  add column if not exists date_modified timestamptz default now() not null;

