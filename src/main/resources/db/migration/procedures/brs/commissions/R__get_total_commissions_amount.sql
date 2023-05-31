drop function if exists brs.get_total_commissions_amount( p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.get_total_commissions_amount( p_project_id bigint)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total numeric;
  v_primary_financier    bigint;
  v_source_id            bigint;
  v_system_size          numeric;
  v_loan_term            bigint;
  v_interest_rate        numeric;
BEGIN

  select int_value
  into v_primary_financier
  from flow.project_process_step p
         inner join flow.project_process_step_custom_field_value v
                    on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (460, 19465)
  where p.project_id = p_project_id
    and p.process_step_id in (3355, 4)
    and int_value is not null
  order by v.date_modified desc
  limit 1;

  select int_value
  into v_source_id
  from flow.project_custom_field_value pcfv
  where pcfv.project_id = p_project_id
    and pcfv.custom_field_group_assignment_id = 17280
    and pcfv.int_value is not null
  order by pcfv.date_modified desc
  limit 1;

  select numeric_value
  into v_system_size
  from flow.project_process_step p
         inner join flow.project_process_step_custom_field_value v
                    on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (40, 19451)
  where p.project_id = p_project_id
    and p.process_step_id in (3355, 4)
    and numeric_value is not null
  order by v.date_modified desc
  limit 1;

  select int_value
  into v_loan_term
  from flow.project_process_step p
         inner join flow.project_process_step_custom_field_value v
                    on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (58, 19469)
  where p.project_id = p_project_id
    and p.process_step_id in (3355, 4)
    and int_value is not null
  order by v.date_modified desc
  limit 1;

  select numeric_value
  into v_interest_rate
  from flow.project_process_step p
         inner join flow.project_process_step_custom_field_value v
                    on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (48, 19470)
  where p.project_id = p_project_id
    and p.process_step_id in (3355, 4)
    and numeric_value is not null
  order by v.date_modified desc
  limit 1;

  SELECT coalesce(round(cp.total*case when v_primary_financier = 722 and v_loan_term = 427 and v_interest_rate = 2.99  then 0 else v_system_size::numeric end
                           - case when cpsa.fee_type_id = 1 then coalesce(case when v_primary_financier = 722 and v_loan_term = 427 and v_interest_rate = 2.99  then 0 else v_system_size::numeric end *cpsa.fee_amount, 0) else
      coalesce(cpsa.fee_amount, 0) end ,2),
                   0)
    into v_total
   FROM flow.project p2
          inner join brs.project_commission pc on pc.project_id = p2.id
          inner join brs.commission_plan cp on pc.commission_plan_id = cp.id and cp.position_id = 1
          left join brs.commission_plan_source_allocation cpsa on cpsa.commission_plan_id = cp.id  and cpsa.milestone_id = 2 and  cpsa.source_id = v_source_id
   where p2.id = p_project_id;



  return v_total;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
