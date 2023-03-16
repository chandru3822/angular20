drop function if exists brs.create_residual(
  IN p_current_user bigint
);
CREATE OR REPLACE FUNCTION brs.create_residual(
  IN p_current_user bigint
)
  RETURNS BOOLEAN
LANGUAGE plpgsql AS
$BODY$
  declare
  v_new_period_start date;
  v_new_period_end date;
  v_new_grace_period_end date;
  v_previous_grace_period_end date;
  v_period_month varchar;
BEGIN

  --   set any active to false
  UPDATE brs.residual r
  SET current = FALSE
  where current = true;

  --get the end date of the most recent one, add 1 day
  select (period_end + interval '1 days')::date
    into v_new_period_start
    from brs.residual r
  order by id desc
  limit 1;

  select (date_trunc('month', v_new_period_start) +
          interval '1 month' - interval '1 day')::date
    into v_new_period_end;

  select trim(TO_CHAR(v_new_period_start, 'Month'))
    into v_period_month;

  select (v_new_period_end + interval '15 day')::date
  into v_new_grace_period_end;

  select (v_new_grace_period_end - interval '1 month')::date
  into v_previous_grace_period_end;

--   raise notice 'new start %', v_new_period_start;
--   raise notice 'new end %', v_new_period_end;
--   raise notice 'new grace %', v_new_grace_period_end;
--   raise notice 'new month %', v_period_month;

  INSERT INTO brs.residual( date_created,date_modified,created_by_id,modified_by_id, current,
                           selected_user_ids, period_start, period_end, grace_period_end, description, previous_grace_period_end)
  VALUES (now(), now(), p_current_user, p_current_user,TRUE,'{}'::bigint[], v_new_period_start,
          v_new_period_end, v_new_grace_period_end, concat(v_period_month, ' Residual'), v_previous_grace_period_end);

  RETURN TRUE;

  EXCEPTION WHEN OTHERS
  THEN RAISE NOTICE 'ERROR: %',SQLERRM;
    RETURN FALSE;

END;
$BODY$;
