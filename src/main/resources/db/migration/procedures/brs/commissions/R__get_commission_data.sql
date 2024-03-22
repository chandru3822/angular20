drop function if exists brs.get_commission_data(p_project_id bigint);
drop function if exists brs.get_commission_data(p_project_id bigint, p_from_booking boolean);
CREATE OR REPLACE FUNCTION brs.get_commission_data(p_project_id bigint, p_from_booking boolean default false)
  RETURNS table
          (
            cancelled_date            date,
            primary_financier         bigint,
            source_id                 bigint,
            system_size               numeric,
            loan_term                 bigint,
            interest_rate             numeric,
            desired_commission_amount numeric,
            commission_strategy_id    bigint
          )
as
$BODY$
DECLARE
  v_cancelled_date                    date;
  v_source_id                         bigint;
  v_primary_financier_fdc             bigint;
  v_system_size_fdc                   numeric;
  v_loan_term_fdc                     bigint;
  v_interest_rate_fdc                 numeric;
  v_desired_commission_amount_fdc     numeric;
  v_commission_strategy_id_fdc        bigint;
  v_primary_financier_booking         bigint;
  v_system_size_booking               numeric;
  v_loan_term_booking                 bigint;
  v_interest_rate_booking             numeric;
  v_desired_commission_amount_booking numeric;
  v_commission_strategy_id_booking    bigint;
