insert into flow.smartlist(name, company_object_type_id, shared, owner_id, date_created, date_modified, created_by_id, modified_by_id,
                           archived, view_object_type_id, main_process_steps, project_details, work_queue_type_id)
select work_queue_type,
       (select id from flow.company_object_type cot where cot.company_id = 2 and cot.object_type_id = 4),
       false, 99999999, now(), null, 99999999, null, false, 1, true, false, wqt.id

from flow.work_queue_type wqt
where wqt.archived is not true
and wqt.company_id = 2
;

select *
from flow.smartlist
order by id desc;

select *
from flow.object_type;

select *
from flow."user"
where id = 99999999
;


select wqt.id,
       wqt.company_id,
       wqt.work_queue_type,
       wqt.archived,
       wqt.work_queue_category_id,
       wqc.work_queue_category,
       wqt.display_order,
       s.id as smartlist_id,
       wqc.color as work_queue_category_color,
       wqc.display_order as work_queue_category_display_order
from flow.work_queue_type wqt
         inner join flow.work_queue_category wqc on wqc.id = wqt.work_queue_category_id
         inner join flow.smartlist s on s.work_queue_type_id = wqt.id
where wqt.id = :id
