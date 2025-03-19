drop function if exists brs.get_partner_commissions_earned(p_project_ids bigint, p_org_id bigint);
CREATE OR REPLACE FUNCTION brs.get_partner_commissions_earned(p_project_id bigint, p_org_id bigint)
  RETURNS table(m1_amount numeric,m2_amount numeric,total_commissions numeric,custom_adder_amount numeric,select_adder_amount numeric,partner_commission_amount numeric) AS
$BODY$
DECLARE
  v_final_price                      numeric;
  v_financing_fees    numeric;
  v_source_fees numeric;
  v_partner_commission_amount numeric;
  v_selected_adder_amount numeric;
  v_partner_adder_cfga_ids bigint[];
  v_partner_dealer_custom_adder_cfga_ids bigint[];
  v_partner_installer_custom_adder_cfga_ids bigint[];
  v_custom_adder_installer_amount numeric;
  v_selected_adder_ids bigint[];
  v_custom_adder_dealer_amount numeric;
  v_total_fees numeric;
v_position_id bigint;
  v_cancelled_date date;
  v_m1_allocation numeric;
  v_m2_allocation numeric;
  v_final_design_complete_date date;
  v_substantial_completion_date date;
  v_ahj_final_inspection_verified date;
v_dealer_redline_amount numeric;
BEGIN

  select cp.position_id,fd.cancelled_date
into v_position_id,v_cancelled_date
  from brs.financial_details fd
         inner join brs.project_details pd on pd.project_id = fd.project_id
         inner join brs.financial_details_partner fdp on fdp.financial_details_id = fd.id and fdp.org_id = p_org_id
         inner join brs.commission_plan cp on cp.id = fdp.partner_commission_plan_id
where fd.project_id = p_project_id;




  select (select string_to_array(value, ',')  ---selected adders
          from flow.company_configuration_value
          where code = 'PARTNER_ADDER_CFGA')::bigint[]
  into v_partner_adder_cfga_ids;

if v_cancelled_date is null then
  SELECT ARRAY_AGG(DISTINCT unnested_value)
  into v_selected_adder_ids
  FROM (
         SELECT UNNEST(pcfv.int_array_value) AS unnested_value
         FROM flow.project_custom_field_value pcfv
         WHERE pcfv.project_id = p_project_id
           AND pcfv.custom_field_group_assignment_id = ANY(v_partner_adder_cfga_ids)
       ) subquery;

  if v_position_id = 743 then --dealer position

    select (select string_to_array(value, ',')  --- partner dealer custom adders
            from flow.company_configuration_value
            where code = 'PARTNER_DEALER_CUSTOM_ADDER_CFA_IDS')::bigint[]
    into v_partner_dealer_custom_adder_cfga_ids;

    SELECT sum(numeric_value)
    into v_custom_adder_dealer_amount
    FROM flow.project_custom_field_value pcfv
    WHERE pcfv.project_id = p_project_id
      AND pcfv.custom_field_group_assignment_id = ANY (v_partner_dealer_custom_adder_cfga_ids);

    select pd.total_system_price,
           pd.loan_amount*coalesce(pd.dealer_fee,0),
           case when cpsa.fee_type_id = 1 then cpsa.fee_amount * fd.system_size when cp.fee_type_id = 2 then cpsa.fee_amount end as source_fees, --perkw flat
           case when cp.fee_type_id = 1 then cp.partner_commission_amount * fd.system_size
                when cp.fee_type_id = 4 then pd.panel_quantity * cp.partner_commission_amount
                when cp.fee_type_id = 2 then cp.partner_commission_amount end as dealer_redline,
           ao.select_adder_amount,
           cpa.allocation,
           cpa1.allocation,
           pd.substantial_completion_date,
           pd.final_design_complete_date
    into v_final_price,v_financing_fees,v_source_fees,v_dealer_redline_amount,v_selected_adder_amount,
      v_m1_allocation,v_m2_allocation,v_substantial_completion_date,v_final_design_complete_date
    from brs.financial_details fd
          inner join brs.project_details pd on pd.project_id = fd.project_id
           inner join brs.financial_details_partner fdp on fdp.financial_details_id = fd.id and fdp.org_id = p_org_id
           inner join brs.commission_plan cp on cp.id = fdp.partner_commission_plan_id
           left join brs.commission_plan_allocation cpa on cpa.commission_plan_id = cp.id and cpa.milestone_id = 4 and cp.position_id = 743
          left join brs.commission_plan_allocation cpa1 on cpa1.commission_plan_id = cp.id and cpa1.milestone_id = 5 and cp.position_id = 743
           left join brs.commission_plan_source_allocation cpsa on cpsa.commission_plan_id = cp.id and cpsa.source_id = fd.source
           left join lateral (select sum(amount) as select_adder_amount from (select case when pcpa.fee_type_id = 1 then pcpa.fee_amount * pd.system_size when pcpa.fee_type_id = 4 then pd.panel_quantity * pcpa.fee_amount
                                                                                          when pcpa.fee_type_id = 2 then pcpa.fee_amount end as amount
                              from brs.partner_commission_plan_adder pcpa where pcpa.commission_plan_id = cp.id and pcpa.adder_id = any(v_selected_adder_ids))as foo) ao  on true
    where fd.project_id = p_project_id;
