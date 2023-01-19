alter table flow.custom_field
	add column if not exists allow_select_self boolean not null default false;
