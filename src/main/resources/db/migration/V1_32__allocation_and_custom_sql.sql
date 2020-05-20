alter table flow.postal_code_zone_user
    add column if not exists allocation int;

alter table flow.postal_code_zone
    add column if not exists distribution_time_frame_days int;

alter table flow.custom_field
    add column if not exists custom_field_sql_reference_table varchar(100);

alter table flow.custom_field
    add column if not exists custom_field_sql_key varchar(100);

update flow.custom_field
    set custom_field_sql_key = (select sql_key from flow.custom_field_sql_key cfsk where cfsk.id = custom_field_sql_key_id)
where custom_field_sql_key_id is not null;

alter table flow.custom_field
    drop column if exists custom_field_sql_key_id;

drop table if exists flow.custom_field_sql_key;

drop FUNCTION if exists flow.get_project_process_step_requirements_with_values(INTEGER, INTEGER[]);

update flow.custom_field
    set custom_field_sql_reference_table = 'brs.ahj'
where custom_field_sql_key is not null;
