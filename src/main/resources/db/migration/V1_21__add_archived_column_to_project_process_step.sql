alter table if exists flow.project_process_step add archived boolean default false not null;

alter table if exists flow.project_process_step_attachment add archived boolean default false not null;

alter table if exists flow.project_process_step_custom_field_value add archived boolean default false not null;

alter table if exists flow.project_process_step_note add archived boolean default false not null;
