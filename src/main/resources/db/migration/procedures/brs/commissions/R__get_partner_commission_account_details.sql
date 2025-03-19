DROP FUNCTION IF EXISTS brs.get_partner_commission_account_details(bigint, BIGINT[], bigint, bigint, DATE, DATE, bigint);
/*MILESTONE 1 175 MILESTONE 2 35*/
CREATE OR REPLACE FUNCTION brs.get_partner_commission_account_details(p_payroll_id bigint,
                                                               p_project_ids BIGINT[],
                                                               p_contact_id bigint,
                                                               p_partner_org_id bigint,
                                                               p_cancel_start_date DATE,
                                                               p_cancel_end_date DATE,
                                                               p_commission_plan_id bigint)
  RETURNS TABLE
          (
            project_id                                  bigint,
            customer_id                                 bigint,
            customer_name                               VARCHAR,
            system_size                                 NUMERIC(10, 2),
            org_id                                      bigint,
            partner_org_name                            character varying,
            cancelled_date                              DATE,
            final_inspection_verified                   DATE,
            final_design_complete_date                   date,
            substantial_completion_date                 DATE,
            commission_plan                             TEXT,
            commission_plan_status                      TEXT,
            commission_plan_id                          bigint,
            total_commissions                           NUMERIC(10, 2),
            commission_earned                           NUMERIC(10, 2),
            commission_paid_to_date                     NUMERIC(10, 2),
            current_pay_commissions                     NUMERIC(10, 2),
            remaining_value_commissions                 NUMERIC(10, 2),
            project_total_value                         NUMERIC(10, 2),
            current_pay                                 NUMERIC(10, 2),
            position_id                                 bigint,
            selected_adder_amount                         numeric,
            custom_adder_amount                         numeric,
            base_commission                             numeric,
            panel_quantity                              bigint
          )
  LANGUAGE plpgsql
AS
$$
DECLARE
  v_is_show_all     BOOLEAN   :=
      p_project_ids IS NULL AND p_contact_id IS NULL AND
      p_partner_org_id IS NULL AND
      p_cancel_start_date IS NULL AND p_cancel_end_date IS NULL AND
      p_commission_plan_id IS NULL;
  --select * from blueraven.get_commission_account_details('2018-07-20',null,null,null,null,null,null,null,null);
  v_period_end_date date;
  v_amounts         numeric[] = '{.03}';
