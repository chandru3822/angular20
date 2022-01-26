insert into flow.company_data_type (company_id, company_data_type, data_type_id, allow_multiple, has_list_values)
values (3, 'System Reference', 8, false, true),
       (3, 'System Reference Multi-Select', 10, true, true);

alter table brs.custom_field
  add column if not exists flow_custom_field_id int
    references flow.custom_field (id);

create index if not exists brs_flow_custom_field_id_ix on
  brs.custom_field (flow_custom_field_id);
