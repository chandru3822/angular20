CREATE OR REPLACE FUNCTION brs.get_calculated_proposal_values(
  p_proposal_id integer)
  returns void
  --   RETURNS TABLE
--           (
--             field_id integer,
--             field_name   character varying,
--             data_type_id integer,
--             value        text,
--             intValue     integer,
--             object_code  character varying
--           )
AS
$BODY$
declare
  v_version_id                              integer;
  v_project_process_step_id                 integer;
  v_estimated_annual_energy_consumption_kwh integer;
  v_first_year_production_estimate          integer;
  v_friends_and_family                      boolean;
  v_system_size                             numeric;
  v_production_factor                       numeric;
  v_funding_range                           numeric;
  v_production_factor_range                 numeric;
  v_points_off_south_production_factor      numeric;
  v_price_change_per_production_point       numeric;
  v_calculated_price_adjustment             numeric;
  v_max_price_adjustment                    numeric;
  v_adjusted_price_per_wat                  numeric;
  v_initial_system_cost                     numeric;
  v_promotion_cost                          numeric;
  v_equipment_inverter_adder                numeric;
  v_equipment_panel_adder                   numeric;
  v_equipment_storage_adder                 numeric;
  v_misc_adders                             numeric;
  v_panel_brand_id                          integer;
  v_panel_watts                             integer;
  v_above_line_rebate                       numeric;
  v_state_id                                integer;
  v_utility_company_id                      integer;
  v_oregon_rebate                           numeric;
  v_colorado_rebate                         numeric;
  v_total_loan_amount                       numeric;
  v_down_payment_amount                     numeric;
  v_total_system_cost_amount                numeric;
  v_panel_degradation_factor                numeric;
  v_federal_tax_incentive_rate              numeric;
  v_federal_tax_incentive_amount            numeric;
  v_monthly_solar_payment                   numeric;
BEGIN
  select proposal_version_id, prop.project_process_step_id,coalesce(pcfv3.boolean_value,false),
         coalesce(pcfv4.numeric_value,0)
  into v_version_id,v_project_process_step_id,v_friends_and_family,v_down_payment_amount
  from brs.proposal prop
  left join brs.proposal_custom_field_value pcfv3 on prop.id = pcfv3.proposal_id and
                                                     pcfv3.custom_field_group_assignment_id = 169
  left join brs.proposal_custom_field_value pcfv4 on prop.id = pcfv4.proposal_id and
                                                     pcfv4.custom_field_group_assignment_id = 134
  where prop.id = p_proposal_id;


  select ppscfv.int_value, ppscfv2.int_value, ppscfv3.numeric_value, ppscfv4.int_value,ppscfv5.int_value,cs.state_id,pd.utility_company
  into
    v_estimated_annual_energy_consumption_kwh,
    v_first_year_production_estimate,
    v_system_size,
    v_panel_watts,
    v_panel_brand_id,
    v_state_id,
    v_utility_company_id
  from flow.project_process_step pps
        inner join flow.project p on pps.project_id = p.id
        inner join flow.company_state cs on p.company_state_id = cs.id
        inner join brs.project_details pd on pd.project_id = p.id
         left join flow.project_process_step_custom_field_value ppscfv on pps.id = ppscfv.project_process_step_id and
                                                                          ppscfv.custom_field_group_assignment_id =
                                                                          22573
         left join flow.project_process_step_custom_field_value ppscfv2 on ppscfv2.project_process_step_id = pps.id and
                                                                           ppscfv2.custom_field_group_assignment_id =
                                                                           22563
         left join flow.project_process_step_custom_field_value ppscfv3 on ppscfv3.project_process_step_id = pps.id and
                                                                           ppscfv3.custom_field_group_assignment_id =
                                                                           22561
         left join flow.project_process_step_custom_field_value ppscfv4 on ppscfv4.project_process_step_id = pps.id and
                                                                           ppscfv4.custom_field_group_assignment_id =
                                                                           22675
         left join flow.project_process_step_custom_field_value ppscfv5 on ppscfv5.project_process_step_id = pps.id and
                                                                           ppscfv5.custom_field_group_assignment_id =
                                                                           22564
  where pps.id = v_project_process_step_id;

  --   raise notice 'v_estimated_annual_energy_consumption_kwh = %',v_estimated_annual_energy_consumption_kwh;
