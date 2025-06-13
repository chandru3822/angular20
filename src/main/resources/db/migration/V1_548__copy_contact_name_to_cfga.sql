
-- Insert the main function definition if it does not already exist    
INSERT INTO flow.db_function (function_name, archived, return_data_type_id, db_function_type_id, display_name,
                              run_in_backend, description, process_step_actionable, event_actionable, creates_pps)
 (select 'flow.flow.set_project_contact_full_name_to_custom_field', false, 5,
        2, 'Copy Contact Name to CFGA', true,
        null, true, false, false
  where not  exists (select id from flow.db_function where function_name = 'flow.flow.set_project_contact_full_name_to_custom_field'));
  
-- Insert parameter: Custom Field Group Assignment ID (required input)
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select  (select id from flow.db_function where function_name = 'flow.flow.set_project_contact_full_name_to_custom_field'), 'Custom Field Group Assignment ID', false, 1, 6, 2, null, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'Custom Field Group Assignment ID' and
                                                                 db_function_id = (select id from flow.db_function where function_name = 'flow.flow.set_project_contact_full_name_to_custom_field')));
                                                                 
-- Insert parameter: Project ID (used to identify the community record)                                                                
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select  (select id from flow.db_function where function_name = 'flow.flow.set_project_contact_full_name_to_custom_field'), 'Project ID', false, 2, 6, 1, 2, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'Project ID' and
                                                                 db_function_id = (select id from flow.db_function where function_name = 'flow.flow.set_project_contact_full_name_to_custom_field')));  
                                                                  
-- Insert parameter: Process Step ID (helps contextualize execution point)                                                                 
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select  (select id from flow.db_function where function_name = 'flow.flow.set_project_contact_full_name_to_custom_field'), 'Process Step ID', false, 3, 6, 1, 4, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'Process Step ID' and
                                                                 db_function_id = (select id from flow.db_function where function_name = 'flow.flow.set_project_contact_full_name_to_custom_field')));
                                                                 
-- Insert parameter: User Id (helps contextualize execution point)                                                                 
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select  (select id from flow.db_function where function_name = 'flow.flow.set_project_contact_full_name_to_custom_field'), 'User Id', false, 4, 6, 1, 1, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'User Id' and
                                                                 db_function_id = (select id from flow.db_function where function_name = 'flow.flow.set_project_contact_full_name_to_custom_field')));
                                                                                                                              
-- Make the function available under a specific company (e.g., company_id = 3)                                                                 
INSERT INTO flow.company_function ( company_function_name, db_function_id, archived, company_id)
    (select 'Copy Contact Name to CFGA', (select id from flow.db_function where function_name = 'flow.flow.set_project_contact_full_name_to_custom_field' ), false, 3
     where not exists (select id from flow.company_function where company_function_name = 'Copy Contact Name to CFGA'));
     