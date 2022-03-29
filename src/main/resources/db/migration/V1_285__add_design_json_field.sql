-- add `Design JSON` field used to store design data fetched from Aurora
with field as (
  insert into flow.custom_field (list_of_value_id, company_id, field_name, company_data_type_id, created_by_id, modified_by_id, company_system_list_id, system_list_option_ids, custom_field_sql_reference_table, custom_field_sql_key, readonly, migrated_original_id, parent_custom_field_id)
    values ( null, 3, 'Design JSON', 1, 99999999, 99999999, null, null, null, null, true, null, null)
    returning id
)
insert into flow.custom_field_object_type (custom_field_id, company_object_type_id, archived, created_by_id, modified_by_id)
select field.id, 4, false, 99999999, 99999999
from field;