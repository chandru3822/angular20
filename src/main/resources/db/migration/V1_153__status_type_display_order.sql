alter table flow.company_project_status_type
add column if not exists display_order int;

-- update all existing records to have a display_order value
update flow.company_project_status_type as t1 set
    display_order = c.column_c
from (
         select id, company_id, ROW_NUMBER () OVER (partition by company_id ORDER BY date_created) -1
         from flow.company_project_status_type
         order by company_id
     ) as c(column_a, column_b, column_c)
where c.column_a = t1.id
;

