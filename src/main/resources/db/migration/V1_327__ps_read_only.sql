insert into flow.white_list_type(white_list_type)
select 'PROCESS_STEP_READ_ONLY'
WHERE NOT exists (select id from flow.white_list_type where white_list_type = 'PROCESS_STEP_READ_ONLY');
insert into flow.white_list_type(white_list_type)
select 'WORK_QUEUE_TYPE_HIDDEN'
WHERE NOT exists (select id from flow.white_list_type where white_list_type = 'WORK_QUEUE_TYPE_HIDDEN');


alter table flow.white_listed_position
add column if not exists work_queue_type_id int references flow.work_queue_type(id);
alter table flow.white_listed_position
  add column if not exists process_step_id int references flow.process_step(id);

alter table flow.process_step add column if not exists readonly boolean not null default false;
alter table flow.work_queue_type add column if not exists hidden boolean not null default false;
