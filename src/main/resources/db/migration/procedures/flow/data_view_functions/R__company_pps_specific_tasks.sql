drop function if exists flow.company_pps_specific_tasks(p_company_id bigint,
                                                        p_project_id bigint,
                                                        p_created_by_id bigint,
                                                        p_modified_by_id bigint);
-- flow.company_event_specific_tasks(bigint, integer, bigint, bigint, unknown, bigint, timestamp without time zone)
CREATE OR REPLACE FUNCTION flow.company_pps_specific_tasks(p_company_id bigint,
                                                           p_project_id bigint,
                                                           p_created_by_id bigint,
                                                           p_modified_by_id bigint)
  RETURNS void AS

$BODY$
declare
  elem                                 BIGINT;
  v_commission_plan_id                 bigint;
  v_status_type                        text;
  v_name                               text;
  v_financial_details_id               bigint;
  v_position_id                        bigint;
  v_partner_m1_amount                  numeric;
  v_partner_m2_amount                  numeric;
  v_partner_total_commissions          numeric;
  v_contact_id                         bigint;
  v_custom_adder_amount                numeric;
  v_selected_adder_amount              numeric;
  v_partner_commission_amount          numeric;
  v_financial_details_partner_id       bigint;
  v_project_id                         bigint;
  v_proposal_number_id_final_design_id bigint;
  v_proposal_number_id_booking         bigint;
  v_proposal_selected_adder_amount     numeric;
  v_proposal_custom_adder_amount       numeric;
  v_project_selected_adder_amount      numeric;
  v_project_custom_adder_amount        numeric;
  v_version_id                         bigint;
  v_auto_applied_adder_amount        numeric;
  v_desired_commission_adder     numeric;
  v_booking boolean;
BEGIN

  if p_company_id = 3 then
    select contact_id, p.id
    into v_contact_id,v_project_id
    from flow.project p
    where p.id = p_project_id
      and exists(select id
                 from flow.data_view dv
                 where dv.id = 2
                   and p.company_process_id = any (dv.company_process_ids));
    if v_project_id is not null then

      perform brs.insert_commissions_on_project(p_project_id);

      select proposal_number_id_final_design, proposal_number_id_booking
      into v_proposal_number_id_final_design_id,v_proposal_number_id_booking
      from brs.project_details pd
      where pd.project_id = p_project_id;

      if (v_proposal_number_id_booking is not null and v_proposal_number_id_final_design_id is null) or
         v_proposal_number_id_final_design_id is not null then

        select project_selected_adder_amount,
               project_custom_adder_amount,
               proposal_selected_adder_amount,
               proposal_custom_adder_amount,
               version_id,
               auto_applied_adder_amount,
               desired_commission_adder
        into v_project_selected_adder_amount,
          v_project_custom_adder_amount,
          v_proposal_selected_adder_amount,
          v_proposal_custom_adder_amount,
          v_version_id,
          v_auto_applied_adder_amount,
          v_desired_commission_adder
        from brs.get_adder_amounts(coalesce(v_proposal_number_id_final_design_id,v_proposal_number_id_booking));

        v_booking = null;
        select pc.is_booking
        into v_booking
        from brs.project_commission pc
        where pc.project_id = p_project_id;

        update brs.financial_details d
        set project_selected_adder_amount  = coalesce(v_project_selected_adder_amount,0),
            project_custom_adder_amount    = coalesce(v_project_custom_adder_amount,0),
            proposal_selected_adder_amount = coalesce(v_proposal_selected_adder_amount,0),
            proposal_custom_adder_amount   = coalesce(v_proposal_custom_adder_amount,0),
            proposal_version_id            = v_version_id,
            auto_applied_adder_amount = coalesce(v_auto_applied_adder_amount,0),
            commissions_earned_m1 = brs.get_commissions_earned(p_project_id,'M1',v_booking),
            commissions_earned_m2 = brs.get_commissions_earned(p_project_id,'M2'),
            overrides_earned_m1 = brs.get_overrides_earned(p_project_id,'M1'),
            overrides_earned_m2 = brs.get_overrides_earned(p_project_id,'M2'),
            total_overrides = brs.get_total_overrides_amount(p_project_id),
            total_commissions = brs.get_total_commissions_amount(p_project_id),
            desired_commission_adder =coalesce(v_desired_commission_adder,0)
        where d.project_id = p_project_id;


      end if;

      --       if v_financial_details_id is null then
