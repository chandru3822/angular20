-- create the function
-- next, assign new function to BR
-- finally, add params to the new function
with newFunction as (
  insert into flow.db_function (function_name, return_data_type_id, db_function_type_id, display_name, run_in_backend, process_step_actionable, event_actionable)
    values ('brs.check_project_zipcode', 3, 1, 'Check Project Zip Code', false, true, true)
    returning id
), assign as (
  insert into flow.company_function (company_function_name, db_function_id, company_id)
    values ('Check Project Zip Code', (select id from newFunction), 3)
)
insert into flow.db_function_param (db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id)
select f.id, 'Project ID', 0, 6, 1, 2
from newFunction f;
