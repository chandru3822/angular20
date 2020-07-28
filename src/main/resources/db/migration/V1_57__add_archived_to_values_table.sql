alter table if exists flow.project_custom_field_value add if not exists archived boolean default false not null;

alter table if exists flow.contact_custom_field_value add if not exists archived boolean default false not null;