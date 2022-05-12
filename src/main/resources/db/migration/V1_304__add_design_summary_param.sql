-- Add the Aurora Design ID param to the already existing DB function which fetches the design ID from Aurora
with dbFunction as (
    select id
    from flow.db_function
    where function_name = 'brs.get_design_summary'
),  params as (
    update flow.db_function_param dfp
        set display_order = display_order + 1
        from dbFunction
        where db_function_id = dbFunction.id
)
insert into flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description)
values ((select id from dbFunction), 'Aurora Design ID - Custom Field Group Assignment ID', false, 0, 6, 2, null, null);