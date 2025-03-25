insert into flow.db_function(function_name, return_data_type_id, db_function_type_id, display_name, description)
select 'brs.populate_bom_from_permit_pack', 11, 2, 'Populate BOM from Permit Pack Log', 'Given the project id, and permit pack log number, archives all existing bom parts and adds the bom parts from the permit pack to the project bom'
	where not exists (select id from flow.db_function where function_name = 'brs.populate_bom_from_permit_pack');
;
