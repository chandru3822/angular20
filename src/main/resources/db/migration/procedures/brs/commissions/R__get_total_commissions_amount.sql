drop function if exists brs.get_total_commissions_amount(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.get_total_commissions_amount(p_project_id bigint)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total                     numeric;
  v_primary_financier         bigint;
  v_source_id                 bigint;
  v_system_size               numeric;
  v_loan_term                 bigint;
  v_interest_rate             numeric;
  v_desired_commission_amount numeric;
  v_commission_strategy_id    bigint;
BEGIN

  select interest_rate,
         loan_term,
         system_size,
         primary_financier,
         source_id,
         desired_commission_amount,
         commission_strategy_id
  from brs.get_commission_data(p_project_id)
  into
    v_interest_rate,
    v_loan_term,
    v_system_size,
    v_primary_financier,
    v_source_id,
    v_desired_commission_amount,
    v_commission_strategy_id;

  if v_commission_strategy_id = 23610 then

    v_total = v_desired_commission_amount * v_system_size * 1000;
  else

    SELECT coalesce(round(cp.total * case
                                       when v_primary_financier = 722 and v_loan_term = 427 and v_interest_rate = 2.99
                                         then 0
                                       else v_system_size::numeric end
                            - case
                                when cpsa.fee_type_id = 1 then coalesce(case
                                                                          when v_primary_financier = 722 and v_loan_term = 427 and v_interest_rate = 2.99
                                                                            then 0
                                                                          else v_system_size::numeric end *
                                                                        cpsa.fee_amount, 0)
                                else
                                  coalesce(cpsa.fee_amount, 0) end, 2),
                    0)
    into v_total
    FROM flow.project p2
           inner join brs.project_commission pc on pc.project_id = p2.id
           inner join brs.commission_plan cp on pc.commission_plan_id = cp.id and cp.position_id = 1
           left join brs.commission_plan_source_allocation cpsa
                     on cpsa.commission_plan_id = cp.id and cpsa.milestone_id = 2 and cpsa.source_id = v_source_id
    where p2.id = p_project_id;
  end if;

  return v_total;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
