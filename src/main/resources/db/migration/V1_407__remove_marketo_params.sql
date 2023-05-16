-- Remove all params except project status
update flow.db_function_param
set archived = true
where id = any(
  select dfp.id
  from flow.db_function_param dfp
  where dfp.db_function_id = 73 and
        dfp.archived is false and
        dfp.parameter_name != 'Set Marketo status'
)