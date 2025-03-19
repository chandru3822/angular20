drop function if exists flow.company_pcfv_specific_tasks(p_project_id bigint, p_company_id bigint,
                                                         p_new_org_id bigint, p_old_org_id bigint);
CREATE OR REPLACE FUNCTION flow.company_pcfv_specific_tasks(p_project_id bigint, p_company_id bigint,
                                                            p_new_org_id bigint, p_old_org_id bigint)
  RETURNS void AS

$BODY$
DECLARE
  v_financial_details_id         bigint;
  v_financial_details_partner_id bigint;
  v_partner_m1_amount            numeric;
  v_partner_m2_amount            numeric;
  v_partner_total_commissions    numeric;
  v_position_id                  bigint;
  v_commission_plan_id           bigint;
  v_commission_plan              text;
  v_commission_status            text;
  v_cp_commission_strategy_id    bigint;
  v_company_feature_id           bigint;
  v_partner_commission_amount    numeric;
  v_selected_adder_amount        numeric;
  v_custom_adder_amount          numeric;
  v_project_id                   bigint;
BEGIN

  --13868,  dealer
  --13876,  ip
  if p_company_id = 3 then

    select p2.id
    into v_project_id
    from flow.project p2
    where p2.id = p_project_id
      and exists (select id
                  from flow.data_view dv
                  where dv.id = 2 and p2.company_process_id = any (dv.company_process_ids));
    if v_project_id is not null then
      if (p_old_org_id is not null and p_new_org_id is null) or
         (p_old_org_id is not null and p_new_org_id is not null and p_old_org_id != p_new_org_id) then

        select fd.id, p.id
        into v_financial_details_id,v_financial_details_partner_id
        from brs.financial_details fd
               inner join brs.financial_details_partner p on p.financial_details_id = fd.id and
                                                             p.position_id in (743, 828) and
                                                             p.org_id = p_old_org_id
        where fd.project_id = p_project_id;

        update brs.financial_details_partner fdp2
        set active                        = false,
            partner_commissions_earned_m1 = 0::numeric,
            partner_commissions_earned_m2 = 0::numeric,
            partner_total_commissions     = 0::numeric,
            base_commission_amount = 0::numeric,
            custom_adder_amount = 0::numeric,
            selected_adder_amount = 0::numeric
        where fdp2.id = v_financial_details_partner_id;
      end if;
      v_financial_details_id = null;
      v_financial_details_partner_id = null;
      if (p_old_org_id is null and p_new_org_id is not null) or
         (p_old_org_id is not null and p_new_org_id is not null and p_old_org_id != p_new_org_id) then

        select fd.id, p.id
        into v_financial_details_id,v_financial_details_partner_id
        from brs.financial_details fd
               inner join brs.financial_details_partner p on p.financial_details_id = fd.id and
                                                             p.position_id in (743, 828) and
                                                             p.org_id = p_new_org_id
        where fd.project_id = p_project_id;

        if v_financial_details_id is null then
          select fd.id
          into v_financial_details_id
          from brs.financial_details fd
          where fd.project_id = p_project_id;
        end if;


        select cp.id, cp.name, cps.status_type, cp.commission_strategy_type_id, cp.position_id
        into v_commission_plan_id,v_commission_plan,v_commission_status,v_cp_commission_strategy_id,v_position_id
        from brs.commission_plan cp
               inner join brs.commission_plan_org cpo on cpo.commission_plan_id = cp.id and cpo.org_id = p_new_org_id
               left join brs.commission_plan_status cps on cps.id = cp.status_id
        where cpo.end_date is null
          and cp.position_id in (743, 828);

        if v_commission_plan_id is not null then

          insert into brs.financial_details_partner(date_created, date_modified, created_by_id, modified_by_id,
                                                    archived,
                                                    partner_commission_plan, partner_commission_plan_id,
                                                    partner_commission_plan_status,
                                                    financial_details_id, org_id, position_id,active)
          values (now(), now(), 99999999, 99999999, false, v_commission_plan, v_commission_plan_id,
                  v_commission_status, v_financial_details_id, p_new_org_id, v_position_id,true)
          ON CONFLICT on constraint org_id_financial_details_id_uniq
            DO UPDATE
            SET partner_commission_plan = EXCLUDED.partner_commission_plan,
                active = true
          returning id into v_financial_details_partner_id;

          v_partner_m1_amount = 0;
          v_partner_total_commissions = 0;
          v_partner_m2_amount = 0;
          select m1_amount,
                 m2_amount,
                 total_commissions,
                 custom_adder_amount,
                 select_adder_amount,
                 partner_commission_amount
          into v_partner_m1_amount,v_partner_m2_amount,v_partner_total_commissions,v_custom_adder_amount,v_selected_adder_amount,v_partner_commission_amount
          from brs.get_partner_commissions_earned(p_project_id, p_new_org_id);

          update brs.financial_details_partner fdp
          set partner_commissions_earned_m1 =v_partner_m1_amount,
              partner_commissions_earned_m2 =v_partner_m2_amount,
              partner_total_commissions     =v_partner_total_commissions,
              custom_adder_amount           = coalesce(v_custom_adder_amount, 0),
              selected_adder_amount         = coalesce(v_selected_adder_amount, 0),
              base_commission_amount        = coalesce(v_partner_commission_amount, 0)
          where fdp.id = v_financial_details_partner_id;

        else
          select cf.id
          into v_company_feature_id
          from flow.company_feature cf
                 inner join flow.feature f on f.id = cf.feature_id
          where f.feature_code = 'COMMISSIONS_CLOSER'
            and cf.company_id = p_company_id;
          insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                             date_created, created_by_id)
          values (v_company_feature_id,
                  'Unable to assign Partner Commission Plan to Project ' || p_project_id || ' and org_id: ' ||
                  p_new_org_id, 1,
                  now(),
                  99999999);

        end if;
      end if;
    end if;
  end if;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
