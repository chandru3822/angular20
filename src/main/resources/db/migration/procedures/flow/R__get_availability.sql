--DROP FUNCTION IF EXISTS flow.get_system_list_options(integer, integer, boolean, integer[]);
CREATE OR REPLACE FUNCTION flow.get_availability(p_start_time timestamp, p_end_time timestamp, p_org_ids int[], p_user_ids int[])

  RETURNS json AS
$$
DECLARE
    v_json json;

BEGIN

  -- if it is a user without slots or an org do the normal

  -- otherwise do the new way

RETURN v_json;
END;
$$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
