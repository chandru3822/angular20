--update param name limit from 50 to 100
alter table if exists flow.db_function_param
alter column parameter_name type varchar(100) using parameter_name::varchar(100);