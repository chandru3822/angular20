DROP FUNCTION IF EXISTS flow.set_project_contact_full_name_to_custom_field(
  bigint, bigint, bigint, bigint
);

CREATE OR REPLACE FUNCTION flow.set_project_contact_full_name_to_custom_field(
  p_cfga_id bigint,
  p_project_id bigint,
  p_process_step_id bigint,
  p_user_id bigint
)
RETURNS boolean AS
$$
DECLARE
  v_full_name TEXT;
  v_data_type_id INTEGER;
  v_pps_id BIGINT;
  v_cfg_process_step_id BIGINT;
BEGIN
  -- 1. Validate that the custom field is of type 'Text'
  SELECT cf.company_data_type_id, cfg.process_step_id
  INTO v_data_type_id, v_cfg_process_step_id
  FROM flow.custom_field_group_assignment cfga
  JOIN flow.custom_field_group cfg ON cfg.id = cfga.custom_field_group_id
  JOIN flow.custom_field cf ON cf.id = cfga.custom_field_id
  WHERE cfga.id = p_cfga_id;

  IF v_data_type_id != 1 THEN
    RAISE NOTICE 'Custom field is not of text type.';
    RETURN FALSE;
  END IF;

  -- 2. Fetch contact full name and project process step ID
  SELECT trim(COALESCE(c.first_name, '') || ' ' || COALESCE(c.last_name, '')), pps.id
  INTO v_full_name, v_pps_id
  FROM flow.project_process_step pps
  JOIN flow.project p ON p.id = pps.project_id
  JOIN flow.contact c ON c.id = p.contact_id
  WHERE pps.project_id = p_project_id
    AND pps.process_step_id = p_process_step_id;

  IF v_full_name IS NULL THEN
    RAISE NOTICE 'No contact full name found.';
    RETURN FALSE;
  END IF;

  -- 3. Upsert logic
  IF v_cfg_process_step_id IS NULL THEN
    -- Global project-level field
    WITH do_update AS (
      UPDATE flow.project_custom_field_value pcv
      SET text_value = v_full_name,
          date_modified = NOW(),
          modified_by_id = p_user_id
      WHERE pcv.custom_field_group_assignment_id = p_cfga_id
        AND pcv.project_id = p_project_id
      RETURNING *
    )
    INSERT INTO flow.project_custom_field_value (
      project_id, custom_field_group_assignment_id,
      date_value, timestamp_value, boolean_value, text_value,
      numeric_value, int_value, int_array_value,
      date_created, date_modified, created_by_id, modified_by_id, rich_text_value
    )
    SELECT
      p_project_id, p_cfga_id,
      NULL, NULL, NULL, v_full_name,
      NULL, NULL, NULL,
      NOW(), NOW(), p_user_id, p_user_id, NULL
    WHERE NOT EXISTS (SELECT 1 FROM do_update);

  ELSE
    -- Project Process-step-level field
    WITH do_update AS (
      UPDATE flow.project_process_step_custom_field_value ppscfv
      SET text_value = v_full_name,
          date_modified = NOW(),
          modified_by_id = p_user_id
      WHERE ppscfv.custom_field_group_assignment_id = p_cfga_id
        AND ppscfv.project_process_step_id = v_pps_id
      RETURNING *
    )
    INSERT INTO flow.project_process_step_custom_field_value (
      project_process_step_id, custom_field_group_assignment_id,
      date_value, timestamp_value, boolean_value, text_value,
      numeric_value, int_value, int_array_value,
      date_created, date_modified, created_by_id, modified_by_id,
      json_value, rich_text_value
    )
    SELECT
      v_pps_id, p_cfga_id,
      NULL, NULL, NULL, v_full_name,
      NULL, NULL, NULL,
      NOW(), NOW(), p_user_id, p_user_id,
      NULL, NULL
    WHERE NOT EXISTS (SELECT 1 FROM do_update);
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
