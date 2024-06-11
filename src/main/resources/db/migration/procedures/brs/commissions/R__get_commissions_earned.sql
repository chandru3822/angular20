drop function if exists brs.get_commissions_earned(p_project_ids bigint, p_code text);
drop function if exists brs.get_commissions_earned(p_project_ids bigint, p_code text, p_from_booking boolean);
CREATE OR REPLACE FUNCTION brs.get_commissions_earned(p_project_id bigint, p_code text, p_from_booking boolean default false)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total                     numeric;
  v_primary_financier         bigint;
  v_source_id                 bigint;
  v_system_size               numeric;
  v_loan_term                 bigint;
  v_interest_rate             numeric;
  v_cancelled_date            timestamp;
  v_desired_commission_amount numeric;
  v_allocation_m1             numeric;
  v_allocation_m2             numeric;
  v_total_commission_amount   numeric;
  v_milestone_2               bigint;
  v_milestone_1               bigint;
  v_commission_strategy_id    bigint;
  v_fee_type_id               bigint;
  v_commission_strategy_type_id bigint;
BEGIN

  select c.allocation, fee_type_id, a.allocation
  into v_allocation_m1,v_fee_type_id,v_allocation_m2
  from brs.financial_details fd
         inner join brs.commission_plan p on p.id = fd.commission_plan_id
         inner join brs.commission_plan_allocation c
                    on c.commission_plan_id = p.id and c.milestone_id = 1
         left join brs.commission_plan_allocation a on a.commission_plan_id = p.id and
                                                       a.milestone_id = 2
  where fd.project_id = p_project_id;

  select commission_strategy_type_id
  into v_commission_strategy_type_id
  from brs.financial_details fd
         inner join brs.commission_plan c on c.id = fd.commission_plan_id
  where fd.project_id = p_project_id;


  select cancelled_date,
         interest_rate,
         loan_term,
         system_size,
         source_id,
         primary_financier,
         desired_commission_amount,
         commission_strategy_id
  from brs.get_commission_data(p_project_id, p_from_booking)
  into v_cancelled_date,
    v_interest_rate,
    v_loan_term,
    v_system_size,
    v_source_id,
    v_primary_financier,
    v_desired_commission_amount,
    v_commission_strategy_id;

  select ppscfv.id
  into v_milestone_2
  from flow.project_process_step pps
         inner join flow.project_process_step_custom_field_value ppscfv
                    on ppscfv.project_process_step_id = pps.id and
                       ppscfv.custom_field_group_assignment_id = 21009
  where pps.project_id = p_project_id
    and pps.process_step_id = 3365
    and ppscfv.date_value is not null;

  select ppscfv.id
  into v_milestone_1
  from flow.project_process_step pps
         inner join flow.project_process_step_custom_field_value ppscfv
                    on ppscfv.project_process_step_id = pps.id and
                       ppscfv.custom_field_group_assignment_id = 1251
  where pps.project_id = p_project_id
    and pps.process_step_id = 175
    and ppscfv.date_value is not null;

  --raise notice 'v_commission_strategy_id %',v_commission_strategy_id;

  if v_commission_strategy_id = 24102 and v_commission_strategy_type_id = 1 and p_code = 'M1' and (v_milestone_1 is not null or p_from_booking is true) then
    v_total_commission_amount = v_desired_commission_amount * v_system_size * 1000;
    if v_cancelled_date is not null then
      v_total = 0.00;
    elsif v_fee_type_id = 1 then
      if v_total_commission_amount <= v_allocation_m1 * v_system_size then
        v_total = v_total_commission_amount;
      else
        v_total = v_allocation_m1 * v_system_size;
      end if;
    elsif v_fee_type_id = 3 then
      v_total = v_total_commission_amount * v_allocation_m1;
    end if;
  elsif v_commission_strategy_id = 24102 and v_commission_strategy_type_id = 1 and p_code = 'M2' and v_milestone_2 is not null then
    v_total_commission_amount = v_desired_commission_amount * v_system_size * 1000;
    if v_cancelled_date is not null then
      v_total = 0.00;
    elsif v_fee_type_id = 1 then
      if v_total_commission_amount <= v_allocation_m1 * v_system_size then
        v_total = 0.00::numeric;
      else
        v_total = v_total_commission_amount - v_allocation_m1 * v_system_size;
      end if;
    elsif v_fee_type_id = 3 then
      v_total = v_total_commission_amount * v_allocation_m2;
    end if;

  elsif p_code = 'M1' then
    select coalesce(
             (SELECT case
                       when v_cancelled_date is not null then
                         0::NUMERIC
                       else coalesce(round(cpa.allocation * case
                                                              when v_primary_financier = 722 and
                                                                   v_loan_term = 427 and v_interest_rate = 2.99 then 0
                                                              else v_system_size::numeric end - case
                                                                                                  when cpsa.milestone_id = 1
                                                                                                    then
                                                                                                    case
                                                                                                      when cpsa.fee_type_id = 1
                                                                                                        then coalesce(
                                                                                                        case
                                                                                                          when
                                                                                                            v_primary_financier =
                                                                                                            722 and
                                                                                                            v_loan_term =
                                                                                                            427 and
                                                                                                            v_interest_rate =
                                                                                                            2.99
                                                                                                            then 0
                                                                                                          else v_system_size::numeric end *
                                                                                                        cpsa.fee_amount,
                                                                                                        0)
                                                                                                      else coalesce(cpsa.fee_amount, 0) end
                                                                                                  else 0 end, 2),
                                     0) end total
              FROM flow.project p1
                     inner join brs.project_details pd on pd.project_id = p1.id
                     inner join brs.project_commission pc on pc.project_id = p1.id
                     inner join brs.commission_plan cp on cp.id = pc.commission_plan_id and cp.position_id = 1
                     inner join brs.commission_plan_allocation cpa
                                on cpa.commission_plan_id = cp.id and cpa.milestone_id = 1
                     left join brs.commission_plan_source_allocation cpsa
                               on cpsa.commission_plan_id = cp.id and cpsa.source_id = v_source_id
                                 and cpsa.milestone_id = 1
              WHERE p1.id = p_project_id
                and (v_milestone_1 is not null or p_from_booking is true)), 0)
    into v_total;

  elsif p_code = 'M2' then
    select coalesce(
             (SELECT case
                       when v_cancelled_date is not null THEN
                         0::NUMERIC
                       else coalesce(round(cpa.allocation * case
                                                              when v_primary_financier = 722 and
                                                                   v_loan_term = 427 and v_interest_rate = 2.99 then 0
                                                              else v_system_size::numeric end - case
                                                                                                  when cpsa.milestone_id = 2
                                                                                                    then
                                                                                                    case
                                                                                                      when cpsa.fee_type_id = 1
                                                                                                        then coalesce(
                                                                                                        case
                                                                                                          when
                                                                                                            v_primary_financier =
                                                                                                            722 and
                                                                                                            v_loan_term =
                                                                                                            427 and
                                                                                                            v_interest_rate =
                                                                                                            2.99
                                                                                                            then 0
                                                                                                          else v_system_size::numeric end *
                                                                                                        cpsa.fee_amount,
                                                                                                        0)
                                                                                                      else coalesce(cpsa.fee_amount, 0) end
                                                                                                  else 0 end, 2),
                                     0) end total
              FROM flow.project p1
                     inner join brs.project_details pd on pd.project_id = p1.id
                     inner join brs.project_commission pc on pc.project_id = p1.id
                     inner join brs.commission_plan cp on cp.id = pc.commission_plan_id and cp.position_id = 1
                     inner join brs.commission_plan_allocation cpa
                                on cpa.commission_plan_id = cp.id and cpa.milestone_id = 2
                     left join brs.commission_plan_source_allocation cpsa
                               on cpsa.commission_plan_id = cp.id and cpa.milestone_id = 2 and
                                  cpsa.source_id = v_source_id
              WHERE p1.id = p_project_id
                and v_milestone_2 is not null), 0)
    into v_total;
  end if;

  return coalesce(v_total, 0);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


