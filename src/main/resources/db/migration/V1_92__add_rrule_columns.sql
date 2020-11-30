alter table if exists flow.resource_appointment
add column if not exists recurrence varchar(255);

alter table if exists flow.resource_appointment
    add column if not exists recurring_start_time timestamp;

alter table if exists flow.resource_appointment
    add column if not exists recurring_end_time timestamp;