--   raise notice 'v_first_year_production_estimate = %',v_first_year_production_estimate;
--   raise notice 'v_system_size = %',v_system_size;
  create temp table proposal_value as (
    with version_values as (
      select distinct on ( vw.proposal_group_uuid, vw.custom_field_group_assignment_id ) vw.id,
                                                                                         vw.custom_field_group_assignment_id,
                                                                                         vw.proposal_group_uuid,
                                                                                         vw.proposal_version_id,
                                                                                         vw.value,
                                                                                         vw.object_code,
                                                                                         vw.field_id,
                                                                                         vw.field_code,
                                                                                         vw.field_name,
                                                                                         vw.modified_by_id,
                                                                                         vw.modified_by,
                                                                                         vw.date_modified
      from brs.proposal_version_custom_field_value_vw vw
      where vw.proposal_version_id <= v_version_id
      order by vw.proposal_group_uuid, vw.custom_field_group_assignment_id, vw.id desc),
         proposal_finance_product as (select pcfv.int_value
                                      from brs.proposal prop
                                             inner join brs.proposal_custom_field_value pcfv
                                                        on prop.id = pcfv.proposal_id and
                                                           pcfv.custom_field_group_assignment_id = 155
                                      where prop.id = p_proposal_id),
         group_uuid_finance_product as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join proposal_finance_product pfp on (vv.value ->> 'intValue')::integer = pfp.int_value
           where vv.object_code = 'PROPOSAL_FINANCE_PRODUCTS' and vv.field_id = 128
             and vv.proposal_version_id = v_version_id),
         finance_product_company_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  (vv2.value ->> 'intValue')::text as intValue,
                  vv2.object_code
           from version_values vv2
                  inner join group_uuid_finance_product g on g.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         utility_company as (select p.id as project_id,
                                    pps.id,
                                    pd.utility_company,
                                    pd.utility_company_name
                             from brs.proposal p
                                    inner join flow.project_process_step pps
                                               on pps.id = p.project_process_step_id
                                    inner join flow.project proj on pps.project_id = proj.id
                                    inner join brs.project_details pd on pd.project_id = proj.id
                             where p.id = p_proposal_id),
         group_uuid_utility as (
           select vv.proposal_group_uuid, uc.utility_company
           from version_values vv
                  inner join utility_company uc on (vv.value ->> 'intValue')::integer = uc.utility_company
           where vv.object_code = 'PROPOSAL_PRICING' and vv.field_id = 85
             and vv.proposal_version_id = v_version_id),
         utility_company_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_name,
                  cdt.data_type_id,
                  g.utility_company,
                  (vv2.value ->> 'value')::text    as value,
                  vv2.object_code,
                  vv2.field_id,
                  (vv2.value ->> 'intValue')::text as int_value
           from version_values vv2
                  inner join group_uuid_utility g on g.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         financier as (select fpcr.field_id, fpcr.intvalue
                       from finance_product_company_results fpcr),
         group_uuid_financier as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join financier f on (vv.value ->> 'intValue')::integer = f.intvalue::integer
             and vv.field_id = 102
           where vv.object_code = 'PROPOSAL_FINANCIERS'
             and vv.proposal_version_id = v_version_id),
         financier_company_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  vv2.object_code,
                  (vv2.value ->> 'intValue')::text as int_value
           from version_values vv2
                  inner join group_uuid_financier g1 on g1.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         zone_adders as (select p.postal_code
                         from brs.proposal prop
                                inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
                                inner join flow.project p on pps.project_id = p.id
                         where prop.id = p_proposal_id
         ),
         group_uuid_zone as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join zone_adders za on (vv.value ->> 'value')::jsonb ?& array [za.postal_code]
           where vv.object_code = 'PROPOSAL_ZONE_ADDERS' and vv.field_id = 122
             and vv.proposal_version_id = v_version_id),
         zone_adder_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  vv2.object_code,
                  (vv2.value ->> 'intValue')::text as int_value
           from version_values vv2
                  inner join group_uuid_zone g1 on g1.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         group_uuid_federal_rebate as (
           select vv.proposal_group_uuid
           from version_values vv
           where vv.object_code = 'PROPOSAL_REBATE'
             and (vv.value ->> 'intValue')::integer = 453
             and vv.custom_field_group_assignment_id = 96
             and vv.proposal_version_id = v_version_id),
         federal_rebate_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  vv2.object_code,
                  (vv2.value ->> 'intValue')::text as int_value
           from version_values vv2
                  inner join group_uuid_federal_rebate g1 on g1.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         state_rebate as (select cs.state_id
                          from brs.proposal prop
                                 inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
                                 inner join flow.project p on pps.project_id = p.id
                                 inner join flow.company_state cs on cs.id = p.company_state_id
                          where prop.id = p_proposal_id
         ),
         group_uuid_state_rebate as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join state_rebate sr on (vv.value ->> 'intValue')::integer = sr.state_id
           where vv.object_code = 'PROPOSAL_REBATE' and vv.field_id = 86
             and vv.proposal_version_id = v_version_id),
         state_rebate_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  vv2.object_code,
                  (vv2.value ->> 'intValue')::text as int_value
           from version_values vv2
                  inner join group_uuid_state_rebate g1 on g1.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         utility_rebate as (select cs.state_id
                            from brs.proposal prop
                                   inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
                                   inner join flow.project p on pps.project_id = p.id
                                   inner join flow.company_state cs on cs.id = p.company_state_id
                            where prop.id = p_proposal_id
         ),
         group_uuid_utility_rebate as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join utility_company_results sr on (vv.value ->> 'intValue')::integer = sr.utility_company
           where vv.object_code = 'PROPOSAL_REBATE'
             and vv.proposal_version_id = v_version_id),
         utility_rebate_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  vv2.object_code,
                  (vv2.value ->> 'intValue')::text as int_value
           from version_values vv2
                  inner join group_uuid_utility_rebate g1 on g1.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         equipment_type_inverter as (select ppscfv.int_value
                                     from brs.proposal prop
                                            inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
                                            inner join flow.project_process_step_custom_field_value ppscfv
                                                       on pps.id = ppscfv.project_process_step_id and
                                                          ppscfv.custom_field_group_assignment_id = 22565
                                     where prop.id = p_proposal_id),
         group_uuid_equipment_type_inverter as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join equipment_type_inverter eti on (vv.value ->> 'intValue')::integer = eti.int_value
           where vv.object_code = 'PROPOSAL_EQUIPMENT_ADDERS' and vv.field_id = 131
             and vv.proposal_version_id = v_version_id),
         equipment_type_inverter_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  (vv2.value ->> 'intValue')::text as intValue,
                  vv2.object_code
           from version_values vv2
                  inner join group_uuid_equipment_type_inverter g on g.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         equipment_type_panel as (select ppscfv.int_value
                                  from brs.proposal prop
                                         inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
                                         inner join flow.project_process_step_custom_field_value ppscfv
                                                    on pps.id = ppscfv.project_process_step_id and
                                                       ppscfv.custom_field_group_assignment_id = 22564
                                  where prop.id = p_proposal_id),
         group_uuid_equipment_type_panel as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join equipment_type_panel etp on (vv.value ->> 'intValue')::integer = etp.int_value
           where vv.object_code = 'PROPOSAL_EQUIPMENT_ADDERS' and vv.field_id = 130
             and vv.proposal_version_id = v_version_id),
         equipment_type_panel_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  (vv2.value ->> 'intValue')::text as intValue,
                  vv2.object_code
           from version_values vv2
                  inner join group_uuid_equipment_type_panel g on g.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         equipment_type_storage as (select pcfv2.int_value,
                                           prop.proposal_version_id
                                    from brs.proposal prop
                                           inner join brs.proposal_custom_field_value pcfv2
                                                      on pcfv2.proposal_id = prop.id
                                                        and pcfv2.custom_field_group_assignment_id = 137 and
                                                         pcfv2.int_value = 509
                                    where prop.id = p_proposal_id),
         group_uuid_equipment_type_storage as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join equipment_type_storage ets on vv.proposal_version_id = ets.proposal_version_id
           where vv.object_code = 'PROPOSAL_EQUIPMENT_ADDERS'
             and (vv.value ->> 'intValue')::integer = 485::integer
             and vv.custom_field_group_assignment_id = 118),
         equipment_type_storage_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  (vv2.value ->> 'intValue')::text as intValue,
                  vv2.object_code
           from version_values vv2
                  inner join group_uuid_equipment_type_storage g on g.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         proposal_misc_adders as (select pcfv.int_array_value, prop.proposal_version_id
                                  from brs.proposal prop
                                         inner join brs.proposal_custom_field_value pcfv on prop.id = pcfv.proposal_id
                                    and pcfv.custom_field_group_assignment_id = 146
                                  where prop.id = p_proposal_id
         ),
         group_uuid_prop_misc as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join proposal_misc_adders pma on pma.proposal_version_id = vv.proposal_version_id
           where vv.object_code = 'PROPOSAL_MISC_ADDERS'
             and vv.custom_field_group_assignment_id = 145
             and (vv.value ->> 'intValue')::integer = any (pma.int_array_value)),
         proposal_misc_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  vv2.object_code,
                  (vv2.value ->> 'intValue')::text as int_value
           from version_values vv2
                  inner join group_uuid_prop_misc g1 on g1.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         source_adders as (select p.id as project_id,
                                  pps.id,
                                  pd.source,
                                  pd.source_name
                           from brs.proposal p
                                  inner join flow.project_process_step pps
                                             on pps.id = p.project_process_step_id
                                  inner join flow.project proj on pps.project_id = proj.id
                                  inner join brs.project_details pd on pd.project_id = proj.id
                           where p.id = p_proposal_id),
         group_uuid_source_adders as (
           select vv.proposal_group_uuid, sa.source
           from version_values vv
                  inner join source_adders sa on (vv.value ->> 'intValue')::integer = sa.source
           where vv.object_code = 'PROPOSAL_SOURCE_STATE_ADDERS' and vv.field_id = 121
             and vv.proposal_version_id = v_version_id),
         source_adder_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  g.source,
                  (vv2.value ->> 'value')::text    as value,
                  vv2.object_code,
                  (vv2.value ->> 'intValue')::text as int_value
           from version_values vv2
                  inner join group_uuid_source_adders g on g.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         small_system_adders as (select p.id as proposal_id,
                                        p.proposal_version_id
                                 from brs.proposal p
                                 where p.id = p_proposal_id),
         group_uuid_small_system_adders as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join small_system_adders ssa on vv.proposal_version_id = ssa.proposal_version_id
           where vv.object_code = 'PROPOSAL_SMALL_SYSTEM_ADDERS'),
         small_system_adder_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  vv2.object_code,
                  (vv2.value ->> 'intValue')::text as int_value
           from version_values vv2
                  inner join group_uuid_small_system_adders g on g.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
         other_adders as (
           select cf.id as field_id, pcfv1.text_value, pcfv2.numeric_value, cf.field_name
           from brs.proposal prop
                  inner join brs.proposal_custom_field_value pcfv1 on pcfv1.proposal_id = prop.id
             and pcfv1.custom_field_group_assignment_id = 165
                  inner join brs.custom_field_group_assignment cfga on cfga.id = pcfv1.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cfga.custom_field_id = cf.id
                  inner join brs.proposal_custom_field_value pcfv2 on pcfv2.proposal_id = prop.id
             and pcfv2.custom_field_group_assignment_id = 167
           where prop.id = p_proposal_id
         ),
         proposal_panel_detail as (select prop.proposal_version_id
                                  from brs.proposal prop
                                  where prop.id = p_proposal_id
         ),
         group_uuid_proposal_panel_detail as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join proposal_panel_detail ppd on ppd.proposal_version_id = vv.proposal_version_id and
                                     (vv.value ->> 'intValue')::integer =v_panel_brand_id and vv.custom_field_group_assignment_id = 170
           where vv.object_code = 'PROPOSAL_PANEL_DETAIL' and vv.field_id = 138),
         group_uuid_proposal_panel_watts_detail as (
           select vv.proposal_group_uuid
           from version_values vv
                  inner join group_uuid_proposal_panel_detail guppd on guppd.proposal_group_uuid = vv.proposal_group_uuid
                              and (vv.value ->> 'value')::integer =v_panel_watts and vv.custom_field_group_assignment_id = 171
           where vv.object_code = 'PROPOSAL_PANEL_DETAIL' and vv.field_id = 139
         ),
         proposal_panel_detail_results as (
           select vv2.proposal_group_uuid,
                  vv2.field_id,
                  vv2.field_name,
                  cdt.data_type_id,
                  (vv2.value ->> 'value')::text    as value,
                  vv2.object_code,
                  (vv2.value ->> 'intValue')::text as int_value
           from version_values vv2
                  inner join group_uuid_proposal_panel_watts_detail g1 on g1.proposal_group_uuid = vv2.proposal_group_uuid
                  inner join brs.custom_field cf on cf.id = vv2.field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id)

         select ucr.proposal_group_uuid,
           ucr.field_id,
           ucr.field_name,
           ucr.data_type_id,
           ucr.value,
           ucr.utility_company::integer,
           ucr.object_code,
           ucr.int_value
    from utility_company_results ucr
    union
    select fcr.proposal_group_uuid,
           fcr.field_id,
           fcr.field_name,
           fcr.data_type_id,
           fcr.value,
           null::integer,
           fcr.object_code,
           fcr.int_value
    from financier_company_results fcr
    union
    select fpcr.proposal_group_uuid,
           fpcr.field_id,
           fpcr.field_name,
           fpcr.data_type_id,
           fpcr.value,
           fpcr.intValue::integer,
           fpcr.object_code,
           fpcr.intValue
    from finance_product_company_results fpcr
    union
    select zar.proposal_group_uuid,
           zar.field_id,
           zar.field_name,
           zar.data_type_id,
           zar.value,
           null::integer,
           zar.object_code,
           zar.int_value
    from zone_adder_results zar
    union
    select frr.proposal_group_uuid,
           frr.field_id,
           frr.field_name,
           frr.data_type_id,
           frr.value,
           null::integer,
           frr.object_code,
           frr.int_value
    from federal_rebate_results frr
    union
    select srr.proposal_group_uuid,
           srr.field_id,
           srr.field_name,
           srr.data_type_id,
           srr.value,
           null::integer,
           srr.object_code,
           srr.int_value
    from state_rebate_results srr
    union
    select urr.proposal_group_uuid,
           urr.field_id,
           urr.field_name,
           urr.data_type_id,
           urr.value,
           null::integer,
           urr.object_code,
           urr.int_value
    from utility_rebate_results urr
    union
    select etir.proposal_group_uuid,
           etir.field_id,
           etir.field_name,
           etir.data_type_id,
           etir.value,
           null::integer,
           etir.object_code,
           etir.intValue
    from equipment_type_inverter_results etir
    union
    select etpr.proposal_group_uuid,
           etpr.field_id,
           etpr.field_name,
           etpr.data_type_id,
           etpr.value,
           null::integer,
           etpr.object_code,
           etpr.intValue
    from equipment_type_panel_results etpr
    union
    select etpsr.proposal_group_uuid,
           etpsr.field_id,
           etpsr.field_name,
           etpsr.data_type_id,
           etpsr.value,
           null::integer,
           etpsr.object_code,
           etpsr.intValue
    from equipment_type_storage_results etpsr
    union
    select pmr.proposal_group_uuid,
           pmr.field_id,
           pmr.field_name,
           pmr.data_type_id,
           pmr.value,
           null::integer,
           pmr.object_code,
           pmr.int_value
    from proposal_misc_results pmr
    union
    select sar.proposal_group_uuid,
           sar.field_id,
           sar.field_name,
           sar.data_type_id,
           sar.value,
           null::integer,
           sar.object_code,
           sar.int_value
    from source_adder_results sar
    union
    select ssar.proposal_group_uuid,
           ssar.field_id,
           ssar.field_name,
           ssar.data_type_id,
           ssar.value,
           null::integer,
           ssar.object_code,
           ssar.int_value
    from small_system_adder_results ssar
    union
    select ppdr.proposal_group_uuid,
           ppdr.field_id,
           ppdr.field_name,
           ppdr.data_type_id,
           ppdr.value,
           null::integer,
           ppdr.object_code,
           ppdr.int_value
    from proposal_panel_detail_results ppdr
    union
    select null::uuid,
           oa.field_id,
           oa.field_name,
           3::integer,
           oa.numeric_value::text,
           null::integer,
           'OTHER_ADDERS',
           null::text
    from other_adders oa
    order by 7, 1);

  create index pv_proposal_group_uuid on proposal_value (proposal_group_uuid);
  create index pv_field_id on proposal_value (field_id);
  create index pv_field_name on proposal_value (field_name);
  create index pv_data_type_id on proposal_value (data_type_id);
  create index pv_value on proposal_value (value);
  create index pv_int_value on proposal_value (int_value);
  create index pv_object_code on proposal_value (object_code);

