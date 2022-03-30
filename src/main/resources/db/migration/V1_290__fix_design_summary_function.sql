--correct the param display order and add the panel watts field
with f as (
  select id from flow.db_function where function_name = 'brs.get_design_summary'
), fixDisplayOrder as (
  update flow.db_function_param
    set display_order = 5
    where parameter_name = 'Design JSON - Custom Field Group Assignment ID' and
          db_function_id = (select id from f)
)
insert into flow.db_function_param (db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id)
select f.id, 'Panel Watts - Custom Field Group Assignment ID'::text, 6, 6::int, 2::int, null::int
from f;