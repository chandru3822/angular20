-- Add 'default project page' column to flow.user_company
alter table if exists flow.user_company
  add column if not exists default_project_page varchar(64);


-- Add Default Project Page to the default field table
with t1 as (
insert into flow.default_field (field_name, column_name, property_name, data_type_id, object_type_id, created_by_id,
                                modified_by_id)
values ('Default Project Page', null, null, 5, 3, 99999999, 99999999)
  returning id
  )
insert into flow.company_default_field(company_id, default_field_id, show_on_user_profile, created_by_id, modified_by_id)
select 3, t1.id, true, 99999999, 99999999
from t1;

with t1 as (
  select cott.id from flow.company_object_type_tab cott
                        join flow.company_object_type cot on cott.company_object_type_id = cot.id
  where tab_name = 'General' and cot.company_id = 3)
update flow.user_company
set default_project_page = concat('tab_', t1.id)
  from t1;
