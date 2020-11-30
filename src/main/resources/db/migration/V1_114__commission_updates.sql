alter table brs.commission_plan
add column if not exists updated timestamp;

alter table brs.commission_plan
    add column if not exists updated_by int references flow."user"(id);
