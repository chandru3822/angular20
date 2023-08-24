-- used to dynamically filter custom fields on the proposal screen

alter table brs.custom_field_group_assignment
  add column if not exists visibility varchar;
