drop function brs.closer_assigned_redline_commission(p_project_id integer);
CREATE OR REPLACE FUNCTION brs.closer_assigned_redline_commission(p_project_id integer)
  returns boolean AS
$BODY$
declare
  v_closer_assigned_to_redline_commission boolean;
BEGIN
  v_closer_assigned_to_redline_commission = false;

  select true
  into v_closer_assigned_to_redline_commission
  from brs.project_details pd
         inner join brs.commission_plan_user cpu on cpu.user_id = pd.closer_user_id
    and ((cpu.end_date is null and cpu.start_date <= now())
      OR now() between cpu.start_date and cpu.end_date) and
      cpu.commission_plan_id = 63
  where pd.project_id = p_project_id;

  return case
           when v_closer_assigned_to_redline_commission is null then false
           else v_closer_assigned_to_redline_commission end;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
