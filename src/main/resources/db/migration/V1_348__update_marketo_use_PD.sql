-- archive params we don't need any more
with function_id as (
  select df.id
  from flow.db_function df
  where df.function_name = 'brs.push_data_to_marketo'
)
update flow.db_function_param
set archived = true
from function_id
where db_function_id = function_id.id and
      parameter_name = any(array['Closer Appointment Start Time - PSE ID', 'Installation Start Time - PSE ID', 'Substantial Completion Date - CFGA ID', 'Inspection Start Time - PSE ID', 'Inspection Passed Date - CFGA ID']);

-- Add new params
with function_id as (
  select df.id
  from flow.db_function df
  where df.function_name = 'brs.push_data_to_marketo'
), params (parameter_name, display_order, data_type_id, parameter_type_id) as (
  values
    ('Update Closer Appointment Start Time from project details', 1, 3, 2),
    ('Update Installation Start Time from project details', 2, 3, 2),
    ('Update Substantial Completion Date from project details', 3, 3, 2),
    ('Update Inspection Start Time from project details', 4, 3, 2),
    ('Update Inspection Passed Date from project details', 5, 3, 2)
)
insert into flow.db_function_param (db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, description)
select f.id, p.parameter_name, p.display_order, p.data_type_id, p.parameter_type_id, 'Leave blank to not update field in Marketo'
from function_id f, params p;