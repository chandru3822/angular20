CREATE OR REPLACE FUNCTION brs.create_payroll(
  IN p_current_user INTEGER
)
  RETURNS BOOLEAN
LANGUAGE plpgsql AS
$BODY$
BEGIN

  --   set any active to false
  UPDATE brs.payroll
  SET current = FALSE;

  INSERT INTO brs.payroll (created, updated, created_by, updated_by, current)
  VALUES (now(), now(), p_current_user, p_current_user, TRUE);

  RETURN TRUE;

  EXCEPTION WHEN OTHERS
  THEN RAISE NOTICE 'ERROR: %',SQLERRM;
    RETURN FALSE;

END;
$BODY$;
