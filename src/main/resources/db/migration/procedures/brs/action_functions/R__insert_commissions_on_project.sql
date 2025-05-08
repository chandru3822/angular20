drop FUNCTION if exists brs.insert_commissions_on_project(p_project_id bigint);
drop FUNCTION if exists brs.insert_commissions_on_project(p_project_id bigint, bigint, boolean);
CREATE OR REPLACE FUNCTION brs.insert_commissions_on_project(p_project_id bigint, p_id bigint default null,
                                                             p_is_override boolean default false)
  RETURNS void
  LANGUAGE plpgsql
AS
$function$
declare
  v_is_booking boolean;
  v_hic_date date;
  v_fdc_date date;
  v_sc_date date;
  v_override_plan_id              bigint;
  v_override_plan                 text;
  v_override_status               text;
  v_commission_plan_id            bigint;
  v_commission_plan               text;
  v_commission_status             text;
  v_user_id                       bigint;
  v_company_feature_id            bigint;
  v_company_id                    bigint;
  v_override_plan_found           bigint;
  v_commission_plan_found         bigint;
  v_start_date                    timestamp;
  v_commission_strategy_id        bigint;
  v_cp_commission_strategy_id     bigint;
BEGIN

  select pd2.final_design_complete_date,
         pd2.installation_agreement_signed_date,
         pd2.substantial_completion_date,
         pd2.closer_user_id,
         pd2.company_id,
         fd2.commission_strategy
  into v_fdc_date,
    v_hic_date,
    v_sc_date,
    v_user_id,
    v_company_id,
    v_commission_strategy_id
  from brs.project_details pd2
         inner join brs.financial_details fd2 on fd2.project_id = pd2.project_id
  where pd2.project_id = p_project_id;

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

  if v_hic_date is not null then
    select op.id, op.name, ops.status_type
    into v_override_plan_id,v_override_plan,v_override_status
    from brs.override_plan op
           left join brs.override_plan_status ops on ops.id = op.status_id
           inner join brs.override_plan_assigned_user opau
                      on opau.override_plan_id = op.id and opau.user_id = v_user_id
    where case
            when p_is_override is true and p_id is not null then
              op.id = p_id
            when p_id is null then
              v_hic_date >= opau.start_date
                and case
                      when opau.end_date is not null then
                        v_hic_date <= opau.end_date
                      else 1 = 1 end
                and op.position_id = 1
            end;
  end if;

  select cp.id, cp.name, cps.status_type, cp.commission_strategy_type_id
  into v_commission_plan_id,v_commission_plan,v_commission_status,v_cp_commission_strategy_id
  from brs.commission_plan cp
         inner join brs.commission_plan_user cpu on cpu.commission_plan_id = cp.id and cpu.user_id = v_user_id
         left join brs.commission_plan_status cps on cps.id = cp.status_id
  where case
          when p_is_override is false and p_id is not null then
            cp.id = p_id
          when p_id is null then
            coalesce(v_fdc_date,v_hic_date, ((now() at time zone 'UTC') at time zone 'US/Mountain'))::date >= cpu.start_date
              and case
                    when cpu.end_date is not null then
                      coalesce(v_fdc_date,v_hic_date, ((now() at time zone 'UTC') at time zone 'US/Mountain'))::date <=
                      cpu.end_date
                    else 1 = 1 end
              and cp.position_id = 1
          end;

  --   if v_commission_strategy_id in (24102,24871) and v_cp_commission_strategy_id != 1 then
