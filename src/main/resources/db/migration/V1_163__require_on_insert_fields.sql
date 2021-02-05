alter table flow.custom_field_object_type
add column if not exists require_on_insert boolean not null default false;
