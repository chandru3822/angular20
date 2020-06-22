alter table flow.custom_field
add column if not exists readonly boolean not null default false;
