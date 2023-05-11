alter table if exists  flow.custom_field_group_assignment
	add column if not exists display_on_snippet boolean default false not null;





