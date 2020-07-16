alter table flow.work_queue_category
add column if not exists display_order int;

alter table flow.work_queue_type
    add column if not exists display_order int;


update flow.work_queue_category as wqc
set display_order = c.displayOrder
from (
         select id,
                ROW_NUMBER () OVER (ORDER BY work_queue_category.work_queue_category) - 1
         from flow.work_queue_category
         order by work_queue_category
     ) as c(id, displayOrder)
where c.id = wqc.id
;