-- raise notice 'v_final_price %',v_final_price;
--     raise notice 'v_financing_fees %',v_financing_fees;
--     raise notice 'v_dealer_redline_amount %',v_dealer_redline_amount;
--     raise notice 'v_source_fees %',v_source_fees;
--     raise notice 'v_selected_adder_amount %',v_selected_adder_amount;
--     raise notice 'v_custom_adder_dealer_amount %',v_custom_adder_dealer_amount;
    v_total_fees = coalesce(v_final_price,0) - coalesce(v_financing_fees,0) - coalesce(v_dealer_redline_amount,0) - coalesce(v_source_fees,0) - coalesce(v_selected_adder_amount,0) - coalesce(v_custom_adder_dealer_amount,0);
    if v_substantial_completion_date is null then
      v_m2_allocation = 0;
    end if;
    if v_final_design_complete_date is null then
      v_m1_allocation = 0;
    end if;

  elsif  v_position_id = 828 then  --installer so I don't ask Carlin anymore

    select (select string_to_array(value, ',')  --- partner installer custom adders
            from flow.company_configuration_value
            where code = 'PARTNER_INSTALLER_CUSTOM_ADDER_CFA_IDS')::bigint[]
    into v_partner_installer_custom_adder_cfga_ids;

    SELECT sum(numeric_value)
    into v_custom_adder_installer_amount
    FROM flow.project_custom_field_value pcfv
    WHERE pcfv.project_id = p_project_id
      AND pcfv.custom_field_group_assignment_id = ANY (v_partner_installer_custom_adder_cfga_ids);

    --raise notice 'v_custom_adder_installer_amount %',v_custom_adder_installer_amount;

    select
           case when cp.fee_type_id = 1 then cp.partner_commission_amount * fd.system_size
                when cp.fee_type_id = 4 then pd.panel_quantity * cp.partner_commission_amount
                when cp.fee_type_id = 2 then cp.partner_commission_amount end as partner_commission_amount,
           ao.select_adder_amount,
           cpa.allocation,
           cpa1.allocation,
            pd.substantial_completion_date,
            pd.ahj_final_inspection_verified
    into v_partner_commission_amount,v_selected_adder_amount,
      v_m1_allocation,v_m2_allocation,v_substantial_completion_date,v_ahj_final_inspection_verified
    from brs.financial_details fd
           inner join brs.project_details pd on pd.project_id = fd.project_id
           inner join brs.financial_details_partner fdp on fdp.financial_details_id = fd.id and fdp.org_id = p_org_id
           inner join brs.commission_plan cp on cp.id = fdp.partner_commission_plan_id
           left join brs.commission_plan_allocation cpa on cpa.commission_plan_id = cp.id and cpa.milestone_id = 6 and cp.position_id = 828
           left join brs.commission_plan_allocation cpa1 on cpa1.commission_plan_id = cp.id and cpa1.milestone_id = 7 and cp.position_id = 828
           left join lateral (select sum(amount) as select_adder_amount from (select case when pcpa.fee_type_id = 1 then pcpa.fee_amount * pd.system_size when pcpa.fee_type_id = 4 then pd.panel_quantity * pcpa.fee_amount
                                                                                          when pcpa.fee_type_id = 2 then pcpa.fee_amount end as amount
                                                                              from brs.partner_commission_plan_adder pcpa where pcpa.commission_plan_id = cp.id and pcpa.adder_id = any(v_selected_adder_ids))as foo) ao  on true
    where fd.project_id = p_project_id;
   -- raise notice 'v_selected_adder_amount %',v_selected_adder_amount;
   -- raise notice 'v_partner_commission_amount %',v_partner_commission_amount;
    v_total_fees = coalesce(v_partner_commission_amount,0) + coalesce(v_selected_adder_amount,0) + coalesce(v_custom_adder_installer_amount,0);
   -- raise notice 'v_total_fees %',v_total_fees;
   -- raise notice 'v_substantial_completion_date %',v_substantial_completion_date;
   -- raise notice 'v_ahj_final_inspection_verified %',v_ahj_final_inspection_verified;
   -- raise notice 'v_m2_allocation %',v_m2_allocation;
    if v_substantial_completion_date is null then
      v_m1_allocation = 0;
    end if;
    if v_ahj_final_inspection_verified is null then
      v_m2_allocation = 0;
    end if;
  end if;



  return query select v_total_fees*coalesce(v_m1_allocation,0),v_total_fees*coalesce(v_m2_allocation,0), coalesce(v_total_fees, 0),coalesce(v_custom_adder_installer_amount,v_custom_adder_dealer_amount,0),coalesce(v_selected_adder_amount,0),coalesce(v_partner_commission_amount,0);
  else
  return query select 0::numeric,0::numeric,0::numeric,0::numeric,0::numeric,0::numeric;
  end if;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


