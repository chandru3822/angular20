CREATE OR REPLACE FUNCTION flow.company_event_specific_tasks(p_company_id integer)
  RETURNS void AS

$BODY$
BEGIN
  if p_company_id = 3 then

  end if;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
