CREATE UNIQUE INDEX IF NOT EXISTS pmp_project_id_uindex
  ON flow.project_message_properties (project_id);
