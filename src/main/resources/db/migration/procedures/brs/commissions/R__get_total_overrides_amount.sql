drop function if exists brs.get_total_overrides_amount(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.get_total_overrides_amount(p_project_id bigint)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total             numeric;
  v_primary_financier bigint;
  v_system_size       numeric;
  v_loan_term         bigint;
  v_interest_rate     numeric;
BEGIN

  select interest_rate,
         loan_term,
         system_size,
         primary_financier
  from brs.get_commission_data(p_project_id)
  into
    v_interest_rate,
    v_loan_term,
    v_system_size,
    v_primary_financier;

  select coalesce(case
                    when v_primary_financier = 722 and v_loan_term = 427 and v_interest_rate = 2.99 then 0
                    else v_system_size::numeric end * op2.total, 0)
  into v_total
  from brs.override_plan op2
         inner join brs.project_override po on op2.id = po.override_plan_id
  where po.project_id = p_project_id
    and op2.position_id = 1;

  return v_total;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
