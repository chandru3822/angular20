alter table flow.custom_field_group
add column if not exists attachment_type_id int references flow.attachment_type(id);

CREATE INDEX if not exists cfg_attachment_type_id_idx ON flow.custom_field_group (attachment_type_id);


alter table flow.custom_field_group
  add column if not exists process_step_attachment_type_id int references flow.process_step_attachment_type(id);

CREATE INDEX if not exists cfg_process_step_attachment_type_id_idx ON flow.custom_field_group (process_step_attachment_type_id);

