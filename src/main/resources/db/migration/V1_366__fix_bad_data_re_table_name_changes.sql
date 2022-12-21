update flow.db_function df
set function_name = 'brs.get_brs_feat_db_cfv'
where id = 2;

update flow.custom_field
set custom_field_sql_reference_table = 'brs.feat_db_ahj'
where custom_field_sql_reference_table = 'brs.ahj';

update flow.custom_field
set custom_field_sql_reference_table = 'brs.ahj_utility'
where custom_field_sql_reference_table = 'brs.feat_db_utility';
