alter table flow.custom_field_group
add column if not exists attachment_type_id int references flow.attachment_type(id);

CREATE INDEX if not exists cfg_attachment_type_id_idx ON flow.custom_field_group (attachment_type_id);
