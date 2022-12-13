drop function if exists brs.get_calculated_proposal_values(bigint, boolean);
drop type if exists brs.calculated_proposal_value;

create type brs.calculated_proposal_value as
(
  proposal_id                                      bigint,
  project_id                                       bigint,
  proposal_archived                                boolean,
  contact_first_name                               varchar,
  contact_last_name                                varchar,
  contact_phone                                    varchar,
  contact_email                                    varchar,
  project_name                                     varchar,
  project_street1                                  varchar,
  project_street2                                  varchar,
  city                                             varchar,
  postal_code                                      varchar,
  project_state                                    varchar,
  project_state_abbrev                             varchar,
  monthly_cost_25_year_average_without_solar       varchar,
  monthly_cost_30_year_average_without_solar       varchar,
  monthly_cost_25_year_average_with_solar          varchar,
  remaining_monthly_electric_bill_25_year_average  varchar,
  remaining_monthly_electric_bill_30_year_average  varchar,
  total_cost_25_years                              varchar,
  total_cost_30_years                              varchar,
  total_savings_25_years                           varchar,
  total_savings_30_years                           varchar,
  monthly_solar_payment                            varchar,
  monthly_cost_today_without_solar                 varchar,
  monthly_cost_today_with_solar                    varchar,
  monthly_cost_today_avg_remaining_electrical_bill varchar,
  initial_monthly_payment_all_credits_to_loan      varchar,
  initial_monthly_payment_no_credits_to_loan       varchar,
  reamortized_monthly_payment_all_credits_to_loan  varchar,
  reamortized_monthly_payment_no_credits_to_loan   varchar,
  monthly_payment_all_credits_to_loan_after_term   varchar,
  monthly_payment_no_credits_to_loan_after_term    varchar,
  system_size                                      numeric,
  first_year_production_estimate                   bigint,
  total_system_cost                                varchar,
  referral_promotion                               varchar,
  total_loan_amount                                varchar,
  federal_tax_incentive_amount                     varchar,
  federal_tax_incentive_rate                       numeric,
  net_system_cost                                  varchar,
  utility_company                                  text,
  estimated_annual_energy_consumption_kwh          bigint,
  current_estimated_annual_utility_bill            varchar,
  current_estimated_cost_per_kwh                   varchar,
  utility_cost_escalator                           numeric,
  state_rebate_amount                              varchar,
  eto_rebate                                       varchar,
  csu_rebate                                       varchar,
  apr                                              numeric,
  loan_term                                        numeric,
  assumed_payment_by_month_18                      varchar,
  panel_degradation_factor                         numeric,
  system_production_25_year                        text,
  estimated_offset                                 numeric,
  led_light_bulbs                                  bigint,
  smart_thermostat                                 bigint,
  total_ee_reduction                               numeric,
  panel_warranty                                   bigint,
  inverter_warranty                                bigint,
  down_payment_amount                              varchar,
  version_id                                       bigint,
  project_process_step_id                          bigint,
  friends_and_family                               boolean,
  production_factor                                numeric,
  funding_range                                    numeric,
  production_factor_range                          numeric,
  points_off_south_production_factor               numeric,
  price_change_per_production_point                numeric,
  calculated_price_adjustment                      numeric,
  max_price_adjustment                             numeric,
  adjusted_price_per_wat                           numeric,
  initial_system_cost                              numeric,
  promotion_cost                                   numeric,
  equipment_inverter_adder                         numeric,
  equipment_panel_adder                            numeric,
  equipment_storage_adder                          numeric,
  misc_adders                                      numeric,
  panel_brand_id                                   bigint,
  panel_watts                                      bigint,
  above_line_rebate                                numeric,
  state_id                                         bigint,
  utility_company_id                               bigint,
  dealer_fee                                       numeric,
  eto_rebate_unit_type_id                          bigint,
  federal_unit_type_id                             bigint,
  inverter_efficiency                              numeric,
  initial_payment_factor                           numeric,
  reamortization_factor                            numeric,
  product_id                                       numeric,
  smart_thermostat_value                           numeric,
  smart_thermostat_adder                           numeric,
  led_light_bulbs_value                            numeric,
  led_light_bulbs_adder                            numeric,
  energy_efficiency_reduction_light_bulbs          numeric,
  energy_efficiency_reduction_thermostat           numeric,
  adjusted_annual_consumption                      numeric,
  instantly_used                                   numeric,
  sent_to_grid                                     numeric,
  after_net_metering                               numeric,
  adjusted_annual_production                       numeric,
  instant_use_assumption                           numeric,
  net_metring_rate                                 numeric,
  cost_of_solar                                    numeric,
  monthly_cost_30_year_average_with_solar          varchar,
  reamortized_payment_factor_without_itc_paydown   numeric,
  secondary_monthly_payment_no_credits_to_loan     varchar,
  panel_brand                                      varchar,
  panel_quantity                                   bigint,
  inverter_brand_id                                bigint,
  inverter_brand                                   varchar,
  aurora_design_id                                 text,
  product_name                                     varchar,
  proposal_nbr                                     bigint,
  other_adder_and_discount                         text,
  other_adder_and_discount_amount                  varchar,
  adder_name                                       text,
  non_solar_cap                                    numeric,
  required_down_payment                            varchar,
  storage_type_id                                  bigint,
  storage_type                                     varchar,
  financier                                        varchar,
  financier_id                                     bigint,
  loan_price_storage                               varchar,
  cash_price_storage                               varchar,
  main_panel_upgrade_cost                          numeric,
  structural_upgrade_cost                          numeric,
  reroof_cost                                      numeric,
  tree_trimming_cost                               numeric,
  trenching_cost                                   numeric,
  ac_unit_relocation_cost                          numeric,
  total_loan_amount_before_rebate                  numeric,
  zone_adder                                       numeric,
  loan_type                                        varchar,
  unapproved_zip_code_adder                        numeric,
  csu_rebate_unit_type_id                          integer
);

drop type brs.excluded_proposal_value;
create type brs.excluded_proposal_value as
(
  version_id                                     bigint,
  project_process_step_id                        bigint,
  friends_and_family                             boolean,
  production_factor                              numeric,
  funding_range                                  numeric,
  production_factor_range                        numeric,
  points_off_south_production_factor             numeric,
  price_change_per_production_point              numeric,
  calculated_price_adjustment                    numeric,
  max_price_adjustment                           numeric,
  adjusted_price_per_wat                         numeric,
  initial_system_cost                            numeric,
  promotion_cost                                 numeric,
  equipment_inverter_adder                       numeric,
  equipment_panel_adder                          numeric,
  equipment_storage_adder                        numeric,
  misc_adders                                    numeric,
  panel_brand_id                                 bigint,
  panel_watts                                    bigint,
  state_id                                       bigint,
  utility_company_id                             bigint,
  dealer_fee                                     numeric,
  eto_rebate_unit_type_id                        bigint,
  federal_unit_type_id                           bigint,
  inverter_efficiency                            numeric,
  initial_payment_factor                         numeric,
  reamortization_factor                          numeric,
  product_id                                     numeric,
  smart_thermostat_value                         numeric,
  smart_thermostat_adder                         numeric,
  led_light_bulbs_value                          numeric,
  led_light_bulbs_adder                          numeric,
  energy_efficiency_reduction_light_bulbs        numeric,
  energy_efficiency_reduction_thermostat         numeric,
  adjusted_annual_consumption                    numeric,
  instantly_used                                 numeric,
  sent_to_grid                                   numeric,
  after_net_metering                             numeric,
  adjusted_annual_production                     numeric,
  instant_use_assumption                         numeric,
  net_metring_rate                               numeric,
  cost_of_solar                                  numeric,
  monthly_cost_30_year_average_with_solar        varchar,
  reamortized_payment_factor_without_itc_paydown numeric,
  proposal_id                                    bigint,
  project_id                                     bigint,
  proposal_archived                              boolean,
  panel_brand                                    character varying,
  inverter_brand_id                              bigint,
  inverter_brand                                 varchar,
  aurora_design_id                               text,
  proposal_nbr                                   bigint,
  storage_type_id                                bigint,
  storage_type                                   varchar,
  financier                                      varchar,
  financier_id                                   bigint,
  loan_price_storage                             numeric,
  cash_price_storage                             numeric,
  main_panel_upgrade_cost                        numeric,
  structural_upgrade_cost                        numeric,
  reroof_cost                                    numeric,
  tree_trimming_cost                             numeric,
  trenching_cost                                 numeric,
  ac_unit_relocation_cost                        numeric,
  total_loan_amount_before_rebate                numeric,
  zone_adder                                     numeric,
  loan_type                                      varchar,
  unapproved_zip_code_adder                      numeric,
  csu_rebate_unit_type_id                        integer
);

CREATE OR REPLACE FUNCTION brs.get_calculated_proposal_values(
  p_proposal_id bigint,
  p_insert_prop_log_history boolean default false)

  RETURNS TABLE
          (
            like brs.calculated_proposal_value
          )
