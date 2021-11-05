alter table flow.project_process_step
  add column if not exists process_step_cancelled_date timestamp;

alter table flow.project_process_step_audit
  add column if not exists process_step_cancelled_date timestamp;
