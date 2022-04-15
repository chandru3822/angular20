alter table if exists flow.project_custom_field_value
  drop column if exists archived;
alter table if exists flow.contact_custom_field_value
  drop column if exists archived;
alter table if exists flow.project_process_step_custom_field_value
  drop column if exists archived;