AS
$BODY$
declare
  v_aurora_design_summary                            jsonb;
  v_version_id                                       bigint;
  v_project_process_step_id                          bigint;
  v_estimated_annual_energy_consumption_kwh          bigint;
  v_first_year_production_estimate                   bigint;
  v_friends_and_family                               boolean;
  v_system_size                                      numeric;
  v_production_factor                                numeric;
  v_funding_range                                    numeric;
  v_production_factor_range                          numeric;
  v_points_off_south_production_factor               numeric;
  v_price_change_per_production_point                numeric;
  v_calculated_price_adjustment                      numeric;
  v_max_price_adjustment                             numeric;
  v_adjusted_price_per_wat                           numeric;
  v_initial_system_cost                              numeric;
  v_promotion_cost                                   numeric;
  v_equipment_inverter_adder                         numeric;
  v_equipment_panel_adder                            numeric;
  v_equipment_storage_adder                          numeric;
  v_misc_adders                                      numeric;
  v_panel_brand_id                                   bigint;
  v_panel_watts                                      bigint;
  v_above_line_rebate                                numeric;
  v_state_id                                         bigint;
  v_utility_company_id                               bigint;
  v_eto_rebate                                       numeric;
  v_csu_rebate                                       numeric;
  v_total_loan_amount                                numeric;
  v_total_loan_amount_before_rebate                  numeric;
  v_down_payment_amount                              numeric;
  v_total_system_cost                                numeric;
  v_panel_degradation_factor                         numeric;
  v_federal_tax_incentive_rate                       numeric;
  v_federal_tax_incentive_amount                     numeric;
  v_monthly_solar_payment                            numeric;
  v_monthly_cost_25_year_average_without_solar       numeric;
  v_monthly_cost_30_year_average_without_solar       numeric;
  v_monthly_cost_25_year_average_with_solar          numeric;
  v_remaining_monthly_electric_bill_25_year_average  numeric;
  v_remaining_monthly_electric_bill_30_year_average  numeric;
  v_total_cost_25_years                              numeric;
  v_total_cost_30_years                              numeric;
  v_total_savings_25_years                           numeric;
  v_total_savings_30_years                           numeric;
  v_dealer_fee                                       numeric;
  v_eto_rebate_unit_type_id                          bigint;
  v_federal_unit_type_id                             bigint;
  v_monthly_cost_today_without_solar                 numeric;
  v_monthly_cost_today_with_solar                    numeric;
  v_monthly_cost_today_avg_remaining_electrical_bill numeric;
  v_initial_monthly_payment_all_credits_to_loan      numeric;
  v_initial_monthly_payment_no_credits_to_loan       numeric;
  v_reamortized_monthly_payment_all_credits_to_loan  numeric;
  v_reamortized_monthly_payment_no_credits_to_loan   numeric;
  v_monthly_payment_all_credits_to_loan_after_term   numeric;
  v_monthly_payment_no_credits_to_loan_after_term    numeric;
  v_referral_promotion                               numeric;
  v_net_system_cost                                  numeric;
  v_utility_company                                  text;
  v_current_estimated_cost_per_kwh                   numeric;
  v_current_estimated_annual_utility_bill            numeric;
  v_system_production_25_year                        numeric;
  v_estimated_offset                                 numeric;
  v_led_light_bulbs                                  bigint;
  v_apr                                              numeric;
  v_smart_thermostat                                 bigint;
  v_loan_term                                        numeric;
  v_total_ee_reduction                               numeric;
  v_assumed_payment_by_month_18                      numeric;
  v_panel_warranty                                   bigint;
  v_inverter_warranty                                bigint;
  v_inverter_efficiency                              numeric;
  v_initial_payment_factor                           numeric;
  v_col_springs_rebate                               numeric;
  v_utility_cost_escalator                           numeric;
  v_state_rebate_amount                              numeric;
  v_reamortization_factor                            numeric;
  v_product_id                                       numeric;
  v_smart_thermostat_value                           numeric;
  v_smart_thermostat_adder                           numeric;
  v_led_light_bulbs_value                            numeric;
  v_led_light_bulbs_adder                            numeric;
  v_energy_efficiency_reduction_thermostat           numeric;
  v_energy_efficiency_reduction_light_bulbs          numeric;
  v_adjusted_annual_consumption                      numeric;
  v_instantly_used                                   numeric;
  v_sent_to_grid                                     numeric;
  v_after_net_metering                               numeric;
  v_adjusted_annual_production                       numeric;
  v_instant_use_assumption                           numeric;
  v_net_metring_rate                                 numeric;
  v_cost_of_solar                                    numeric;
  v_monthly_cost_30_year_average_with_solar          numeric;
  v_reamortized_payment_factor_without_itc_paydown   numeric;
  v_unit_type_state_rebate                           bigint;
  v_secondary_monthly_payment_no_credits_to_loan     numeric;
  v_proposal_id                                      bigint;
  v_project_id                                       bigint;
  v_proposal_archived                                boolean;
  v_contact_first_name                               character varying;
  v_contact_last_name                                character varying;
  v_contact_phone                                    character varying;
  v_contact_email                                    character varying;
  v_project_name                                     character varying;
  v_project_street1                                  character varying;
  v_project_street2                                  character varying;
  v_city                                             character varying;
  v_postal_code                                      character varying;
  v_project_state                                    character varying;
  v_project_state_abbrev                             character varying;
  v_panel_brand                                      character varying;
  v_panel_quantity                                   bigint;
  v_inverter_brand                                   varchar;
  v_inverter_brand_id                                bigint;
  v_aurora_design_id                                 text;
  v_product_name                                     character varying;
  v_proposal_nbr                                     bigint;
  v_display_name                                     varchar;
  v_other_adder_and_discount                         text;
  v_other_adder_and_discount_amount                  numeric;
  v_adder                                            text;
  v_required_down_payment                            numeric;
  v_non_solar_cap                                    numeric;
  v_storage_type_id                                  bigint;
  v_storage_type                                     varchar;
  v_financier                                        varchar;
  v_financier_id                                     bigint;
  v_cash_price_storage                               numeric;
  v_loan_price_storage                               numeric;
  v_main_panel_upgrade_cost                          numeric;
  v_structural_upgrade_cost                          numeric;
  v_reroof_cost                                      numeric;
  v_tree_trimming_cost                               numeric;
  v_trenching_cost                                   numeric;
  v_ac_unit_relocation_cost                          numeric;
  v_zone_adder                                       numeric;
  v_loan_type                                        varchar;
  v_unapproved_zip_code_adder                        numeric;
  v_csu_rebate_unit_type_id                          integer;
BEGIN

  select prop.id                                   as proposal_id,
         proposal_version_id,
         prop.project_process_step_id,
         coalesce(pcfv3.boolean_value, false),
         coalesce(pcfv4.numeric_value, 0),
         pcfv5.int_value,
         lov.name,
         p.id                                      as project_id,
         prop.archived,
         c.first_name,
         c.last_name,
         p.project_name,
         p.street1,
         p.street2,
         p.city,
         p.postal_code,
         s.state,
         s.abbreviation                            as state_abbreviation,
         c.mobile,
         c.email,
         pcfv7.numeric_value,
         pcfv6.text_value,
         pcfv8.int_value,
         lov2.name,
         pcfv10.numeric_value,
         pcfv11.numeric_value,
         pcfv12.numeric_value,
         pcfv13.numeric_value,
         pcfv14.numeric_value,
         pcfv15.numeric_value,
         prop.proposal_nbr,
         coalesce(prop.name, 'New Proposal') ||
         case
           when prop.revision_number = 0 then ''
           else ' (' || prop.revision_number::varchar || ')' end
           || ' - ' || prop.proposal_nbr || '.pdf' as display_name
  into v_proposal_id,v_version_id,v_project_process_step_id,v_friends_and_family,v_down_payment_amount,v_product_id,v_product_name,
    v_project_id,v_proposal_archived,v_contact_first_name,v_contact_last_name,v_project_name,v_project_street1,
    v_project_street2,v_city,v_postal_code,v_project_state,v_project_state_abbrev,v_contact_phone,v_contact_email,
    v_other_adder_and_discount_amount,v_other_adder_and_discount,v_storage_type_id,v_storage_type,v_main_panel_upgrade_cost,
    v_structural_upgrade_cost,
    v_reroof_cost,
    v_tree_trimming_cost,
    v_trenching_cost,
    v_ac_unit_relocation_cost,
    v_proposal_nbr,
    v_display_name
  from brs.proposal prop
         inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
         inner join flow.project p on pps.project_id = p.id
         inner join flow.contact c on p.contact_id = c.id
         inner join flow.company_state cs on p.company_state_id = cs.id
         inner join flow.state s on cs.state_id = s.id
         left join brs.proposal_custom_field_value pcfv3 on prop.id = pcfv3.proposal_id and
                                                            pcfv3.custom_field_group_assignment_id = 169
         left join brs.proposal_custom_field_value pcfv4 on prop.id = pcfv4.proposal_id and
                                                            pcfv4.custom_field_group_assignment_id = 134
         left join brs.proposal_custom_field_value pcfv5 on prop.id = pcfv5.proposal_id and
                                                            pcfv5.custom_field_group_assignment_id = 147
         left join brs.proposal_custom_field_value pcfv6 on prop.id = pcfv6.proposal_id and
                                                            pcfv6.custom_field_group_assignment_id = 165
         left join brs.proposal_custom_field_value pcfv7 on prop.id = pcfv7.proposal_id and
                                                            pcfv7.custom_field_group_assignment_id = 167

         left join flow.list_of_value lov on lov.id = pcfv5.int_value
         left join brs.proposal_custom_field_value pcfv8 on prop.id = pcfv8.proposal_id and
                                                            pcfv8.custom_field_group_assignment_id = 200
         left join brs.list_of_value lov2 on lov2.id = pcfv8.int_value
         left join brs.proposal_custom_field_value pcfv10 on prop.id = pcfv10.proposal_id and
                                                             pcfv10.custom_field_group_assignment_id = 201
         left join brs.proposal_custom_field_value pcfv11 on prop.id = pcfv11.proposal_id and
                                                             pcfv11.custom_field_group_assignment_id = 202
         left join brs.proposal_custom_field_value pcfv12 on prop.id = pcfv12.proposal_id and
                                                             pcfv12.custom_field_group_assignment_id = 203
         left join brs.proposal_custom_field_value pcfv13 on prop.id = pcfv13.proposal_id and
                                                             pcfv13.custom_field_group_assignment_id = 204
         left join brs.proposal_custom_field_value pcfv14 on prop.id = pcfv14.proposal_id and
                                                             pcfv14.custom_field_group_assignment_id = 205
         left join brs.proposal_custom_field_value pcfv15 on prop.id = pcfv15.proposal_id and
                                                             pcfv15.custom_field_group_assignment_id = 206
  where prop.id = p_proposal_id;

  select string_agg(lov.name, ',')
  into v_adder
  from brs.proposal prop
         inner join brs.proposal_custom_field_value pcfv on prop.id = pcfv.proposal_id and
                                                            pcfv.custom_field_group_assignment_id = 146
         inner join brs.list_of_value lov on lov.id = any (pcfv.int_array_value)
  where prop.id = p_proposal_id;


  select ppscfv.int_value,
         ppscfv2.int_value,
         ppscfv3.numeric_value,
         ppscfv4.int_value,
         ppscfv5.int_value,
         lov.name,
         cs.state_id,
         pd.utility_company,
         pd.utility_company_name,
         ppscfv6.json_value,
         ppscfv7.int_value,
         ppscfv8.int_value,
         ppscfv9.int_value,
         ppscfv10.int_value,
         lov1.name,
         ppscfv11.text_value,
         pd.unapproved_zip_code_adder
  into
    v_estimated_annual_energy_consumption_kwh,
    v_first_year_production_estimate,
    v_system_size,
    v_panel_watts,
    v_panel_brand_id,
    v_panel_brand,
    v_state_id,
    v_utility_company_id,
    v_utility_company,
    v_aurora_design_summary,
    v_led_light_bulbs,
    v_smart_thermostat,
    v_panel_quantity,
    v_inverter_brand_id,
    v_inverter_brand,
    v_aurora_design_id,
    v_unapproved_zip_code_adder
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
         left join flow.list_of_value lov on lov.id = ppscfv5.int_value
         left join flow.project_process_step_custom_field_value ppscfv6 on ppscfv6.project_process_step_id = pps.id and
                                                                           ppscfv6.custom_field_group_assignment_id =
                                                                           22682
         left join flow.project_process_step_custom_field_value ppscfv7 on ppscfv7.project_process_step_id = pps.id and
                                                                           ppscfv7.custom_field_group_assignment_id =
                                                                           22566
         left join flow.project_process_step_custom_field_value ppscfv8 on ppscfv8.project_process_step_id = pps.id and
                                                                           ppscfv8.custom_field_group_assignment_id =
                                                                           22567
         left join flow.project_process_step_custom_field_value ppscfv9 on ppscfv9.project_process_step_id = pps.id and
                                                                           ppscfv9.custom_field_group_assignment_id =
                                                                           22562
         left join flow.project_process_step_custom_field_value ppscfv10
                   on ppscfv10.project_process_step_id = pps.id and
                      ppscfv10.custom_field_group_assignment_id =
                      22565
         left join flow.list_of_value lov1 on lov1.id = ppscfv10.int_value
         left join flow.project_process_step_custom_field_value ppscfv11
                   on ppscfv11.project_process_step_id = pps.id and
                      ppscfv11.custom_field_group_assignment_id =
                      22560
  where pps.id = v_project_process_step_id;

  raise notice 'v_estimated_annual_energy_consumption_kwh = %',v_estimated_annual_energy_consumption_kwh;
  --   raise notice 'v_first_year_production_estimate = %',v_first_year_production_estimate;
