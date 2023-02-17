insert into flow.white_list_type (white_list_type)
select 'PROCESS_STEP_EVENT_READ_ONLY' WHERE not exists( select id from flow.white_list_type where white_list_type.white_list_type = 'PROCESS_STEP_EVENT_READ_ONLY');

alter table if exists  flow.white_listed_position
	add column if not exists process_step_event_id integer;

alter table if exists flow.process_step_event
	add column if not exists readonly boolean default false not null;

