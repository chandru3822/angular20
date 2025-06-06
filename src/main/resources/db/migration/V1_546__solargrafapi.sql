INSERT INTO flow.db_function (function_name, archived, return_data_type_id, db_function_type_id, display_name,
                              run_in_backend, description, process_step_actionable, event_actionable, creates_pps)
 (select 'brs.get_solargraf_summary', false, null,
        2, 'Save Solargraf Summary', true,
        null, true, false, false
  where not  exists (select id from flow.db_function where function_name = 'brs.get_solargraf_summary'));


INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select  (select id from flow.db_function where function_name = 'brs.get_solargraf_summary'), 'System Size (kW) - Custom Field Group Assignment ID', false, 1, 6, 2, null, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'System Size (kW) - Custom Field Group Assignment ID' and
                                                                 db_function_id = (select id from flow.db_function where function_name = 'brs.get_solargraf_summary')));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
 (select  (select id from flow.db_function where function_name = 'brs.get_solargraf_summary'), '1st Year Production Estimate - Custom Field Group Assignment ID', false, 2, 6, 2, null, null, false, null
  where not exists (select id from flow.db_function_param where parameter_name = '1st Year Production Estimate - Custom Field Group Assignment ID' and
    db_function_id = (select id from flow.db_function where function_name = 'brs.get_solargraf_summary')));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select  (select id from flow.db_function where function_name = 'brs.get_solargraf_summary'), 'Panel Quantity - Custom Field Group Assignment ID', false, 3, 6, 2, null, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'Panel Quantity - Custom Field Group Assignment ID' and
     db_function_id = (select id from flow.db_function where function_name = 'brs.get_solargraf_summary')));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select (select id from flow.db_function where function_name = 'brs.get_solargraf_summary'), 'Panel Brand - Custom Field Group Assignment ID', false, 4, 6, 2, null, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'Panel Brand - Custom Field Group Assignment ID' and
     db_function_id = (select id from flow.db_function where function_name = 'brs.get_solargraf_summary')));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select (select id from flow.db_function where function_name = 'brs.get_solargraf_summary'), 'Solargraf ID - Custom Field Group Assignment ID', false, 0, 6, 2, null, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'Solargraf ID - Custom Field Group Assignment ID' and
     db_function_id = (select id from flow.db_function where function_name = 'brs.get_solargraf_summary')));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select (select id from flow.db_function where function_name = 'brs.get_solargraf_summary'), 'Inverter Brand - Custom Field Group Assignment ID', false, 5, 6, 2, null, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'Inverter Brand - Custom Field Group Assignment ID' and
     db_function_id = (select id from flow.db_function where function_name = 'brs.get_solargraf_summary')));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select (select id from flow.db_function where function_name = 'brs.get_solargraf_summary'), 'Panel Watts - Custom Field Group Assignment ID', false, 7, 6, 2, null, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'Panel Watts - Custom Field Group Assignment ID' and
     db_function_id = (select id from flow.db_function where function_name = 'brs.get_solargraf_summary')));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select (select id from flow.db_function where function_name = 'brs.get_solargraf_summary'), 'Solargraf JSON - Custom Field Group Assignment ID', false, 6, 6, 2, null, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'Solargraf JSON - Custom Field Group Assignment ID' and
     db_function_id = (select id from flow.db_function where function_name = 'brs.get_solargraf_summary')));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select(select id from flow.db_function where function_name = 'brs.get_solargraf_summary'), 'Panel Name - Custom Field Group Assignment ID', false, 8, 6, 2, null, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'Panel Name - Custom Field Group Assignment ID' and
     db_function_id = (select id from flow.db_function where function_name = 'brs.get_solargraf_summary')));
INSERT INTO flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, nullable, system_list_id)
  (select (select id from flow.db_function where function_name = 'brs.get_solargraf_summary'), 'Storage Type - Custom Field Group Assignment ID', false, 9, 6, 2, null, null, false, null
   where not exists (select id from flow.db_function_param where parameter_name = 'Storage Type - Custom Field Group Assignment ID' and
     db_function_id = (select id from flow.db_function where function_name = 'brs.get_solargraf_summary')));
