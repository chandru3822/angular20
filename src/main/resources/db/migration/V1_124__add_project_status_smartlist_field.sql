insert into flow.smartlist_field (company_object_type_id, name, reference_table, reference_column, created_by_id, company_data_type_id, join_table, join_column, smartlist_system_list_id)
values

-- Atlas Solar Advisors, company_id = 12
(51, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 101, 'flow.project', 'company_project_status_type_id', 3),

-- B+C Electric, company_id = 4
(6, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 15, 'flow.project', 'company_project_status_type_id', 3),

-- Direct Solar of America, company_id = 13
(56, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 115, 'flow.project', 'company_project_status_type_id', 3),

-- Eco Lux Solar, company_id = 25
(11, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 25, 'flow.project', 'company_project_status_type_id', 3),

-- Energy Pal, company_id = 17
(76, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 155, 'flow.project', 'company_project_status_type_id', 3),

-- New Markets, company_id = 9
(36, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 65, 'flow.project', 'company_project_status_type_id', 3),

-- Revolution Solar, company_id = 14
(61, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 125, 'flow.project', 'company_project_status_type_id', 3),

-- Salient Solar, company_id = 6
(16, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 35, 'flow.project', 'company_project_status_type_id', 3),

-- Smart Money Solar, company_id = 15
(66, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 135, 'flow.project', 'company_project_status_type_id', 3),

-- Solar 101, company_id = 10
(41, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 85, 'flow.project', 'company_project_status_type_id', 3),

-- Solenrgi, company_id = 7
(21, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 45, 'flow.project', 'company_project_status_type_id', 3),

-- Sun Run, company_id = 8
(26, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 55, 'flow.project', 'company_project_status_type_id', 3),

-- Supernova Energy, company_id = 16
(71, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 145, 'flow.project', 'company_project_status_type_id', 3),

-- TGE Solar, company_id = 11
(46, 'Project Status', 'flow.company_project_status_type', 'project_status_type', 2350555, 95, 'flow.project', 'company_project_status_type_id', 3);

update flow.smartlist_field
set smartlist_system_list_id = 2
where name = 'Process Step Status';

update flow.smartlist_field
set smartlist_system_list_id = 1
where name = 'Contact State' or name = 'Project State';