--     select cp.id, cp.name, cps.status_type
--     into v_commission_plan_id,v_commission_plan,v_commission_status
--     from brs.commission_plan cp
--            left join brs.commission_plan_status cps on cps.id = cp.status_id
--     where cp.id = 63;
--   end if;

  select is_booking
  into v_is_booking
  from brs.project_commission pc2
  where pc2.project_id = p_project_id;

  if v_user_id is not null and v_commission_plan_id is not null and v_commission_plan_found < 1 then

    insert into brs.project_commission(project_id, commission_plan_id, is_booking)
    values (p_project_id, v_commission_plan_id, case when v_fdc_date is null then true else null end);

    update brs.financial_details
    set commission_plan_id     = v_commission_plan_id,
        commission_plan        = v_commission_plan,
        commission_plan_status = v_commission_status
    where project_id = p_project_id;
  elsif v_user_id is not null and v_commission_plan_id is not null and v_commission_plan_found > 0 and
        v_is_booking is true then
    update brs.project_commission c
    set is_booking = case when v_fdc_date is not null then null else is_booking end,
        commission_plan_id = v_commission_plan_id
    where c.project_id = p_project_id;

    update brs.financial_details
    set commission_plan_id     = v_commission_plan_id,
        commission_plan        = v_commission_plan,
        commission_plan_status = v_commission_status
    where project_id = p_project_id;

  elsif p_project_id is not null and v_user_id is not null then
    select cf.id
    into v_company_feature_id
    from flow.company_feature cf
           inner join flow.feature f on f.id = cf.feature_id
    where f.feature_code = 'COMMISSIONS_CLOSER'
      and cf.company_id = v_company_id;
    insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                       date_created, created_by_id)
    values (v_company_feature_id, 'Unable to assign Commission Plan to Project ' || p_project_id || '.', 1, now(),
            99999999);
  end if;

  if v_hic_date is not null and v_user_id is not null and v_override_plan_id is not null and
     v_override_plan_found < 1 then

    insert into brs.project_override(project_id, override_plan_id)
    values (p_project_id, v_override_plan_id);

    update brs.financial_details d
    set override_plan_id     = v_override_plan_id,
        override_plan        = v_override_plan,
        override_plan_status = v_override_status
    where project_id = p_project_id;

  elsif v_start_date is not null and p_project_id is not null and v_user_id is not null then

    select cf.id
    into v_company_feature_id
    from flow.company_feature cf
           inner join flow.feature f on f.id = cf.feature_id
    where f.feature_code = 'COMMISSIONS_CLOSER'
      and cf.company_id = v_company_id;
    insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                       date_created, created_by_id)
    values (v_company_feature_id, 'Unable to assign Override Plan to Project ' || p_project_id || '.', 1, now(),
            99999999);
  end if;


  --   if v_start_date is not null then
--     with update_data as (select foo.project_id,
--                                 brs.get_commissions_earned(foo.project_id, 'M1') as commission_earned_m1,
--                                 brs.get_overrides_earned(foo.project_id, 'M1')   as overrides_earned_m1,
--                                 brs.get_commissions_earned(foo.project_id, 'M2') as commission_earned_m2,
--                                 brs.get_overrides_earned(foo.project_id, 'M2')   as overrides_earned_m2,
--                                 brs.get_total_commissions_amount(foo.project_id) as total_commissions,
--                                 brs.get_total_overrides_amount(foo.project_id)   as total_overrides
--                          from (select pd.project_id
--                                from brs.project_details pd
--                                where pd.final_design_complete_date is not null
--                                  and project_id = p_project_id) as foo)
--     update brs.financial_details pd
--     set commissions_earned_m1 = ud.commission_earned_m1,
--         overrides_earned_m1   = ud.overrides_earned_m1,
--         commissions_earned_m2 = ud.commission_earned_m2,
--         overrides_earned_m2   = ud.overrides_earned_m2,
--         total_commissions     = ud.total_commissions,
--         total_overrides       = ud.total_overrides
--     from update_data ud
--     where ud.project_id = pd.project_id;
--
--   else
--     with update_data as (select foo.project_id,
--                                 brs.get_commissions_earned(foo.project_id, 'M1',
--                                                            case
--                                                              when v_start_date is not null
--                                                                then false
--                                                              else true
--                                                              end)       as commission_earned_m1,
--                                 brs.get_total_commissions_amount(foo.project_id) as total_commissions
--                          from (select pd.project_id
--                                from brs.project_details pd
--                                where pd.final_design_complete_date is not null
--                                  and project_id = p_project_id) as foo)
--     update brs.financial_details pd
--     set commissions_earned_m1 = ud.commission_earned_m1,
--         total_commissions     = ud.total_commissions
--     from update_data ud
--     where ud.project_id = pd.project_id;
--   end if;
END;
$function$
