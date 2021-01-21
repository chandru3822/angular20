drop FUNCTION if exists brs.update_project_status( integer,  varchar);
drop FUNCTION if exists brs.project_status_active( integer);
drop FUNCTION if exists brs.project_status_on_hold( integer);
drop FUNCTION if exists brs.project_status_cancelled( integer);
update flow.action_param_dynamic_value
set archived = true
where process_step_action_company_function_id in (select id
                                                  from flow.process_step_action_company_function
                                                  where company_function_id in (257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272));
update flow.process_step_action_company_function
set archived = true
where company_function_id in (257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272);


update flow.company_function
set archived = true
where id in (257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272);


update flow.db_function
set archived = true
where function_name = 'brs.update_project_status';
