CREATE OR REPLACE FUNCTION brs.insert_commissions_on_project(p_project_id integer)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_override_plan_id                 integer;
    v_commission_plan_id               integer;
    v_residual_plan_id                 integer;
    v_user_id                          integer;
    v_company_feature_id               integer;
    v_company_id                       integer;
    v_custom_field_group_assignment_id integer;
    v_override_plan_found              bigint;
    v_commission_plan_found             bigint;
BEGIN


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

    select op.id
    into v_override_plan_id
    from brs.override_plan op
             inner join brs.override_plan_assigned_user opau
                        on opau.override_plan_id = op.id and opau.user_id = v_user_id
    where (now() AT TIME ZONE 'US/Mountain') >= opau.start_date
      and case
              when opau.end_date is not null then
                  (now() AT TIME ZONE 'US/Mountain') <= opau.end_date
              else 1 = 1 end
    and op.position_id = 1;

    select cp.id
    into v_commission_plan_id
    from brs.commission_plan cp
             inner join brs.commission_plan_user cpu on cpu.commission_plan_id = cp.id and cpu.user_id = v_user_id
    where (now() AT TIME ZONE 'US/Mountain') >= cpu.start_date
      and case
              when cpu.end_date is not null then
                  (now() AT TIME ZONE 'US/Mountain') <= cpu.end_date
              else 1 = 1 end
    and cp.position_id = 1;

    --     select rp.id
--     into v_residual_plan_id
--     from brs.residual_plan rp
--              inner join brs.residual_plan_user rpu on rpu.residual_plan_id = rp.id and rpu.user_id = v_user_id
--     where (now() AT TIME ZONE 'US/Mountain') >= rpu.start_date and case when rpu.end_date is not null then
--                                                                                 (now() AT TIME ZONE 'US/Mountain') <= rpu.end_date else 1=1 end;


--    delete from brs.project_residual where project_id = p_project_id;

    if v_user_id is not null and v_commission_plan_id is not null and v_commission_plan_found < 1 then
        --delete from brs.project_commission where project_id = p_project_id;
        insert into brs.project_commission(project_id, commission_plan_id)
        values (p_project_id, v_commission_plan_id);
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
    --         insert into brs.project_residual( project_id, residual_plan_id)
--         values (p_project_id,v_residual_plan_id);

END;
$function$
