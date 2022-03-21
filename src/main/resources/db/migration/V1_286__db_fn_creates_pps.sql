alter table flow.db_function
add column if not exists creates_pps boolean not null default false;

update flow.db_function
set creates_pps = true
where id in (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event');
