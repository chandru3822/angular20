update flow.smartlist_field
set reference_table = 'flow.project_status_type',
    join_table = 'flow.company_project_status_type',
    join_column = 'project_status_type_id'
where smartlist_system_list_id = 3;

update flow.smartlist_field
set reference_table = 'flow.company_project_status_type',
    join_table = 'flow.project',
    join_column = 'company_project_status_type_id'
where smartlist_system_list_id = 5;