--   raise notice 'v_system_size = %',v_system_size;
  create temp table proposal_value as (with version_values
                                              as (select distinct on ( vw.proposal_group_uuid, vw.custom_field_group_assignment_id ) vw.id,
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
                                                    and proposal_group_uuid not in (select distinct proposal_group_uuid
                                                                                    from brs.proposal_version_custom_field_group
                                                                                    where archived is not null
                                                                                      and proposal_version_id <= v_version_id)
                                                  order by vw.proposal_group_uuid, vw.custom_field_group_assignment_id,
                                                           vw.id desc),
                                            proposal_finance_product as (select pcfv.int_value
                                                                         from brs.proposal prop
                                                                                inner join brs.proposal_custom_field_value pcfv
                                                                                           on prop.id =
                                                                                              pcfv.proposal_id and
                                                                                              pcfv.custom_field_group_assignment_id =
                                                                                              155
                                                                         where prop.id = p_proposal_id),
                                            group_uuid_finance_product as (select vv.proposal_group_uuid
                                                                           from version_values vv
                                                                                  inner join proposal_finance_product pfp
                                                                                             on (vv.value ->> 'intValue')::bigint = pfp.int_value
                                                                           where vv.object_code = 'PROPOSAL_FINANCE_PRODUCTS'
                                                                             and vv.field_id = 128
                                                                             and vv.proposal_version_id <= v_version_id),
                                            finance_product_company_results as (select vv2.proposal_group_uuid,
                                                                                       vv2.field_id,
                                                                                       vv2.field_name,
                                                                                       cdt.data_type_id,
                                                                                       (vv2.value ->> 'value')::text    as value,
                                                                                       (vv2.value ->> 'intValue')::text as intValue,
                                                                                       vv2.object_code
                                                                                from version_values vv2
                                                                                       inner join group_uuid_finance_product g
                                                                                                  on g.proposal_group_uuid = vv2.proposal_group_uuid
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
                                            group_uuid_utility as (select vv.proposal_group_uuid, uc.utility_company
                                                                   from version_values vv
                                                                          inner join utility_company uc
                                                                                     on (vv.value ->> 'intValue')::bigint = uc.utility_company
                                                                   where vv.object_code = 'PROPOSAL_PRICING'
                                                                     and vv.field_id = 85
                                                                     and vv.proposal_version_id <= v_version_id),
                                            utility_company_results as (select vv2.proposal_group_uuid,
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
                                            group_uuid_financier as (select vv.proposal_group_uuid
                                                                     from version_values vv
                                                                            inner join financier f
                                                                                       on (vv.value ->> 'intValue')::bigint =
                                                                                          f.intvalue::bigint
                                                                                         and vv.field_id = 102
                                                                     where vv.object_code = 'PROPOSAL_FINANCIERS'
                                                                       and vv.proposal_version_id <= v_version_id),
                                            financier_company_results as (select vv2.proposal_group_uuid,
                                                                                 vv2.field_id,
                                                                                 vv2.field_name,
                                                                                 cdt.data_type_id,
                                                                                 (vv2.value ->> 'value')::text    as value,
                                                                                 vv2.object_code,
                                                                                 (vv2.value ->> 'intValue')::text as int_value
                                                                          from version_values vv2
                                                                                 inner join group_uuid_financier g1
                                                                                            on g1.proposal_group_uuid = vv2.proposal_group_uuid
                                                                                 inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                                 inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
                                            zone_adders as (select p.postal_code
                                                            from brs.proposal prop
                                                                   inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
                                                                   inner join flow.project p on pps.project_id = p.id
                                                            where prop.id = p_proposal_id),
                                            group_uuid_zone as (select vv.proposal_group_uuid
                                                                from version_values vv
                                                                       inner join zone_adders za
                                                                                  on (vv.value ->> 'value')::jsonb ?& array [za.postal_code]
                                                                where vv.object_code = 'PROPOSAL_ZONE_ADDERS'
                                                                  and vv.field_id = 122
                                                                  and vv.proposal_version_id <= v_version_id),
                                            zone_adder_results as (select vv2.proposal_group_uuid,
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
                                            group_uuid_federal_rebate as (select vv.proposal_group_uuid
                                                                          from version_values vv
                                                                          where vv.object_code = 'PROPOSAL_REBATE'
                                                                            and (vv.value ->> 'intValue')::bigint = 453
                                                                            and vv.custom_field_group_assignment_id = 96
                                                                            and vv.proposal_version_id <= v_version_id),
                                            federal_rebate_results as (select vv2.proposal_group_uuid,
                                                                              vv2.field_id,
                                                                              vv2.field_name,
                                                                              cdt.data_type_id,
                                                                              (vv2.value ->> 'value')::text    as value,
                                                                              vv2.object_code,
                                                                              (vv2.value ->> 'intValue')::text as int_value
                                                                       from version_values vv2
                                                                              inner join group_uuid_federal_rebate g1
                                                                                         on g1.proposal_group_uuid = vv2.proposal_group_uuid
                                                                              inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                              inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
                                            group_uuid_referral_rebate as (select vv.proposal_group_uuid
                                                                           from version_values vv
                                                                           where vv.object_code = 'PROPOSAL_REBATE'
                                                                             and (vv.value ->> 'intValue')::bigint = 535
                                                                             and vv.custom_field_group_assignment_id = 150
                                                                             and vv.proposal_version_id <= v_version_id),
                                            referral_rebate_results as (select vv2.proposal_group_uuid,
                                                                               vv2.field_id,
                                                                               vv2.field_name,
                                                                               cdt.data_type_id,
                                                                               (vv2.value ->> 'value')::text    as value,
                                                                               vv2.object_code,
                                                                               (vv2.value ->> 'intValue')::text as int_value
                                                                        from version_values vv2
                                                                               inner join group_uuid_referral_rebate g1
                                                                                          on g1.proposal_group_uuid = vv2.proposal_group_uuid
                                                                               inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                               inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),

                                            state_rebate as (select cs.state_id
                                                             from brs.proposal prop
                                                                    inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
                                                                    inner join flow.project p on pps.project_id = p.id
                                                                    inner join flow.company_state cs on cs.id = p.company_state_id
                                                             where prop.id = p_proposal_id),
                                            group_uuid_state_rebate as (select vv.proposal_group_uuid
                                                                        from version_values vv
                                                                               inner join state_rebate sr on (vv.value ->> 'intValue')::bigint = sr.state_id
                                                                        where vv.object_code = 'PROPOSAL_REBATE'
                                                                          and vv.field_id = 86
                                                                          and vv.proposal_version_id <= v_version_id),
                                            state_rebate_results as (select vv2.proposal_group_uuid,
                                                                            vv2.field_id,
                                                                            vv2.field_name,
                                                                            cdt.data_type_id,
                                                                            (vv2.value ->> 'value')::text    as value,
                                                                            vv2.object_code,
                                                                            (vv2.value ->> 'intValue')::text as int_value
                                                                     from version_values vv2
                                                                            inner join group_uuid_state_rebate g1
                                                                                       on g1.proposal_group_uuid = vv2.proposal_group_uuid
                                                                            inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                            inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
                                            utility_rebate as (select p.id as project_id,
                                                                      pps.id,
                                                                      pd.utility_company,
                                                                      pd.utility_company_name
                                                               from brs.proposal p
                                                                      inner join flow.project_process_step pps
                                                                                 on pps.id = p.project_process_step_id
                                                                      inner join flow.project proj on pps.project_id = proj.id
                                                                      inner join brs.project_details pd on pd.project_id = proj.id
                                                               where p.id = p_proposal_id),
                                            group_uuid_utility_rebate as (select vv.proposal_group_uuid
                                                                          from version_values vv
                                                                                 inner join utility_rebate sr
                                                                                            on (vv.value ->> 'intValue')::bigint = sr.utility_company
                                                                          where vv.object_code = 'PROPOSAL_REBATE'
                                                                            and vv.proposal_version_id <= v_version_id),
                                            utility_rebate_results as (select vv2.proposal_group_uuid,
                                                                              vv2.field_id,
                                                                              vv2.field_name,
                                                                              cdt.data_type_id,
                                                                              (vv2.value ->> 'value')::text    as value,
                                                                              vv2.object_code,
                                                                              (vv2.value ->> 'intValue')::text as int_value
                                                                       from version_values vv2
                                                                              inner join group_uuid_utility_rebate g1
                                                                                         on g1.proposal_group_uuid = vv2.proposal_group_uuid
                                                                              inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                              inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
--                                             equipment_type_inverter as (select ppscfv.int_value
--                                                                         from brs.proposal prop
--                                                                                inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
--                                                                                inner join flow.project_process_step_custom_field_value ppscfv
--                                                                                           on pps.id =
--                                                                                              ppscfv.project_process_step_id and
--                                                                                              ppscfv.custom_field_group_assignment_id =
--                                                                                              22565
--                                                                         where prop.id = p_proposal_id),
--                                             group_uuid_equipment_type_inverter as (select vv.proposal_group_uuid
--                                                                                    from version_values vv
--                                                                                           inner join equipment_type_inverter eti
--                                                                                                      on (vv.value ->> 'intValue')::bigint = eti.int_value
--                                                                                    where vv.object_code = 'PROPOSAL_EQUIPMENT_ADDERS'
--                                                                                      and vv.field_id = 131
--                                                                                      and vv.proposal_version_id <= v_version_id),
--                                             equipment_type_inverter_results as (select vv2.proposal_group_uuid,
--                                                                                        vv2.field_id,
--                                                                                        vv2.field_name,
--                                                                                        cdt.data_type_id,
--                                                                                        (vv2.value ->> 'value')::text    as value,
--                                                                                        (vv2.value ->> 'intValue')::text as intValue,
--                                                                                        vv2.object_code
--                                                                                 from version_values vv2
--                                                                                        inner join group_uuid_equipment_type_inverter g
--                                                                                                   on g.proposal_group_uuid = vv2.proposal_group_uuid
--                                                                                        inner join brs.custom_field cf on cf.id = vv2.field_id
--                                                                                        inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
--                                             equipment_type_panel as (select ppscfv.int_value
--                                                                      from brs.proposal prop
--                                                                             inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
--                                                                             inner join flow.project_process_step_custom_field_value ppscfv
--                                                                                        on pps.id =
--                                                                                           ppscfv.project_process_step_id and
--                                                                                           ppscfv.custom_field_group_assignment_id =
--                                                                                           22564
--                                                                      where prop.id = p_proposal_id),
--                                             group_uuid_equipment_type_panel as (select vv.proposal_group_uuid
--                                                                                 from version_values vv
--                                                                                        inner join equipment_type_panel etp
--                                                                                                   on (vv.value ->> 'intValue')::bigint = etp.int_value
--                                                                                 where vv.object_code = 'PROPOSAL_EQUIPMENT_ADDERS'
--                                                                                   and vv.field_id = 130
--                                                                                   and vv.proposal_version_id <= v_version_id),
--                                             equipment_type_panel_results as (select vv2.proposal_group_uuid,
--                                                                                     vv2.field_id,
--                                                                                     vv2.field_name,
--                                                                                     cdt.data_type_id,
--                                                                                     (vv2.value ->> 'value')::text    as value,
--                                                                                     (vv2.value ->> 'intValue')::text as intValue,
--                                                                                     vv2.object_code
--                                                                              from version_values vv2
--                                                                                     inner join group_uuid_equipment_type_panel g
--                                                                                                on g.proposal_group_uuid = vv2.proposal_group_uuid
--                                                                                     inner join brs.custom_field cf on cf.id = vv2.field_id
--                                                                                     inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
                                            equipment_type_storage as (select pcfv2.int_value,
                                                                              prop.proposal_version_id
                                                                       from brs.proposal prop
                                                                              inner join brs.proposal_custom_field_value pcfv2
                                                                                         on pcfv2.proposal_id = prop.id
                                                                                           and
                                                                                            pcfv2.custom_field_group_assignment_id =
                                                                                            137 and
                                                                                            pcfv2.int_value = 509
                                                                       where prop.id = p_proposal_id),
                                            group_uuid_equipment_type_storage as (select vv.proposal_group_uuid
                                                                                  from version_values vv
                                                                                         inner join equipment_type_storage ets
                                                                                                    on vv.proposal_version_id <= ets.proposal_version_id
                                                                                  where vv.object_code = 'PROPOSAL_STORAGE_DETAILS'
                                                                                    and (vv.value ->> 'intValue')::bigint = v_storage_type_id
                                                                                    and vv.custom_field_group_assignment_id = 186),
                                            equipment_type_storage_results as (select vv2.proposal_group_uuid,
                                                                                      vv2.field_id,
                                                                                      vv2.field_name,
                                                                                      cdt.data_type_id,
                                                                                      (vv2.value ->> 'value')::text    as value,
                                                                                      (vv2.value ->> 'intValue')::text as intValue,
                                                                                      vv2.object_code
                                                                               from version_values vv2
                                                                                      inner join group_uuid_equipment_type_storage g
                                                                                                 on g.proposal_group_uuid = vv2.proposal_group_uuid
                                                                                      inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                                      inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
                                            group_uuid_equipment_type_smart_thermostat as (select vv.proposal_group_uuid
                                                                                           from version_values vv
                                                                                           where vv.object_code = 'PROPOSAL_EQUIPMENT_ADDERS'
                                                                                             and (vv.value ->> 'intValue')::bigint = 536::bigint
                                                                                             and vv.custom_field_group_assignment_id = 118),
                                            equipment_type_smart_thermostat_results as (select vv2.proposal_group_uuid,
                                                                                               vv2.field_id,
                                                                                               vv2.field_name,
                                                                                               cdt.data_type_id,
                                                                                               (vv2.value ->> 'value')::text    as value,
                                                                                               (vv2.value ->> 'intValue')::text as intValue,
                                                                                               vv2.object_code
                                                                                        from version_values vv2
                                                                                               inner join group_uuid_equipment_type_smart_thermostat g
                                                                                                          on g.proposal_group_uuid = vv2.proposal_group_uuid
                                                                                               inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                                               inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
                                            group_uuid_equipment_type_led_lightbulbs as (select vv.proposal_group_uuid
                                                                                         from version_values vv
                                                                                         where vv.object_code = 'PROPOSAL_EQUIPMENT_ADDERS'
                                                                                           and (vv.value ->> 'intValue')::bigint = 537::bigint
                                                                                           and vv.custom_field_group_assignment_id = 118),
                                            equipment_type_led_lightbulbs_results as (select vv2.proposal_group_uuid,
                                                                                             vv2.field_id,
                                                                                             vv2.field_name,
                                                                                             cdt.data_type_id,
                                                                                             (vv2.value ->> 'value')::text    as value,
                                                                                             (vv2.value ->> 'intValue')::text as intValue,
                                                                                             vv2.object_code
                                                                                      from version_values vv2
                                                                                             inner join group_uuid_equipment_type_led_lightbulbs g
                                                                                                        on g.proposal_group_uuid = vv2.proposal_group_uuid
                                                                                             inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                                             inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
                                            proposal_misc_adders as (select pcfv.int_array_value
                                                                     from brs.proposal prop
                                                                            inner join brs.proposal_custom_field_value pcfv
                                                                                       on prop.id = pcfv.proposal_id
                                                                                         and
                                                                                          pcfv.custom_field_group_assignment_id =
                                                                                          146
                                                                     where prop.id = p_proposal_id),
                                            test as (select foo.id, array_agg(foo.my_value)::bigint[] as my_value
                                                     from (select vv.id,
                                                                  jsonb_array_elements((vv.value ->> 'intArrayValue')::jsonb) as my_value
                                                           from version_values vv
                                                           where vv.object_code = 'PROPOSAL_MISC_ADDERS'
                                                             and vv.custom_field_group_assignment_id = 145) as foo
                                                     group by foo.id),
                                            group_uuid_prop_misc as (select vv.proposal_group_uuid
                                                                     from version_values vv
                                                                            inner join test t on t.id = vv.id
                                                                            inner join proposal_misc_adders pma
                                                                                       on t.my_value && pma.int_array_value::bigint[]

                                                                     where vv.object_code = 'PROPOSAL_MISC_ADDERS'
                                                                       and vv.custom_field_group_assignment_id = 145
                                                                     group by vv.proposal_group_uuid),
                                            proposal_misc_results as (select vv2.proposal_group_uuid,
                                                                             vv2.field_id,
                                                                             vv2.field_name,
                                                                             cdt.data_type_id,
                                                                             (vv2.value ->> 'value')::text    as value,
                                                                             vv2.object_code,
                                                                             (vv2.value ->> 'intValue')::text as int_value
                                                                      from version_values vv2
                                                                             inner join group_uuid_prop_misc g1
                                                                                        on g1.proposal_group_uuid = vv2.proposal_group_uuid
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
                                            group_uuid_source_adders as (select vv.proposal_group_uuid, sa.source
                                                                         from version_values vv
                                                                                inner join source_adders sa on (vv.value ->> 'intValue')::bigint = sa.source
                                                                         where vv.object_code = 'PROPOSAL_SOURCE_STATE_ADDERS'
                                                                           and vv.field_id = 121
                                                                           and vv.proposal_version_id <= v_version_id),
                                            source_adder_results as (select vv2.proposal_group_uuid,
                                                                            vv2.field_id,
                                                                            vv2.field_name,
                                                                            cdt.data_type_id,
                                                                            g.source,
                                                                            (vv2.value ->> 'value')::text    as value,
                                                                            vv2.object_code,
                                                                            (vv2.value ->> 'intValue')::text as int_value
                                                                     from version_values vv2
                                                                            inner join group_uuid_source_adders g
                                                                                       on g.proposal_group_uuid = vv2.proposal_group_uuid
                                                                            inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                            inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
                                            group_uuid_small_system_adders as (select vv.proposal_group_uuid
                                                                               from version_values vv
                                                                               where vv.object_code = 'PROPOSAL_SMALL_SYSTEM_ADDERS'),
                                            small_system_adder_results as (select vv2.proposal_group_uuid,
                                                                                  vv2.field_id,
                                                                                  vv2.field_name,
                                                                                  cdt.data_type_id,
                                                                                  (vv2.value ->> 'value')::text    as value,
                                                                                  vv2.object_code,
                                                                                  (vv2.value ->> 'intValue')::text as int_value
                                                                           from version_values vv2
                                                                                  inner join group_uuid_small_system_adders g
                                                                                             on g.proposal_group_uuid = vv2.proposal_group_uuid
                                                                                  inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
                                            other_adders as (select cf.id as field_id,
                                                                    pcfv1.text_value,
                                                                    pcfv2.numeric_value,
                                                                    cf.field_name
                                                             from brs.proposal prop
                                                                    inner join brs.proposal_custom_field_value pcfv1
                                                                               on pcfv1.proposal_id = prop.id
                                                                                 and
                                                                                  pcfv1.custom_field_group_assignment_id =
                                                                                  165
                                                                    inner join brs.custom_field_group_assignment cfga
                                                                               on cfga.id = pcfv1.custom_field_group_assignment_id
                                                                    inner join brs.custom_field cf on cfga.custom_field_id = cf.id
                                                                    inner join brs.proposal_custom_field_value pcfv2
                                                                               on pcfv2.proposal_id = prop.id
                                                                                 and
                                                                                  pcfv2.custom_field_group_assignment_id =
                                                                                  167
                                                             where prop.id = p_proposal_id),
                                            group_uuid_proposal_panel_detail as (select vv.proposal_group_uuid
                                                                                 from version_values vv
                                                                                 where (vv.value ->> 'intValue')::bigint = v_panel_brand_id
                                                                                   and vv.custom_field_group_assignment_id = 170
                                                                                   and vv.object_code = 'PROPOSAL_PANEL_DETAIL'
                                                                                   and vv.field_id = 138),
                                            group_uuid_proposal_panel_watts_detail as (select vv.proposal_group_uuid
                                                                                       from version_values vv
                                                                                              inner join group_uuid_proposal_panel_detail guppd
                                                                                                         on guppd.proposal_group_uuid =
                                                                                                            vv.proposal_group_uuid
                                                                                                           and
                                                                                                            (vv.value ->> 'value')::bigint =
                                                                                                            v_panel_watts and
                                                                                                            vv.custom_field_group_assignment_id =
                                                                                                            171
                                                                                       where vv.object_code = 'PROPOSAL_PANEL_DETAIL'
                                                                                         and vv.field_id = 139),
                                            proposal_panel_detail_results as (select vv2.proposal_group_uuid,
                                                                                     vv2.field_id,
                                                                                     vv2.field_name,
                                                                                     cdt.data_type_id,
                                                                                     (vv2.value ->> 'value')::text    as value,
                                                                                     vv2.object_code,
                                                                                     (vv2.value ->> 'intValue')::text as int_value
                                                                              from version_values vv2
                                                                                     inner join group_uuid_proposal_panel_watts_detail g1
                                                                                                on g1.proposal_group_uuid = vv2.proposal_group_uuid
                                                                                     inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                                     inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id),
                                            proposal_inverter_details as (select ppscfv.int_value
                                                                          from brs.proposal prop
                                                                                 inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
                                                                                 inner join flow.project_process_step_custom_field_value ppscfv
                                                                                            on pps.id =
                                                                                               ppscfv.project_process_step_id and
                                                                                               ppscfv.custom_field_group_assignment_id =
                                                                                               22565
                                                                          where prop.id = p_proposal_id),
                                            group_uuid_proposal_inverter as (select vv.proposal_group_uuid
                                                                             from version_values vv
                                                                                    inner join proposal_inverter_details eti
                                                                                               on (vv.value ->> 'intValue')::bigint = eti.int_value
                                                                             where vv.object_code = 'PROPOSAL_INVERTER_DETAILS'
                                                                               and vv.field_id = 131
                                                                               and vv.proposal_version_id <= v_version_id),
                                            proposal_inverter_results as (select vv2.proposal_group_uuid,
                                                                                 vv2.field_id,
                                                                                 vv2.field_name,
                                                                                 cdt.data_type_id,
                                                                                 (vv2.value ->> 'value')::text    as value,
                                                                                 (vv2.value ->> 'intValue')::text as intValue,
                                                                                 vv2.object_code
                                                                          from version_values vv2
                                                                                 inner join group_uuid_proposal_inverter g
                                                                                            on g.proposal_group_uuid = vv2.proposal_group_uuid
                                                                                 inner join brs.custom_field cf on cf.id = vv2.field_id
                                                                                 inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id)
                                       select ucr.proposal_group_uuid,
                                              ucr.field_id,
                                              ucr.field_name,
                                              ucr.data_type_id,
                                              ucr.value,
                                              ucr.utility_company::bigint,
                                              ucr.object_code,
                                              ucr.int_value
                                       from utility_company_results ucr
                                       union
                                       select fcr.proposal_group_uuid,
                                              fcr.field_id,
                                              fcr.field_name,
                                              fcr.data_type_id,
                                              fcr.value,
                                              null::bigint,
                                              fcr.object_code,
                                              fcr.int_value
                                       from financier_company_results fcr
                                       union
                                       select fpcr.proposal_group_uuid,
                                              fpcr.field_id,
                                              fpcr.field_name,
                                              fpcr.data_type_id,
                                              fpcr.value,
                                              fpcr.intValue::bigint,
                                              fpcr.object_code,
                                              fpcr.intValue
                                       from finance_product_company_results fpcr
                                       union
                                       select zar.proposal_group_uuid,
                                              zar.field_id,
                                              zar.field_name,
                                              zar.data_type_id,
                                              zar.value,
                                              null::bigint,
                                              zar.object_code,
                                              zar.int_value
                                       from zone_adder_results zar
                                       union
                                       select frr.proposal_group_uuid,
                                              frr.field_id,
                                              frr.field_name,
                                              frr.data_type_id,
                                              frr.value,
                                              null::bigint,
                                              frr.object_code,
                                              frr.int_value
                                       from federal_rebate_results frr
                                       union
                                       select rrr.proposal_group_uuid,
                                              rrr.field_id,
                                              rrr.field_name,
                                              rrr.data_type_id,
                                              rrr.value,
                                              null::bigint,
                                              rrr.object_code,
                                              rrr.int_value
                                       from referral_rebate_results rrr
                                       union
                                       select srr.proposal_group_uuid,
                                              srr.field_id,
                                              srr.field_name,
                                              srr.data_type_id,
                                              srr.value,
                                              null::bigint,
                                              srr.object_code,
                                              srr.int_value
                                       from state_rebate_results srr
                                       union
                                       select urr.proposal_group_uuid,
                                              urr.field_id,
                                              urr.field_name,
                                              urr.data_type_id,
                                              urr.value,
                                              null::bigint,
                                              urr.object_code,
                                              urr.int_value
                                       from utility_rebate_results urr
--                                       union
--                                        select etir.proposal_group_uuid,
--                                               etir.field_id,
--                                               etir.field_name,
--                                               etir.data_type_id,
--                                               etir.value,
--                                               null::bigint,
--                                               etir.object_code,
--                                               etir.intValue
--                                        from equipment_type_inverter_results etir
--                                        union
--                                        select etpr.proposal_group_uuid,
--                                               etpr.field_id,
--                                               etpr.field_name,
--                                               etpr.data_type_id,
--                                               etpr.value,
--                                               null::bigint,
--                                               etpr.object_code,
--                                               etpr.intValue
--                                        from equipment_type_panel_results etpr
                                       union
                                       select etpsr.proposal_group_uuid,
                                              etpsr.field_id,
                                              etpsr.field_name,
                                              etpsr.data_type_id,
                                              etpsr.value,
                                              null::bigint,
                                              etpsr.object_code,
                                              etpsr.intValue
                                       from equipment_type_storage_results etpsr
                                       union
                                       select etstr.proposal_group_uuid,
                                              etstr.field_id,
                                              etstr.field_name,
                                              etstr.data_type_id,
                                              etstr.value,
                                              null::bigint,
                                              etstr.object_code,
                                              etstr.intValue
                                       from equipment_type_smart_thermostat_results etstr
                                       union
                                       select etllr.proposal_group_uuid,
                                              etllr.field_id,
                                              etllr.field_name,
                                              etllr.data_type_id,
                                              etllr.value,
                                              null::bigint,
                                              etllr.object_code,
                                              etllr.intValue
                                       from equipment_type_led_lightbulbs_results etllr
                                       union
                                       select pmr.proposal_group_uuid,
                                              pmr.field_id,
                                              pmr.field_name,
                                              pmr.data_type_id,
                                              pmr.value,
                                              null::bigint,
                                              pmr.object_code,
                                              pmr.int_value
                                       from proposal_misc_results pmr
                                       union
                                       select sar.proposal_group_uuid,
                                              sar.field_id,
                                              sar.field_name,
                                              sar.data_type_id,
                                              sar.value,
                                              null::bigint,
                                              sar.object_code,
                                              sar.int_value
                                       from source_adder_results sar
                                       union
                                       select ssar.proposal_group_uuid,
                                              ssar.field_id,
                                              ssar.field_name,
                                              ssar.data_type_id,
                                              ssar.value,
                                              null::bigint,
                                              ssar.object_code,
                                              ssar.int_value
                                       from small_system_adder_results ssar
                                       union
                                       select ppdr.proposal_group_uuid,
                                              ppdr.field_id,
                                              ppdr.field_name,
                                              ppdr.data_type_id,
                                              ppdr.value,
                                              null::bigint,
                                              ppdr.object_code,
                                              ppdr.int_value
                                       from proposal_panel_detail_results ppdr
                                       union
                                       select pir.proposal_group_uuid,
                                              pir.field_id,
                                              pir.field_name,
                                              pir.data_type_id,
                                              pir.value,
                                              null::bigint,
                                              pir.object_code,
                                              pir.intValue
                                       from proposal_inverter_results pir
                                       union
                                       select null::uuid,
                                              oa.field_id,
                                              oa.field_name,
                                              3::bigint,
                                              oa.numeric_value::text,
                                              null::bigint,
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

  raise notice 'v_product_id = % ',v_product_id;
  raise notice 'v_version_id = % ',v_version_id;
  raise notice 'v_project_process_step_id = % ',v_project_process_step_id;
  raise notice 'v_friends_and_family = % ',v_friends_and_family;
  raise notice 'v_panel_watts = % ',v_panel_watts;
  raise notice 'v_panel_brand_id = % ',v_panel_brand_id;
  raise notice 'v_state_id = % ',v_state_id;

  raise notice 'v_main_panel_upgrade_cost = % ',v_main_panel_upgrade_cost;
  raise notice 'v_structural_upgrade_cost = % ',v_structural_upgrade_cost;
  raise notice 'v_reroof_cost = % ',v_reroof_cost;
  raise notice 'v_tree_trimming_cost = % ',v_tree_trimming_cost;
  raise notice 'v_trenching_cost = % ',v_trenching_cost;
  raise notice 'v_ac_unit_relocation_cost = % ',v_ac_unit_relocation_cost;


  select value::numeric
  into v_apr
  from proposal_value pv
  where field_id = 111
    and object_code = 'PROPOSAL_FINANCE_PRODUCTS';
  raise notice 'v_apr = %',v_apr;

  select value::numeric
  into v_instant_use_assumption
  from proposal_value pv1
  where pv1.field_id = 147
    and object_code = 'PROPOSAL_PRICING';

  select value::numeric
  into v_reamortized_payment_factor_without_itc_paydown
  from proposal_value pv1
  where pv1.field_id = 148
    and object_code = 'PROPOSAL_FINANCE_PRODUCTS';
  raise notice 'v_reamortized_payment_factor_without_itc_paydown = % ',v_reamortized_payment_factor_without_itc_paydown;


  select value::numeric
  into v_net_metring_rate
  from proposal_value pv1
  where pv1.field_id = 92
    and object_code = 'PROPOSAL_PRICING';

  v_instantly_used = v_first_year_production_estimate * v_instant_use_assumption; --TODO
  v_sent_to_grid = v_first_year_production_estimate - coalesce(v_instantly_used, 0);
  v_after_net_metering = v_sent_to_grid * v_net_metring_rate;
  v_adjusted_annual_production = coalesce(v_instantly_used, 0) + coalesce(v_after_net_metering, 0);

  raise notice 'v_instant_use_assumption = % ',v_instant_use_assumption;
  raise notice 'v_net_metring_rate = % ',v_net_metring_rate;
  raise notice 'v_instantly_used = % ',v_instantly_used;
  raise notice 'v_sent_to_grid = % ',v_sent_to_grid;
  raise notice 'v_after_net_metering = % ',v_after_net_metering;
  raise notice 'v_adjusted_annual_production = % ',v_adjusted_annual_production;


  with smart_thermostat as (select proposal_group_uuid
                            from proposal_value
                            where field_id = 117
                              and int_value::bigint = 536
                              and object_code = 'PROPOSAL_EQUIPMENT_ADDERS')
  select value::numeric
  into v_smart_thermostat_value
  from proposal_value pv1
         inner join smart_thermostat st on st.proposal_group_uuid = pv1.proposal_group_uuid
  where pv1.field_id = 119;
  raise notice 'v_smart_thermostat_value = % ',v_smart_thermostat_value;

  with smart_thermostat as (select proposal_group_uuid
                            from proposal_value
                            where field_id = 117
                              and int_value::bigint = 536
                              and object_code = 'PROPOSAL_EQUIPMENT_ADDERS')
  select value::numeric
  into v_energy_efficiency_reduction_thermostat
  from proposal_value pv1
         inner join smart_thermostat st on st.proposal_group_uuid = pv1.proposal_group_uuid
  where pv1.field_id = 145;
  raise notice 'v_energy_efficiency_reduction_thermostat = % ',v_energy_efficiency_reduction_thermostat;

  with light_bulbs as (select proposal_group_uuid
                       from proposal_value
                       where field_id = 117
                         and int_value::bigint = 537
                         and object_code = 'PROPOSAL_EQUIPMENT_ADDERS')
  select value::numeric
  into v_led_light_bulbs_value
  from proposal_value pv1
         inner join light_bulbs st on st.proposal_group_uuid = pv1.proposal_group_uuid
  where pv1.field_id = 119;
  raise notice 'v_led_light_bulbs_value = % ',v_led_light_bulbs_value;

  with light_bulbs as (select proposal_group_uuid
                       from proposal_value
                       where field_id = 117
                         and int_value::bigint = 537
                         and object_code = 'PROPOSAL_EQUIPMENT_ADDERS')
  select value::numeric
  into v_energy_efficiency_reduction_light_bulbs
  from proposal_value pv1
         inner join light_bulbs st on st.proposal_group_uuid = pv1.proposal_group_uuid
  where pv1.field_id = 145;
  raise notice 'v_energy_efficiency_reduction_light_bulbs = % ',v_energy_efficiency_reduction_light_bulbs;

  select value::numeric
  into v_loan_term
  from proposal_value
  where field_id = 110
    and object_code = 'PROPOSAL_FINANCE_PRODUCTS';
  raise notice 'v_loan_term = % ',v_loan_term;

  select value::bigint
  into v_panel_warranty
  from proposal_value
  where field_id = 143
    and object_code = 'PROPOSAL_PANEL_DETAIL';
  raise notice 'v_panel_warranty = % ',v_panel_warranty;

  select value::bigint
  into v_inverter_warranty
  from proposal_value
  where field_id = 143
    and object_code = 'PROPOSAL_INVERTER_DETAILS';
  raise notice 'v_inverter_warranty = % ',v_inverter_warranty;

  v_state_rebate_amount = 0.00::numeric;
  with state_rebates as (select proposal_group_uuid
                         from proposal_value
                         where field_id = 86
                           and object_code = 'PROPOSAL_REBATE')
  select value::numeric
  into v_state_rebate_amount
  from proposal_value pv1
         inner join state_rebates sr2 on sr2.proposal_group_uuid = pv1.proposal_group_uuid
  where pv1.field_id = 98;
  v_state_rebate_amount = coalesce(v_state_rebate_amount, 0);
  raise notice 'v_state_rebate_amount***************************** = % ',v_state_rebate_amount;
  with state_rebates as (select proposal_group_uuid
                         from proposal_value
                         where field_id = 86
                           and object_code = 'PROPOSAL_REBATE')
  select int_value::bigint
  into v_unit_type_state_rebate
  from proposal_value pv1
         inner join state_rebates sr2 on sr2.proposal_group_uuid = pv1.proposal_group_uuid
  where pv1.field_id = 97;


  raise notice 'v_utility_company_id = % ',v_utility_company_id;
--call first formula
  select value::numeric * 100
  into v_panel_degradation_factor
  from proposal_value
  where field_id = 136
    and object_code = 'PROPOSAL_PANEL_DETAIL';
  raise notice 'v_panel_degradation_factor = %',v_panel_degradation_factor;

  select coalesce(value::numeric, 0::numeric)
  into v_dealer_fee
  from proposal_value
  where field_id = 114
    and object_code = 'PROPOSAL_FINANCE_PRODUCTS';

  raise notice 'v_dealer_fee = %',v_dealer_fee;

  select value::numeric
  into v_reamortization_factor
  from proposal_value
  where field_id = 116
    and object_code = 'PROPOSAL_FINANCE_PRODUCTS';

  raise notice 'v_reamortization_factor = %',v_reamortization_factor;

  raise notice 'v_first_year_production_estimate = %',v_first_year_production_estimate;
  raise notice 'v_system_size = %',v_system_size;

  v_production_factor = v_first_year_production_estimate / (v_system_size * 1000);
  raise notice 'v_production_factor = %',v_production_factor;

  v_funding_range =
      (select value::numeric from proposal_value where field_id = 90 and object_code = 'PROPOSAL_PRICING') -
      (select value::numeric from proposal_value where field_id = 91 and object_code = 'PROPOSAL_PRICING');

  raise notice 'v_funding_range = %',v_funding_range;
  v_production_factor_range =
      (select value::numeric from proposal_value where field_id = 89 and object_code = 'PROPOSAL_PRICING') -
      (select value::numeric from proposal_value where field_id = 88 and object_code = 'PROPOSAL_PRICING');

  raise notice 'v_production_factor_range = %',v_production_factor_range;
  v_points_off_south_production_factor = v_production_factor - (select value::numeric
                                                                from proposal_value
                                                                where field_id = 89
                                                                  and object_code = 'PROPOSAL_PRICING');

  raise notice 'v_points_off_south_production_factor = %',v_points_off_south_production_factor;
  v_price_change_per_production_point = coalesce(v_funding_range, 0) / v_production_factor_range; --TODO
  raise notice 'v_price_change_per_production_point = %',v_price_change_per_production_point;

  v_calculated_price_adjustment = v_price_change_per_production_point * v_points_off_south_production_factor;
  raise notice 'v_calculated_price_adjustment = %',v_calculated_price_adjustment;

  v_max_price_adjustment = (select least(greatest((v_funding_range * -1), v_calculated_price_adjustment), 0))::numeric +
                           case when v_friends_and_family is true then .5::numeric else 0::numeric end;
  raise notice 'v_max_price_adjustment = %',v_max_price_adjustment;


  v_adjusted_price_per_wat =
      (select value::numeric from proposal_value where field_id = 90 and object_code = 'PROPOSAL_PRICING') +
      v_max_price_adjustment;
  raise notice 'v_adjusted_price_per_wat = %',v_adjusted_price_per_wat;


  v_initial_system_cost = v_system_size::numeric * 1000::numeric * v_adjusted_price_per_wat::numeric;
  raise notice 'v_initial_system_cost = %',v_initial_system_cost;

  select int_value, value
  into v_financier_id,v_financier
  from proposal_value
  where object_code = 'PROPOSAL_FINANCE_PRODUCTS'
    and field_id = 102;
  raise notice 'v_financier_id = %',v_financier_id;
  raise notice 'v_financier = %',v_financier;


  v_equipment_storage_adder = 0;
  select value
  into v_cash_price_storage
  from proposal_value
  where object_code = 'PROPOSAL_STORAGE_DETAILS'
    and field_id = 157;
  v_cash_price_storage = coalesce(v_cash_price_storage, 0) * (1 + v_dealer_fee);
  v_equipment_storage_adder = coalesce(v_cash_price_storage, 0);
  v_loan_price_storage = v_cash_price_storage;

  raise notice 'v_cash_price_storage = %',v_cash_price_storage;
  raise notice 'v_loan_price_storage = %',v_loan_price_storage;

  raise notice 'v_storage adder based on loan type = %',v_equipment_storage_adder;

  v_equipment_panel_adder = brs.get_equipment_amount_by_type(v_system_size, 'PROPOSAL_PANEL_DETAIL');
  raise notice 'v_equipment_panel_adder = %',v_equipment_panel_adder;

  v_equipment_inverter_adder = brs.get_equipment_amount_by_type(v_system_size, 'PROPOSAL_INVERTER_DETAILS');
  raise notice 'v_equipment_inverter_adder = %',v_equipment_inverter_adder;

  v_misc_adders = brs.get_misc_adder_amount(v_system_size);
  raise notice 'v_misc_adders = %',v_misc_adders;

  select value::numeric
  into v_initial_payment_factor
  from proposal_value
  where field_id = 115
    and object_code = 'PROPOSAL_FINANCE_PRODUCTS';
  raise notice 'v_initial_payment_factor = %',v_initial_payment_factor;

  v_smart_thermostat_adder = 0.00::numeric;
  if v_smart_thermostat is not null and v_smart_thermostat_value is not null then
    v_smart_thermostat_adder = v_smart_thermostat * v_smart_thermostat_value;
  end if;
  raise notice 'v_smart_thermostat_adder = %',v_smart_thermostat_adder;
  v_led_light_bulbs_adder = 0.00::numeric;
  if v_led_light_bulbs is not null and v_led_light_bulbs_value is not null then
    v_led_light_bulbs_adder = v_led_light_bulbs * v_led_light_bulbs_value;
  end if;
  raise notice 'v_led_light_bulbs_adder = %',v_led_light_bulbs_adder;

  v_promotion_cost = 0.00;
  if v_product_id = 293 then
    v_promotion_cost =
        ((coalesce(v_initial_system_cost, 0) + coalesce(v_equipment_storage_adder, 0) +
          coalesce(v_unapproved_zip_code_adder, 0) +
          coalesce(v_equipment_panel_adder, 0) + coalesce(v_equipment_inverter_adder, 0) +
          coalesce(v_misc_adders, 0) + coalesce(v_smart_thermostat_adder, 0) + coalesce(v_led_light_bulbs_adder, 0) +
          coalesce(v_main_panel_upgrade_cost, 0)::numeric +
          coalesce(v_structural_upgrade_cost, 0)::numeric + coalesce(v_reroof_cost, 0)::numeric +
          coalesce(v_tree_trimming_cost, 0)::numeric + coalesce(v_trenching_cost, 0)::numeric +
          coalesce(v_ac_unit_relocation_cost, 0)::numeric) * v_initial_payment_factor * 18)
        /
        (1 - v_dealer_fee - (v_initial_payment_factor * 18));
  elsif v_product_id = 19424 then
    v_promotion_cost =
        ((coalesce(v_initial_system_cost, 0) + coalesce(v_equipment_storage_adder, 0) +
          coalesce(v_unapproved_zip_code_adder, 0) +
          coalesce(v_equipment_panel_adder, 0) + coalesce(v_equipment_inverter_adder, 0) +
          coalesce(v_misc_adders, 0) + coalesce(v_smart_thermostat_adder, 0) + coalesce(v_led_light_bulbs_adder, 0) +
          coalesce(v_main_panel_upgrade_cost, 0)::numeric +
          coalesce(v_structural_upgrade_cost, 0)::numeric + coalesce(v_reroof_cost, 0)::numeric +
          coalesce(v_tree_trimming_cost, 0)::numeric + coalesce(v_trenching_cost, 0)::numeric +
          coalesce(v_ac_unit_relocation_cost, 0)::numeric) *
         (v_reamortization_factor - v_initial_payment_factor) * 42) /
        (1 - v_dealer_fee - (v_reamortization_factor - v_initial_payment_factor) *
                            42);
  end if;
  raise notice 'v_promotion_cost = %',v_promotion_cost;

  raise notice 'v_down_payment_amount = %',v_down_payment_amount;

  select value::numeric
  into v_zone_adder
  from proposal_value
  where field_id = 119
    and object_code = 'PROPOSAL_ZONE_ADDERS';
  raise notice 'v_zone_adder = %',v_zone_adder;
  v_total_loan_amount_before_rebate = ((coalesce(v_initial_system_cost, 0) - coalesce(v_down_payment_amount, 0)) +
                                       coalesce(v_equipment_inverter_adder, 0) +
                                       coalesce(v_equipment_panel_adder, 0) + coalesce(v_equipment_storage_adder, 0) +
                                       coalesce(v_unapproved_zip_code_adder, 0) +
                                       coalesce(v_smart_thermostat_adder, 0) + coalesce(v_led_light_bulbs_adder, 0) +
                                       coalesce(v_main_panel_upgrade_cost, 0)::numeric +
                                       coalesce(v_structural_upgrade_cost, 0)::numeric +
                                       coalesce(v_reroof_cost, 0)::numeric +
                                       coalesce(v_tree_trimming_cost, 0)::numeric +
                                       coalesce(v_trenching_cost, 0)::numeric +
                                       coalesce(v_ac_unit_relocation_cost, 0)::numeric +
                                       coalesce(v_misc_adders, 0) + coalesce(v_promotion_cost, 0) +
                                       coalesce(v_zone_adder, 0));
  raise notice 'v_total_loan_amount_before_rebate = %',v_total_loan_amount_before_rebate;

  v_eto_rebate = 0;
  if v_state_id = 37 then
    with group_record as (select proposal_group_uuid
                          from proposal_value pv
                          where pv.field_id::bigint = 93
                            and int_value::bigint = 451
                            and exists(select pv1.proposal_group_uuid
                                       from proposal_value pv1
                                       where pv.proposal_group_uuid = pv1.proposal_group_uuid
                                         and pv1.field_id = 85
                                         and int_value::bigint = v_utility_company_id))
    select value::numeric,
           (select int_value as unit_type_id
            from proposal_value pv1
                   inner join group_record gr on gr.proposal_group_uuid = pv1.proposal_group_uuid and
                                                 field_id = 97) as unit_type_id
    into v_eto_rebate,v_eto_rebate_unit_type_id
    from proposal_value pv2
           inner join group_record gp on gp.proposal_group_uuid = pv2.proposal_group_uuid
    where pv2.field_id::bigint = 98;

    if v_eto_rebate_unit_type_id = 460 then
      v_eto_rebate = v_eto_rebate * v_system_size * 1000;
    elsif v_eto_rebate_unit_type_id = 458 then
      v_eto_rebate = (coalesce(v_total_loan_amount_before_rebate, 0) +
                      coalesce(v_down_payment_amount, 0)) * coalesce(v_eto_rebate, 0);
    end if;
  end if;
  raise notice 'v_eto_rebate = %',v_eto_rebate;

  v_csu_rebate = 0;
  if v_utility_company_id = 241 then
    with proposal_group_uuid as (select proposal_group_uuid
                                 from proposal_value
                                 where field_id = 85
                                   and object_code = 'PROPOSAL_REBATE'
                                   and int_value::bigint = v_utility_company_id)
    select value::numeric
    into v_csu_rebate
    from proposal_value pv
           inner join proposal_group_uuid pgu on pgu.proposal_group_uuid = pv.proposal_group_uuid
    where field_id = 98
      and object_code = 'PROPOSAL_REBATE';

    with proposal_group_uuid as (select proposal_group_uuid
                                 from proposal_value
                                 where field_id = 85
                                   and object_code = 'PROPOSAL_REBATE'
                                   and int_value::bigint = v_utility_company_id)
    select int_value
    into v_csu_rebate_unit_type_id
    from proposal_value pv
           inner join proposal_group_uuid pgu on pgu.proposal_group_uuid = pv.proposal_group_uuid
    where field_id = 97
      and object_code = 'PROPOSAL_REBATE';

    if v_csu_rebate_unit_type_id = 460 then
      v_csu_rebate = v_csu_rebate * v_system_size * 1000;

    end if;

    raise notice 'v_csu_rebate = %',v_csu_rebate;
    raise notice 'v_csu_rebate_unit_type_id = %',v_csu_rebate_unit_type_id;

    select value::numeric
    into v_inverter_efficiency
    from proposal_value
    where field_id = 142
      and object_code = 'PROPOSAL_INVERTER_DETAILS';
    raise notice 'v_inverter_efficiency = %',v_inverter_efficiency;

    select *
    into v_col_springs_rebate
    from brs.get_colorado_rebate(v_aurora_design_summary, v_csu_rebate,
                                 v_inverter_efficiency);

  end if;
  raise notice 'v_col_springs_rebate = %',v_col_springs_rebate;
  v_above_line_rebate = coalesce(v_eto_rebate, 0) + coalesce(v_csu_rebate, 0);
  raise notice 'v_above_line_rebate = %',v_above_line_rebate;

  v_total_loan_amount =
      (coalesce(v_total_loan_amount_before_rebate, 0) - coalesce(v_above_line_rebate, 0)) / (1 - v_dealer_fee);
  raise notice 'v_total_loan_amount = %',v_total_loan_amount;


  with referral_promotion as (select proposal_group_uuid
                              from proposal_value pv
                              where object_code = 'PROPOSAL_REBATE'
                                and pv.field_id::bigint = 93
                                and pv.int_value::bigint = 535)
  select value::numeric
  into v_referral_promotion
  from proposal_value pv1
         inner join referral_promotion rp on rp.proposal_group_uuid = pv1.proposal_group_uuid
    and pv1.field_id = 98;

  v_referral_promotion = coalesce(v_referral_promotion, 0);
  raise notice 'v_referral_promotion = %',v_referral_promotion;

  v_total_system_cost =
    (coalesce(v_total_loan_amount, 0) + coalesce(v_down_payment_amount, 0) + coalesce(v_above_line_rebate, 0) +
     coalesce(v_referral_promotion, 0));
  raise notice 'v_total_system_cost = %',v_total_system_cost;

  if v_unit_type_state_rebate = 460 then
    v_state_rebate_amount = v_state_rebate_amount * v_system_size * 1000;
  elsif v_unit_type_state_rebate = 458 then
    v_state_rebate_amount = v_state_rebate_amount * v_total_system_cost;
  elsif v_unit_type_state_rebate = 459 then
    v_state_rebate_amount = v_state_rebate_amount;
  elsif v_unit_type_state_rebate = 539 then
    v_state_rebate_amount = coalesce(v_state_rebate_amount, 0) * v_first_year_production_estimate;
  end if;

  raise notice 'v_state_rebate_amount = % ',v_state_rebate_amount;
  raise notice 'v_unit_type_state_rebate = % ',v_unit_type_state_rebate;

  with federal as (select proposal_group_uuid
                   from proposal_value pv
                   where object_code = 'PROPOSAL_REBATE'
                     and pv.field_id::bigint = 93
                     and pv.int_value::bigint = 449)
  select value::numeric,
         (select int_value as unit_type_id
          from proposal_value pv1
                 inner join federal gr on gr.proposal_group_uuid = pv1.proposal_group_uuid and
                                          field_id = 97) as unit_type_id
  into v_federal_tax_incentive_rate,v_federal_unit_type_id
  from proposal_value pv1
         inner join federal f on f.proposal_group_uuid = pv1.proposal_group_uuid
    and pv1.field_id = 98;

  select value::numeric
  into v_non_solar_cap
  from proposal_value
  where field_id = 106
    and object_code = 'PROPOSAL_FINANCIERS';
  raise notice 'v_non_solar_cap = %',v_non_solar_cap;

  v_required_down_payment =
    greatest((coalesce(v_misc_adders, 0) + coalesce(v_other_adder_and_discount_amount, 0) +
              coalesce(v_main_panel_upgrade_cost, 0)::numeric + coalesce(v_unapproved_zip_code_adder, 0) +
              coalesce(v_structural_upgrade_cost, 0)::numeric + coalesce(v_reroof_cost, 0)::numeric +
              coalesce(v_tree_trimming_cost, 0)::numeric + coalesce(v_trenching_cost, 0)::numeric +
              coalesce(v_ac_unit_relocation_cost, 0)::numeric) - (v_total_system_cost * v_non_solar_cap), 0);


  if v_federal_tax_incentive_rate is not null and v_federal_unit_type_id = 460 then
    v_federal_tax_incentive_amount = v_federal_tax_incentive_rate * v_system_size * 1000;
  elsif v_federal_tax_incentive_rate is not null and v_federal_unit_type_id = 458 then
    v_federal_tax_incentive_amount =
        (v_total_loan_amount + v_down_payment_amount + v_required_down_payment) * v_federal_tax_incentive_rate;
  elsif v_federal_tax_incentive_rate is not null and v_federal_unit_type_id = 459 then
    v_federal_tax_incentive_amount = v_federal_tax_incentive_rate;
  end if;
  raise notice 'v_federal_tax_incentive_rate = %',v_federal_tax_incentive_rate;
  raise notice 'v_federal_tax_incentive_amount = %',v_federal_tax_incentive_amount;

  v_monthly_solar_payment = coalesce(v_total_loan_amount, 0) * v_initial_payment_factor;
  raise notice 'v_monthly_solar_payment = %',v_monthly_solar_payment;

  select value::numeric
  into v_current_estimated_cost_per_kwh
  from proposal_value
  where field_id = 87
    and object_code = 'PROPOSAL_PRICING';
  raise notice 'v_current_estimated_cost_per_kwh = %',v_current_estimated_cost_per_kwh;

  select value::numeric
  into v_utility_cost_escalator
  from proposal_value
  where field_id = 94
    and object_code = 'PROPOSAL_PRICING';

  raise notice 'v_utility_cost_escaltor = %',v_utility_cost_escalator;

  v_total_ee_reduction =
    least(((v_estimated_annual_energy_consumption_kwh *
            v_energy_efficiency_reduction_thermostat) + ---Judson said this should be the least
           (v_energy_efficiency_reduction_light_bulbs * v_led_light_bulbs)),
          v_estimated_annual_energy_consumption_kwh * .2);
  raise notice 'v_total_ee_reduction = %',v_total_ee_reduction;

  v_adjusted_annual_consumption =
      coalesce(v_estimated_annual_energy_consumption_kwh::numeric, 0) - coalesce(v_total_ee_reduction, 0);
  raise notice 'v_adjusted_annual_consumption = %',v_adjusted_annual_consumption;

  v_remaining_monthly_electric_bill_25_year_average = brs.get_year_avg_remaining_monthly_electric_bill(
    v_current_estimated_cost_per_kwh,
    v_utility_cost_escalator,
    v_adjusted_annual_consumption,
    v_adjusted_annual_production,
    v_panel_degradation_factor,
    25);
  raise notice 'v_remaining_monthly_electric_bill_25_year_average = %',v_remaining_monthly_electric_bill_25_year_average;

  v_remaining_monthly_electric_bill_30_year_average = brs.get_year_avg_remaining_monthly_electric_bill(
    v_current_estimated_cost_per_kwh,
    v_utility_cost_escalator,
    v_adjusted_annual_consumption,
    v_adjusted_annual_production,
    v_panel_degradation_factor,
    30);
  raise notice 'v_remaining_monthly_electric_bill_30_year_average = %',v_remaining_monthly_electric_bill_30_year_average;

  v_monthly_cost_25_year_average_without_solar = brs.get_monthly_cost_average_without_solar(
    v_current_estimated_cost_per_kwh::numeric,
    v_utility_cost_escalator,
    v_estimated_annual_energy_consumption_kwh::numeric,
    300,
    25);
  raise notice 'v_monthly_cost_25_year_average_without_solar = %',v_monthly_cost_25_year_average_without_solar;

  v_monthly_cost_30_year_average_without_solar = brs.get_monthly_cost_average_without_solar(
    v_current_estimated_cost_per_kwh::numeric,
    v_utility_cost_escalator,
    v_estimated_annual_energy_consumption_kwh::numeric,
    360,
    30);
  raise notice 'v_monthly_cost_30_year_average_without_solar = %',v_monthly_cost_30_year_average_without_solar;

  if v_product_id = 19424 then
    select *
    into v_reamortized_monthly_payment_all_credits_to_loan
    from flow.get_reamortized_monthly_payment((v_apr / 12)::numeric, ((v_loan_term * 12) - 18)::smallint,
                                              (coalesce(v_total_loan_amount, 0) -
                                               coalesce(v_federal_tax_incentive_amount, 0) -
                                               coalesce(v_state_rebate_amount, 0) -
                                               coalesce(v_above_line_rebate, 0))::numeric);
  else
    v_reamortized_monthly_payment_all_credits_to_loan =
        (coalesce(v_total_loan_amount, 0) - coalesce(v_federal_tax_incentive_amount, 0) -
         coalesce(v_state_rebate_amount, 0)) * v_reamortization_factor;
  end if;


  raise notice 'v_reamortized_monthly_payment_all_credits_to_loan = %',v_reamortized_monthly_payment_all_credits_to_loan;

  v_cost_of_solar = v_reamortized_monthly_payment_all_credits_to_loan * 12 * v_loan_term;
  raise notice 'v_cost_of_solar = %',v_cost_of_solar;

  v_monthly_cost_25_year_average_with_solar = v_remaining_monthly_electric_bill_25_year_average +
                                              ((v_reamortized_monthly_payment_all_credits_to_loan * 12 *
                                                v_loan_term) / 300)
    + (v_down_payment_amount / 300);
  raise notice 'v_monthly_cost_25_year_average_with_solar = %',v_monthly_cost_25_year_average_with_solar;

  v_monthly_cost_30_year_average_with_solar = v_remaining_monthly_electric_bill_30_year_average +
                                              ((v_reamortized_monthly_payment_all_credits_to_loan * 12 *
                                                v_loan_term) / 360)
    + (v_down_payment_amount / 360);
  raise notice 'v_monthly_cost_30_year_average_with_solar = %',v_monthly_cost_30_year_average_with_solar;


  v_total_cost_25_years = brs.get_year_cost_by_years(
    v_current_estimated_cost_per_kwh,
    v_utility_cost_escalator,
    v_estimated_annual_energy_consumption_kwh,
    25);
  raise notice 'v_total_cost_25_years = %',v_total_cost_25_years;

  v_total_cost_30_years = brs.get_year_cost_by_years(
    v_current_estimated_cost_per_kwh,
    v_utility_cost_escalator,
    v_estimated_annual_energy_consumption_kwh,
    30);
  raise notice 'v_total_cost_30_years = %',v_total_cost_30_years;

  v_total_savings_25_years = v_total_cost_25_years - (v_monthly_cost_25_year_average_with_solar * 300);
  raise notice 'v_total_savings_25_years = %',v_total_savings_25_years;

  v_total_savings_30_years = v_total_cost_30_years - (v_monthly_cost_30_year_average_with_solar * 360);
  raise notice 'v_total_savings_30_years = %',v_total_savings_30_years;

  v_monthly_cost_today_without_solar =
        v_estimated_annual_energy_consumption_kwh * v_current_estimated_cost_per_kwh / 12;
  raise notice 'v_monthly_cost_today_without_solar = %',v_monthly_cost_today_without_solar;

  v_estimated_offset = (v_adjusted_annual_production::numeric /
                        (v_adjusted_annual_consumption))::numeric;
  raise notice 'v_estimated_offset = %',v_estimated_offset;

  v_monthly_cost_today_avg_remaining_electrical_bill = greatest(0.00::numeric, (v_current_estimated_cost_per_kwh *
                                                                                (v_adjusted_annual_consumption -
                                                                                 v_adjusted_annual_production)) /
                                                                               12);
  raise notice 'v_monthly_cost_today_avg_remaining_electrical_bill = %',v_monthly_cost_today_avg_remaining_electrical_bill;

  if v_product_id = 293 then
    v_initial_monthly_payment_all_credits_to_loan = 0::numeric;
  else
    v_initial_monthly_payment_all_credits_to_loan = v_total_loan_amount * v_initial_payment_factor;
  end if;

  raise notice 'v_initial_monthly_payment_all_credits_to_loan = %',v_initial_monthly_payment_all_credits_to_loan;

  v_initial_monthly_payment_no_credits_to_loan = v_total_loan_amount * v_initial_payment_factor;
  raise notice 'v_initial_monthly_payment_no_credits_to_loan = %',v_initial_monthly_payment_no_credits_to_loan;

  if v_product_id = 19424 then
    select *
    into v_reamortized_monthly_payment_no_credits_to_loan
    from flow.get_reamortized_monthly_payment((v_apr / 12)::numeric, ((v_loan_term * 12) - 18)::smallint,
                                              v_total_loan_amount::numeric);
  else
    v_reamortized_monthly_payment_no_credits_to_loan = v_total_loan_amount * v_reamortization_factor;
  end if;


  raise notice 'v_reamortized_monthly_payment_no_credits_to_loan = %',v_reamortized_monthly_payment_no_credits_to_loan;

  v_monthly_payment_all_credits_to_loan_after_term = 0.00;

  raise notice 'v_monthly_payment_all_credits_to_loan_after_term = %',v_monthly_payment_all_credits_to_loan_after_term;
  v_monthly_payment_no_credits_to_loan_after_term = 0.00;

  raise notice 'v_monthly_payment_no_credits_to_loan_after_term = %',v_monthly_payment_no_credits_to_loan_after_term;

  if v_product_id = 293 then
    v_monthly_cost_today_with_solar = greatest(0, (v_current_estimated_cost_per_kwh *
                                                   (v_adjusted_annual_consumption -
                                                    v_adjusted_annual_production)) / 12);
  elsif v_product_id = 19424 then
    v_monthly_cost_today_with_solar = 0::numeric;
  else
    v_monthly_cost_today_with_solar = greatest(0, (v_current_estimated_cost_per_kwh *
                                                   (v_adjusted_annual_consumption -
                                                    v_adjusted_annual_production)) / 12) +
                                      v_initial_monthly_payment_all_credits_to_loan;
  end if;
  raise notice 'v_monthly_cost_today_with_solar = %',v_monthly_cost_today_with_solar;

  v_net_system_cost =
      v_total_system_cost - coalesce(v_referral_promotion, 0) - coalesce(v_federal_tax_incentive_amount, 0) -
      coalesce(v_above_line_rebate, 0);
  raise notice 'v_net_system_cost = %',v_net_system_cost;

  v_current_estimated_annual_utility_bill =
      v_estimated_annual_energy_consumption_kwh * v_current_estimated_cost_per_kwh;
  raise notice 'v_current_estimated_annual_utility_bill = %',v_current_estimated_annual_utility_bill;

  v_system_production_25_year = brs.get_system_production_25_year(
    v_first_year_production_estimate,
    v_panel_degradation_factor,
    25);
  raise notice 'v_system_production_25_year = %',v_system_production_25_year;


  raise notice 'v_led_light_bulbs = %',v_led_light_bulbs;

  raise notice 'v_smart_thermostat = %',v_smart_thermostat;

  v_secondary_monthly_payment_no_credits_to_loan =
      v_reamortized_monthly_payment_no_credits_to_loan -
      (coalesce(v_reamortized_monthly_payment_all_credits_to_loan, 0) -
       coalesce(v_initial_monthly_payment_all_credits_to_loan, 0));
  raise notice 'v_secondary_monthly_payment_no_credits_to_loan = %',v_secondary_monthly_payment_no_credits_to_loan;

  v_assumed_payment_by_month_18 = v_federal_tax_incentive_amount;
  raise notice 'v_assumed_payment_by_month_18 = %',v_assumed_payment_by_month_18;

  v_loan_type = concat(v_financier || ' ' || v_loan_term);
  raise notice 'v_loan_type = %',v_loan_type;


  if p_insert_prop_log_history is true then
    insert into brs.proposal_log_history(project_id, fullname, address, city, state, zip, phone,
                                         email, loan_term, interest_rate, optional_down_payment,
                                         number_of_leds, number_of_ecobees, cost_per_kwh_before_solar,
                                         bp_plus_promotion, year_1_kwh_output, panel_number,
                                         panel_wattage, system_size, panel, number_of_inverters, inverter_mfg,
                                         inverter_custom_getting,
                                         utility_name, total_yearly_usage_pre_solar,
                                         panel_adder,
                                         panel_adder_cost, total_adder_costs,
                                         loan_fundingw, loan_cost_to_customer,
                                         total_cost_to_customer, offset_percent, dealer_fee, utility_escalator,
                                         annual_degradation, production_factor,
                                         total_cost, down_payment_above_line_incentive, referral_promotion,
                                         loan_funding_amount, loan_amount, itc, state_tax_credit,
                                         monthly_cost_today_before_solar, monthly_solar_costs,
                                         average_monthly_leftover_utility_power_kwh,
                                         average_monthly_power_cost_after_solar,
                                         current_monthly_consumption, consumption_after_ee, kwh_savings_from_ee,
                                         current_yearly_consumption, yearly_consumption_after_ee,
                                         twenty_five_year_cost_of_power_before_solar,
                                         twenty_five_energy_cost, lifetime_savings,
                                         twenty_five_year_remaining_utility_bill,
                                         eighteen_plus_payment_itc_only, month_eighteen_payment_all_incentives,
                                         nineteen_plus_payments_all_incentives, date_created,
                                         promotion_eighteen_months_free,
                                         proposal_date, proposal_nbr, proposal_log_id,
                                         bp_plus_amount, aurora_design_id, loan_type, filename)
    values (v_project_id, v_project_name, v_project_street1, v_city, v_project_state_abbrev,
            v_postal_code, v_contact_phone, v_contact_email, v_loan_term, v_apr, v_down_payment_amount,
            v_led_light_bulbs, v_smart_thermostat, v_current_estimated_cost_per_kwh, v_promotion_cost,
            v_first_year_production_estimate,
            v_panel_quantity,
            v_panel_watts, v_system_size, v_panel_brand, v_panel_quantity, v_inverter_brand, v_inverter_brand,
            v_utility_company,
            v_estimated_annual_energy_consumption_kwh, v_equipment_panel_adder,
            v_equipment_panel_adder * (v_system_size * 1000),
            (coalesce(v_equipment_storage_adder, 0) + coalesce(v_unapproved_zip_code_adder, 0) +
             coalesce(v_equipment_panel_adder, 0) + coalesce(v_equipment_inverter_adder, 0) +
             coalesce(v_misc_adders, 0) + coalesce(v_smart_thermostat_adder, 0) + coalesce(v_led_light_bulbs_adder, 0) +
             coalesce(v_main_panel_upgrade_cost, 0)::numeric +
             coalesce(v_structural_upgrade_cost, 0)::numeric + coalesce(v_reroof_cost, 0)::numeric +
             coalesce(v_tree_trimming_cost, 0)::numeric + coalesce(v_trenching_cost, 0)::numeric +
             coalesce(v_ac_unit_relocation_cost, 0)::numeric), v_adjusted_price_per_wat,
            v_total_loan_amount,
            v_total_system_cost, v_estimated_offset, v_dealer_fee, v_utility_cost_escalator, v_panel_degradation_factor,
            v_production_factor,
            v_total_system_cost, (v_down_payment_amount + v_above_line_rebate), v_referral_promotion,
            v_initial_system_cost, v_total_loan_amount,
            v_federal_tax_incentive_amount, v_state_rebate_amount, v_monthly_cost_today_without_solar,
            v_monthly_solar_payment,
            v_monthly_cost_today_avg_remaining_electrical_bill, v_monthly_cost_today_with_solar,
            (v_estimated_annual_energy_consumption_kwh / 12),
            (v_estimated_annual_energy_consumption_kwh - v_total_ee_reduction), v_total_ee_reduction,
            v_estimated_annual_energy_consumption_kwh,
            (v_estimated_annual_energy_consumption_kwh - v_total_ee_reduction),
            v_monthly_cost_25_year_average_without_solar,
            v_total_cost_25_years, v_total_savings_25_years, v_remaining_monthly_electric_bill_25_year_average,
            v_reamortized_monthly_payment_all_credits_to_loan,
            v_initial_monthly_payment_all_credits_to_loan, v_reamortized_monthly_payment_all_credits_to_loan, now(),
            v_promotion_cost,
            now(), v_proposal_nbr, v_proposal_id, v_promotion_cost,
            v_aurora_design_id, v_loan_type, v_display_name);
  end if;

  return query
    select v_proposal_id,
           v_project_id,
           v_proposal_archived,
           v_contact_first_name,
           v_contact_last_name,
           v_contact_phone,
           v_contact_email,
           v_project_name,
           v_project_street1,
           v_project_street2,
           v_city,
           v_postal_code,
           v_project_state,
           v_project_state_abbrev,
           cast(round(v_monthly_cost_25_year_average_without_solar, 2) as money)::varchar,
           cast(round(v_monthly_cost_30_year_average_without_solar, 2) as money)::varchar,
           cast(round(v_monthly_cost_25_year_average_with_solar, 2) as money)::varchar,
           cast(round(v_remaining_monthly_electric_bill_25_year_average, 2) as money)::varchar,
           cast(round(v_remaining_monthly_electric_bill_30_year_average, 2) as money)::varchar,
           cast(round(v_total_cost_25_years, 2) as money)::varchar,
           cast(round(v_total_cost_30_years, 2) as money)::varchar,
           cast(round(v_total_savings_25_years, 2) as money)::varchar,
           cast(round(v_total_savings_30_years, 2) as money)::varchar,
           cast(round(v_monthly_solar_payment, 2) as money)::varchar,
           cast(round(v_monthly_cost_today_without_solar, 2) as money)::varchar,
           cast(round(v_monthly_cost_today_with_solar, 2) as money)::varchar,
           cast(round(v_monthly_cost_today_avg_remaining_electrical_bill, 2) as money)::varchar,
           cast(round(v_initial_monthly_payment_all_credits_to_loan, 2) as money)::varchar,
           cast(round(v_initial_monthly_payment_no_credits_to_loan, 2) as money)::varchar,
           cast(round(v_reamortized_monthly_payment_all_credits_to_loan, 2) as money)::varchar,
           cast(round(v_reamortized_monthly_payment_no_credits_to_loan, 2) as money)::varchar,
           cast(round(v_monthly_payment_all_credits_to_loan_after_term, 2) as money)::varchar,
           cast(round(v_monthly_payment_no_credits_to_loan_after_term, 2) as money)::varchar,
           v_system_size,
           v_first_year_production_estimate,
           cast(round(v_total_system_cost, 2) as money)::varchar,
           cast(round(v_referral_promotion, 2) as money)::varchar,
           cast(round(v_total_loan_amount, 2) as money)::varchar,
           cast(round(v_federal_tax_incentive_amount, 2) as money)::varchar,
           round(v_federal_tax_incentive_rate, 2) * 100,
           cast(round(v_net_system_cost, 2) as money)::varchar,
           v_utility_company,
           v_estimated_annual_energy_consumption_kwh,
           cast(round(v_current_estimated_annual_utility_bill, 2) as money)::varchar,
           cast(round(v_current_estimated_cost_per_kwh, 4) as money)::varchar,
           round(v_utility_cost_escalator * 100, 2),
           cast(round(v_state_rebate_amount, 2) as money)::varchar,
           cast(round(v_eto_rebate, 2) as money)::varchar,
           cast(round(v_csu_rebate, 2) as money)::varchar,
           round(v_apr * 100, 2),
           v_loan_term,
           cast(round(v_assumed_payment_by_month_18, 2) as money)::varchar,
           round(v_panel_degradation_factor, 2),
           TO_CHAR(round(v_system_production_25_year, 0), 'FM9,999,999'),--comma not money
           round(round(v_estimated_offset, 2) * 100, 0),
           v_led_light_bulbs,
           v_smart_thermostat,
           round(v_total_ee_reduction, 0),
           v_panel_warranty,
           v_inverter_warranty,
           cast(round(v_down_payment_amount, 2) as money)::varchar,
           v_version_id,
           v_project_process_step_id,
           v_friends_and_family,
           round(v_production_factor, 2),
           round(v_funding_range, 2),
           round(v_production_factor_range, 2),
           round(v_points_off_south_production_factor, 2),
           round(v_price_change_per_production_point, 2),
           round(v_calculated_price_adjustment, 2),
           round(v_max_price_adjustment, 2),
           round(v_adjusted_price_per_wat, 2),
           round(v_initial_system_cost, 2),
           round(v_promotion_cost, 2),
           round(v_equipment_inverter_adder, 2),
           round(v_equipment_panel_adder, 2),
           round(v_equipment_storage_adder, 2),
           round(v_misc_adders, 2),
           v_panel_brand_id,
           v_panel_watts,
           round(v_above_line_rebate, 2),
           v_state_id,
           v_utility_company_id,
           v_dealer_fee,
           v_eto_rebate_unit_type_id,
           v_federal_unit_type_id,
           round(v_inverter_efficiency, 2),
           v_initial_payment_factor,
           v_reamortization_factor,
           v_product_id,
           v_smart_thermostat_value,
           round(v_smart_thermostat_adder, 2),
           v_led_light_bulbs_value,
           round(v_led_light_bulbs_adder, 2),
           round(v_energy_efficiency_reduction_light_bulbs, 2),
           round(v_energy_efficiency_reduction_thermostat, 2),
           v_adjusted_annual_consumption,
           v_instantly_used,
           v_sent_to_grid,
           v_after_net_metering,
           v_adjusted_annual_production,
           round(v_instant_use_assumption, 2),
           round(v_net_metring_rate, 2),
           round(v_cost_of_solar, 2),
           cast(round(v_monthly_cost_30_year_average_with_solar, 2) as money)::varchar,
           v_reamortized_payment_factor_without_itc_paydown,
           cast(round(v_secondary_monthly_payment_no_credits_to_loan, 2) as money)::varchar,
           v_panel_brand,
           v_panel_quantity,
           v_inverter_brand_id,
           v_inverter_brand,
           v_aurora_design_id,
           v_product_name,
           v_proposal_nbr,
           v_other_adder_and_discount,
           cast(round(v_other_adder_and_discount_amount, 2) as money)::varchar,
           v_adder,
           round(v_non_solar_cap, 2),
           cast(round(v_required_down_payment, 2) as money)::varchar,
           v_storage_type_id,
           v_storage_type,
           v_financier,
           v_financier_id,
           cast(round(v_loan_price_storage, 2) as money)::varchar,
           cast(round(v_cash_price_storage, 2) as money)::varchar,
           round(v_main_panel_upgrade_cost, 2),
           round(v_structural_upgrade_cost, 2),
           round(v_reroof_cost, 2),
           round(v_tree_trimming_cost, 2),
           round(v_trenching_cost, 2),
           round(v_ac_unit_relocation_cost, 2),
           round(v_total_loan_amount_before_rebate, 2),
           round(v_zone_adder, 2),
           v_loan_type,
           round(v_unapproved_zip_code_adder, 2),
           v_csu_rebate_unit_type_id;

  drop table proposal_value;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;


