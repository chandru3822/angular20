alter table flow.process_step_action
    ADD column if not exists time_based_trigger boolean not null default false;


select *
from flow.process_step_action_child_process
