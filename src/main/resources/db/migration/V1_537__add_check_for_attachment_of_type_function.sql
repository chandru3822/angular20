-- add new system list type and system list option
insert into flow.system_list_type (system_list_type)
    select 'attachment_types'
        where not exists
            (select id from flow.system_list_type where system_list_type = 'attachment_types');

insert into flow.system_list (system_list, system_list_type_id, has_sub_options)
select 'Attachment Types by Type', slt.id , true
from flow.system_list_type slt
where slt.system_list_type = 'attachment_types'
	and not exists
            (select id from flow.system_list where system_list = 'Attachment Types by Type');

--add column to flow.db_function_param
alter table flow.db_function_param add column if not exists system_list_id INTEGER;

-- create the function
-- next, assign new function to BR
-- finally, add params to the new function
with newFunction as (
  insert into flow.db_function (function_name, return_data_type_id, db_function_type_id, display_name, run_in_backend, process_step_actionable, event_actionable, creates_pps, description)
    values ('brs.check_for_attachment_of_type', 3, 1, 'Check For Uploaded File', false, true, true, false, 'A function that allows defining a specific attachment type that must be uploaded to the process step or event as a requirement before an action can proceed. This ensures that required documentation is uploaded before advancing a process step or workflow action.')
    returning id
), assign as (
  insert into flow.company_function (company_function_name, db_function_id, company_id)
    values ('Check For Uploaded File', (select id from newFunction), 3)
)
insert into flow.db_function_param (db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id, system_list_id)
select f.id, 'Attachment Type', 0, 9, 2, null, sl.id
from newFunction f
cross join flow.system_list sl
where not exists (select id from flow.db_function_param where parameter_name = 'Attachment Type' and data_type_id = 9)
and sl.system_list = 'Attachment Types by Type';
