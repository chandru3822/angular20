update flow.db_function
set process_step_actionable = true,
    event_actionable = true
where function_name = 'brs.push_data_to_marketo';