alter table if exists flow.event_company_event_status_type
	add column if not exists editable_in_schedule boolean not null default false;
