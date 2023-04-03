
alter table if exists  flow.process_step_event_action
	add column if not exists show_on_cancelled_completed_events boolean default false not null;
