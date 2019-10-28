alter table flow.org
    add column if not exists use_schedule boolean not null default false;

alter table flow.org
    add column if not exists state_id integer references flow.state(id);

alter table flow.process_step_requirement
    add column if not exists immutable boolean not null default false;
