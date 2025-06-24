UPDATE flow.db_function
SET run_in_backend = false,
    event_actionable = true
WHERE function_name = 'flow.set_project_contact_full_name_to_custom_field';
