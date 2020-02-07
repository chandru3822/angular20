alter table flow.process_step_action
    add column if not exists always_enabled boolean not null default false;
