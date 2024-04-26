drop function if exists brs.get_total_overrides_amount(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.get_total_overrides_amount(p_project_id bigint)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total                     numeric;
  v_primary_financier         bigint;
  v_system_size               numeric;
  v_loan_term                 bigint;
  v_interest_rate             numeric;
  v_desired_commission_amount numeric;
  v_red_line_m2_allocation    numeric;
  v_red_line_m1_allocation    numeric;
  v_commission_strategy_id    bigint;
BEGIN

  select interest_rate,
         loan_term,
         system_size,
         primary_financier,
         desired_commission_amount,
         commission_strategy_id
  from brs.get_commission_data(p_project_id)
  into
    v_interest_rate,
    v_loan_term,
    v_system_size,
    v_primary_financier,
    v_desired_commission_amount,
    v_commission_strategy_id;

  select sum(u.red_line_m1_allocation), sum(u.red_line_m2_allocation)
  into v_red_line_m1_allocation,v_red_line_m2_allocation
  from brs.financial_details f
         inner join brs.override_plan o on o.id = f.override_plan_id
         inner join brs.override_plan_receiving_user u on u.override_plan_id = o.id
  where f.project_id = p_project_id
    and (u.red_line_m1_allocation > 0 or u.red_line_m2_allocation >0);

  if v_commission_strategy_id = 24102 then
    v_total = v_desired_commission_amount * v_system_size * 1000;
    v_total = v_total*(v_red_line_m1_allocation + v_red_line_m2_allocation);
  else
    select coalesce(case
                      when v_primary_financier = 722 and v_loan_term = 427 and v_interest_rate = 2.99 then 0
                      else v_system_size::numeric end * op2.total, 0)
    into v_total
    from brs.override_plan op2
           inner join brs.project_override po on op2.id = po.override_plan_id
    where po.project_id = p_project_id
      and op2.position_id = 1;
  end if;

  return coalesce(v_total, 0);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