--         insert into brs.financial_details(project_id, contact_id, company_id, date_modified)
--         values (p_project_id, v_contact_id, 3, now())
--         returning id into v_financial_details_id;
--       end if;

      FOREACH elem IN ARRAY coalesce(brs.get_partner_projects(p_project_id), ARRAY[]::bigint[])
        LOOP
          v_commission_plan_id = null;
          v_status_type = null;
          v_name = null;
          v_partner_m1_amount = 0::numeric;
          v_partner_m2_amount = 0::numeric;
          v_partner_total_commissions = 0::numeric;
          v_contact_id = null;
          v_financial_details_id = null;
          v_financial_details_partner_id = null;

          select fd.id
          into v_financial_details_id
          from brs.financial_details fd
                 inner join brs.financial_details_partner f on f.financial_details_id = fd.id
          where fd.project_id = p_project_id
            and f.org_id = elem;

          select cp.id, cp.name, cps.status_type, cp.position_id
          into v_commission_plan_id,v_name,v_status_type,v_position_id
          from brs.commission_plan cp
                 inner join brs.commission_plan_org cpo on cpo.commission_plan_id = cp.id and cpo.org_id = elem
                 left join brs.commission_plan_status cps on cps.id = cp.status_id
          where cpo.org_id = elem
            and cp.position_id in (743, 828);

          if v_commission_plan_id is not null then

            insert into brs.financial_details_partner(date_created, date_modified, created_by_id, modified_by_id,
                                                      archived,
                                                      partner_commissions_earned_m1, partner_commissions_earned_m2,
                                                      partner_total_commissions,
                                                      partner_commission_plan,
                                                      partner_commission_plan_id, partner_commission_plan_status,
                                                      financial_details_id, org_id, position_id,
                                                      custom_adder_amount,
                                                      selected_adder_amount,
                                                      base_commission_amount,
                                                      active)
            values (now(), now(), p_created_by_id, p_modified_by_id, false,
                    v_partner_m1_amount, v_partner_m2_amount, v_partner_total_commissions, v_name,
                    v_commission_plan_id,
                    v_status_type, v_financial_details_id, elem, v_position_id, v_custom_adder_amount,
                    v_selected_adder_amount, v_partner_commission_amount, true)
            ON CONFLICT on constraint org_id_financial_details_id_uniq
              DO UPDATE
              SET partner_commissions_earned_m1 = EXCLUDED.partner_commissions_earned_m1,
                  partner_commissions_earned_m2 = EXCLUDED.partner_commissions_earned_m2,
                  partner_total_commissions     = EXCLUDED.partner_total_commissions,
                  custom_adder_amount           = excluded.custom_adder_amount,
                  selected_adder_amount         = excluded.selected_adder_amount,
                  base_commission_amount        = excluded.base_commission_amount,
                  active                        = true
            returning id into v_financial_details_partner_id;
          end if;

          select m1_amount,
                 m2_amount,
                 total_commissions,
                 custom_adder_amount,
                 select_adder_amount,
                 partner_commission_amount
          into v_partner_m1_amount,v_partner_m2_amount,v_partner_total_commissions,v_custom_adder_amount,v_selected_adder_amount,v_partner_commission_amount
          from brs.get_partner_commissions_earned(p_project_id, elem);


          update brs.financial_details_partner fdp
          set partner_commissions_earned_m1 =v_partner_m1_amount,
              partner_commissions_earned_m2 =v_partner_m2_amount,
              partner_total_commissions     =v_partner_total_commissions,
              custom_adder_amount           = coalesce(v_custom_adder_amount, 0),
              selected_adder_amount         = coalesce(v_selected_adder_amount, 0),
              base_commission_amount        = coalesce(v_partner_commission_amount, 0)
          where fdp.id = v_financial_details_partner_id;

        end loop;
    end if;
  end if;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

