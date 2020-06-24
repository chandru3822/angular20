update flow.process_step_requirement
set list_of_value_ids = null
where list_of_value_ids = '{null}';

update flow.custom_field
set system_list_option_ids = null
where system_list_option_ids = '{null}';
