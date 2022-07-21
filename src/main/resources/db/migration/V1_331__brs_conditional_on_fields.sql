alter table brs.custom_field_group_assignment
  add column if not exists conditional_on_cfga_id int references brs.custom_field_group_assignment (id);

create index if not exists brs_cfga_conditional_on_cfga_id_ix
  on brs.custom_field_group_assignment (conditional_on_cfga_id);
