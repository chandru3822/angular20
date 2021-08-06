alter table if exists flow.smartlist
  add column if not exists primary_user_position boolean default false not null;

insert into flow.smartlist_system_list (id, smartlist_system_list)
values  (6, 'Org Level'),
        (7, 'Org Type'),
        (8, 'User Status'),
        (9, 'Position');

insert into flow.smartlist_field (company_object_type_id, name, reference_table, reference_column, created_by_id, company_data_type_id, join_table, join_column, smartlist_system_list_id)
values (3, 'User ID', 'flow.user', 'id', 2350555, 5, null, null, null),
       (5, 'Org ID', 'flow.org', 'id', 2350555, 5, null, null, null);

insert into flow.smartlist_field (company_object_type_id, name, reference_table, reference_column, date_created, date_modified, created_by_id, modified_by_id, archived, company_data_type_id, join_table, join_column, smartlist_system_list_id)
values  (3, 'User Last Name', 'flow.user', 'last_name', '2021-06-23 18:17:32.938786', null, 2350555, null, false, 1, null, null, null),
        (5, 'Org Name', 'flow.org', 'org_name', '2021-06-23 18:37:41.875869', null, 2350555, null, false, 1, null, null, null),
        (5, 'Org is Active', 'flow.org', 'active_flag', '2021-06-23 18:37:41.875869', null, 2350555, null, false, 4, null, null, null),
        (5, 'Org Level', 'flow.org_level', 'level_name', '2021-06-23 19:35:36.118769', null, 2350555, null, false, 1, 'flow.org_type', 'org_level_id', 6),
        (5, 'Org Type', 'flow.org_type', 'type_name', '2021-06-23 19:44:37.538770', null, 2350555, null, false, 1, 'flow.org', 'org_type_id', 7),
        (3, 'User Position', 'flow.position', 'position', '2021-06-23 20:23:10.445779', null, 2350555, null, false, 1, 'flow.user_position', 'position_id', 9),
        (3, 'User Status', 'flow.user_status_type', 'user_status_type', '2021-06-23 20:43:30.101277', null, 2350555, null, false, 1, 'flow.company_user_status', 'user_status_type_id', 8),
        (3, 'User First Name', 'flow.user', 'first_name', '2021-06-23 21:31:58.757217', null, 2350555, null, false, 1, null, null, null),
        (3, 'User Email', 'flow.user', 'email', '2021-06-23 21:33:56.583504', null, 2350555, null, false, 1, null, null, null),
        (3, 'User Phone Number', 'flow.user', 'phone_number', '2021-06-23 21:35:57.446556', null, 2350555, null, false, 1, null, null, null),
        (3, 'User Start Date', 'flow.user_position', 'start_date', '2021-06-23 21:35:57.446556', null, 2350555, null, false, 2, null, null, null),
        (3, 'User End Date', 'flow.user_position', 'end_date', '2021-06-23 21:35:57.446556', null, 2350555, null, false, 2, null, null, null);