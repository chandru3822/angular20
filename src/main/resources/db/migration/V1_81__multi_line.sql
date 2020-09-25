--added some return values, need to drop
drop function flow.set_closer_appointment(integer, integer, timestamp, int[]);

alter table if exists flow.custom_field
    add column if not exists multi_line boolean not null default false;
