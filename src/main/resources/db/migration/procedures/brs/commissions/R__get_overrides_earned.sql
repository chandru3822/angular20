drop function if exists brs.get_overrides_earned(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.get_overrides_earned(p_project_id bigint)
  RETURNS numeric AS
$BODY$
DECLARE
  v_total             numeric;
  v_primary_financier bigint;
  v_system_size       numeric;
  v_loan_term         bigint;
  v_interest_rate     numeric;
  v_cancelled_date    timestamp;
BEGIN

  select cancelled_date,
         interest_rate,
         loan_term,
         system_size,
         primary_financier
  from brs.get_commission_data(p_project_id)
  into v_cancelled_date,
    v_interest_rate,
    v_loan_term,
    v_system_size,
    v_primary_financier;

  select coalesce(
           (SELECT case
                     when v_cancelled_date is not null then
                       0::numeric
                     else coalesce(round(case
                                           when v_primary_financier = 722 and v_loan_term = 427 and
                                                v_interest_rate = 2.99 then 0
                                           else v_system_size::numeric end * (select sum(m1_allocation)
                                                                              from brs.override_plan_receiving_user opru
                                                                              where opru.override_plan_id = op.id), 2),
                                   0) end total
            FROM flow.project p1
                   inner join brs.project_details pd on pd.project_id = p1.id
                   inner join brs.project_override po on po.project_id = p1.id
                   inner join brs.override_plan op on op.id = po.override_plan_id and op.position_id = 1
            WHERE p1.id = p_project_id
              and exists (select ppscfv.id
                          from flow.project_process_step pps
                                 inner join flow.project_process_step_custom_field_value ppscfv
                                            on ppscfv.project_process_step_id = pps.id and
                                               ppscfv.custom_field_group_assignment_id = 1251
                          where pps.project_id = p_project_id
                            and pps.process_step_id = 175
                            and ppscfv.date_value is not null)), 0) + coalesce(
           (SELECT case
                     when v_cancelled_date is not null then
                       0::NUMERIC
                     else coalesce(round(case
                                           when v_primary_financier = 722 and v_loan_term = 427 and
                                                v_interest_rate = 2.99 then 0
                                           else v_system_size::numeric end * (select sum(m2_allocation)
                                                                              from brs.override_plan_receiving_user opru
                                                                              where opru.override_plan_id = op.id), 2),
                                   0) end total
            FROM flow.project p1
                   inner join brs.project_details pd on pd.project_id = p1.id
                   inner join brs.project_override po on po.project_id = p1.id
                   inner join brs.override_plan op on op.id = po.override_plan_id and op.position_id = 1
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


  return v_total;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
