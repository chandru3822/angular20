INSERT INTO flow.attachment_type (id, attachment_type, attachment_code, company_id, archived, key_pattern_id, is_system)
VALUES
  (33, 'PROJECT_DOCUMENT', 'PROJECT_DOCUMENT', 1, false, 1, true),
  (34, 'PROCESS_STEP_DOCUMENT', 'PROCESS_STEP_DOCUMENT', 1, false, 1, true)
ON CONFLICT DO NOTHING;
