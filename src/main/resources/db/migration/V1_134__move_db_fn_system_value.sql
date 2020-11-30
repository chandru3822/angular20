-- i already handled creating this in db_fn_param and updating the values directly in uat and prod
-- so when this code rolls up all we need to do is drop the old column
alter table flow.company_function_param
drop column if exists system_value_id;
