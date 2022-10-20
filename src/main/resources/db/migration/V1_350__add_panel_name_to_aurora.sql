-- add 'Panel Name' param to the Aurora design summary DB function
with db_function as (
  select id
  from flow.db_function
  where function_name = 'brs.get_design_summary'
)
insert into flow.db_function_param (db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description)
select db_function.id, 'Panel Name - Custom Field Group Assignment ID', false, 8, 6, 2, null, null
from db_function