CREATE OR REPLACE FUNCTION brs.get_ledger_adjustment_current_totals( p_payroll_id integer,p_project_ids bigint[],p_payroll_adjustment_type_id integer)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total numeric;

BEGIN


  SELECT (
    select coalesce(sum(amount),0)
    from brs.payroll_adjustment  pca
    where pca.project_id = any (p_project_ids) and
          pca.payroll_id = p_payroll_id AND
          pca.payroll_adjustment_type_id = p_payroll_adjustment_type_id
  )
  into v_total;
  return v_total;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
