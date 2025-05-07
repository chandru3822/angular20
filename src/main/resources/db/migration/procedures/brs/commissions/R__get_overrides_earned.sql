drop function if exists brs.get_overrides_earned(p_project_id bigint, p_code text);
CREATE OR REPLACE FUNCTION brs.get_overrides_earned(p_project_id bigint, p_code text)
  RETURNS numeric AS
$BODY$
DECLARE
  v_total                     numeric;
  v_primary_financier         bigint;
  v_system_size               numeric;
  v_loan_term                 bigint;
  v_interest_rate             numeric;
  v_cancelled_date            timestamp;
  v_desired_commission_amount numeric;
  v_total_commission_amount   numeric;
  v_allocation_m1             numeric;
  v_red_line_m2_allocation    numeric;
  v_red_line_m1_allocation    numeric;
  v_commission_strategy_id    bigint;
  v_commission_strategy_type_id bigint;
  v_override_plan_id bigint;
  v_fdc_date date;
  v_sc_date date;
BEGIN
  select c.allocation,fd.override_plan_id
  into v_allocation_m1,v_override_plan_id
  from brs.financial_details fd
         inner join brs.commission_plan_allocation c
                    on c.commission_plan_id = fd.commission_plan_id and c.milestone_id = 1
  where fd.project_id = p_project_id;

  select commission_strategy_type_id,
         p.interest_rate,
         p.loan_term,
         p.system_size,
         p.primary_financier,
         fd.desired_commission_amount,
         fd.commission_strategy,
         p.final_design_complete_date,
         p.substantial_completion_date,
         p.cancelled_date
  into v_commission_strategy_type_id,
    v_interest_rate,
    v_loan_term,
    v_system_size,
    v_primary_financier,
    v_desired_commission_amount,
    v_commission_strategy_id,
    v_fdc_date,
    v_sc_date,
    v_cancelled_date
  from brs.financial_details fd
         inner join brs.commission_plan c on c.id = fd.commission_plan_id
         inner join brs.project_details p on p.project_id = fd.project_id
  where fd.project_id = p_project_id;

  select sum(u.red_line_m1_allocation), sum(u.red_line_m2_allocation)
  into v_red_line_m1_allocation,v_red_line_m2_allocation
  from brs.financial_details f
         inner join brs.override_plan o on o.id = f.override_plan_id
         inner join brs.override_plan_receiving_user u on u.override_plan_id = o.id
  where f.project_id = p_project_id
    and (u.red_line_m1_allocation > 0 or u.red_line_m2_allocation >0);
  -- raise notice 'v_desired_commission_amount %',v_desired_commission_amount;
  if v_commission_strategy_id = 24102 and  v_override_plan_id < 2635 and (v_commission_strategy_type_id is null or v_commission_strategy_type_id = 1) and p_code = 'M1' and v_fdc_date is not null then
    v_total_commission_amount = v_desired_commission_amount * v_system_size * 1000;
    --     raise notice 'v_total_commission_amount %',v_total_commission_amount;
--     raise notice 'v_allocation_m1 %',v_allocation_m1;
--     raise notice 'v_red_line_m1_allocation %',v_red_line_m1_allocation;
--     raise notice 'v_system_size %',v_system_size;
    if v_cancelled_date is not null then
      v_total = 0.00;
    else
      v_total = v_total_commission_amount * v_red_line_m1_allocation;
      -- raise notice 'total %',v_allocation_m1 * v_system_size * v_red_line_m1_allocation;
    end if;
  elsif v_commission_strategy_id = 24102 and v_override_plan_id < 2635 and (v_commission_strategy_type_id is null or v_commission_strategy_type_id = 1) and p_code = 'M2' and v_sc_date is not null then
    v_total_commission_amount = v_desired_commission_amount * v_system_size * 1000;
    if v_cancelled_date is not null then
      v_total = 0.00;
    else
      v_total = v_total_commission_amount * v_red_line_m2_allocation;
    end if;

  elsif p_code = 'M1' then
    select coalesce(
             (SELECT case
                       when v_cancelled_date is not null then
                         0::numeric
                       else coalesce(round(case
                                             when v_primary_financier = 722 and v_loan_term = 427 and
                                                  v_interest_rate = 2.99 then 0
                                             else v_system_size::numeric end * (select sum(m1_allocation)
                                                                                from brs.override_plan_receiving_user opru
                                                                                where opru.override_plan_id = op.id),
                                           2),
                                     0) end total
              FROM flow.project p1
                     inner join brs.project_details pd on pd.project_id = p1.id
                     inner join brs.project_override po on po.project_id = p1.id
                     inner join brs.override_plan op on op.id = po.override_plan_id and op.position_id = 1
              WHERE p1.id = p_project_id
                and v_fdc_date is not null), 0)
    into v_total;
  else
    select coalesce(
             (SELECT case
                       when v_cancelled_date is not null then
                         0::NUMERIC
                       else coalesce(round(case
                                             when v_primary_financier = 722 and v_loan_term = 427 and
                                                  v_interest_rate = 2.99 then 0
                                             else v_system_size::numeric end * (select sum(m2_allocation)
                                                                                from brs.override_plan_receiving_user opru
                                                                                where opru.override_plan_id = op.id),
                                           2),
                                     0) end total
              FROM flow.project p1
                     inner join brs.project_details pd on pd.project_id = p1.id
                     inner join brs.project_override po on po.project_id = p1.id
                     inner join brs.override_plan op on op.id = po.override_plan_id and op.position_id = 1
              WHERE p1.id = p_project_id
                and v_sc_date is not null), 0)
    into v_total;
  end if;

  if v_cancelled_date is not null then
    return 0.00::numeric;
  end if;
  return coalesce(v_total, 0);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
