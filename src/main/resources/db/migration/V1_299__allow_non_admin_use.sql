alter table flow.process_step_company_process_step_status_type
add column if not exists allow_non_admin_use boolean not null default false;

update flow.process_step_company_process_step_status_type pscpsst
set allow_non_admin_use = true
from flow.process_step ps
where ps.id = pscpsst.process_step_id
and ps.non_admin_add is true;

