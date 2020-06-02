alter table flow.smartlist_requirement
add list_of_value_id int;

alter table flow.smartlist_requirement
add list_of_value_ids int[];

alter table flow.smartlist_requirement
add system_list_option_id int;

alter table flow.smartlist_requirement
add custom_sql_option_id int;

alter table flow.smartlist_requirement
add constraint sr_list_of_value_id_fk foreign key (list_of_value_id) references flow.list_of_value;