-- create the function
-- next, assign new function to BR
-- finally, add params to the new function
with newFunction as (
  insert into flow.db_function (function_name, return_data_type_id, db_function_type_id, display_name, run_in_backend, description)
    values ('brs.get_design_summary', null, 2, 'Save Design Summary', true, null)
    returning id
), assign as (
  insert into flow.company_function (company_function_name, db_function_id, company_id, migrated_original_id)
    values ('Save Design Summary', (select id from newFunction), 3, null)
), params (parameter_name, display_order, data_type_id, parameter_type_id, system_value_id) as (
  values ('System Size (kW) - Custom Field Group Assignment ID'::text, 0::int, 6::int, 2::int, null::int),
         ('1st Year Production Estimate - Custom Field Group Assignment ID'::text, 1::int, 6::int, 2::int, null::int),
         ('Panel Quantity - Custom Field Group Assignment ID'::text, 2::int, 6::int, 2::int, null::int),
         ('Panel Brand - Custom Field Group Assignment ID'::text, 3::int, 6::int, 2::int, null::int),
         ('Inverter Brand - Custom Field Group Assignment ID'::text, 4::int, 6::int, 2::int, null::int),
         ('Design JSON - Custom Field Group Assignment ID'::text, 4::int, 6::int, 2::int, null::int)
)
insert into flow.db_function_param (db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id)
select f.id, p.parameter_name, p.display_order, p.data_type_id, p.parameter_type_id, p.system_value_id
from params p, newFunction f;