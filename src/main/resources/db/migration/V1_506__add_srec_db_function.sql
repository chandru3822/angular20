-- create DB function
-- assign DB function to BR
-- add params to DB function
with newFunction as (
    insert into flow.db_function (function_name, return_data_type_id, db_function_type_id, display_name, run_in_backend, process_step_actionable, description)
        values ('brs.send_disclosure_form', null, 2, 'Send Disclosure Form', true, true, 'Send disclosure form for an IL SREC project')
        returning id
), assign as (
    insert into flow.company_function (company_function_name, db_function_id, company_id)
        values ('Send Disclosure Form', (select id from newFunction), 3)
), params (parameter_name, display_order, data_type_id, parameter_type_id, system_value_id, description) as (
    values
        ('Proposal Log Number - CFGA ID', 0, 6, 2, null::bigint, 'Proposal log number used for form generation'),
        ('Disclosure Form ID - CFGA ID', 1, 6, 2, null::bigint, 'Field to store returned form ID')
)
insert into flow.db_function_param (db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id, description)
select f.id, p.parameter_name, p.display_order, p.data_type_id, p.parameter_type_id, p.system_value_id, p.description
from params p, newFunction f;