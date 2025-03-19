drop function if exists brs.get_partner_ledger_adjustment_current_totals( p_payroll_id bigint,p_project_id bigint,p_org_id bigint,p_payroll_adjustment_type_id bigint);
CREATE OR REPLACE FUNCTION brs.get_partner_ledger_adjustment_current_totals( p_payroll_id bigint,p_project_id bigint,p_org_id bigint,p_payroll_adjustment_type_id bigint)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total numeric;

BEGIN


  SELECT (
    select coalesce(sum(amount),0)
    from brs.partner_payroll_adjustment  pca
    where pca.project_id = p_project_id and
          pca.org_id = p_org_id and
          pca.payroll_id = p_payroll_id AND
          pca.payroll_adjustment_type_id = p_payroll_adjustment_type_id
  )
  into v_total;



  return v_total;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
