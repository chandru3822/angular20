drop function if exists brs.clone_override_plan(
  p_override_plan   bigint,
  p_start_date      DATE,
  p_assigned_users  bigint [],
  p_receiving_users bigint [],
  p_created_by      bigint,
  p_user_to_add     bigint);
CREATE OR REPLACE FUNCTION brs.clone_override_plan(
  p_override_plan   bigint,
  p_start_date      DATE,
  p_assigned_users  bigint [],
  p_receiving_users bigint [],
  p_created_by      bigint,
  p_user_to_add     bigint)
  RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
  _cloned  RECORD;
  _cloneId bigint;
BEGIN
  SELECT *
  INTO _cloned
  FROM brs.override_plan
  WHERE id = p_override_plan;


  -- create a new override plan with defaults from the copied plan
  INSERT INTO brs.override_plan (
    name, description, total, status_id, created_by, created, updated_by, updated, position_id, parent_id)
  VALUES (
    coalesce(_cloned.name, '') || ' - [COPY]',
    _cloned.description,
    coalesce(_cloned.total, 0),
    1, --PENDING
    p_created_by,
    now(),
    p_created_by,
    now(),
    _cloned.position_id,
    _cloned.id
  )
  RETURNING id
    INTO _cloneId;


  -- set the end_date for selected users on the original_plan, this has to be done first before creating new records
  IF p_assigned_users IS NOT NULL THEN
  UPDATE brs.override_plan_assigned_user
  SET end_date = p_start_date - INTERVAL '1 day', date_modified = now()
  WHERE override_plan_id = p_override_plan
        AND user_id = ANY (p_assigned_users)
        AND end_date IS NULL;

  -- copy over assigned users, make sure to not bring over anyone who already has an end date
  WITH assigned_users AS (
      SELECT DISTINCT user_id
      FROM brs.override_plan_assigned_user
      WHERE override_plan_id = p_override_plan
            AND user_id = ANY (p_assigned_users)
            AND end_date IS NOT NULL
  )
  INSERT INTO brs.override_plan_assigned_user
  (override_plan_id, user_id, start_date)
    SELECT
      _cloneId,
      user_id,
      p_start_date
    FROM assigned_users;

END IF;

IF p_receiving_users IS NOT NULL THEN
  WITH receiving_users AS (
      SELECT *
      FROM brs.override_plan_receiving_user
      WHERE override_plan_id = p_override_plan
            AND user_id = ANY (p_receiving_users)
  )
  INSERT INTO brs.override_plan_receiving_user
  (override_plan_id, user_id, m1_allocation,m2_allocation)
    SELECT
      _cloneId,
      user_id,
      m1_allocation,
      m2_allocation
    FROM receiving_users;

END IF;

IF p_user_to_add IS NOT NULL THEN
  INSERT INTO brs.override_plan_receiving_user
  (override_plan_id, user_id, m1_allocation,m2_allocation)
  VALUES (_cloneId, p_user_to_add, 0,0)
  ON CONFLICT (override_plan_id, user_id)
            DO NOTHING;

END IF;

    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Clone Override Plan',
            'p_override_plan: ' || p_override_plan ||
            ' p_start_date: '|| p_start_date ||
            ' p_assigned_users: ' || p_assigned_users::text ||
            ' p_receiving_users: ' || p_receiving_users::text ||
            ' p_created_by: ' || p_created_by ||
            ' p_user_to_add: ' || p_user_to_add,
            p_created_by);

  RETURN _cloneId;

  EXCEPTION WHEN OTHERS
  THEN RAISE NOTICE 'ERROR: %',SQLERRM;
    RETURN null;
END;
$$;
