INSERT INTO flow.db_function (function_name, archived, return_data_type_id, db_function_type_id)
    (select 'brs.populate_system_and_financial_fields', false, 6, 2
     where not exists (select id from flow.db_function where function_name = 'brs.populate_system_and_financial_fields'));

INSERT INTO flow.db_function_param ( db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id)
    (select (select id from flow.db_function where function_name = 'brs.populate_system_and_financial_fields' ) , 'project_id', false, 6, 6, 1
     where not exists (select id from flow.db_function_param where db_function_id in (select id from flow.db_function where function_name = 'brs.populate_system_and_financial_fields')));


INSERT INTO flow.company_function ( company_function_name, db_function_id, archived, company_id)
    (select 'Populate System and Financial Fields', (select id from flow.db_function where function_name = 'brs.populate_system_and_financial_fields' ), false, 3
     where not exists (select id from flow.company_function where company_function_name = 'Populate System and Financial Fields'));


INSERT INTO flow.company_function_param ( company_function_id, custom_field_group_assignment_id,
                                          archived, system_value_id, db_function_param_id, created_by_id,
                                          date_created, modified_by_id, date_modified)
    (select (select id
             from flow.company_function
             where company_function_name = 'Populate System and Financial Fields'), null,
            false, 2, (select id
                       from flow.db_function_param
                       where parameter_name = 'project_id' and
                               db_function_id in (select id
                                                  from flow.db_function
                                                  where function_name = 'brs.populate_system_and_financial_fields')), 2350555, '2020-08-14 22:42:53.711131', 2350555, '2020-08-14 22:42:53.711131'
     where not exists (select id
                       from flow.company_function_param
                       where company_function_id in (select id
                                                     from flow.company_function
                                                     where company_function_name = 'Populate System and Financial Fields') ));
