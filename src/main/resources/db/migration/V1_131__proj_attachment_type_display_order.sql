alter table if exists flow.project_attachment_type
add column  if not exists display_order int;

-- update all existing records to have a display_order value
update flow.project_attachment_type as t1 set
    display_order = c.column_c
from (
         select id, company_id, ROW_NUMBER () OVER (partition by company_id ORDER BY date_created)
         from flow.project_attachment_type
         order by company_id
     ) as c(column_a, column_b, column_c)
where c.column_a = t1.id
;
