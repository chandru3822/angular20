drop function if exists brs.create_payroll(
  IN p_current_user bigint,
  in p_position_id bigint
);
CREATE OR REPLACE FUNCTION brs.create_payroll(
  IN p_current_user bigint,
  in p_position_id bigint
)
  RETURNS BOOLEAN
LANGUAGE plpgsql AS
$BODY$
BEGIN

  --   set any active to false
  UPDATE brs.payroll
  SET current = FALSE
  where position_id = p_position_id;

  INSERT INTO brs.payroll (created, updated, created_by, updated_by, current,position_id)
  VALUES (now(), now(), p_current_user, p_current_user, TRUE,p_position_id);

  insert into flow.company_function_log(function_name, parameters, run_by_id)
  values ('Create Payroll', 'p_current_user: ' || p_current_user ||
                            ' p_position_id: '|| p_position_id,
          p_current_user);

  RETURN TRUE;

  EXCEPTION WHEN OTHERS
  THEN RAISE NOTICE 'ERROR: %',SQLERRM;
    RETURN FALSE;

END;
$BODY$;
