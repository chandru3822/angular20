-- archive param we don't need any more
with function_id as (
  select df.id
  from flow.db_function df
  where df.function_name = 'brs.push_data_to_marketo'
)
update flow.db_function_param
set archived = true
from function_id
where db_function_id = function_id.id and
      parameter_name = 'Final Design Approved Date - CFGA ID';

-- Add new param
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

-- add descriptions for params
with function_id as (
  select df.id
  from flow.db_function df
  where df.function_name = 'brs.push_data_to_marketo'
), descriptions (status, everything_else) as (
  values (
           'Leave blank to not update field in Marketo. If set to "Final Design Sent", that field will also be pushed',
           'Leave blank to not update field in Marketo'
         )
)
update flow.db_function_param
set description = case when parameter_name = 'Set Marketo status' then descriptions.status else descriptions.everything_else end
from function_id, descriptions
where db_function_id = function_id.id;