-- This set of queries adds the view_object_type_id column which holds the object ID of which screen
-- this smartlist should be listed on, then fills in the proper data
alter table if exists flow.smartlist add column if not exists view_object_type_id int;
alter table if exists flow.smartlist drop constraint if exists smartlist_view_object_type_id_fk;
alter table if exists flow.smartlist
add constraint smartlist_view_object_type_id_fk foreign key (view_object_type_id) references flow.object_type;
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
alter table if exists flow.smartlist alter column view_object_type_id set not null;
comment on column flow.smartlist.view_object_type_id is 'The screen where the smartlist should show';


-- This set of queries adds the main_process_steps column which is a flag to determine if the smartlist query should
-- select only process steps marked as main, or all process steps. Filling data and defaulting to true since I believe that will
-- be what is selected the majority of the time
alter table if exists flow.smartlist add column if not exists main_process_steps boolean;
update flow.smartlist
set main_process_steps = true;
alter table if exists flow.smartlist alter column main_process_steps set not null;
alter table if exists flow.smartlist alter column main_process_steps set default true;
alter table flow.smartlist alter column main_process_steps set not null;
alter table flow.smartlist alter column main_process_steps set default true;
comment on column flow.smartlist.main_process_steps is 'Flag of if the smartlist should select only the main or all process steps';