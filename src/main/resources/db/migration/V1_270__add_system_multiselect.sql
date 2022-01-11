with data_type as (
  insert into flow.data_type (data_type, custom_behavior, system_list)
    values ('system multiselect', true, false)
    returning id)
insert
into flow.company_data_type (company_id, company_data_type, data_type_id, allow_multiple)
select 3, 'System Multi-Select', dt.id, true
from data_type dt;
