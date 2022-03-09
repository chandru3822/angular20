alter table flow.custom_field
add column if not exists allow_now boolean not null default false;
