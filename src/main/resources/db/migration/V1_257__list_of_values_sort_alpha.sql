alter table if exists flow.custom_field
add column if not exists sort_list_values_alphabetically boolean not null default false;

alter table if exists brs.custom_field
  add column if not exists sort_list_values_alphabetically boolean not null default false;

