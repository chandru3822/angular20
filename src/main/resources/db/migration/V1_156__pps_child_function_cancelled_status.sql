alter table flow.process_step_action_child_process
add column if not exists company_process_step_status_type_id int references flow.company_process_step_status_type(id);

-- update all child processes to have a status to use for cancelled
update flow.process_step_action_child_process as t1 set
    company_process_step_status_type_id = (select cpsst.id
                                           from flow.company_process_step_status_type cpsst
                                           where cpsst.process_step_status_type_id = 3
                                             and cpsst.company_id = ps.company_id)
from flow.process_step ps
    where ps.id = t1.process_step_id;

alter table flow.process_step_action
add column if not exists multiple_uses boolean not null default false;

alter table flow.project_process_step_action
add column if not exists allow_multiple_uses boolean not null default false;