--call first formula
   select value::numeric
   into v_panel_degradation_factor
   from proposal_value
   where field_id = 136 and
         object_code = 'PROPOSAL_PANEL_DETAIL';

  with federal as (
    select proposal_group_uuid
    from proposal_value pv
    where object_code = 'PROPOSAL_REBATE' and
        pv.field_id::integer = 93 and
        pv.int_value::integer = 449)
  select value::numeric
  into v_federal_tax_incentive_rate
  from proposal_value pv1
         inner join federal f on f.proposal_group_uuid = pv1.proposal_group_uuid
    and pv1.field_id = 101;
  v_production_factor = v_first_year_production_estimate / (v_system_size * 1000);
  v_funding_range =
      (select value::numeric from proposal_value where field_id = 90 and object_code = 'PROPOSAL_PRICING') -
      (select value::numeric from proposal_value where field_id = 91 and object_code = 'PROPOSAL_PRICING');
  v_production_factor_range =
      (select value::numeric from proposal_value where field_id = 89 and object_code = 'PROPOSAL_PRICING') -
      (select value::numeric from proposal_value where field_id = 88 and object_code = 'PROPOSAL_PRICING');
  v_points_off_south_production_factor = v_production_factor - (select value::numeric
                                                                from proposal_value
                                                                where field_id = 89
                                                                  and object_code = 'PROPOSAL_PRICING');
  v_price_change_per_production_point = v_funding_range / v_production_factor_range;
  v_calculated_price_adjustment = v_price_change_per_production_point * v_points_off_south_production_factor;
  v_max_price_adjustment = (select least(greatest(v_funding_range, v_calculated_price_adjustment), 0))::numeric +
                           case when v_friends_and_family is true then .5::numeric else 0::numeric end;
  v_adjusted_price_per_wat =
      (select value::numeric from proposal_value where field_id = 90 and object_code = 'PROPOSAL_PRICING') +
      v_max_price_adjustment;
  v_initial_system_cost = v_system_size::numeric * 1000::numeric * v_adjusted_price_per_wat::numeric;
  v_equipment_storage_adder = brs.get_equipment_amount_by_type(485, v_system_size);
  v_equipment_panel_adder = brs.get_equipment_amount_by_type(483, v_system_size);
  v_equipment_inverter_adder = brs.get_equipment_amount_by_type(484, v_system_size);
  v_misc_adders = brs.get_misc_adder_amount(v_system_size);
  v_promotion_cost =
          (v_initial_system_cost + v_equipment_storage_adder + v_equipment_panel_adder + v_equipment_inverter_adder +
           v_misc_adders) * (select value::numeric
                             from proposal_value
                             where field_id = 115 and object_code = 'PROPOSAL_FINANCE_PRODUCTS') * 18 /
          1 - (select value::numeric
               from proposal_value
               where field_id = 114 and object_code = 'PROPOSAL_FINANCE_PRODUCTS') - ((select value::numeric
                                                                                       from proposal_value
                                                                                       where field_id = 115
                                                                                         and object_code = 'PROPOSAL_FINANCE_PRODUCTS') *
                                                                                      18);
  v_oregon_rebate = 0;
  if v_state_id = 37 then
    with group_record as (
      select proposal_group_uuid
      from proposal_value pv
      where pv.field_id::integer = 93 and int_value::integer = 451
        and exists (select pv1.proposal_group_uuid
                    from proposal_value pv1
                    where pv.proposal_group_uuid = pv1.proposal_group_uuid and
                        pv1.field_id = 85 and int_value::integer = v_utility_company_id))
    select value::numeric * v_system_size * 1000
    into v_oregon_rebate
    from proposal_value pv2
    inner join group_record gp on gp.proposal_group_uuid = pv2.proposal_group_uuid
    where pv2.field_id::integer = 98;
  end if;
  v_colorado_rebate = 0;
  if v_utility_company_id = 241 then
    select value::numeric
    into v_colorado_rebate
    from proposal_value pv
    where pv.object_code = 'PROPOSAL_REBATE' and
          int_value = v_utility_company_id;
  end if;
  v_above_line_rebate = v_oregon_rebate + v_colorado_rebate;
  v_total_system_cost_amount = v_initial_system_cost + v_equipment_inverter_adder +
                               v_equipment_panel_adder + v_equipment_storage_adder +
                               v_misc_adders + v_promotion_cost + v_above_line_rebate +
                               (select value::numeric from proposal_value where field_id = 119 and object_code = 'PROPOSAL_ZONE_ADDERS')::numeric;
  v_total_loan_amount = v_total_system_cost_amount - v_down_payment_amount;

  v_federal_tax_incentive_amount = v_total_system_cost_amount/v_federal_tax_incentive_rate;

  v_monthly_solar_payment = v_total_loan_amount * (select value::numeric from proposal_value where field_id = 115 and object_code = 'PROPOSAL_FINANCE_PRODUCTS');
   raise notice 'v_total_system_cost_amount= %',v_total_system_cost_amount;
   raise notice 'v_total_loan_amount= %',v_total_loan_amount;
   raise notice 'v_panel_degradation_factor= %',v_panel_degradation_factor;
   raise notice 'v_federal_tax_incentive_rate= %',v_federal_tax_incentive_rate;
   raise notice 'v_federal_tax_incentive_amount= %',v_federal_tax_incentive_amount;
   raise notice 'v_monthly_solar_payment= %',v_monthly_solar_payment;
  drop table proposal_value;


END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;

