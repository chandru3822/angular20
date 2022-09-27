with function_id as (
  select df.id
  from flow.db_function df
  where df.function_name = 'brs.push_data_to_marketo'
), display_order as (
  select count(dfp.id) as count
  from flow.db_function_param dfp, function_id
  where dfp.db_function_id = function_id.id and
        dfp.archived is not true
)
insert into flow.db_function_param (db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id)
select f.id, 'Update Final Design Approved Date from project details', d.count + 1, 3, 2, null::bigint
from function_id f, display_order d;