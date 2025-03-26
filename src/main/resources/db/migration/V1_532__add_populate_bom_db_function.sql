with newFunction as (
insert into flow.db_function(function_name, return_data_type_id, db_function_type_id, display_name, process_step_actionable, description)
values ('brs.populate_bom_from_permit_pack', 11, 2, 'Populate BOM from Permit Pack Log', true,'Given the project id, archives all existing bom parts and adds the bom parts from the permit pack to the project bom')
	returning id, display_name),
	assign as (
insert into flow.company_function (company_function_name, db_function_id, company_id)
values((select display_name from newFunction), (select id from newFunction), 3)
	), params (parameter_name, display_order, data_type_id, parameter_type_id, system_value_id) as (
values
	('project_id', 0, 6, 1, 2)
	)
insert into flow.db_function_param (db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id)
select f.id, p.parameter_name, p.display_order, p.data_type_id, p.parameter_type_id, p.system_value_id
from params p, newFunction f;
