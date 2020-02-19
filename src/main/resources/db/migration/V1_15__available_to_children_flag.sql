alter table flow.position
    add column if not exists available_to_children boolean not null default false;

alter table flow.org
    add column if not exists available_to_children boolean not null default false;

alter table flow.org_type
    add column if not exists available_to_children boolean not null default false;

alter table flow."user"
    drop column if exists schedulable;

alter table flow.position
    add column if not exists schedulable boolean not null default false;