v_position_id  bigint;
BEGIN

  select period_end,p.position_id
  into v_period_end_date,v_position_id
  from brs.payroll p
  where id = p_payroll_id;


  RETURN QUERY
    select *
    from (SELECT pd.project_id::bigint                                                        as project_id,
                 pd.contact_id::bigint                                                as customer_id,
                 pd.project_name::character varying,
                 fd.system_size,
                 fdp.org_id::bigint                                                        as closer_user_id,
                 o.org_name as partner_org_name,
                 fd.cancelled_date                                                   as cancelled_date,
                 pd.ahj_final_inspection_verified as ahj_final_inspection_verified,
                 pd.final_design_complete_date,
                 fd.substantial_completion_date                                      as substantial_completion_date,
                 fdp.partner_commission_plan                                                  AS commission_plan,
                 fdp.partner_commission_plan_status                                           AS commission_plan_status,
                 fdp.partner_commission_plan_id                                               AS commission_plan_id,
                 coalesce(fdp.partner_total_commissions, 0)                                   AS total_commissions,
                 coalesce(fdp.partner_commissions_earned_m1, 0) + case
                                                           when v_position_id = 828 and pd.ahj_final_inspection_verified <= v_period_end_date then
                                                             coalesce(fdp.partner_commissions_earned_m2, 0)
                                                           when v_position_id = 743 and pd.substantial_completion_date <= v_period_end_date then
                                                             coalesce(fdp.partner_commissions_earned_m2, 0)
                                                           else
                                                             0::numeric end          AS commission_earned,
                 coalesce(fdp.partner_total_commissions_paid_to_date,0),
                 coalesce(fdp.partner_commissions_earned_m1, 0) + case
                                                                    when v_position_id = 828 and pd.ahj_final_inspection_verified <= v_period_end_date then
                                                                      coalesce(fdp.partner_commissions_earned_m2, 0)
                                                                    when v_position_id = 743 and pd.substantial_completion_date <= v_period_end_date then
                                                                      coalesce(fdp.partner_commissions_earned_m2, 0)
                                                                    else
                                                                      0::numeric end  - coalesce(fdp.partner_total_commissions_paid_to_date, 0)
                   AS current_pay_commissions,
                 case
                   when fd.cancelled_date is not null
                     then 0::numeric
                   else coalesce(fdp.partner_total_commissions, 0) -
                       ( coalesce(fdp.partner_commissions_earned_m1, 0) +case
                                                                           when v_position_id = 828 and pd.ahj_final_inspection_verified <= v_period_end_date then
                                                                             coalesce(fdp.partner_commissions_earned_m2, 0)
                                                                           when v_position_id = 743 and pd.substantial_completion_date <= v_period_end_date then
                                                                             coalesce(fdp.partner_commissions_earned_m2, 0)
                                                                           else
                                                                             0::numeric end)

                   end                                                               AS remaining_value_commissions,

                 coalesce(fdp.partner_total_commissions, 0)  AS project_total_value,
                 coalesce(fdp.partner_commissions_earned_m1, 0) + case
                                                                    when v_position_id = 828 and pd.ahj_final_inspection_verified <= v_period_end_date then
                                                                      coalesce(fdp.partner_commissions_earned_m2, 0)
                                                                    when v_position_id = 743 and pd.substantial_completion_date <= v_period_end_date then
                                                                      coalesce(fdp.partner_commissions_earned_m2, 0)
                                                                    else
                                                                      0::numeric end  - coalesce(fdp.partner_total_commissions_paid_to_date, 0)  as current_pay,
            cp.position_id,
            coalesce(fdp.selected_adder_amount,0::numeric),
                 coalesce(fdp.custom_adder_amount,0::numeric),
                 coalesce(fdp.base_commission_amount,0::numeric),
            pd.panel_quantity::bigint
          FROM brs.project_details pd
                 inner join brs.financial_details fd on fd.project_id = pd.project_id
                 inner join  brs.financial_details_partner fdp on fdp.financial_details_id = fd.id and (fdp.active is true or fdp.partner_total_commissions_paid_to_date > 0) and
                                                                  fdp.position_id = v_position_id
                 inner join brs.commission_plan cp on cp.id = fdp.partner_commission_plan_id
                 inner join flow.org o on o.id = fdp.org_id
                -- left join lateral brs.get_partner_ledger_adjustment_current_totals(p_payroll_id,pd.project_id,o.id, 4) la on true
          WHERE ((pd.on_hold_date is null) or (pd.on_hold_date is not null and off_hold_date is not null))
            and (case when v_position_id = 828 then fd.substantial_completion_date else fd.final_design_complete_date end <= v_period_end_date or
                 case when v_position_id = 828 then pd.ahj_final_inspection_verified else fd.substantial_completion_date end <= v_period_end_date)
            AND CASE
                  WHEN p_commission_plan_id IS NOT NULL
                    THEN fdp.partner_commission_plan_id = p_commission_plan_id
                  ELSE 1 = 1 END
            and CASE
                  WHEN p_project_ids IS NOT NULL
                    THEN pd.project_id = ANY (p_project_ids)
              else 1=1
                 END
            AND CASE
                  WHEN p_contact_id IS NOT NULL
                    THEN pd.contact_id = p_contact_id
                  ELSE 1 = 1 END
            AND CASE
                  WHEN p_partner_org_id IS NOT NULL
                    THEN p_partner_org_id = fdp.org_id
              ELSE 1 = 1 END
            AND CASE
                  WHEN p_cancel_start_date IS NOT NULL
                    THEN fd.cancelled_date::date BETWEEN p_cancel_start_date AND p_cancel_end_date
                  ELSE 1 = 1 END
          order by 3) as foo1
    where CASE
            WHEN p_project_ids IS NOT NULL
              THEN foo1.project_id = ANY (p_project_ids) else  abs((coalesce(foo1.current_pay_commissions, 0))) > any (v_amounts) end;
END
$$;
