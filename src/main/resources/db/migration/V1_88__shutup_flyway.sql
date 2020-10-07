with objectType as (
  select
    s.id smartlist_id,
    cot.id as object_type_id
  from flow.smartlist s
         inner join flow.company_object_type cot on cot.id = s.company_object_type_id
)
update flow.smartlist
set view_object_type_id = case when objectType.object_type_id = 2 then 2 else 1 end
from objectType
where id = objectType.smartlist_id;