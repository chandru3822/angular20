alter table flow.custom_field_group_assignment
add column if not exists use_parent_data boolean not null default false;
