drop index if exists flow.wqc_comp1_idx;
create unique index wqc_comp1_idx
  on flow.work_queue_cycle (project_process_step_id, company_process_step_status_type_id,
                            process_step_work_queue_type_process_step_status_type_id)
  where date_exited_queue is null;
alter table flow.work_queue_cycle drop column  if exists is_cancelled;
