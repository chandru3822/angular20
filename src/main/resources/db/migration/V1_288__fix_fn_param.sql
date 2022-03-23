update flow.db_function_param
set display_order = 2
where db_function_id = 64
  and parameter_type_id = 2
  and parameter_name = 'Property to Save';
