drop FUNCTION if exists brs.insert_commissions_on_project(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.insert_commissions_on_project(p_project_id bigint)
  RETURNS void
  LANGUAGE plpgsql
AS
$function$
declare
  v_override_plan_id      bigint;
  v_override_plan text;
  v_override_status text;
  v_commission_plan_id    bigint;
  v_commission_plan text;
  v_commission_status text;
  v_residual_plan_id      bigint;
  v_residual_plan text;
  v_residual_status text;
  v_user_id               bigint;
  v_company_feature_id    bigint;
  v_company_id            bigint;
  v_override_plan_found   bigint;
  v_commission_plan_found bigint;
  v_start_date            timestamp;
  v_found_user_on_plan    bigint;
v_found_user_residual     bigint;
BEGIN

  select rp.id,rp.name,rps.status_type
  into v_residual_plan_id,v_residual_plan,v_residual_status
  from brs.residual_plan rp
  left join brs.residual_plan_status rps on rps.id = rp.residual_plan_status_id
  where rp.default_plan is true;

  select min(ppscfv.date_value) milestone_one_complete_date
  into v_start_date
  from flow.project_process_step pps
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 1251
  where pps.process_step_id = 175
    and pps.project_id = p_project_id;

  select count(1)
  into v_override_plan_found
  from brs.project_override po
         inner join brs.override_plan op on po.override_plan_id = op.id and op.position_id = 1
  where project_id = p_project_id;

  select count(1)
  into v_commission_plan_found
  from brs.project_commission pc
         inner join brs.commission_plan cp on pc.commission_plan_id = cp.id and cp.position_id = 1
  where project_id = p_project_id;

  select pd.closer_user_id
  into v_user_id
  from brs.project_details pd
  where project_id = p_project_id;

  select c.company_id
  into v_company_id
  from flow.project p
         inner join flow.contact c on c.id = p.contact_id
  where p.id = p_project_id;

  select op.id,op.name,ops.status_type
  into v_override_plan_id,v_override_plan,v_override_status
  from brs.override_plan op
         left join brs.override_plan_status ops on ops.id = op.status_id
         inner join brs.override_plan_assigned_user opau
                    on opau.override_plan_id = op.id and opau.user_id = v_user_id
  where v_start_date >= opau.start_date
    and case
          when opau.end_date is not null then
            v_start_date <= opau.end_date
          else 1 = 1 end
    and op.position_id = 1;

  select cp.id,cp.name,cps.status_type
  into v_commission_plan_id,v_commission_plan,v_commission_status
  from brs.commission_plan cp
         inner join brs.commission_plan_user cpu on cpu.commission_plan_id = cp.id and cpu.user_id = v_user_id
         left join brs.commission_plan_status cps on cps.id = cp.status_id
  where v_start_date >= cpu.start_date
    and case
          when cpu.end_date is not null then
            v_start_date <= cpu.end_date
          else 1 = 1 end
    and cp.position_id = 1;

  if v_user_id is not null and v_commission_plan_id is not null and v_commission_plan_found < 1 then
    --delete from brs.project_commission where project_id = p_project_id;
    insert into brs.project_commission(project_id, commission_plan_id)
    values (p_project_id, v_commission_plan_id);

    update brs.financial_details
    set commission_plan_id = v_commission_plan_id,
        commission_plan = v_commission_plan,
        commission_plan_status = v_commission_status
    where project_id = p_project_id;

  else
    select cf.id
    into v_company_feature_id
    from flow.company_feature cf
           inner join flow.feature f on f.id = cf.feature_id
    where f.feature_code = 'COMMISSIONS'
      and cf.company_id = v_company_id;
    insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                       date_created, created_by_id)
    values (v_company_feature_id, 'Unable to assign Commission Plan to Project ' || p_project_id || '.', 1, now(),
            99999999);
  end if;

  if v_user_id is not null and v_override_plan_id is not null and v_override_plan_found < 1 then
    --delete from brs.project_override where project_id = p_project_id;
    insert into brs.project_override(project_id, override_plan_id)
    values (p_project_id, v_override_plan_id);

    update brs.financial_details d
    set override_plan_id = v_override_plan_id,
        override_plan = v_override_plan,
        override_plan_status = v_override_status
    where project_id = p_project_id;
  else

    select cf.id
    into v_company_feature_id
    from flow.company_feature cf
           inner join flow.feature f on f.id = cf.feature_id
    where f.feature_code = 'COMMISSIONS'
      and cf.company_id = v_company_id;
    insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                       date_created, created_by_id)
    values (v_company_feature_id, 'Unable to assign Override Plan to Project ' || p_project_id || '.', 1, now(),
            99999999);
  end if;


  if v_user_id is not null and v_residual_plan_id is not null then

    select count(1)
    into v_found_user_residual
    from brs.user_residual ur
    where user_id = v_user_id;

    if v_found_user_residual < 1 then
      insert into brs.user_residual(user_id, residual_plan_id, date_created, created_by_id, modified_by_id)
      values (v_user_id, v_residual_plan_id, now(), 99999999, 99999999);
    end if;

    update brs.financial_details d
    set residual_plan_id = v_residual_plan_id,
        residual_plan = v_residual_plan,
        residual_plan_status = v_residual_status
    where project_id = p_project_id;

    select count(1)
    into v_found_user_on_plan
    from brs.residual_plan_user rpu
    where user_id = v_user_id;

    if v_found_user_on_plan < 1 then
      insert into brs.residual_plan_user(residual_plan_id, user_id, start_date, end_date, note,
                                         date_created, created_by_id, date_modified, modified_by_id)
      values (v_residual_plan_id, v_user_id, now(), null, 'auto generated from insert_commission_on_project function',
              now(), 99999999, now(), 99999999);
    end if;
  elsif p_project_id is not null and v_user_id is not null then

    select cf.id
    into v_company_feature_id
    from flow.company_feature cf
           inner join flow.feature f on f.id = cf.feature_id
    where f.feature_code = 'COMMISSIONS'
      and cf.company_id = v_company_id;

    insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                       date_created, created_by_id)
    values (v_company_feature_id,
            'Unable to assign Residual Plan to Project  ' || p_project_id || 'and for User ID ' || v_user_id || '.', 1,
            now(),
            99999999);
  end if;


END;
$function$
