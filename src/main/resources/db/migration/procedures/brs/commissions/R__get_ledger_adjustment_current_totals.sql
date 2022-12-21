drop function if exists brs.get_ledger_adjustment_current_totals( p_payroll_id bigint,p_project_ids bigint[],p_payroll_adjustment_type_id bigint);
CREATE OR REPLACE FUNCTION brs.get_ledger_adjustment_current_totals( p_payroll_id bigint,p_project_ids bigint[],p_payroll_adjustment_type_id bigint)
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

    insert into flow.company_function_log(function_name, parameters)
    values ('Get Ledger Adjustment Current Totals', 'p_payroll_id: ' || p_payroll_id ||
                                                    ' p_project_ids: ' || p_project_ids ||
                                                    ' p_payroll_adjustment_type_id: ' || p_payroll_adjustment_type_id);

  return v_total;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
