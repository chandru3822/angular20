alter table flow.smartlist_requirement
add column if not exists list_of_value_id int;

alter table flow.smartlist_requirement
add column if not exists list_of_value_ids int[];

alter table flow.smartlist_requirement
add column if not exists system_list_option_id int;

alter table flow.smartlist_requirement
add column if not exists custom_sql_option_id int;

alter table flow.smartlist_requirement drop constraint  if exists sr_list_of_value_id_fk;
