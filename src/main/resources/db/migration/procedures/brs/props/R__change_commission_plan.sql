drop procedure if exists brs.change_commission_plan(
  p_project_id bigint,
  p_commission_plan_id bigint);
CREATE OR REPLACE procedure brs.change_commission_plan(
  p_project_id bigint,
  p_commission_plan_id bigint)
AS
$BODY$
declare
v_commission_plan_name text;
BEGIN

  select cp.name
  into v_commission_plan_name
    from brs.commission_plan cp
  where cp.id = p_commission_plan_id;

  update brs.project_commission pc
  set commission_plan_id =p_commission_plan_id
  where project_id = p_project_id;

  update brs.financial_details fd
  set commission_plan = v_commission_plan_name,
      commission_plan_id = p_commission_plan_id
  where project_id = p_project_id;


  call brs.reset_financial_details(p_project_id);
END
$BODY$
  LANGUAGE plpgsql;


