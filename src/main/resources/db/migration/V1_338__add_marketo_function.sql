-- create the function
-- next, assign new function to BR
-- finally, add params to the new function
with newFunction as (
  insert into flow.db_function (function_name, return_data_type_id, db_function_type_id, display_name, run_in_backend, description)
    values ('brs.push_data_to_marketo', null, 2, 'Update Marketo', true, null)
    returning id
), assign as (
  insert into flow.company_function (company_function_name, db_function_id, company_id)
    values ('Update Marketo', (select id from newFunction), 3)
), params (parameter_name, display_order, data_type_id, parameter_type_id, system_value_id, description) as (
  values
    ('Set Marketo status', 0, 5, 2, null, 'Leave blank to not update project status in Marketo'),
    ('Closer Appointment Start Time - PSE ID', 1, 6, 2, null::bigint, 'Leave blank to not update field in Marketo'),
    ('Final Design Approved Date - CFGA ID', 2, 6, 2, null::bigint, 'Leave blank to not update field in Marketo'),
    ('Installation Start Time - PSE ID', 3, 6, 2, null::bigint, 'Leave blank to not update field in Marketo'),
    ('Substantial Completion Date - CFGA ID', 4, 6, 2, null::bigint, 'Leave blank to not update field in Marketo'),
    ('Inspection Start Time - PSE ID', 5, 6, 2, null::bigint, 'Leave blank to not update field in Marketo'),
    ('Inspection Passed Date - CFGA ID', 6, 6, 2, null::bigint, 'Leave blank to not update field in Marketo'),
    ('Update Energized Date from project details', 7, 3, 2, null::bigint, null)
)
insert into flow.db_function_param (db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id)
select f.id, p.parameter_name, p.display_order, p.data_type_id, p.parameter_type_id, p.system_value_id
from params p, newFunction f;