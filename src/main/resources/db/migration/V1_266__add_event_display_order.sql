alter table flow.company_event_status_type
add column if not exists display_order int;

update flow.company_event_status_type as t1 set
  display_order = c.column_c
from (
       select id, ROW_NUMBER () OVER (order by id) - 1
       from flow.company_event_status_type psat
     ) as c(column_a, column_c)
where c.column_a = t1.id;
