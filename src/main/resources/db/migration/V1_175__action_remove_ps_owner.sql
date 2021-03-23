alter table flow.process_step_action
add column if not exists remove_process_step_owner boolean not null default false;

update flow.process_step_action psa
set remove_process_step_owner = true
from flow.company_process_step_status_type cpsst
where cpsst.id = psa.company_process_step_status_type_id
  and cpsst.process_step_status_type_id = 1
