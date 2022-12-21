drop function if exists brs.clone_residual_plan(
  p_residual_plan bigint,
  p_start_date      DATE,
  p_users           bigint [],
  p_created_by      bigint);
CREATE OR REPLACE FUNCTION brs.clone_residual_plan(
  p_residual_plan bigint,
  p_start_date      DATE,
  p_users           bigint [],
  p_created_by      bigint)
  RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
  _cloned  RECORD;
  _cloneId bigint;
  _assignedUserIds bigint[];
BEGIN
  SELECT *
  INTO _cloned
  FROM brs.residual_plan
  WHERE id = p_residual_plan;

  -- create a new residual plan with defaults from the copied plan
  INSERT INTO brs.residual_plan
  (name, description, residual_status_id, position_id, created, created_by)
  VALUES (
    coalesce(_cloned.name, '') || ' - [COPY]',
    _cloned.description,
    1, --PENDING
    _cloned.position_id,
    now(),
    p_created_by
  )
  RETURNING id
    INTO _cloneId;

  -- copy over all level allocations to new plan
  WITH allocations AS (
      SELECT *
      FROM brs.residual_plan_allocation
      WHERE residual_plan_id = p_residual_plan
  )
  INSERT INTO brs.residual_plan_allocation
  (residual_plan_id, name, total, level, nbr_fdc_lower, nbr_fdc_upper)
    SELECT
      _cloneId,
      a.name,
      a.total,
           a.level,
           a.nbr_fdc_lower,
           a.nbr_fdc_upper
    FROM allocations a;

  IF p_users IS NOT NULL THEN
  -- get list of user ids to be modified
  SELECT array_agg(id)
  INTO _assignedUserIds
  FROM brs.residual_plan_user
  WHERE residual_plan_id = p_residual_plan
    AND user_id = ANY (p_users)
    AND end_date IS NULL;

  -- set the end_date for selected users on the original_plan, this has to be done first before creating new records
  UPDATE brs.residual_plan_user
  SET end_date = p_start_date - INTERVAL '1 day'
  WHERE id = ANY(_assignedUserIds);

  -- copy over assigned users
  WITH plan_users AS (
      SELECT *
      FROM brs.residual_plan_user
      WHERE id = ANY(_assignedUserIds)
  )
  INSERT INTO brs.residual_plan_user
  (residual_plan_id, user_id, start_date)
    SELECT
      _cloneId,
      user_id,
      p_start_date
    FROM plan_users;

    END IF;

    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Clone Residual Plan', 'p_residual_plan: ' || p_residual_plan ||
                                   ' p_start_date: '|| p_start_date ||
                                   ' p_users: ' || p_users ||
                                   ' p_created_by: ' || p_created_by,
            p_created_by);

  RETURN _cloneId;
END;
$$;
