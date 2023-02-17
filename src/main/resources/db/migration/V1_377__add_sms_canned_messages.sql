update flow.db_function_param
set
  description = description || ', 18: proposal started, 19: proposal complete - project, 20: regen started, 21: regen complete'
where
    db_function_id = 17 and
    parameter_name = 'Message Type ID'