drop function if exists brs.create_residual(
  IN p_current_user bigint
);
CREATE OR REPLACE FUNCTION brs.create_residual(
  IN p_current_user bigint
)
  RETURNS BOOLEAN
LANGUAGE plpgsql AS
$BODY$
BEGIN

  --   set any active to false
  UPDATE brs.residual r
  SET current = FALSE
  where current = true;

  INSERT INTO brs.residual( date_created,date_modified,created_by_id,modified_by_id,current, selected_user_ids)
  VALUES (now(), now(), p_current_user, p_current_user,TRUE,'{}'::bigint[]);

  RETURN TRUE;

  EXCEPTION WHEN OTHERS
  THEN RAISE NOTICE 'ERROR: %',SQLERRM;
    RETURN FALSE;

END;
$BODY$;
