insert into flow.white_list_type(white_list_type)
select 'WORK_QUEUE_CATEGORY_HIDDEN'
WHERE NOT exists (select id from flow.white_list_type where white_list_type = 'WORK_QUEUE_CATEGORY_HIDDEN');


alter table flow.white_listed_position
add column if not exists work_queue_category_id int references flow.work_queue_category(id);


alter table flow.work_queue_category add column if not exists hidden boolean not null default false;
