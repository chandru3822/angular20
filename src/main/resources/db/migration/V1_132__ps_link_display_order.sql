alter table if exists flow.process_step_link
add column  if not exists display_order int;

-- update all existing records to have a display_order value
update flow.process_step_link as t1 set
    display_order = c.column_c
from (
         select id, process_step_id, ROW_NUMBER () OVER (partition by process_step_id ORDER BY date_created)
         from flow.process_step_link
         order by process_step_id
     ) as c(column_a, column_b, column_c)
where c.column_a = t1.id
;
