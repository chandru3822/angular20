drop function if exists brs.get_commissions_earned(p_project_ids bigint, p_code text);
CREATE OR REPLACE FUNCTION brs.get_commissions_earned(p_project_id bigint, p_code text)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total             numeric;
  v_primary_financier bigint;
  v_source_id         bigint;
  v_system_size       numeric;
  v_loan_term         bigint;
  v_interest_rate     numeric;
  v_cancelled_date    timestamp;
BEGIN

  select cancelled_date,
         interest_rate,
         loan_term,
         system_size,
         source_id,
         primary_financier
  from brs.get_commission_data(p_project_id)
  into v_cancelled_date,
    v_interest_rate,
    v_loan_term,
    v_system_size,
    v_source_id,
    v_primary_financier;

  if p_code = 'M1' then
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
                                                                                                            when v_primary_financier =
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
                and exists (select ppscfv.id
                            from flow.project_process_step pps
                                   inner join flow.project_process_step_custom_field_value ppscfv
                                              on ppscfv.project_process_step_id = pps.id and
                                                 ppscfv.custom_field_group_assignment_id = 1251
                            where pps.project_id = p_project_id
                              and pps.process_step_id = 175
                              and ppscfv.date_value is not null)), 0)
    into v_total;

  else
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
                                                                                                            when v_primary_financier =
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
                and exists (select ppscfv.id
                            from flow.project_process_step pps
                                   inner join flow.project_process_step_custom_field_value ppscfv
                                              on ppscfv.project_process_step_id = pps.id and
                                                 ppscfv.custom_field_group_assignment_id = 21009
                            where pps.project_id = p_project_id
                              and pps.process_step_id = 3365
                              and ppscfv.date_value is not null)), 0)
    into v_total;
  end if;

  return coalesce(v_total, 0);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


