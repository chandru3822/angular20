-- modify contact owner smartlist field
update flow.smartlist_field
set reference_table = 'flow.contact_user',
    reference_column = 'concat("contact_user".first_name, '' '', "contact_user".last_name)'
where name = 'Contact Owner';

-- add project owner smartlist field
insert into flow.smartlist_field (company_object_type_id, name, reference_table, reference_column, created_by_id, company_data_type_id, join_table, join_column, smartlist_system_list_id)
values
(1, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 7, 'flow.project', 'user_position_id', null),
(6, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 17, 'flow.project', 'user_position_id', null),
(11, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 27, 'flow.project', 'user_position_id', null),
(16, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 37, 'flow.project', 'user_position_id', null),
(21, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 47, 'flow.project', 'user_position_id', null),
(26, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 57, 'flow.project', 'user_position_id', null),
(41, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 87, 'flow.project', 'user_position_id', null),
(46, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 97, 'flow.project', 'user_position_id', null),
(51, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 107, 'flow.project', 'user_position_id', null),
(56, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 117, 'flow.project', 'user_position_id', null),
(61, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 127, 'flow.project', 'user_position_id', null),
(66, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 137, 'flow.project', 'user_position_id', null),
(71, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 147, 'flow.project', 'user_position_id', null),
(76, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 157, 'flow.project', 'user_position_id', null),
(81, 'Project Owner', 'flow.project_user', 'concat("project_user".first_name, '' '', "project_user".last_name)', 2350555, 167, 'flow.project', 'user_position_id', null);