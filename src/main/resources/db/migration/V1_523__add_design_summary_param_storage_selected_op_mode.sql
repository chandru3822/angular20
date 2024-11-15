-- Add Storage Type param to the already existing DB function which fetches the storage_selected_operating_mode from Aurora
with dbFunction as (
	select id
	from flow.db_function
	where function_name = 'brs.get_design_summary'
)
insert into flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description)
values ((select id from dbFunction),
        'Storage Type - Custom Field Group Assignment ID', false,
        (select max(display_order) from
							flow.db_function_param, dbFunction
                            where db_function_id = dbFunction.id) + 1,
        6, 2, null, null);
