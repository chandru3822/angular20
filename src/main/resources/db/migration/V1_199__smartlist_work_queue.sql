insert into flow.smartlist(name, company_object_type_id, shared, owner_id, date_created, date_modified, created_by_id, modified_by_id,
                           archived, view_object_type_id, main_process_steps, project_details, work_queue_type_id)
select work_queue_type,
       (select id from flow.company_object_type cot where cot.company_id = 3 and cot.object_type_id = 4),
       false, 99999999, now(), null, 99999999, null, false, 1, true, false, wqt.id

from flow.work_queue_type wqt
where wqt.archived is not true
and wqt.company_id = 3
;
