drop function if exists brs.get_total_overrides_amount( p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.get_total_overrides_amount( p_project_id bigint)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total numeric;
  v_primary_financier    bigint;
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

      select coalesce(case when v_primary_financier = 722 and v_loan_term = 427 and v_interest_rate = 2.99  then 0 else v_system_size::numeric end * op2.total,0)
      into v_total
       from brs.override_plan op2
              inner join brs.project_override po on op2.id = po.override_plan_id
       where po.project_id = p_project_id and op2.position_id = 1;

  return v_total;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
