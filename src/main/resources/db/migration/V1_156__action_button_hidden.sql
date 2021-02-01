alter table flow.process_step_action
add column if not exists hidden boolean not null default false;


