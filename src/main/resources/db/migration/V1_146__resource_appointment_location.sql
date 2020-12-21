alter table flow.resource_appointment
    add column if not exists title varchar(255);

alter table flow.resource_appointment
    add column if not exists location varchar(255);

alter table flow.resource_appointment
    add column if not exists latitude double precision;

alter table flow.resource_appointment
    add column if not exists longitude double precision;

update flow.resource_appointment
set title = substring(description, 0, 254)
where id > 0;
