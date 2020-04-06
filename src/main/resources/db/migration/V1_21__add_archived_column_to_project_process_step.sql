alter table if exists flow.project_process_step add if not exists archived  boolean default false not null;

alter table if exists flow.project_process_step_attachment add if not exists archived boolean default false not null;

alter table if exists flow.project_process_step_custom_field_value add if not exists archived boolean default false not null;

alter table if exists flow.project_process_step_note add if not exists archived  boolean default false not null;
