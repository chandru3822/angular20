drop function if exists brs.clone_commission_plan(
  p_commission_plan bigint,
  p_start_date      DATE,
  p_users           bigint [],
  p_created_by      bigint);
CREATE OR REPLACE FUNCTION brs.clone_commission_plan(
  p_commission_plan bigint,
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
  FROM brs.commission_plan
  WHERE id = p_commission_plan;

  -- create a new override plan with defaults from the copied plan
  INSERT INTO brs.commission_plan
  (name, description, total, status_id, position_id, created, created_by, parent_id)
  VALUES (
    coalesce(_cloned.name, '') || ' - [COPY]',
    _cloned.description,
    coalesce(_cloned.total, 0),
    1, --PENDING
    _cloned.position_id,
    now(),
    p_created_by,
    _cloned.id
  )
  RETURNING id
    INTO _cloneId;

  -- copy over all milestones to new plan
  WITH milestones AS (
      SELECT *
      FROM brs.commission_plan_allocation
      WHERE commission_plan_id = p_commission_plan
  )
  INSERT INTO brs.commission_plan_allocation
  (commission_plan_id, milestone_id, allocation)
    SELECT
      _cloneId,
      ms.milestone_id,
      ms.allocation
    FROM milestones ms;

  -- copy over all sources to new plan
  WITH sources AS (
      SELECT *
      FROM brs.commission_plan_source_allocation
      WHERE commission_plan_id = p_commission_plan
  )
  INSERT INTO brs.commission_plan_source_allocation
  (commission_plan_id, milestone_id, fee_amount, fee_type_id, source_id)
    SELECT
      _cloneId,
      s.milestone_id,
      s.fee_amount,
      s.fee_type_id,
      s.source_id
    FROM sources s;

  IF p_users IS NOT NULL THEN
  -- get list of user ids to be modified
  SELECT array_agg(id)
  INTO _assignedUserIds
  FROM brs.commission_plan_user
  WHERE commission_plan_id = p_commission_plan
    AND user_id = ANY (p_users)
    AND end_date IS NULL;

  -- set the end_date for selected users on the original_plan, this has to be done first before creating new records
  UPDATE brs.commission_plan_user
  SET end_date = p_start_date - INTERVAL '1 day', date_modified = now()
  WHERE id = ANY(_assignedUserIds);

  -- copy over assigned users
  WITH plan_users AS (
      SELECT *
      FROM brs.commission_plan_user
      WHERE id = ANY(_assignedUserIds)
  )
  INSERT INTO brs.commission_plan_user
  (commission_plan_id, user_id, start_date)
    SELECT
      _cloneId,
      user_id,
      p_start_date
    FROM plan_users;

    END IF;

    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Clone Commission Plan','p_commission_plan: ' || p_commission_plan ||
                                    ' p_start_date: '|| p_start_date ||
                                    ' p_users: ' || p_users::text ||
                                    ' p_created_by: ' || p_created_by,
            p_created_by);

  RETURN _cloneId;
END;
$$;
