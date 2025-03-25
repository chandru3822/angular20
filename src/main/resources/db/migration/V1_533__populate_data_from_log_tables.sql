INSERT INTO flow.db_function (function_name, archived, return_data_type_id, db_function_type_id,
                              display_name, run_in_backend, description, process_step_actionable,
                              event_actionable, creates_pps)
 (select  'brs.populate_values_from_log_history', false, null, 2, 'Populate Values from Log History', false, null, true, true, false
  where not exists (select id from flow.db_function where function_name ='brs.populate_values_from_log_history'));



INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order,
                                    data_type_id, parameter_type_id, system_value_id, description, nullable)
 (select  (select id from flow.db_function as df where df.function_name = 'brs.populate_values_from_log_history'),
         'Project ID', false, 0, 6, 1, 2, null, false
  where not exists (select id from flow.db_function_param where parameter_name = 'Project ID'));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order,
                                    data_type_id, parameter_type_id, system_value_id, description, nullable)
 (select  (select id from flow.db_function as df where df.function_name = 'brs.populate_values_from_log_history'),
         'Current User ID', false, 1, 6, 1, 1, null, false
  where not exists (select id from flow.db_function_param where parameter_name = 'Current User ID'));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order,
                                    data_type_id, parameter_type_id, system_value_id, description, nullable)
 (select  (select id from flow.db_function as df where df.function_name = 'brs.populate_values_from_log_history'),
         'Table Name', false, 2, 5, 2, null, null, false
  where not exists (select id from flow.db_function_param where parameter_name = 'Table Name'));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order,
                                    data_type_id, parameter_type_id, system_value_id, description, nullable)
 ( select (select id from flow.db_function as df where df.function_name = 'brs.populate_values_from_log_history'),
         'Log ID CFGA', false, 3, 6, 2, null, null, false
   where not exists (select id from flow.db_function_param where parameter_name = 'Log ID CFGA'));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order,
                                    data_type_id, parameter_type_id, system_value_id, description, nullable)
 ( select (select id from flow.db_function as df where df.function_name = 'brs.populate_values_from_log_history'),
         'Column Name', false, 4, 5, 2, null, null, false
   where not exists (select id from flow.db_function_param where parameter_name = 'Column Name'));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order,
                                    data_type_id, parameter_type_id, system_value_id, description, nullable)
 (select (select id from flow.db_function as df where df.function_name = 'brs.populate_values_from_log_history'),
         'Override Existing Value', false, 5, 3, 2, null, null, false
  where not exists (select id from flow.db_function_param where parameter_name = 'Override Existing Value'));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order,
                                    data_type_id, parameter_type_id, system_value_id, description, nullable)
 ( select (select id from flow.db_function as df where df.function_name = 'brs.populate_values_from_log_history'),
         'Populate to CFGA', false, 6, 6, 2, null, null, false
   where not exists (select id from flow.db_function_param where parameter_name = 'Populate to CFGA'));
