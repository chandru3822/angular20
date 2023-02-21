insert into flow.white_list_type (white_list_type)
select 'EVENT_START_TIME_HIDDEN' WHERE not exists (select id from flow.white_list_type where white_list_type.white_list_type = 'EVENT_START_TIME_HIDDEN');

insert into flow.white_list_type (white_list_type)
select 'EVENT_END_TIME_HIDDEN' WHERE not exists (select id from flow.white_list_type where white_list_type.white_list_type = 'EVENT_END_TIME_HIDDEN');

insert into flow.white_list_type (white_list_type)
select 'EVENT_RESOURCE_HIDDEN' WHERE not exists (select id from flow.white_list_type where white_list_type.white_list_type = 'EVENT_RESOURCE_HIDDEN');

alter table if exists  flow.event
	add column if not exists start_time_hidden boolean default false not null;
alter table if exists  flow.event
	add column if not exists end_time_hidden boolean default false not null;
alter table if exists  flow.event
	add column if not exists resource_hidden boolean default false not null;