BEGIN

  select p2.cancelled_date
  into v_cancelled_date
  from flow.project p2
  where p2.id = p_project_id;


  select coalesce(v.int_value, pd.primary_financier)
  into v_primary_financier_fdc
  from flow.project_process_step p
         left join flow.project_process_step_custom_field_value v
                   on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (19465) and
                      int_value is not null
         inner join brs.project_details pd on pd.project_id = p.project_id
  where p.project_id = p_project_id
    and p.process_step_id in (3355)
    and p.main is true;


  select coalesce(v.numeric_value, fd.desired_commission_amount)
  into v_desired_commission_amount_fdc
  from flow.project_process_step p
         left join flow.project_process_step_custom_field_value v
                   on v.project_process_step_id = p.id and v.custom_field_group_assignment_id = 26166 and
                      numeric_value is not null
         inner join brs.financial_details fd on fd.project_id = p.project_id
  where p.project_id = p_project_id
    and p.process_step_id in (3355)
    and p.main is true;

  select coalesce(v.int_value, fd.commission_strategy)
  into v_commission_strategy_id_fdc
  from flow.project_process_step p
         left join flow.project_process_step_custom_field_value v
                   on v.project_process_step_id = p.id and
                      v.custom_field_group_assignment_id = 26176 and --26168 stage -- 26176 prod
                      int_value is not null
         inner join brs.financial_details fd on fd.project_id = p.project_id
  where p.project_id = p_project_id
    and p.process_step_id in (3355)
    and p.main is true;

  select pcfv.int_value
  into v_source_id
  from flow.project_custom_field_value pcfv
  where pcfv.project_id = p_project_id
    and pcfv.custom_field_group_assignment_id = 17280
    and pcfv.int_value is not null;

  select coalesce(v.numeric_value, pd.system_size)
  into v_system_size_fdc
  from flow.project_process_step p
         left join flow.project_process_step_custom_field_value v
                   on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (19451, 25391) and
                      numeric_value is not null
         inner join brs.project_details pd on pd.project_id = p.project_id
  where p.project_id = p_project_id
    and p.process_step_id in (3355, 3620)
    and p.main is true;

  select coalesce(v.int_value, pd.loan_term)
  into v_loan_term_fdc
  from flow.project_process_step p
         left join flow.project_process_step_custom_field_value v
                   on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (19469) and
                      int_value is not null
         inner join brs.project_details pd on pd.project_id = p.project_id
  where p.project_id = p_project_id
    and p.process_step_id in (3355)
    and p.main is true;

  select coalesce(v.numeric_value, pd.interest_rate)
  into v_interest_rate_fdc
  from flow.project_process_step p
         left join flow.project_process_step_custom_field_value v
                   on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (19470) and
                      numeric_value is not null
         inner join brs.project_details pd on pd.project_id = p.project_id
  where p.project_id = p_project_id
    and p.process_step_id in (3355)
    and p.main is true;

  if p_from_booking is true then
    select coalesce(v.int_value, pd.primary_financier)
    into v_primary_financier_booking
    from flow.project_process_step p
           left join flow.project_process_step_custom_field_value v
                     on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (460) and
                        int_value is not null
           inner join brs.project_details pd on pd.project_id = p.project_id
    where p.project_id = p_project_id
      and p.process_step_id in (4)
      and p.main is true;

    select coalesce(v.numeric_value, fd.desired_commission_amount)
    into v_desired_commission_amount_booking
    from flow.project_process_step p
           left join flow.project_process_step_custom_field_value v
                     on v.project_process_step_id = p.id and v.custom_field_group_assignment_id = 26943 and
                        numeric_value is not null
           inner join brs.financial_details fd on fd.project_id = p.project_id
    where p.project_id = p_project_id
      and p.process_step_id in (4)
      and p.main is true;

    select coalesce(v.int_value, fd.commission_strategy)
    into v_commission_strategy_id_booking
    from flow.project_process_step p
           left join flow.project_process_step_custom_field_value v
                     on v.project_process_step_id = p.id and
                        v.custom_field_group_assignment_id = 26944 and
                        int_value is not null
           inner join brs.financial_details fd on fd.project_id = p.project_id
    where p.project_id = p_project_id
      and p.process_step_id in (4)
      and p.main is true;

    select coalesce(v.numeric_value, pd.system_size)
    into v_system_size_booking
    from flow.project_process_step p
           left join flow.project_process_step_custom_field_value v
                     on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (40) and
                        numeric_value is not null
           inner join brs.project_details pd on pd.project_id = p.project_id
    where p.project_id = p_project_id
      and p.process_step_id in (4)
      and p.main is true;

    select coalesce(v.int_value, pd.loan_term)
    into v_loan_term_booking
    from flow.project_process_step p
           left join flow.project_process_step_custom_field_value v
                     on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (58) and
                        int_value is not null
           inner join brs.project_details pd on pd.project_id = p.project_id
    where p.project_id = p_project_id
      and p.process_step_id in (4)
      and p.main is true;

    select coalesce(v.numeric_value, pd.interest_rate)
    into v_interest_rate_booking
    from flow.project_process_step p
           left join flow.project_process_step_custom_field_value v
                     on v.project_process_step_id = p.id and v.custom_field_group_assignment_id in (48) and
                        numeric_value is not null
           inner join brs.project_details pd on pd.project_id = p.project_id
    where p.project_id = p_project_id
      and p.process_step_id in (4)
      and p.main is true;

  end if;

  if p_from_booking is false then
    return query
      select v_cancelled_date,
             coalesce(v_primary_financier_fdc, -1),
             coalesce(v_source_id, -1),
             coalesce(v_system_size_fdc, 0),
             coalesce(v_loan_term_fdc, -1),
             coalesce(v_interest_rate_fdc, 0),
             coalesce(v_desired_commission_amount_fdc, 0),
             coalesce(v_commission_strategy_id_fdc, 0);
  else
    return query
      select v_cancelled_date,
             coalesce(v_primary_financier_fdc, v_primary_financier_booking, -1),
             coalesce(v_source_id, -1),
             coalesce(v_system_size_fdc, v_system_size_booking, 0),
             coalesce(v_loan_term_fdc, v_loan_term_booking, -1),
             coalesce(v_interest_rate_fdc, v_interest_rate_booking, 0),
             coalesce(v_desired_commission_amount_fdc, v_desired_commission_amount_booking, 0),
             coalesce(v_commission_strategy_id_fdc, v_commission_strategy_id_booking, 0);
  end if;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


