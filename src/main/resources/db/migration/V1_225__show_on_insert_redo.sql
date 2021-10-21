alter table flow.custom_field_group_assignment
  add column if not exists show_on_insert boolean not null default false;
alter table flow.custom_field_group_assignment
  add column if not exists require_on_insert boolean not null default false;

-- update cfga.show_on_insert so this can be used correctly
update flow.custom_field_group_assignment as t1 set
  show_on_insert = true
from (
       select cfga.id
       from flow.custom_field_group_assignment cfga
              inner join flow.custom_field cf on cfga.custom_field_id = cf.id
              inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
              inner join flow.custom_field_object_type cfot on cfot.custom_field_id = cf.id and cfg.company_object_type_id = cfot.company_object_type_id
              inner join flow.company_object_type cot on cfot.company_object_type_id = cot.id
              inner join flow.object_type ot on cot.object_type_id = ot.id
       where cf.company_id in (3, 19)
         and cf.archived is false
         and cfga.archived is false
         and cfot.archived is false
         and cfot.show_on_insert is true
     ) as c(column_a)
where c.column_a = t1.id;

-- update cfga.require_on_insert so this can be used correctly
update flow.custom_field_group_assignment as t1 set
  require_on_insert = true
from (
       select cfga.id
       from flow.custom_field_group_assignment cfga
              inner join flow.custom_field cf on cfga.custom_field_id = cf.id
              inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
              inner join flow.custom_field_object_type cfot on cfot.custom_field_id = cf.id and cfg.company_object_type_id = cfot.company_object_type_id
              inner join flow.company_object_type cot on cfot.company_object_type_id = cot.id
              inner join flow.object_type ot on cot.object_type_id = ot.id
       where cf.company_id in (3, 19)
         and cf.archived is false
         and cfga.archived is false
         and cfot.archived is false
         and cfot.require_on_insert is true
     ) as c(column_a)
where c.column_a = t1.id;

alter table flow.custom_field_object_type
drop column if exists show_on_insert;
alter table flow.custom_field_object_type
  drop column if exists require_on_insert;
