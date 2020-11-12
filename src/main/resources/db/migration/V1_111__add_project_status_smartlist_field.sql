insert into flow.smartlist_system_list (id, smartlist_system_list)
values (3, 'Project Status') on conflict do nothing;

insert into flow.smartlist_field (company_object_type_id, name, reference_table, reference_column, created_by_id, company_data_type_id, join_table, join_column, smartlist_system_list_id)
values (1, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 1, 'flow.project', 'company_project_status_type_id', 3);
