drop function if exists brs.get_commission_data(p_project_ids bigint);
CREATE OR REPLACE FUNCTION brs.get_commission_data(p_project_id bigint)
  RETURNS table
          (
            cancelled_date    date,
            primary_financier bigint,
            source_id         bigint,
            system_size       numeric,
            loan_term         bigint,
            interest_rate     numeric
          )
as
$BODY$
DECLARE
  v_primary_financier bigint;
  v_source_id         bigint;
  v_system_size       numeric;
  v_loan_term         bigint;
  v_interest_rate     numeric;
  v_cancelled_date    date;
BEGIN

  select p2.cancelled_date
  into v_cancelled_date
  from flow.project p2
  where p2.id = p_project_id;

  select coalesce(v.int_value,pd.primary_financier)
  into v_primary_financier
  from flow.project_process_step p
         left join flow.project_process_step_custom_field_value v
                   on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (19465) and
                      int_value is not null
         inner join brs.project_details pd on pd.project_id = p.project_id
  where p.project_id = p_project_id
    and p.process_step_id in (3355)
    and p.main is true;

  select pcfv.int_value
  into v_source_id
  from flow.project_custom_field_value pcfv
  where pcfv.project_id = p_project_id
    and pcfv.custom_field_group_assignment_id = 17280
    and pcfv.int_value is not null;

  select coalesce(v.numeric_value,pd.system_size)
  into v_system_size
  from flow.project_process_step p
         left join flow.project_process_step_custom_field_value v
                   on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (19451) and
                      numeric_value is not null
         inner join brs.project_details pd on pd.project_id = p.project_id
  where p.project_id = p_project_id
    and p.process_step_id in (3355)
    and p.main is true;

  select coalesce(v.int_value,pd.loan_term)
  into v_loan_term
  from flow.project_process_step p
         left join flow.project_process_step_custom_field_value v
                   on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (19469) and
                      int_value is not null
         inner join brs.project_details pd on pd.project_id = p.project_id
  where p.project_id = p_project_id
    and p.process_step_id in (3355)
    and p.main is true;

  select coalesce(v.numeric_value,pd.interest_rate)
  into v_interest_rate
  from flow.project_process_step p
         left join flow.project_process_step_custom_field_value v
                   on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (19470) and
                      numeric_value is not null
         inner join brs.project_details pd on pd.project_id = p.project_id
  where p.project_id = p_project_id
    and p.process_step_id in (3355)
    and p.main is true;

  return query
    select v_cancelled_date,
           coalesce(v_primary_financier,-1),
           coalesce(v_source_id,-1),
           coalesce(v_system_size,0),
           coalesce(v_loan_term,-1),
           coalesce(v_interest_rate,0);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


