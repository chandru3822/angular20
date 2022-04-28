CREATE OR REPLACE FUNCTION brs.get_ledger_totals(p_payroll_id integer, p_project_ids bigint[],p_ledger_type_id integer,p_position_id integer)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total numeric;
  v_payroll_status_id integer;
BEGIN
    select p.payroll_status_id
      into v_payroll_status_id
      from brs.payroll p
      where id= p_payroll_id;
/*
1;"COMMISSION"
2;"COMMISSION_ADJUSTMENT"
3;"OVERRIDE"
4;"RESIDUAL"*/



      select
      (
        SELECT coalesce(sum(amount), 0)
        FROM brs.project_commission_ledger pcl
        WHERE pcl.project_id = any(p_project_ids)
              AND pcl.ledger_type_id = p_ledger_type_id
          and pcl.position_id = p_position_id
             )
    into v_total;

  return v_total;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
