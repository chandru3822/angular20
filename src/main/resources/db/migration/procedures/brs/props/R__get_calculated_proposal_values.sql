drop function if exists brs.get_calculated_proposal_values(bigint, boolean, boolean);
drop function if exists brs.get_calculated_proposal_values(bigint, boolean);
drop type if exists brs.calculated_proposal_value cascade;

create type brs.calculated_proposal_value as
(
  proposal_id                                        bigint,
  project_id                                         bigint,
  proposal_archived                                  boolean,
  contact_first_name                                 varchar,
  contact_last_name                                  varchar,
  contact_phone                                      varchar,
  contact_email                                      varchar,
  project_name                                       varchar,
  project_street1                                    varchar,
  project_street2                                    varchar,
  city                                               varchar,
  postal_code                                        varchar,
  project_state                                      varchar,
  project_state_abbrev                               varchar,
  monthly_cost_25_year_average_without_solar         varchar,
  monthly_cost_30_year_average_without_solar         varchar,
  monthly_cost_25_year_average_with_solar            varchar,
  remaining_monthly_electric_bill_25_year_average    varchar,
  remaining_monthly_electric_bill_30_year_average    varchar,
  total_cost_25_years                                varchar,
  total_cost_30_years                                varchar,
  total_savings_25_years                             varchar,
  total_savings_30_years                             varchar,
  monthly_solar_payment                              varchar,
  monthly_cost_today_without_solar                   varchar,
  monthly_cost_today_with_solar                      varchar,
  monthly_cost_today_avg_remaining_electrical_bill   varchar,
  initial_monthly_payment_all_credits_to_loan        varchar,
  initial_monthly_payment_no_credits_to_loan         varchar,
  reamortized_monthly_payment_all_credits_to_loan    varchar,
  reamortized_monthly_payment_no_credits_to_loan     varchar,
  monthly_payment_all_credits_to_loan_after_term     varchar,
  monthly_payment_no_credits_to_loan_after_term      varchar,
  system_size                                        numeric,
  system_size_ac                                     numeric,
  first_year_production_estimate                     bigint,
  total_system_cost                                  varchar,
  referral_promotion                                 varchar,
  total_loan_amount                                  varchar,
  federal_tax_incentive_amount                       varchar,
  federal_tax_incentive_rate                         numeric,
  net_system_cost                                    varchar,
  utility_company                                    text,
  estimated_annual_energy_consumption_kwh            bigint,
  current_estimated_annual_utility_bill              varchar,
  current_estimated_cost_per_kwh                     varchar,
  utility_cost_escalator                             numeric,
  ill_srec_rebate_amount                             varchar,
  apr                                                numeric,
  loan_term                                          numeric,
  assumed_payment_by_month_18                        varchar,
  panel_degradation_factor                           numeric,
  system_production_25_year                          text,
  estimated_offset                                   numeric,
  led_light_bulbs                                    bigint,
  smart_thermostat                                   bigint,
  total_ee_reduction                                 numeric,
  down_payment_amount                                varchar,
  version_id                                         bigint,
  project_process_step_id                            bigint,
  friends_and_family                                 boolean,
  production_factor                                  numeric,
  funding_range                                      numeric,
  production_factor_range                            numeric,
  points_off_south_production_factor                 numeric,
  price_change_per_production_point                  numeric,
  calculated_price_adjustment                        numeric,
  max_price_adjustment                               numeric,
  adjusted_price_per_wat                             numeric,
  initial_system_cost                                numeric,
  promotion_cost                                     numeric,
  equipment_inverter_adder                           numeric,
  equipment_panel_adder                              numeric,
  equipment_storage_adder                            numeric,
  misc_adders                                        numeric,
  panel_brand_id                                     bigint,
  panel_watts                                        bigint,
  above_line_rebate                                  numeric,
  state_id                                           bigint,
  utility_company_id                                 bigint,
  dealer_fee                                         numeric,
  eto_rebate_unit_type_id                            bigint,
  federal_unit_type_id                               bigint,
  inverter_efficiency                                numeric,
  initial_payment_factor                             numeric,
  reamortization_factor                              numeric,
  product_id                                         numeric,
  smart_thermostat_value                             numeric,
  smart_thermostat_adder                             numeric,
  led_light_bulbs_value                              numeric,
  led_light_bulbs_adder                              numeric,
  energy_efficiency_reduction_light_bulbs            numeric,
  energy_efficiency_reduction_thermostat             numeric,
  adjusted_annual_consumption                        numeric,
  instantly_used                                     numeric,
  sent_to_grid                                       numeric,
  after_net_metering                                 numeric,
  adjusted_annual_production                         numeric,
  instant_use_assumption                             numeric,
  net_metring_rate                                   numeric,
  cost_of_solar                                      numeric,
  monthly_cost_30_year_average_with_solar            varchar,
  reamortized_payment_factor_without_itc_paydown     numeric,
  secondary_monthly_payment_no_credits_to_loan       varchar,
  panel_brand                                        varchar,
  panel_quantity                                     bigint,
  inverter_brand_id                                  bigint,
  inverter_brand                                     varchar,
  aurora_design_id                                   text,
  product_name                                       varchar,
  proposal_nbr                                       bigint,
  other_adder_and_discount                           text,
  other_adder_and_discount_amount                    varchar,
  adder_name                                         text,
  non_solar_cap                                      numeric,
  required_down_payment                              varchar,
  required_down_payment_number                       numeric,
  storage_type_id                                    bigint,
  storage_type                                       varchar,
  financier                                          varchar,
  financier_id                                       bigint,
  storage_cost_with_fees                                 varchar,
  cash_price_storage                                 varchar,
  main_panel_upgrade_cost                            numeric,
  structural_upgrade_cost                            numeric,
  reroof_cost                                        numeric,
  tree_trimming_cost                                 numeric,
  trenching_cost                                     numeric,
  ac_unit_relocation_cost                            numeric,
  total_amount_to_be_financed                        numeric,
  zone_adder                                         numeric,
  loan_type                                          varchar,
  unapproved_zip_code_adder                          numeric,
  csu_rebate_unit_type_id                            integer,
  financial_option                                   varchar,
  check_from_br                                      varchar,
  site_survey_time_estimate                          integer,
  site_survey_resource_type_yn                       text,
  site_survey_resource_type                          text,
  site_survey_items                                  text,
  number_of_batteries                                numeric,
  estimated_backup_days                              numeric,
  solar_rebate_for_hic                               numeric,
  total_square_footage                               numeric,
  net_payment_from_customer                          varchar,
  initial_monthly_payment_all_credits_to_loan_bpPlus varchar,
  below_line_rebate                                  varchar,
  below_line_rebate_number                           numeric,
  above_line_rebate_without_odoe                     varchar,
  odoe_rebate                                        varchar,
  above_line_rebate_without_odoe_number              numeric,
  odoe_rebate_number                                 numeric,
  deposit_amount                                     varchar,
  deposit_amount_number                              numeric,
  has_critter_guard boolean,
 -- commission_details json,
  qualifies_for_incentive       boolean,
  above_the_line_utility_rebate_amount varchar,
  below_the_line_utility_rebate_amount varchar,
  below_the_line_utility_rebate_amount_number numeric,
  above_the_line_state_rebate_amount varchar,
  below_the_line_state_rebate_amount varchar,
  below_the_line_state_rebate_amount_number numeric,
  all_rebates jsonb,
  eto_rebate_amount varchar,
  eto_rebate_number numeric,
  virginia_srec_rebate_amount varchar,
  virginia_srec_rebate_amount_number numeric,
  storage_capacity numeric,
  nominal_power numeric,
  battery_manufacturers_warranty bigint,
  battery_workmanship_warranty bigint,
  virtual_sales_price_adjustment numeric,
  red_line_funding_amount numeric,
  closer_gen_discount numeric,
  small_system_size_adder_amount numeric,
  denver_care_rebate_amount varchar,
  denver_care_rebate_amount_number numeric,
  denver_care_rebate_mpu_amount_number numeric,
  denver_care_rebate_mpu_amount  varchar,
  denver_care_rebate_battery_amount_number numeric,
  denver_care_rebate_battery_amount varchar,
  rete_reamortized_monthly_payment_all_credits_to_loan varchar,
  rete_incentive_applied boolean,
  rete_depreciation_incentive_amount_number numeric,
  rete_depreciation_incentive_amount varchar,
  rete_adder  varchar,
  setter_lead_cost numeric,
  digital_lead_cost numeric,
  lead_cost_adder numeric,
  grid_tied_battery boolean,
  proposal_template_id bigint
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
  reamortized_payment_factor_without_itc_paydown numeric,
  proposal_id                                    bigint,
  project_id                                     bigint,
  proposal_archived                              boolean,
  panel_brand                                    character varying,
  aurora_design_id                               text,
  proposal_nbr                                   bigint,
  storage_type_id                                bigint,
  financier                                      varchar,
  financier_id                                   bigint,
  cash_price_storage                             numeric,
  total_amount_to_be_financed       numeric,
  zone_adder                                     numeric,
  loan_type                                      varchar,
  unapproved_zip_code_adder                      numeric,
  csu_rebate_unit_type_id                        integer,
  financial_option                               varchar,
  site_survey_time_estimate                      integer,
  site_survey_resource_type_yn                   text,
  site_survey_resource_type                      text,
  site_survey_items                              text,
  all_rebates jsonb
);

CREATE OR REPLACE FUNCTION brs.get_calculated_proposal_values(
  p_proposal_id bigint,
  p_insert_prop_log_history boolean default false
)

  RETURNS TABLE
          (
            like brs.calculated_proposal_value
          )
AS
$BODY$
declare
  v_aurora_design_summary                               jsonb;
  v_version_id                                          bigint;
  v_project_process_step_id                             bigint;
  v_estimated_annual_energy_consumption_kwh             bigint;
  v_first_year_production_estimate                      bigint;
  v_friends_and_family                                  boolean;
  v_system_size                                         numeric;
  v_system_size_ac                                      numeric;
  v_production_factor                                   numeric;
  v_funding_range                                       numeric;
  v_production_factor_range                             numeric;
  v_points_off_south_production_factor                  numeric;
  v_price_change_per_production_point                   numeric;
  v_calculated_price_adjustment                         numeric;
  v_max_price_adjustment                                numeric;
  v_initial_system_cost                                 numeric;
  v_promotion_cost                                      numeric;
  v_equipment_inverter_adder                            numeric;
  v_equipment_panel_adder                               numeric;
  v_equipment_storage_adder                             numeric;
  v_misc_adders                                         numeric;
  v_panel_brand_id                                      bigint;
  v_panel_watts                                         bigint;
  v_above_line_rebate                                   numeric;
  v_state_id                                            bigint;
  v_utility_company_id                                  bigint;
  v_total_loan_amount                                   numeric;
  v_total_amount_to_be_financed                         numeric;
  v_down_payment_amount                                 numeric;
  v_total_system_cost                                   numeric;
  v_panel_degradation_factor                            numeric;
  v_federal_tax_incentive_rate                          numeric;
  v_federal_tax_incentive_amount                        numeric;
  v_monthly_solar_payment                               numeric;
  v_monthly_cost_25_year_average_without_solar          numeric;
  v_monthly_cost_30_year_average_without_solar          numeric;
  v_monthly_cost_25_year_average_with_solar             numeric;
  v_remaining_monthly_electric_bill_25_year_average     numeric;
  v_remaining_monthly_electric_bill_30_year_average     numeric;
  v_total_cost_25_years                                 numeric;
  v_total_cost_30_years                                 numeric;
  v_total_savings_25_years                              numeric;
  v_total_savings_30_years                              numeric;
  v_dealer_fee                                          numeric;
  v_eto_rebate_unit_type_id                             bigint;
  v_federal_unit_type_id                                bigint;
  v_monthly_cost_today_without_solar                    numeric;
  v_monthly_cost_today_with_solar                       numeric;
  v_monthly_cost_today_avg_remaining_electrical_bill    numeric;
  v_initial_monthly_payment_all_credits_to_loan         numeric;
  v_initial_monthly_payment_no_credits_to_loan          numeric;
  v_reamortized_monthly_payment_all_credits_to_loan     numeric;
  v_reamortized_monthly_payment_no_credits_to_loan      numeric;
  v_monthly_payment_all_credits_to_loan_after_term      numeric;
  v_monthly_payment_no_credits_to_loan_after_term       numeric;
  v_referral_promotion                                  numeric;
  v_net_system_cost                                     numeric;
  v_utility_company                                     text;
  v_current_estimated_cost_per_kwh                      numeric;
  v_current_estimated_annual_utility_bill               numeric;
  v_system_production_25_year                           numeric;
  v_estimated_offset                                    numeric;
  v_led_light_bulbs                                     bigint;
  v_apr                                                 numeric;
  v_smart_thermostat                                    bigint;
  v_loan_term                                           numeric;
  v_total_ee_reduction                                  numeric;
  v_assumed_payment_by_month_18                         numeric;
  v_inverter_efficiency                                 numeric;
  v_initial_payment_factor                              numeric;
  v_col_springs_rebate                                  numeric;
  v_utility_cost_escalator                              numeric;
  v_reamortization_factor                               numeric;
  v_product_id                                          numeric;
  v_smart_thermostat_value                              numeric;
  v_smart_thermostat_adder                              numeric;
  v_led_light_bulbs_value                               numeric;
  v_led_light_bulbs_adder                               numeric;
  v_energy_efficiency_reduction_thermostat              numeric;
  v_energy_efficiency_reduction_light_bulbs             numeric;
  v_adjusted_annual_consumption                         numeric;
  v_instantly_used                                      numeric;
  v_sent_to_grid                                        numeric;
  v_after_net_metering                                  numeric;
  v_adjusted_annual_production                          numeric;
  v_instant_use_assumption                              numeric;
  v_net_metring_rate                                     numeric;
  v_cost_of_solar                                        numeric;
  v_monthly_cost_30_year_average_with_solar              numeric;
  v_reamortized_payment_factor_without_itc_paydown       numeric;
  v_secondary_monthly_payment_no_credits_to_loan         numeric;
  v_proposal_id                                          bigint;
  v_project_id                                           bigint;
  v_proposal_archived                                    boolean;
  v_contact_first_name                                   character varying;
  v_contact_last_name                                    character varying;
  v_contact_phone                                        character varying;
  v_contact_email                                        character varying;
  v_project_name                                         character varying;
  v_project_street1                                      character varying;
  v_project_street2                                      character varying;
  v_city                                                 character varying;
  v_postal_code                                          character varying;
  v_project_state                                        character varying;
  v_project_state_abbrev                                 character varying;
  v_panel_brand                                          character varying;
  v_panel_quantity                                       bigint;
  v_inverter_brand                                       varchar;
  v_inverter_brand_id                                    bigint;
  v_aurora_design_id                                     text;
  v_product_name                                         character varying;
  v_proposal_nbr                                         bigint;
  v_display_name                                         varchar;
  v_other_adder_and_discount                             text;
  v_other_adder_and_discount_amount                      numeric;
  v_adder                                                text;
  v_required_down_payment                                numeric;
  v_non_solar_cap                                        numeric;
  v_storage_type_id                                      bigint;
  v_storage_type                                         varchar;
  v_financier                                            varchar;
  v_financier_id                                         bigint;
  v_cash_price_storage                                   numeric;
  v_storage_cost_with_fees                               numeric;
  v_main_panel_upgrade_cost                              numeric;
  v_structural_upgrade_cost                              numeric;
  v_reroof_cost                                          numeric;
  v_tree_trimming_cost                                   numeric;
  v_trenching_cost                                       numeric;
  v_ac_unit_relocation_cost                              numeric;
  v_zone_adder                                           numeric;
  v_loan_type                                            varchar;
  v_unapproved_zip_code_adder                            numeric;
  v_csu_rebate_unit_type_id                              integer;
  v_financial_option                                     varchar;
  v_check_from_br                                        numeric;
  v_site_survey_time_adders                              bigint[];
  v_site_survey_time_estimate                            integer;
  v_site_survey_resource_type_yn                         text;
  v_site_survey_resource_type                            text;
  v_site_survey_items                                    text;
  v_number_of_batteries                                  numeric;
  v_estimated_backup_days                                numeric(10, 1);
  v_solar_rebate_for_hic                                 numeric;
  v_total_square_footage                                 numeric;
  v_net_payment_from_customer                            numeric(10, 2);
  v_total_system_cost_before_rebates                     numeric;
  v_srec_realization                                     numeric;
  v_il_srec_greater_25                                   numeric;
  v_il_srec_less_10                                      numeric;
  v_il_srec_between_10_25                                numeric;
  v_ill_srec_rebate_amount                               numeric;
  v_srec_rebate_cap_percent_of_total                     numeric;
  v_srec_rebate_cap_amount                               numeric;
  v_financial_product_id                                 bigint;
  v_production_factor_east_west                          numeric;
  v_production_factor_south                              numeric;
  v_maximum_funding_amount_per_watt                      numeric;
  v_minimum_funding_amount_per_watt                      numeric;
  v_unit_type_id_smart_thermostat                        bigint;
  v_unit_type_id_led                                     bigint;
  v_misc_adders_array                                    bigint[];
  v_panel_unit_type_id                                   bigint;
  v_panel_adder_amount                                   numeric;
  v_panel_states                                         bigint[];
  v_inverter_unit_type_id                                bigint;
  v_inverter_adder_amount                                numeric;
  v_small_system_size_adder_amount                       numeric;
  v_small_system_size_adder                              numeric;
  v_small_system_size_unit_type_id                       bigint;
  v_small_system_size_value                              numeric;
  v_rebate_amount                                        numeric;
  v_rebate_cap_amount                                    numeric;
  v_rebate_cap_percentage                                numeric;
  v_odoe_income_status                                   bigint;
  v_battery_rebate_amount                                numeric;
  v_battery_rebate_cap_percent_of_total                  numeric;
  v_battery_rebate_cap_amount                            numeric;
  v_odoe_rebate                                          numeric;
  v_system_size_cutoff                                   numeric;
  v_commission_strategy_id                               bigint;
  v_closer_gen_discount                                  numeric;
  v_high_commission_funding_amount_per_watt              numeric;
  v_redline_utility_adder                                numeric;
  v_desired_commission_amount                            numeric;
  v_source_id                                            bigint;
  v_adjusted_price_per_watt                              numeric;
  v_lead_source_discount                                 numeric;
  v_redline_markup                                       numeric;
  v_admin_discount                                       numeric;
  v_storage_capacity                                     numeric;
  v_required_down_payment_number                         numeric;
  v_minimum_odoe_tsrf                                    bigint;
  v_odoe_rebate_id                                       bigint;
  v_virginia_srec_rebate_amount                          numeric;
  v_virginia_srec_rate                                   numeric;
  v_initial_monthly_payment_all_credits_to_loan_bpPlus   numeric;
  v_above_line_rebate_without_odoe                       numeric;
  v_ancillary_cost_portion_of_loan_before_rebates        numeric;
  v_additional_fee_for_exceeding_non_solar_threshold     numeric;
  v_non_solar_threshold_for_additional_fee               numeric;
  v_maximum_dollar_per_watt_for_solar                    numeric;
  v_no_ancillary_amount_to_finance                       numeric;
  v_dealer                                               bigint;
  v_dealer_markup                                        numeric;
  v_dealer_redline_price                                 numeric;
  v_deposit_amount                                       numeric;
  v_deposit_amount_number                                numeric;
  v_has_critter_guard                                    boolean;
  v_storage_name                                         text;
  v_storage_id                                           bigint;
  v_storage_brand                                        text;
  v_storage_brand_id                                     bigint;
  v_qualifies_for_incentive                              bigint[];
  v_qualifies_for_incentive_boolean                      boolean;
  v_below_line_rebate                                    numeric;
  v_above_the_line_utility_rebate_amount                 numeric;
  v_above_the_line_utility_rebates                       jsonb;
  v_rebates                                              jsonb;
  v_below_the_line_utility_rebate_amount                 numeric;
  v_below_the_line_utility_rebates                       jsonb;
  v_below_the_line_state_rebate_amount                   numeric;
  v_below_the_line_state_rebates                         jsonb;
  v_above_the_line_state_rebate_amount                   numeric;
  v_above_the_line_state_rebates                         jsonb;
  v_referral_promotion_rebate_name                       text;
  v_ill_srec_rebate_name                                 text;
  v_virginia_srec_rebate_name                            text;
  v_odoe_rebate_name                                     text;
  v_federal_tax_incentive_rebate_name                    text;
  v_below_the_line_state_rebate_first_year_cap_amount    numeric;
  v_below_the_line_utility_rebate_first_year_cap_amount  numeric;
  v_total_rebate_first_year_cap_amount                   numeric;
  v_eto_rebate_amount                                    numeric;
  v_nominal_power                                        numeric;
  v_battery_manufacturers_warranty                       bigint;
  v_battery_workmanship_warranty                         bigint;
  v_adder_amount                                         numeric;
  v_company_process_id                                   integer;
  v_virtual_sales_price_adjustment                       numeric;
  v_virtual_sales_base_price                             numeric;
  v_total_ancillary_costs                                numeric;
  v_solar_only_cap_down_payment                          numeric;
  v_ancillary_percent_cap_down_payment                   numeric;
  v_battery_cap_down_payment                             numeric;
  v_all_ancillary_costs                                  jsonb;
  v_denver_care_rebate_amount                            numeric;
  v_denver_care_rebate_amount_number                     numeric;
  v_site_survey_resource_type_id                         bigint;
  v_loan_term_id                                         bigint;
  v_other_oregon_discount                                numeric;
  v_site_survey_item_ids                                 bigint[];
  v_panel_model                                          text;
  v_financed_pv_price_per_watt_to_customer               numeric;
  v_first_year_avoided_bill                              numeric;
  v_max_base_price_per_watt                              numeric;
  v_maximum_funding_amount_discount                      numeric;
  v_minimum_funding_amount_discount                      numeric;
  v_redline_funding_amount_discount                      numeric;
  v_virtual_sales_price_amount_discount                  numeric;
  v_qualifies_for_swr                                    boolean;
  v_proposal_qualifies_for_swr                           boolean;
  v_kwh_rate_discount                                    numeric;
  v_denver_care_rebate_battery_amount                    numeric;
  v_denver_care_rebate_mpu_amount                        numeric;
  v_rete_incentive_applied                               boolean;
  v_rete_depreciation_incentive_amount                   numeric;
  v_rete_reamortized_monthly_payment_all_credits_to_loan numeric;
  v_rete_adder                                           numeric;
  v_base_price_per_watt                                  numeric;
  v_minimum_price_per_watt numeric;
v_closer_gen_source_ids bigint[];
  v_setter_lead_cost numeric;
  v_digital_lead_cost numeric;
  v_lead_cost_adder numeric;
  v_grid_tied_battery boolean;
  v_storage_heat_detector_adder numeric;
v_grid_tied_battery_not_allowed boolean;
v_storage_states bigint[];
v_reamortized_monthly_payment_for_roi_calcs numeric;
v_intial_monthly_payment_for_solar_only_costs numeric;
v_proposal_template_id bigint;
BEGIN

  select (select string_to_array(value, ',')
          from flow.company_configuration_value
          where code = 'CLOSER_GEN_SOURCE_IDS')::bigint[]
  into v_closer_gen_source_ids;

  select proposal_id,
         version_id,
         project_process_step_id,
         friends_and_family,
         down_payment_amount,
         product_id,
         product_name,
         project_id,
         proposal_archived,
         contact_first_name,
         contact_last_name,
         project_name,
         project_street1,
         project_street2,
         city,
         postal_code,
         project_state,
         project_state_abbrev,
         contact_phone,
         contact_email,
         other_adder_and_discount_amount,
         other_adder_and_discount,
         storage_type_id,
         storage_type,
         main_panel_upgrade_cost,
         structural_upgrade_cost,
         reroof_cost,
         tree_trimming_cost,
         trenching_cost,
         ac_unit_relocation_cost,
         total_square_footage,
         proposal_nbr,
         display_name,
         financial_product_id,
         odoe_income_status,
         desired_commission_amount,
         source_id,
         admin_discount,
         dealer,
         dealer_markup,
         estimated_annual_energy_consumption_kwh,
         first_year_production_estimate,
         system_size,
         panel_watts,
         panel_brand_id,
         panel_brand,
         state_id,
         utility_company_id,
         utility_company,
         aurora_design_summary,
         led_light_bulbs,
         smart_thermostat,
         panel_quantity,
         inverter_brand_id,
         inverter_brand,
         aurora_design_id,
         unapproved_zip_code_adder,
         site_survey_time_adders,
         misc_adders_array,
         commission_strategy_id,
         qualifies_for_incentive,
         adder_amount,
         company_process_id,
         virtual_sales_price_adjustment,
         system_size_ac,
         panel_model,
         qualifies_for_swr,
         rete_incentive_applied,
         rete_depreciation_incentive_amount,
         base_price_per_watt,
         proposal_template_id
  into v_proposal_id,
    v_version_id,
    v_project_process_step_id,
    v_friends_and_family,
    v_down_payment_amount,
    v_product_id,
    v_product_name,
    v_project_id,
    v_proposal_archived,
    v_contact_first_name,
    v_contact_last_name,
    v_project_name,
    v_project_street1,
    v_project_street2,
    v_city,
    v_postal_code,
    v_project_state,
    v_project_state_abbrev,
    v_contact_phone,
    v_contact_email,
    v_other_adder_and_discount_amount,
    v_other_adder_and_discount,
    v_storage_type_id,
    v_storage_type,
    v_main_panel_upgrade_cost,
    v_structural_upgrade_cost,
    v_reroof_cost,
    v_tree_trimming_cost,
    v_trenching_cost,
    v_ac_unit_relocation_cost,
    v_total_square_footage,
    v_proposal_nbr,
    v_display_name,
    v_financial_product_id,
    v_odoe_income_status,
    v_desired_commission_amount,
    v_source_id,
    v_admin_discount,
    v_dealer,
    v_dealer_markup,
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
    v_unapproved_zip_code_adder,
    v_site_survey_time_adders,
    v_misc_adders_array,
    v_commission_strategy_id,
    v_qualifies_for_incentive,
    v_adder_amount,
    v_company_process_id,
    v_virtual_sales_price_adjustment,
    v_system_size_ac,
    v_panel_model,
    v_proposal_qualifies_for_swr,
    v_rete_incentive_applied,
    v_rete_depreciation_incentive_amount,
    v_base_price_per_watt,
    v_proposal_template_id
  from brs.get_proposal_details(p_proposal_id);

  select string_agg(lov.name, ',')
  into v_adder
  from brs.proposal prop
         inner join brs.proposal_custom_field_value pcfv on prop.id = pcfv.proposal_id and
                                                            pcfv.custom_field_group_assignment_id = 146
         inner join brs.list_of_value lov on lov.id = any (pcfv.int_array_value)
  where prop.id = p_proposal_id;


  --raise notice 'v_system_size_ac = %',v_system_size_ac;
  --raise notice 'v_panel_model = %',v_panel_model;
  --raise notice 'v_first_year_production_estimate = %',v_first_year_production_estimate;
  --raise notice 'v_system_size = %',v_system_size;
  --raise notice 'v_estimated_annual_energy_consumption_kwh = %',v_estimated_annual_energy_consumption_kwh;
  --raise notice 'v_product_id = % ',v_product_id;
  --raise notice 'v_unapproved_zip_code_adder = % ',v_unapproved_zip_code_adder;
  --raise notice 'v_version_id = % ',v_version_id;
  --raise notice 'v_project_process_step_id = % ',v_project_process_step_id;
  --raise notice 'v_friends_and_family = % ',v_friends_and_family;
  --raise notice 'v_panel_watts = % ',v_panel_watts;
  --raise notice 'v_panel_brand_id = % ',v_panel_brand_id;
  --raise notice 'v_state_id = % ',v_state_id;
  --raise notice 'v_postal_code = % ',v_postal_code;
  --raise notice 'v_main_panel_upgrade_cost = % ',v_main_panel_upgrade_cost;
  --raise notice 'v_structural_upgrade_cost = % ',v_structural_upgrade_cost;
  --raise notice 'v_reroof_cost = % ',v_reroof_cost;
  --raise notice 'v_tree_trimming_cost = % ',v_tree_trimming_cost;
  --raise notice 'v_trenching_cost = % ',v_trenching_cost;
  --raise notice 'v_ac_unit_relocation_cost = % ',v_ac_unit_relocation_cost;
  --raise notice 'v_qualifies_for_incentive = % ',v_qualifies_for_incentive;
  --raise notice 'v_rete_incentive_applied = % ',v_rete_incentive_applied;
  --raise notice 'v_rete_depreciation_incentive_amount = % ',v_rete_depreciation_incentive_amount;
  --raise notice 'v_misc_adders_array = % ',v_misc_adders_array;

  select setter_lead_cost, digital_lead_cost
  into v_setter_lead_cost, v_digital_lead_cost
  from brs.get_lead_cost_details(v_version_id, v_postal_code);

  if v_commission_strategy_id = 26056 and v_source_id = 525 then
    v_lead_cost_adder = v_setter_lead_cost * (v_system_size * 1000);
  elseif v_commission_strategy_id = 26056 and v_source_id = any(array[16766,19099,527,522,528]) then
    v_lead_cost_adder = v_digital_lead_cost * (v_system_size * 1000);
  else
    v_lead_cost_adder = 0;
  end if;

  select dealer_redline_price
  into v_dealer_redline_price
  from brs.get_proposal_dealer_redline_pricing(v_version_id, v_state_id, coalesce(v_dealer,0));

  --raise notice 'v_dealer_redline_price = % ',v_dealer_redline_price;
  --raise notice 'v_dealer_markup = % ',v_dealer_markup;
  --raise notice 'v_dealer = % ',v_dealer;

  v_small_system_size_adder_amount = 0.00::numeric;
  select small_system_size_adder,
         small_system_size_value,
         small_system_size_unit_type_id
  into v_small_system_size_adder,v_small_system_size_value,v_small_system_size_unit_type_id
  from brs.get_proposal_small_system_adders(v_version_id);

  if v_system_size < v_small_system_size_value then
    select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_SMALL_SYSTEM_ADDERS',
                                       v_small_system_size_adder::numeric, v_small_system_size_unit_type_id::bigint,
                                       0::numeric,
                                       null,
                                       null)
    into v_small_system_size_adder_amount;
  end if;

  --raise notice 'v_small_system_size_adder_amount = % ',v_small_system_size_adder_amount;


  with t as (select adder_name, val,applied_by_default,array_agg(p::integer) filter (where states is not null) as states
             from brs.get_proposal_site_survey_adders(v_version_id)
                    left join jsonb_array_elements_text(states) p on true
             group by adder_name, val, applied_by_default
             )
  select string_agg(t.adder_name, ','),array_agg(val)
  into v_site_survey_items,v_site_survey_item_ids
  from t
  where (val = any (v_site_survey_time_adders) or
        (applied_by_default is true and v_state_id = any(states)) or
         (applied_by_default is true and states is null));

  select string_agg(name,',')
  into v_site_survey_items
  from flow.list_of_value v
  where v.id = any(v_site_survey_item_ids)
    and parent_id = 19823;

  --raise notice 'v_site_survey_items = %',v_site_survey_items;

  select sum(site_survey_duration::bigint)
  into v_site_survey_time_estimate
  from (with t as (select site_survey_duration, val
                   from brs.get_proposal_site_survey_adders(v_version_id))
        select site_survey_duration::bigint
        from brs.get_proposal_site_survey_adders(v_version_id)
        where applied_by_default is true
          and states is null
        union all
        select site_survey_duration
        from t
        where val = any (v_site_survey_time_adders)
        union all
        select site_survey_duration
        from (SELECT ARRAY(SELECT jsonb_array_elements_text(states)) as states, site_survey_duration
              from brs.get_proposal_site_survey_adders(v_version_id)
              where states is not null) as foo
        where v_state_id = any (foo.states::int[])) as foo;

  --raise notice 'v_site_survey_time_estimate = %',v_site_survey_time_estimate;

  with t as (select *
             from brs.get_proposal_site_survey_adders(v_version_id))
  select can_be_completed_by_surveyor
  into v_site_survey_resource_type_yn
  from t
  where can_be_completed_by_surveyor = 'No'
    and val = any (v_site_survey_time_adders)
    and applied_by_default is null
  limit 1;
  --raise notice 'v_site_survey_resource_type_yn = %',v_site_survey_resource_type_yn;


  if v_site_survey_resource_type_yn is null then
    with t as (select *
               from brs.get_proposal_site_survey_adders(v_version_id))
    select can_be_completed_by_surveyor
    into v_site_survey_resource_type_yn
    from t
    where can_be_completed_by_surveyor = 'Yes'
      and val = any (v_site_survey_time_adders)
      and applied_by_default is null
    limit 1;
  end if;


  --raise notice 'v_site_survey_resource_type_yn = %',v_site_survey_resource_type_yn;
  if v_site_survey_resource_type_yn is not null and v_site_survey_resource_type_yn = 'No' then
    v_site_survey_resource_type = 'Service Tech or Higher';
    v_site_survey_resource_type_id = 19822;
  elsif v_site_survey_resource_type_yn is not null and v_site_survey_resource_type_yn = 'Yes' then
    v_site_survey_resource_type = 'Site Surveyor';
    v_site_survey_resource_type_id = 19821;
  end if;

  --raise notice 'v_site_survey_resource_type = %',v_site_survey_resource_type;

  select apr,
         financial_option,
         reamortized_payment_factor_without_itc_paydown,
         loan_term_id,
         loan_term,
         dealer_fee,
         reamortization_factor,
         financier_id,
         financier,
         initial_payment_factor
  into v_apr,v_financial_option,v_reamortized_payment_factor_without_itc_paydown,v_loan_term_id,v_loan_term,
    v_dealer_fee,v_reamortization_factor,v_financier_id,v_financier,v_initial_payment_factor
  from brs.get_proposal_finance_products(v_version_id, v_financial_product_id);


  --raise notice 'v_apr = %',v_apr;
  --raise notice 'v_financial_option = %',v_financial_option;
  --raise notice 'v_reamortized_payment_factor_without_itc_paydown = % ',v_reamortized_payment_factor_without_itc_paydown;
  --raise notice 'v_loan_term = % ',v_loan_term;
  --raise notice 'v_dealer_fee = %',v_dealer_fee;
  --raise notice 'v_reamortization_factor = %',v_reamortization_factor;
  --raise notice 'v_financier_id = %',v_financier_id;
  --raise notice 'v_financier = %',v_financier;
  --raise notice 'v_initial_payment_factor = %',v_initial_payment_factor;

  select instant_use_assumption,
         net_metring_rate,
         production_factor_east_west,
         production_factor_south,
         maximum_funding_amount_per_watt,
         minimum_funding_amount_per_watt,
         current_estimated_cost_per_kwh,
         utility_cost_escalator,
         high_commission_funding_amount_per_watt,
         closer_gen_discount,
         virtual_sales_base_price,
         max_base_price_per_watt,
         redline_utility_adder,
         grid_tied_battery_not_allowed
  into v_instant_use_assumption,v_net_metring_rate,v_production_factor_east_west,
    v_production_factor_south,v_maximum_funding_amount_per_watt,v_minimum_funding_amount_per_watt,
    v_current_estimated_cost_per_kwh,v_utility_cost_escalator,v_high_commission_funding_amount_per_watt,v_closer_gen_discount,
    v_virtual_sales_base_price,v_max_base_price_per_watt,v_redline_utility_adder,v_grid_tied_battery_not_allowed
  from brs.get_proposal_pricing(v_version_id, v_utility_company_id);

  select kwh_rate_discount,
         maximum_funding_amount_discount,
         minimum_funding_amount_discount,
         redline_funding_amount_discount,
         virtual_sales_price_amount_discount,
         qualifies_for_swr
  into
    v_kwh_rate_discount,
    v_maximum_funding_amount_discount,
    v_minimum_funding_amount_discount,
    v_redline_funding_amount_discount,
    v_virtual_sales_price_amount_discount,
    v_qualifies_for_swr
  from brs.get_proposal_discounts(v_version_id, v_utility_company_id, true::boolean);

  v_current_estimated_cost_per_kwh = case when v_qualifies_for_swr is not null and v_qualifies_for_swr is true and v_proposal_qualifies_for_swr is not null and v_proposal_qualifies_for_swr is true  then (v_current_estimated_cost_per_kwh - coalesce(v_kwh_rate_discount,0)) else v_current_estimated_cost_per_kwh end;

  --raise notice 'v_proposal_qualifies_for_swr = %',v_proposal_qualifies_for_swr;
  --raise notice 'v_kwh_rate_discount = %',v_kwh_rate_discount;
  --raise notice 'v_maximum_funding_amount_discount = %',v_maximum_funding_amount_discount;
  --raise notice 'v_minimum_funding_amount_discount = %',v_minimum_funding_amount_discount;
  --raise notice 'v_redline_funding_amount_discount = %',v_redline_funding_amount_discount;
  --raise notice 'v_virtual_sales_price_amount_discount = %',v_virtual_sales_price_amount_discount;
  --raise notice 'v_qualifies_for_swr = %',v_qualifies_for_swr;

  --raise notice 'v_current_estimated_cost_per_kwh = %',v_current_estimated_cost_per_kwh;
  --raise notice 'v_instant_use_assumption = %',v_instant_use_assumption;
  --raise notice 'v_net_metring_rate = %',v_net_metring_rate;
  --raise notice 'production_factor_east_west = %',v_production_factor_east_west;
  --raise notice 'production_factor_south = %',v_production_factor_south;
  --raise notice 'maximum_funding_amount_per_watt = %',v_maximum_funding_amount_per_watt;
  --raise notice 'minimum_funding_amount_per_watt = %',v_minimum_funding_amount_per_watt;

  --raise notice 'v_current_estimated_cost_per_kwh = %',v_current_estimated_cost_per_kwh;
  --raise notice 'v_utility_cost_escaltor = %',v_utility_cost_escalator;
  --raise notice 'v_storage_type_id = %',v_storage_type_id;
  -- --todo test this

  select number_of_batteries,
         cash_price_storage,
         storage_capacity,
         storage_id,
         storage_brand_id,
         nominal_power,
         battery_manufacturers_warranty,
         battery_workmanship_warranty,
         grid_tied_battery,
         states
  into v_number_of_batteries,v_cash_price_storage,v_storage_capacity,
    v_storage_id,v_storage_brand_id,v_nominal_power,
    v_battery_manufacturers_warranty,v_battery_workmanship_warranty,v_grid_tied_battery,v_storage_states
  from brs.get_proposal_storage_details(v_version_id, coalesce(v_storage_type_id,0),coalesce(v_financier_id,0));
--raise notice 'v_storage_states %',v_storage_states;
  if v_storage_states != '{}' and not v_state_id = any(v_storage_states) then
    raise exception 'Storage options are not available in this state. %',(select state from flow.state where id = v_state_id );
  end if;

  if v_grid_tied_battery_not_allowed is true and v_grid_tied_battery is true then
    raise exception 'Grid Tied Batteries are not allowed in this Utility.  Please select a different Storage Type.';
  end if;


  if v_storage_id is not null then
    select name
    into v_storage_name
    from brs.list_of_value l
    where l.id = v_storage_id and
          l.parent_id =556;
  end if;

  if v_storage_brand_id is not null then
    select name
    into v_storage_brand
    from flow.list_of_value l
    where l.id = v_storage_brand_id and
      l.parent_id = 19407;
  end if;

  v_number_of_batteries = coalesce(v_number_of_batteries, 0);
  --raise notice 'v_battery_workmanship_warranty = %',v_battery_workmanship_warranty;
  --raise notice 'v_battery_manufacturers_warranty = %',v_battery_manufacturers_warranty;
  --raise notice 'v_number_of_batteries = %',v_number_of_batteries;
  --raise notice 'v_cash_price_storage = %',v_cash_price_storage;
  --raise notice 'v_storage_type_id = %',v_storage_type_id;
  --raise notice 'v_storage_name = %',v_storage_name;
  --raise notice 'v_storage_brand = %',v_storage_brand;
  --raise notice 'v_storage_brand_id = %',v_storage_brand_id;



  v_instantly_used = v_first_year_production_estimate * v_instant_use_assumption;
  v_sent_to_grid = v_first_year_production_estimate - coalesce(v_instantly_used, 0);
  v_after_net_metering = v_sent_to_grid * v_net_metring_rate;
  v_adjusted_annual_production = coalesce(v_instantly_used, 0) + coalesce(v_after_net_metering, 0);

  --raise notice 'v_instant_use_assumption = % ',v_instant_use_assumption;
  --raise notice 'v_net_metring_rate = % ',v_net_metring_rate;
  --raise notice 'v_instantly_used = % ',v_instantly_used;
  --raise notice 'v_sent_to_grid = % ',v_sent_to_grid;
  --raise notice 'v_after_net_metering = % ',v_after_net_metering;
  --raise notice 'v_adjusted_annual_production = % ',v_adjusted_annual_production;

  select smart_thermostat_value,
         energy_efficiency_reduction_thermostat,
         unit_type_id_smart_thermostat
  into v_smart_thermostat_value,v_energy_efficiency_reduction_thermostat,v_unit_type_id_smart_thermostat
  from brs.get_proposal_equipment_adders(v_version_id)
  where equipment_type_id = 536;

  --raise notice 'v_smart_thermostat_value = % ',v_smart_thermostat_value;
  --raise notice 'v_energy_efficiency_reduction_thermostat = % ',v_energy_efficiency_reduction_thermostat;

  select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_EQUIPMENT_ADDERS',
                                     v_smart_thermostat_value::numeric, v_unit_type_id_smart_thermostat::bigint,
                                     0::numeric,
                                     null,
                                     null)
  into v_smart_thermostat_value;

  select smart_thermostat_value,
         energy_efficiency_reduction_thermostat,
         unit_type_id_smart_thermostat
  into v_led_light_bulbs_value,v_energy_efficiency_reduction_light_bulbs,v_unit_type_id_led
  from brs.get_proposal_equipment_adders(v_version_id)
  where equipment_type_id = 537;


  select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_EQUIPMENT_ADDERS',
                                     v_led_light_bulbs_value::numeric, v_unit_type_id_led::bigint,
                                     0::numeric,
                                     null,
                                     null)
  into v_led_light_bulbs_value;

  --raise notice 'v_led_light_bulbs_value = % ',v_led_light_bulbs_value;
  --raise notice 'v_energy_efficiency_reduction_light_bulbs = % ',v_energy_efficiency_reduction_light_bulbs;

  select panel_degradation_factor,
         panel_unit_type_id,
         panel_adder_amount,
         panel_states
  into v_panel_degradation_factor,v_panel_unit_type_id,v_panel_adder_amount,v_panel_states
  from brs.get_proposal_panel_details(v_version_id, v_panel_brand_id, v_panel_watts);


  --raise notice 'v_panel_degradation_factor = %',v_panel_degradation_factor;
  --raise notice 'v_panel_unit_type_id = %',v_panel_unit_type_id;
  --raise notice 'v_panel_adder_amount = %',v_panel_adder_amount;
  --raise notice 'v_panel_states = %',v_panel_states;

  select inverter_efficiency,
         inverter_unit_type_id,
         inverter_adder_amount
  into v_inverter_efficiency,v_inverter_unit_type_id,v_inverter_adder_amount
  from brs.get_proposal_inverter_details(v_version_id, v_inverter_brand_id);

  --raise notice 'v_inverter_efficiency = %',v_inverter_efficiency;
  --raise notice 'v_inverter_brand_id = %',v_inverter_brand_id;
  --raise notice 'v_inverter_unit_type_id = %',v_inverter_unit_type_id;
  --raise notice 'v_inverter_adder_amount = %',v_inverter_adder_amount;

  --raise notice 'v_utility_company_id = % ',v_utility_company_id;
  --call first formula

  --raise notice 'v_first_year_production_estimate = %',v_first_year_production_estimate;
  --raise notice 'v_system_size = %',v_system_size;

  v_production_factor = v_first_year_production_estimate / (v_system_size * 1000);
  --raise notice 'v_production_factor = %',v_production_factor;

  v_funding_range = case when v_qualifies_for_swr is not null and v_qualifies_for_swr is true and v_proposal_qualifies_for_swr is not null and v_proposal_qualifies_for_swr is true then
    (v_maximum_funding_amount_per_watt - coalesce(v_maximum_funding_amount_discount,0)) else
      v_maximum_funding_amount_per_watt end - case when v_qualifies_for_swr is not null and v_qualifies_for_swr is true and v_proposal_qualifies_for_swr is not null and v_proposal_qualifies_for_swr is true then
        (v_minimum_funding_amount_per_watt - coalesce(v_minimum_funding_amount_discount,0)) else v_minimum_funding_amount_per_watt end ;

  --raise notice 'v_funding_range = %',v_funding_range;
  v_production_factor_range = v_production_factor_south - v_production_factor_east_west;

  --raise notice 'v_production_factor_range = %',v_production_factor_range;
  v_points_off_south_production_factor = v_production_factor - v_production_factor_south;

  --raise notice 'v_points_off_south_production_factor = %',v_points_off_south_production_factor;
  v_price_change_per_production_point = coalesce(v_funding_range, 0) / v_production_factor_range;

  --raise notice 'v_price_change_per_production_point = %',v_price_change_per_production_point;

  v_calculated_price_adjustment = v_price_change_per_production_point * v_points_off_south_production_factor;
  --raise notice 'v_calculated_price_adjustment = %',v_calculated_price_adjustment;

  v_max_price_adjustment = (select least(greatest((v_funding_range * -1), v_calculated_price_adjustment), 0))::numeric -
                           case
                             when v_friends_and_family is true then .5::numeric
                             else 0::numeric
                             end;
  --raise notice 'v_max_price_adjustment = %',v_max_price_adjustment;
  if v_commission_strategy_id = 24871 then
    if v_source_id is null or not v_source_id = any (v_closer_gen_source_ids) then
      raise exception 'The Denver Redline strategy can only be used on self-gen projects';
    else
      v_minimum_price_per_watt = (select * from brs.get_minimum_price_per_watt(v_proposal_id));
      if v_minimum_price_per_watt is null then
        raise exception 'The Denver Redline funding amount can not be found, please contact pay@blueravensolar.com';
      end if;
    end if;
    if v_base_price_per_watt is null or v_base_price_per_watt < 0 or v_base_price_per_watt < v_minimum_price_per_watt then
     -- raise exception 'Price Per Watt is below minimum allowed value = %',v_minimum_price_per_watt;

    else
      v_adjusted_price_per_watt = v_base_price_per_watt;
      v_desired_commission_amount = v_base_price_per_watt - v_minimum_price_per_watt;
      --the value from proposal_pricing or user or proposal pricing that may trump user + override amount < v_base_price_per_watt
    end if;
  elseif v_commission_strategy_id = 26056 then
    v_minimum_price_per_watt = (select * from brs.get_minimum_price_per_watt(v_proposal_id));
    if v_minimum_price_per_watt is null then
      raise exception 'Your Redline cannot be found, please contact pay@blueravensolar.com';
    end if;
    v_desired_commission_amount = greatest(coalesce(v_desired_commission_amount / 1000, 0), 0);
    v_adjusted_price_per_watt = v_minimum_price_per_watt + v_desired_commission_amount;
  elsif v_commission_strategy_id = 24443 and v_dealer is not null then
    v_adjusted_price_per_watt = coalesce(v_dealer_redline_price, 0) + coalesce(v_dealer_markup, 0);
  elsif v_commission_strategy_id = 24102 then
    v_desired_commission_amount = greatest(coalesce(v_desired_commission_amount / 1000, 0), 0);
    v_redline_markup = greatest(v_desired_commission_amount / 0.68, 0);
    v_lead_source_discount = case
                               when v_version_id < 123 then--- CARLIN --- ADD CLOSER GEN SOURCE IDS
                                 case
                                   when v_source_id in (523, 524) then coalesce(v_closer_gen_discount, 0)
                                   else 0 end
                               else
                                 case
                                   when v_source_id in (523, 524, 530, 20016) then coalesce(v_closer_gen_discount, 0)
                                   else 0 end
      end;
    v_adjusted_price_per_watt =
          case when  v_commission_strategy_id = 24102 and v_dealer = 2291 and v_version_id > 137 then
                 coalesce(v_dealer_redline_price, 0)
          else
            case when v_qualifies_for_swr is not null and v_qualifies_for_swr is true and v_proposal_qualifies_for_swr is not null and v_proposal_qualifies_for_swr is true then
              coalesce(v_high_commission_funding_amount_per_watt, 0) - coalesce(v_redline_funding_amount_discount, 0) else coalesce(v_high_commission_funding_amount_per_watt, 0) end end + coalesce(v_redline_markup, 0) - coalesce(v_lead_source_discount, 0);
    --raise notice 'v_desired_commission_amount = %',v_desired_commission_amount;
    --raise notice 'v_redline_markup = %',v_redline_markup;
    --raise notice 'v_lead_source_discount = %',v_lead_source_discount;
    --raise notice 'v_adjusted_price_per_watt = %',v_adjusted_price_per_watt;
    --raise notice 'v_high_commission_funding_amount_per_watt = %',v_high_commission_funding_amount_per_watt;
  elsif v_virtual_sales_price_adjustment is not null and v_virtual_sales_base_price is not null and
        v_commission_strategy_id = 24103 then
    v_adjusted_price_per_watt  = v_virtual_sales_base_price + case when v_qualifies_for_swr is not null and v_qualifies_for_swr is true and v_proposal_qualifies_for_swr is not null and v_proposal_qualifies_for_swr is true then (v_virtual_sales_price_adjustment - coalesce(v_virtual_sales_price_amount_discount,0)) else v_virtual_sales_price_adjustment end;
  elsif v_commission_strategy_id is not null and v_commission_strategy_id not in (24103,24102,24443,24871)  then
    v_adjusted_price_per_watt =
      case when v_qualifies_for_swr is not null and v_qualifies_for_swr is true and v_proposal_qualifies_for_swr is not null and v_proposal_qualifies_for_swr is true then (v_maximum_funding_amount_per_watt - coalesce(v_maximum_funding_amount_discount,0)) else v_maximum_funding_amount_per_watt end +
        v_max_price_adjustment;
  end if;
  --raise notice 'v_virtual_sales_price_adjustment = %',v_virtual_sales_price_adjustment;
  --raise notice 'v_virtual_sales_base_price = %',v_virtual_sales_base_price;
  --raise notice 'v_commission_strategy_id = %',v_commission_strategy_id;
  --raise notice 'v_adjusted_price_per_watt = %',v_adjusted_price_per_watt;
  --raise notice 'v_max_base_price_per_watt = %',v_max_base_price_per_watt;

  if coalesce(v_max_base_price_per_watt,0) > 0 and v_adjusted_price_per_watt > v_max_base_price_per_watt and
     v_commission_strategy_id = 24102  then
    raise exception 'The desired commission is too high.  Please enter a value at or below % ',(v_max_base_price_per_watt-v_high_commission_funding_amount_per_watt)*.68*1000;
  end if;

  v_initial_system_cost = v_system_size::numeric * 1000::numeric * v_adjusted_price_per_watt::numeric;
  --raise notice 'v_initial_system_cost = %',v_initial_system_cost;

  v_equipment_storage_adder = 0;
  v_equipment_storage_adder = coalesce(v_cash_price_storage, 0);



  --raise notice 'v_storage adder based on loan type = %',v_equipment_storage_adder;

  select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_PANEL_DETAIL', v_panel_adder_amount::numeric,
                                     v_panel_unit_type_id::bigint, 0::numeric, v_panel_states, v_state_id)
  into v_equipment_panel_adder;
  --raise notice 'v_equipment_panel_adder = %',v_equipment_panel_adder;

  select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_INVERTER_DETAILS', v_inverter_adder_amount::numeric,
                                     v_inverter_unit_type_id::bigint, 0::numeric, null, null)
  into v_equipment_inverter_adder;
  --raise notice 'v_equipment_inverter_adder = %',v_equipment_inverter_adder;
  v_has_critter_guard = false;
  if 23457 = any (v_misc_adders_array) then
    v_has_critter_guard = true;
  end if;

  if v_storage_type is not null then
    select  (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric   as adder_amount
    into v_storage_heat_detector_adder
    from brs.get_proposal_version_value(v_version_id, array [(718, 'Storage Heat Detector', null, null)::ProposalFieldFilter,
      (341, null, null, v_state_id)::ProposalFieldFilter],
                                        'PROPOSAL_MISC_ADDERS');
  end if;



  select misc_adder,rete_incentive_adder
  into v_misc_adders,v_rete_adder
  from brs.get_misc_adder_amount(v_version_id,v_system_size, v_misc_adders_array,v_rete_incentive_applied);
  --raise notice 'v_misc_adders = %',v_misc_adders;
  --raise notice 'v_rete_adder = %',v_rete_adder;
  --raise notice 'v_has_critter_guard = %',v_has_critter_guard;

  v_misc_adders = v_misc_adders + coalesce(v_storage_heat_detector_adder,0);

  --raise notice 'v_storage_heat_detector_adder = %',v_storage_heat_detector_adder;


  v_smart_thermostat_adder = 0.00::numeric;
  if v_smart_thermostat is not null and v_smart_thermostat_value is not null then
    v_smart_thermostat_adder = v_smart_thermostat * v_smart_thermostat_value;
  end if;
  --raise notice 'v_smart_thermostat_adder = %',v_smart_thermostat_adder;
  v_led_light_bulbs_adder = 0.00::numeric;
  if v_led_light_bulbs is not null and v_led_light_bulbs_value is not null then
    v_led_light_bulbs_adder = v_led_light_bulbs * v_led_light_bulbs_value;
  end if;
  --raise notice 'v_led_light_bulbs_adder = %',v_led_light_bulbs_adder;

  v_postal_code = substring(v_postal_code, 1, 5);
  --this was the old way
--   with my_zips
--          as (select adder_value,postal_codes from brs.get_proposal_zone_adders(v_version_id))
--   select adder_value
--   into v_zone_adder
--   from my_zips
--   where v_postal_code::bigint = any (postal_codes);

  --re: carlin - pull this value from the process step, coalesce to zero, dont pull from zone
  select coalesce(v_adder_amount, 0)
  into v_zone_adder;

  --raise notice 'v_zone_adder = %',v_zone_adder;
  --raise notice 'v_equipment_storage_adder = %',v_equipment_storage_adder;
  --raise notice 'v_equipment_panel_adder = %',v_equipment_panel_adder;
  --raise notice 'v_equipment_inverter_adder = %',v_equipment_inverter_adder;

  v_total_ancillary_costs = coalesce(v_main_panel_upgrade_cost, 0)::numeric +
                            coalesce(v_structural_upgrade_cost, 0)::numeric +
                            coalesce(v_reroof_cost, 0)::numeric +
                            coalesce(v_tree_trimming_cost, 0)::numeric +
                            coalesce(v_trenching_cost, 0)::numeric +
                            coalesce(v_ac_unit_relocation_cost, 0)::numeric;  ---todo add these thing for Michael and make sure it's perfect  all_ancillary_costs

  --raise notice 'v_total_ancillary_costs = %',v_total_ancillary_costs;

  v_promotion_cost = 0.00;
  if v_product_id = 293 then
    v_promotion_cost =
      ((coalesce(v_initial_system_cost, 0) + case
                                               when v_dealer is null then
                                                 coalesce(v_unapproved_zip_code_adder, 0) +
                                                 coalesce(v_equipment_panel_adder, 0) +
                                                 coalesce(v_equipment_inverter_adder, 0) +
                                                 coalesce(v_zone_adder, 0) +
                                                 coalesce(v_misc_adders, 0) +
                                                 coalesce(v_redline_utility_adder, 0) +
                                                 coalesce(v_small_system_size_adder_amount, 0) +
                                                 coalesce(v_smart_thermostat_adder, 0) +
                                                 coalesce(v_led_light_bulbs_adder, 0) +
                                                 coalesce(v_lead_cost_adder, 0)
                                               else 0::numeric end +
        v_total_ancillary_costs::numeric + coalesce(v_equipment_storage_adder, 0)) * v_initial_payment_factor * 18)
        /
      (1 - v_dealer_fee - (v_initial_payment_factor * 18));
    --   elsif v_product_id = 19424 then
    --     v_promotion_cost =
    --         ((coalesce(v_initial_system_cost, 0) + case
    --                                                  when v_dealer is null then
    --                                                      coalesce(v_unapproved_zip_code_adder, 0) +
    --                                                      coalesce(v_equipment_panel_adder, 0) +
    --                                                      coalesce(v_equipment_inverter_adder, 0) +
    --                                                      coalesce(v_zone_adder, 0) +
    --                                                      coalesce(v_misc_adders, 0) +
    --                                                      coalesce(v_small_system_size_adder_amount, 0) +
    --                                                      coalesce(v_smart_thermostat_adder, 0) +
    --                                                      coalesce(v_led_light_bulbs_adder, 0)
    --                                                  else 0::numeric end +
    --           coalesce(v_main_panel_upgrade_cost, 0)::numeric + coalesce(v_equipment_storage_adder, 0) +
    --           coalesce(v_structural_upgrade_cost, 0)::numeric + coalesce(v_reroof_cost, 0)::numeric +
    --           coalesce(v_tree_trimming_cost, 0)::numeric + coalesce(v_trenching_cost, 0)::numeric +
    --           coalesce(v_ac_unit_relocation_cost, 0)::numeric) *
    --          (v_reamortization_factor - v_initial_payment_factor) * 42) /
    --         (1 - v_dealer_fee - (v_reamortization_factor - v_initial_payment_factor) *
    --                             42);
  end if;

  --raise notice 'v_promotion_cost = %',v_promotion_cost;
  --raise notice 'v_down_payment_amount = %',v_down_payment_amount;
  v_non_solar_cap = 0.00;
  v_non_solar_threshold_for_additional_fee = 0.00;
  v_additional_fee_for_exceeding_non_solar_threshold = 0.00;
  v_maximum_dollar_per_watt_for_solar = 0.00;

  select non_solar_cap,
         non_solar_threshold_for_additional_fee,
         additional_fee_for_exceeding_non_solar_threshold,
         maximum_dollar_per_watt_for_solar
  into v_non_solar_cap,v_non_solar_threshold_for_additional_fee,
    v_additional_fee_for_exceeding_non_solar_threshold,
    v_maximum_dollar_per_watt_for_solar
  from brs.get_proposal_financiers(v_version_id, v_financier_id);

  if v_financier_id = 24153 then -- ENFIN HAS SPECIAL CAPS
    if coalesce(v_number_of_batteries,0) > 0 and coalesce(v_reroof_cost,0) = 0 then
      v_maximum_dollar_per_watt_for_solar = 10::numeric;
    elsif coalesce(v_number_of_batteries,0) = 0 and coalesce(v_reroof_cost,0) > 0 then
      v_maximum_dollar_per_watt_for_solar = 12::numeric;
    elsif coalesce(v_number_of_batteries,0) > 0 and coalesce(v_reroof_cost,0) > 0 then
      v_maximum_dollar_per_watt_for_solar = 15::numeric;
    elsif coalesce(v_number_of_batteries,0) = 0 and coalesce(v_reroof_cost,0) = 0 and v_state_id = 5 then -- California
      v_maximum_dollar_per_watt_for_solar = 7::numeric;
    else
      v_maximum_dollar_per_watt_for_solar = 6.5::numeric;
    end if;
    if v_system_size <= 4.5 then
      v_maximum_dollar_per_watt_for_solar = (v_maximum_dollar_per_watt_for_solar + 1::numeric);
    end if;
  end if;

  if v_financier_id = 19203 then
    if coalesce(v_number_of_batteries,0) > 0  then
      v_maximum_dollar_per_watt_for_solar = 12.5::numeric;
    else
      v_maximum_dollar_per_watt_for_solar = 8.0::numeric;
    end if;
  end if;

  --raise notice 'v_non_solar_cap = %',v_non_solar_cap;
  --raise notice 'v_maximum_dollar_per_watt_for_solar = %',v_maximum_dollar_per_watt_for_solar;

  --dealer fee escalator for ancillary costs above threshold
  v_ancillary_cost_portion_of_loan_before_rebates = 0.00;
  v_ancillary_cost_portion_of_loan_before_rebates = ( --ancillary costs in this block
                                                      v_total_ancillary_costs::numeric
                                                      ) /
                                                    ( --initial system cost + all adders + ancillary costs + promotion amount
                                                        coalesce(v_initial_system_cost, 0) +
                                                        case
                                                          when v_dealer is null then
                                                              coalesce(v_unapproved_zip_code_adder, 0) +
                                                              coalesce(v_equipment_panel_adder, 0) +
                                                              coalesce(v_equipment_inverter_adder, 0) +
                                                              coalesce(v_zone_adder, 0) +
                                                              coalesce(v_misc_adders, 0) +
                                                              coalesce(v_redline_utility_adder, 0) +
                                                              coalesce(v_promotion_cost, 0) +
                                                              coalesce(v_small_system_size_adder_amount, 0) +
                                                              coalesce(v_lead_cost_adder, 0)
                                                          else 0::numeric end +
                                                        v_total_ancillary_costs::numeric +
                                                        coalesce(v_equipment_storage_adder, 0)
                                                      ); -- this gives the percentage of the total cost (excluding rebates) that is made up by ancillary
  if v_ancillary_cost_portion_of_loan_before_rebates > v_non_solar_threshold_for_additional_fee then
    v_dealer_fee = v_dealer_fee + v_additional_fee_for_exceeding_non_solar_threshold;
  end if;
  --raise notice 'v_dealer_fee after = %',v_dealer_fee;
  --raise notice 'v_ancillary_cost_portion_of_loan_before_rebates = %',v_ancillary_cost_portion_of_loan_before_rebates;
  --raise notice 'v_additional_fee_for_exceeding_non_solar_threshold = %',v_additional_fee_for_exceeding_non_solar_threshold;
  --raise notice 'v_non_solar_threshold_for_additional_fee = %',v_non_solar_threshold_for_additional_fee;

  --raise notice 'v_zone_adder = %',v_zone_adder;
--   raise notice 'v_lead_cost_adder = %',v_lead_cost_adder;
  v_total_amount_to_be_financed = ((coalesce(v_initial_system_cost, 0) - coalesce(v_down_payment_amount, 0)) +
                                       case
                                         when v_dealer is null then
                                             coalesce(v_equipment_inverter_adder, 0) +
                                             coalesce(v_equipment_panel_adder, 0) +
                                             coalesce(v_unapproved_zip_code_adder, 0) +
                                             coalesce(v_smart_thermostat_adder, 0) +
                                             coalesce(v_led_light_bulbs_adder, 0) +
                                             coalesce(v_misc_adders, 0) +
                                             coalesce(v_redline_utility_adder, 0) +
                                             coalesce(v_small_system_size_adder_amount, 0) +
                                             coalesce(v_promotion_cost, 0) +
                                             coalesce(v_zone_adder, 0) +
                                             coalesce(v_lead_cost_adder, 0)
                                         else 0::numeric end +
                                       v_total_ancillary_costs::numeric +
                                       coalesce(v_equipment_storage_adder, 0));
--   raise notice 'v_total_amount_to_be_financed = %',v_total_amount_to_be_financed;

  v_no_ancillary_amount_to_finance = ((coalesce(v_initial_system_cost, 0) - coalesce(v_down_payment_amount, 0)) +
                                      case
                                        when v_dealer is null then
                                            coalesce(v_equipment_inverter_adder, 0) +
                                            coalesce(v_equipment_panel_adder, 0) +
                                            coalesce(v_unapproved_zip_code_adder, 0) +
                                            coalesce(v_smart_thermostat_adder, 0) +
                                            coalesce(v_led_light_bulbs_adder, 0) +
                                            coalesce(v_redline_utility_adder, 0) +
                                            coalesce(v_misc_adders, 0) + coalesce(v_small_system_size_adder_amount, 0) +
                                            coalesce(v_promotion_cost, 0) +
                                            coalesce(v_zone_adder, 0) +
                                            coalesce(v_lead_cost_adder, 0)
                                        else 0::numeric end);
  --raise notice 'v_no_ancillary_amount_to_finance = %',v_no_ancillary_amount_to_finance;

  select deposit_amount
  into v_deposit_amount
  from brs.get_proposal_deposits(v_version_id, v_state_id);

  --raise notice 'v_deposit_amount % ',v_deposit_amount;
  v_deposit_amount_number = coalesce(v_deposit_amount, 0);
  --raise notice 'v_deposit_amount_number % ',v_deposit_amount_number;

  select rebate_amount,rebate
  into v_referral_promotion,v_referral_promotion_rebate_name
  from brs.get_proposal_rebates(v_version_id)
  where rebate_id = 535;
  v_referral_promotion = coalesce(v_referral_promotion, 0);

  if v_referral_promotion_rebate_name is not null then
    v_rebates = coalesce(v_rebates,'{}'::jsonb) || jsonb_build_object(v_referral_promotion_rebate_name, round(v_referral_promotion,2));
  end if;

  --raise notice 'v_referral_promotion = %',v_referral_promotion;
  --raise notice 'v_other_adder_and_discount_amount = %',v_other_adder_and_discount_amount;

  v_total_system_cost_before_rebates =
    (coalesce(v_total_amount_to_be_financed, 0) + coalesce(v_down_payment_amount, 0) +
     coalesce((v_other_adder_and_discount_amount), 0));
  --raise notice 'v_total_system_cost_before_rebates = %',v_total_system_cost_before_rebates;
  --raise notice 'v_company_process_id = %',v_company_process_id;

  --illinios
  if v_state_id = 13 and v_company_process_id = 1 then
    select srec_less_10,
           srec_between_10_25,
           srec_greater_25,
           srec_realization,
           rebate_cap_amount,
           rebate_cap_percent_of_total,
           rebate
    into v_il_srec_less_10,v_il_srec_between_10_25,v_il_srec_greater_25,v_srec_realization,
      v_srec_rebate_cap_amount,v_srec_rebate_cap_percent_of_total,v_ill_srec_rebate_name
    from brs.get_proposal_rebates(v_version_id)
    where state_id = 13 and
        rebate_type_id = 1911 and
        case when v_version_id >= 111 then
        utility_company_id = v_utility_company_id
        else true end and
        rebate_id = 1905;

    --raise notice 'v_il_srec_less_10 = %',v_il_srec_less_10;
    --raise notice 'v_il_srec_between_10_25 = %',v_il_srec_between_10_25;
    --raise notice 'v_il_srec_greater_25 = %',v_il_srec_greater_25;
    --raise notice 'v_srec_realization = %',v_srec_realization;
    --raise notice 'v_srec_rebate_cap_amount***************************** = % ',v_srec_rebate_cap_amount;
    --raise notice 'v_srec_rebate_cap_percent_of_total***************************** = % ',v_srec_rebate_cap_percent_of_total;

    -- inverter_efficiency
    -- ONLY IF THE state is Illinois ((15 year production * inverter_efficiency)/1000) * if system is less then < IL srec 10   else greater then >= 10 and less than 25 else greater than 25 * srec realization
    v_ill_srec_rebate_amount =
        ((brs.get_system_production_year(v_first_year_production_estimate, v_panel_degradation_factor, 15) *
          v_inverter_efficiency) / 1000) * case
                                             when case when v_version_id <= 141 then v_system_size else v_system_size_ac/1000 end <= 10::numeric then
                                               v_il_srec_less_10
                                             when case when v_version_id <= 141 then v_system_size else v_system_size_ac/1000 end > 10::numeric and case when v_version_id <= 141 then v_system_size else v_system_size_ac/1000 end < 25::numeric then
                                               v_il_srec_between_10_25
                                             when case when v_version_id <= 141 then v_system_size else v_system_size_ac/1000 end >= 25 then
                                               v_il_srec_greater_25 end * v_srec_realization;

    if v_srec_rebate_cap_amount is not null then
      v_ill_srec_rebate_amount = least(v_ill_srec_rebate_amount::numeric, v_srec_rebate_cap_amount::numeric);
    elsif v_srec_rebate_cap_percent_of_total is not null then
      v_ill_srec_rebate_amount =
        least(v_ill_srec_rebate_amount, v_srec_rebate_cap_percent_of_total * v_total_system_cost_before_rebates);
    end if;
    --raise notice 'v_ill_srec_rebate_amount = %',v_ill_srec_rebate_amount;
    if v_ill_srec_rebate_name is not null then
      v_rebates = coalesce(v_rebates,'{}'::jsonb) || jsonb_build_object(v_ill_srec_rebate_name, round(v_ill_srec_rebate_amount,2));
    end if;
  end if;

  --virginia
  if v_state_id = 46 then
    select rebate_amount,
           rebate
    into v_virginia_srec_rate,v_virginia_srec_rebate_name
    from brs.get_proposal_rebates(v_version_id)
    where state_id = 46 and
        rebate_type_id = 1911 and
        rebate_id = 1969;

    --raise notice 'v_virginia_srec_rate = %',v_virginia_srec_rate;
    v_virginia_srec_rebate_amount = v_virginia_srec_rate * v_system_size * 1000;
    --raise notice 'v_virginia_srec_rebate_amount = %',v_virginia_srec_rebate_amount;
    if v_virginia_srec_rebate_name is not null then
      v_rebates = coalesce(v_rebates,'{}'::jsonb) || jsonb_build_object(v_virginia_srec_rebate_name, round(v_virginia_srec_rebate_amount,2));
    end if;
  end if;

  --   v_csu_rebate = 0;
  --   if v_utility_company_id = 241 then
  --     with proposal_group_uuid as (select proposal_group_uuid
  --                                  from proposal_value
  --                                  where field_id = 85
  --                                    and object_code = 'PROPOSAL_REBATE'
  --                                    and int_value::bigint = v_utility_company_id)
  -- select value::numeric
  -- into v_csu_rebate
  -- from proposal_value pv
  --        inner join proposal_group_uuid pgu on pgu.proposal_group_uuid = pv.proposal_group_uuid
  -- where field_id = 98
  --   and object_code = 'PROPOSAL_REBATE';
  --
  -- with proposal_group_uuid as (select proposal_group_uuid
  --                              from proposal_value
  --                              where field_id = 85
  --                                and object_code = 'PROPOSAL_REBATE'
  --                                and int_value::bigint = v_utility_company_id)
  -- select int_value
  -- into v_csu_rebate_unit_type_id
  -- from proposal_value pv
  --        inner join proposal_group_uuid pgu on pgu.proposal_group_uuid = pv.proposal_group_uuid
  -- where field_id = 97
  --   and object_code = 'PROPOSAL_REBATE';
  --
  -- if v_csu_rebate_unit_type_id = 460 then
  --       v_csu_rebate = v_csu_rebate * v_system_size * 1000;
  -- end if;

  --raise notice 'v_csu_rebate = %',v_csu_rebate;
  --raise notice 'v_csu_rebate_unit_type_id = %',v_csu_rebate_unit_type_id;


  -- select *
  -- into v_col_springs_rebate
  -- from brs.get_colorado_rebate(v_aurora_design_summary, v_csu_rebate,
  --                              v_inverter_efficiency);
  --end if;

  select rebate_amount,
         rebate_cap_amount,
         rebate_cap_percent_of_total,
         odoe_battery_rebate_amount,
         odoe_battery_rebate_cap_amount,
         odoe_battery_rebate_percent_total,
         odoe_system_size_cutoff,
         minimum_tsrf_for_qualification,
         rebate_id,
         rebate
  into v_rebate_amount,v_rebate_cap_amount,v_rebate_cap_percentage,
    v_battery_rebate_amount,v_battery_rebate_cap_amount,v_battery_rebate_cap_percent_of_total,
    v_system_size_cutoff,v_minimum_odoe_tsrf,v_odoe_rebate_id,v_odoe_rebate_name
  from brs.get_proposal_rebates(v_version_id)
  where rebate_id = v_odoe_income_status;

  --raise notice 'v_minimum_odoe_tsrf % ',v_minimum_odoe_tsrf;
  --raise notice 'v_odoe_rebate_id % ',v_odoe_rebate_id;
  --raise notice 'v_odoe_income_status % ',v_odoe_income_status;
  --raise notice 'v_rebate_amount % ',v_rebate_amount;
  --raise notice 'v_rebate_cap_amount % ',v_rebate_cap_amount;
  --raise notice 'v_rebate_cap_percentage % ',v_rebate_cap_percentage;
  --raise notice 'v_battery_rebate_amount % ',v_battery_rebate_amount;
  --raise notice 'v_battery_rebate_cap_amount % ',v_battery_rebate_cap_amount;
  --raise notice 'v_battery_rebate_cap_percent_of_total % ',v_battery_rebate_cap_percent_of_total;
  --raise notice 'v_system_size_cutoff % ',v_system_size_cutoff;

  v_odoe_rebate = 0::numeric;
  if v_odoe_rebate_id is not null and (v_version_id <= 130 or v_system_size >= 9 or v_version_id = 132)  then
    select *
    into v_odoe_rebate
    from brs.get_rebate_for_standard_low_income(v_aurora_design_summary,
                                                v_system_size,
                                                v_rebate_cap_amount,
                                                v_rebate_cap_percentage,
                                                v_total_system_cost_before_rebates,
                                                v_panel_watts,
                                                v_rebate_amount,
                                                v_system_size_cutoff,
                                                v_number_of_batteries,
                                                v_battery_rebate_cap_percent_of_total,
                                                v_battery_rebate_cap_amount,
                                                v_battery_rebate_amount,
                                                v_equipment_storage_adder,
                                                v_minimum_odoe_tsrf);
    if v_odoe_rebate_name is not null then
      v_rebates = coalesce(v_rebates,'{}'::jsonb) || jsonb_build_object(v_odoe_rebate_name, round(v_odoe_rebate,2));
    end if;
  elseif v_odoe_rebate_id is not null then
    v_other_oregon_discount = 400;
  end if;
  --raise notice 'v_odoe_rebate % ',v_odoe_rebate;
  --raise notice 'v_col_springs_rebate = %',v_col_springs_rebate;

  v_above_the_line_utility_rebate_amount = 0.00::numeric;
  select above_the_line_utility_rebate_amount,rebates,eto_rebate_amount,denver_care_rebate,
    denver_care_rebate_mpu,denver_care_rebate_battery
  into v_above_the_line_utility_rebate_amount,v_above_the_line_utility_rebates,v_eto_rebate_amount,v_denver_care_rebate_amount,
    v_denver_care_rebate_mpu_amount,v_denver_care_rebate_battery_amount
  from brs.get_above_the_line_utility_rebates(v_version_id, v_utility_company_id,
                                              v_aurora_design_summary,v_system_size,
                                              v_total_system_cost_before_rebates,
                                              v_state_id,v_qualifies_for_incentive,
                                                v_storage_capacity,
                                              v_storage_type_id,
                                              v_proposal_qualifies_for_swr,
                                                    coalesce(v_main_panel_upgrade_cost,0));

  --raise notice 'v_above_the_line_utility_rebate_amount = %',v_above_the_line_utility_rebate_amount;
  --raise notice 'v_denver_care_rebate_mpu_amount = %',v_denver_care_rebate_mpu_amount;
  --raise notice 'v_denver_care_rebate_battery_amount = %',v_denver_care_rebate_battery_amount;
  --raise notice 'v_above_the_line_utility_rebates = %',v_above_the_line_utility_rebates;
  --raise notice 'v_eto_rebate_amount = %',v_eto_rebate_amount;
  v_denver_care_rebate_amount_number = v_denver_care_rebate_amount;
  --raise notice 'v_denver_care_rebate_amount_number = %',v_denver_care_rebate_amount_number;

  if v_above_the_line_utility_rebates is not null or v_above_the_line_utility_rebates != '{}' then
    v_rebates = coalesce(v_rebates,'{}'::jsonb) || v_above_the_line_utility_rebates;
  end if;
  --raise notice 'v_rebates after utility above the line rebates %',v_rebates;
  --raise notice 'above_the_line_utility_rebate_amount %',v_above_the_line_utility_rebate_amount;

  select above_the_line_state_rebate_amount, rebates
  into v_above_the_line_state_rebate_amount,v_above_the_line_state_rebates
  from brs.get_above_the_line_state_rebates(v_version_id, v_state_id,
                                            v_system_size,
                                            v_total_system_cost_before_rebates,
                                            v_qualifies_for_incentive);

  --raise notice 'v_above_the_line_state_rebate_amount = %',v_above_the_line_state_rebate_amount;
  --raise notice 'v_above_the_line_state_rebates = %',v_above_the_line_state_rebates;

  if v_above_the_line_state_rebates is not null or v_above_the_line_state_rebates != '{}' then
    v_rebates = coalesce(v_rebates,'{}'::jsonb) || v_above_the_line_state_rebates;
  end if;

  if v_other_oregon_discount is not null or v_other_oregon_discount > 0 then
    v_rebates = coalesce(v_rebates,'{}'::jsonb) || jsonb_build_object('Other Oregon Discount', round(v_other_oregon_discount,2));
  end if;

  --raise notice 'v_rebates after state above the line rebates %',v_rebates;
  --raise notice 'above_the_line_state_rebate_amount %',v_above_the_line_state_rebate_amount;

  --raise notice 'v_other_oregon_discount %',v_other_oregon_discount;

  v_above_line_rebate = coalesce(v_other_oregon_discount,0) + coalesce(v_above_the_line_state_rebate_amount,0) + coalesce(v_above_the_line_utility_rebate_amount, 0) + coalesce(v_ill_srec_rebate_amount, 0) + coalesce(v_odoe_rebate, 0);

  if v_version_id < 107 then
    v_total_system_cost =
      (((coalesce(v_total_amount_to_be_financed, 0) + coalesce(v_down_payment_amount, 0)) / (1 - v_dealer_fee)) +
       coalesce(v_above_line_rebate, 0) + coalesce(v_deposit_amount, 0) +
       case
         when v_dealer is null then
           case
             when v_version_id < 74 then
               (284.00::numeric / (1 - v_dealer_fee))
             else 0::numeric end
         else 0::numeric end);
  else
    v_total_system_cost =
      (coalesce(v_total_amount_to_be_financed, 0) / (1 - v_dealer_fee)) + coalesce(v_down_payment_amount, 0) +
       coalesce(v_above_line_rebate, 0) + coalesce(v_deposit_amount, 0);
  end if;

  --raise notice 'v_total_system_cost = %',v_total_system_cost;
  --raise notice 'v_required_down_payment = %',v_required_down_payment;
  if v_version_id < 107 then
    if v_financier_id = 722 then --check solar only $/Watt price cap for goodleap
      v_required_down_payment =
        greatest(
          (
            (((((coalesce(v_no_ancillary_amount_to_finance, 0) -
                 coalesce(v_above_line_rebate, 0) -
                 case
                   when v_product_id = 293 then (coalesce(v_required_down_payment, 0) +
                                                 (coalesce(v_required_down_payment, 0)
                                                   * v_initial_payment_factor * 18) /
                                                 ((1 - v_dealer_fee) - (v_initial_payment_factor * 18)))
                   else coalesce(v_required_down_payment, 0) end -
                 case
                   when v_product_id = 293 then (coalesce(v_down_payment_amount, 0) *
                                                 v_initial_payment_factor * 18) /
                                                ((1 - v_dealer_fee) - (v_initial_payment_factor * 18))
                   else 0::numeric end) / (1 - v_dealer_fee)) -
               case
                 when v_dealer is null then
                   case
                     when v_version_id < 74 then
                       coalesce(v_other_adder_and_discount_amount, 0) +
                       (284.00::numeric / (1 - v_dealer_fee))
                     else 0::numeric end
                 else 0::numeric end -
               coalesce(v_admin_discount, 0)) /
              (v_system_size * 1000)) -
             v_maximum_dollar_per_watt_for_solar) * v_system_size * 1000
            ) * (1 - v_dealer_fee)
          , 0);
    end if;
    --raise notice 'v_required_down_payment first one = %',v_required_down_payment;

    v_required_down_payment = coalesce(v_required_down_payment, 0) +
                              greatest(
                                (
                                  (
                                    ( --this block is ancillary cost
                                      v_total_ancillary_costs::numeric
                                      ) -
                                    (
                                      ( --this block is total system cost pre dealer fee plus ancillary cost pre dealer fee
                                        (v_total_system_cost * (1 - v_dealer_fee))
                                        ) * v_non_solar_cap
                                      )
                                    ) / (1 - v_non_solar_cap)
                                  )
                                , 0,
                                ((( --this block is ancillary cost
                                    v_total_ancillary_costs::numeric
                                    ) / (1 - v_dealer_fee)) -
                                 (v_system_size * 1000 * v_maximum_dollar_per_watt_for_solar)) * (1 - v_dealer_fee));

    --raise notice 'v_required_down_payment before batteries = %',v_required_down_payment;

    if v_number_of_batteries > 0 and v_financier_id = 722 then
      v_required_down_payment = coalesce(v_required_down_payment, 0) +
                                greatest(
                                  (
                                    (v_equipment_storage_adder / (1 - v_dealer_fee)) -
                                    least(50000::numeric, (2500::numeric * v_storage_capacity))
                                    )
                                  , 0);
      --raise notice 'v_required_down_payment_before_$/Watt_cap = %',v_required_down_payment;
    end if;
  elsif v_version_id < 123 then
    v_battery_cap_down_payment =  coalesce(case
                                             when (v_number_of_batteries > 0 and v_financier_id = 722) then
                                               greatest(0,
                                                        v_equipment_storage_adder -
                                                        50000::numeric * (1-v_dealer_fee)
                                               )
                                             else 0
                                             end,0);

    v_solar_only_cap_down_payment = case when v_dealer_fee > 0 then coalesce(((v_no_ancillary_amount_to_finance + coalesce(v_down_payment_amount,0)) -
                                              (v_maximum_dollar_per_watt_for_solar * v_system_size * 1000 * (1 - v_dealer_fee))) /
                                             (v_dealer_fee +
                                              case -- promotion_cost will be lower when down payments are applied. This case accounts for that.
                                                when v_product_id = 293 then (v_initial_payment_factor * 18) /
                                                                             ((1 - v_dealer_fee) - (v_initial_payment_factor * 18))
                                                else 0::numeric end),0)
                                    else 0::numeric end;

    v_ancillary_percent_cap_down_payment = case when v_dealer_fee > 0 then coalesce((v_total_ancillary_costs -
                                                     v_non_solar_cap * (v_no_ancillary_amount_to_finance + coalesce(v_down_payment_amount,0) ) -
                                                     v_non_solar_cap * coalesce(v_equipment_storage_adder,0) -
                                                     v_non_solar_cap * v_total_ancillary_costs) /
                                                    (v_non_solar_cap * (1 - v_dealer_fee) - v_non_solar_cap + 1 -
                                                     case when v_product_id = 293 then (v_non_solar_cap * v_initial_payment_factor * 18) /
                                                                                       ((1 - v_dealer_fee) - (v_initial_payment_factor * 18))
                                                          else 0::numeric end),0)
                                                    else 0::numeric end;
    if (v_down_payment_amount + v_above_line_rebate + v_battery_cap_down_payment) >
       v_ancillary_percent_cap_down_payment then
      -- If the sum of above_line_rebate and down_payment_amount is more than the default, the % will change
      -- find the difference and apply those amounts to the ancillary work instead of requiring a down payment
      v_ancillary_percent_cap_down_payment = coalesce((v_total_ancillary_costs -
                                                       v_non_solar_cap *
                                                       (v_total_amount_to_be_financed - v_above_line_rebate -
                                                        v_battery_cap_down_payment - case when v_product_id = 293 then
                                                                                ((coalesce(v_down_payment_amount, 0) + coalesce(v_above_line_rebate, 0) + v_battery_cap_down_payment)
                                                                                * v_initial_payment_factor * 18) /
                                                                                ((1 - v_dealer_fee) - (v_initial_payment_factor * 18))
                                                                                else 0::numeric end) -
                                                       v_non_solar_cap * (1 - v_dealer_fee) *
                                                       (v_above_line_rebate + v_down_payment_amount + v_battery_cap_down_payment)),
                                                      0);
    end if;

    --raise notice 'v_solar_only_cap_down_payment = %',v_solar_only_cap_down_payment;
    --raise notice 'v_ancillary_percent_cap_down_payment = %',v_ancillary_percent_cap_down_payment;
    --raise notice 'v_battery_cap_down_payment = %',v_battery_cap_down_payment;

    v_solar_only_cap_down_payment = greatest(0, v_solar_only_cap_down_payment);
    v_ancillary_percent_cap_down_payment = greatest(0, v_ancillary_percent_cap_down_payment);
    v_battery_cap_down_payment = greatest(0, v_battery_cap_down_payment);


    v_required_down_payment =
      greatest(0,
               greatest(0, coalesce(v_solar_only_cap_down_payment,0), coalesce(v_ancillary_percent_cap_down_payment,0))
                 + coalesce(v_battery_cap_down_payment,0)
                 - coalesce(v_down_payment_amount,0) - coalesce(v_above_line_rebate,0)
      );
  else
    --GoodLeap  ID = 116
    --    Solar Only -> Excluding any ancillary and battery pricing, total system price <= $6.50/W
    --    Ancillary -> Ancillary work (excluding batteries) can account for 50% of total loan amount
    --    Battery -> = $50000 max battery cost in loan. Battery cannot be more than $___ /kWh
    --SunPower ID = 20065
    --    Solar Only -> Excluding any ancillary and battery pricing, total system price <= $10/W
    --    Ancillary -> Ancillary work (excluding batteries) can account for 15% of total loan amount
    --    No specified battery cap
    --EnFin ID = 24152
    --    IF SYSTEM SIZE > 4.5kW LOAN amount must meet:
    --    $6.50/W standard cap ($7 in CA)
    --    $10/W if PV + Battery
    --    $12/W if PV + Reroof
    --    $15/W if PV + Battery + Reroof
    --    IF SYSTEM SIZE <= 4.5kW LOAN amount must meet:
    --    $7.50/W standard cap ($8 in CA)
    --    $11/W if PV + Battery
    --    $13/W if PV + Reroof
    --    $16/W if PV + Battery + Reroof

    v_battery_cap_down_payment = coalesce(case
                                            when (coalesce(v_number_of_batteries,0) > 0 and v_financier_id = 722) then
                                              greatest(0,
                                                       coalesce(v_equipment_storage_adder,0) -
                                                       50000::numeric * (1 - v_dealer_fee)
                                              )
                                            else 0
                                            end, 0);

    v_solar_only_cap_down_payment = case
                                      when v_financier_id = 722 then
                                        greatest(
                                          case when v_dealer_fee > 0 then coalesce(
                                            ((coalesce(v_no_ancillary_amount_to_finance,0) + coalesce(v_down_payment_amount, 0)) -
                                             case
                                               when v_product_id = 293
                                                 then -- promotion_cost will be lower when down payments are applied. This case accounts for that.
                                                 (coalesce(v_battery_cap_down_payment, 0) * v_initial_payment_factor * 18) /
                                                 ((1 - v_dealer_fee) - (v_initial_payment_factor * 18))
                                               else 0::numeric end -
                                             (coalesce(v_maximum_dollar_per_watt_for_solar,0) *
                                              v_system_size * 1000 *
                                              (1 - v_dealer_fee))) /
                                            (v_dealer_fee +
                                             case
                                               when v_product_id = 293
                                                 then -- promotion_cost will be lower when down payments are applied. This case accounts for that.
                                                 (v_initial_payment_factor * 18) /
                                                 ((1 - v_dealer_fee) - (v_initial_payment_factor * 18))
                                               else 0::numeric end)
                                            , 0) else 0::numeric end
                                          ,0)
                                      when v_financier_id in (24153,19203) then --EnFin and Sunlight has a single cap that changes depending on what's added. Ancillary costs can't be excluded
                                        greatest(
                                          coalesce(
                                            (coalesce(v_total_amount_to_be_financed,0) +
                                             coalesce(v_down_payment_amount, 0) -
                                             coalesce(v_maximum_dollar_per_watt_for_solar,0) * v_system_size * 1000 * (1 - v_dealer_fee) -
                                             (coalesce(v_admin_discount,0)-coalesce(v_rete_adder,0))*(1-v_dealer_fee)) /
                                            (case when v_product_id = 293 then
                                                    ((v_initial_payment_factor * 18) /
                                                     ((1 - v_dealer_fee) - (v_initial_payment_factor * 18)))
                                                  else 0::numeric end + 1)
                                            , 0)
                                          , 0)
                                      else
                                        greatest(
                                          case when coalesce(v_maximum_dollar_per_watt_for_solar,0) > 0 then coalesce(
                                            (coalesce(v_no_ancillary_amount_to_finance, 0) +
                                             coalesce(v_down_payment_amount, 0) -
                                             coalesce(v_maximum_dollar_per_watt_for_solar,0)* v_system_size * 1000 * (1 - v_dealer_fee) -
                                             (coalesce(v_admin_discount,0)-coalesce(v_rete_adder,0))*(1-v_dealer_fee)) /
                                            (case when v_product_id = 293 then
                                                    ((v_initial_payment_factor * 18) /
                                                     ((1 - v_dealer_fee) - (v_initial_payment_factor * 18)))
                                                  else 0::numeric end + 1)
                                            , 0) else 0::numeric end
                                          , 0)
      end;

    if v_solar_only_cap_down_payment > 0 then
      v_solar_only_cap_down_payment = v_solar_only_cap_down_payment + 1;
    end if;

    v_ancillary_percent_cap_down_payment = case
                                             when coalesce(v_non_solar_cap,0) > 0 then coalesce((v_non_solar_cap *
                                                                                  (coalesce(v_total_amount_to_be_financed,0) + coalesce(v_down_payment_amount, 0) -
                                                                                   coalesce(v_battery_cap_down_payment,0) - coalesce(v_solar_only_cap_down_payment,0) -
                                                                                   case
                                                                                     when v_product_id = 293 then
                                                                                       (((coalesce(v_battery_cap_down_payment,0) + coalesce(v_solar_only_cap_down_payment,0))
                                                                                         * v_initial_payment_factor * 18) /
                                                                                        ((1 - v_dealer_fee) - (v_initial_payment_factor * 18)))
                                                                                     else 0::numeric end) - coalesce(v_total_ancillary_costs,0)) /
                                                                                 (coalesce(v_non_solar_cap,0) * (1 +
                                                                                                     case
                                                                                                       when v_product_id = 293 then
                                                                                                         (coalesce(v_non_solar_cap,0) * v_initial_payment_factor * 18) /
                                                                                                         ((1 - v_dealer_fee) - (v_initial_payment_factor * 18))
                                                                                                       else 0::numeric end)-1), 0)
                                             else 0::numeric end;
    if (coalesce(v_down_payment_amount,0) + coalesce(v_above_line_rebate,0) + coalesce(v_battery_cap_down_payment,0)) >
       coalesce(v_ancillary_percent_cap_down_payment,0) and coalesce(v_non_solar_cap,0) >0 then
      -- If the sum of above_line_rebate and down_payment_amount is more than the default, the % will change
      -- find the difference and apply those amounts to the ancillary work instead of requiring a down payment
      v_ancillary_percent_cap_down_payment = coalesce(coalesce(v_total_ancillary_costs,0)-
                                                      coalesce(v_non_solar_cap,0) *
                                                      (coalesce(v_total_amount_to_be_financed,0) - coalesce(v_above_line_rebate,0) -
                                                       case
                                                         when v_product_id = 293 then
                                                           ((coalesce(v_down_payment_amount, 0) +
                                                             coalesce(v_above_line_rebate, 0)) *
                                                            v_initial_payment_factor * 18) /
                                                           ((1 - v_dealer_fee) - (v_initial_payment_factor * 18))
                                                         else 0::numeric end)
        ,0);
    end if;

    --raise notice 'v_solar_only_cap_down_payment = %',v_solar_only_cap_down_payment;
    --raise notice 'v_ancillary_percent_cap_down_payment = %',v_ancillary_percent_cap_down_payment;
    --raise notice 'v_battery_cap_down_payment = %',v_battery_cap_down_payment;

    v_solar_only_cap_down_payment = greatest(0, v_solar_only_cap_down_payment);
    v_ancillary_percent_cap_down_payment = greatest(0, v_ancillary_percent_cap_down_payment);
    v_battery_cap_down_payment = greatest(0, v_battery_cap_down_payment);


    v_required_down_payment =
      greatest(0,
               coalesce(v_solar_only_cap_down_payment,0)
                 + coalesce(v_ancillary_percent_cap_down_payment,0)
                 + coalesce(v_battery_cap_down_payment,0)
                 - coalesce(v_down_payment_amount,0) - coalesce(v_above_line_rebate,0)
      );
  end if;

  v_storage_cost_with_fees = (coalesce(v_equipment_storage_adder, 0)-coalesce(v_battery_cap_down_payment, 0)) / (1 - v_dealer_fee) + coalesce(v_battery_cap_down_payment, 0);

  --raise notice 'v_equipment_storage_adder = %',v_equipment_storage_adder;
  --raise notice 'v_storage_cost_with_fees = %',v_storage_cost_with_fees;

  --raise notice 'v_storage_capacity %',v_storage_capacity;
  --raise notice 'v_required_down_payment = %',v_required_down_payment;

  v_required_down_payment_number = v_required_down_payment;

  --raise notice 'v_required_down_payment_number = %',v_required_down_payment_number;


  v_total_loan_amount =
    ((coalesce(v_total_amount_to_be_financed, 0) - case
                                                     when v_version_id < 107 then coalesce(v_above_line_rebate, 0)
                                                     else case
                                                            when v_product_id = 293 then (
                                                              coalesce(v_above_line_rebate, 0) +
                                                              (coalesce(v_above_line_rebate, 0) * v_initial_payment_factor * 18) /
                                                              ((1 - v_dealer_fee) - (v_initial_payment_factor * 18)))
                                                            else coalesce(v_above_line_rebate, 0) end end -
      case
        when v_product_id = 293 then (coalesce(v_required_down_payment, 0) +
                                      (coalesce(v_required_down_payment, 0) * v_initial_payment_factor * 18) /
                                      ((1 - v_dealer_fee) - (v_initial_payment_factor * 18)))
        else coalesce(v_required_down_payment, 0) end -
      case
        when v_product_id = 293 then (coalesce(v_down_payment_amount, 0) * v_initial_payment_factor * 18) /
                                     ((1 - v_dealer_fee) - (v_initial_payment_factor * 18))
        else 0::numeric end) / (1 - v_dealer_fee)) -
    coalesce(v_other_adder_and_discount_amount, 0) +
    case
      when v_dealer is null then
        case
          when v_version_id < 74 then
            (284.00::numeric / (1 - v_dealer_fee))
          else 0::numeric end
      else 0::numeric end - coalesce(v_admin_discount, 0)+coalesce(v_rete_adder,0);
  --raise notice 'v_total_loan_amount = %',v_total_loan_amount;
  --raise notice 'v_above_line_rebate = %',v_above_line_rebate;
  --raise notice 'v_admin_discount = %',v_admin_discount;

  v_check_from_br = 0.00::numeric;
  if v_product_id in (293, 19424) then
    v_check_from_br = round((v_total_loan_amount * v_initial_payment_factor)::numeric, 2);
    v_promotion_cost = v_check_from_br * 18;
    --raise notice 'v_promotion_cost = %',v_promotion_cost;
  end if;
  --raise notice 'v_check_from_br = %',v_check_from_br;

  select below_the_line_utility_rebate_amount,rebates,below_the_line_utility_rebate_first_year_cap_amount
  into v_below_the_line_utility_rebate_amount,v_below_the_line_utility_rebates,v_below_the_line_utility_rebate_first_year_cap_amount
  from brs.get_below_the_line_utility_rebates(v_version_id, v_utility_company_id,
                                              v_aurora_design_summary,v_system_size,
                                              (coalesce(v_total_loan_amount, 0) + coalesce(v_down_payment_amount, 0) +
                                               coalesce(v_required_down_payment, 0)),
                                              v_state_id,v_qualifies_for_incentive,v_storage_capacity,v_storage_type_id);

  --raise notice 'v_below_the_line_utility_rebate_amount = %',v_below_the_line_utility_rebate_amount;
  --raise notice 'v_below_the_line_utility_rebates = %',v_below_the_line_utility_rebates;

  if v_below_the_line_utility_rebates is not null or v_below_the_line_utility_rebates != '{}' then
    v_rebates = coalesce(v_rebates,'{}'::jsonb) || v_below_the_line_utility_rebates;
  end if;

  --raise notice 'v_rebates after utility below the line rebates %',v_rebates;
  --raise notice 'v_below_the_line_utility_rebate_amount %',v_below_the_line_utility_rebate_amount;
  --raise notice 'v_below_the_line_utility_rebate_first_year_cap_amount %',v_below_the_line_utility_rebate_first_year_cap_amount;

  v_qualifies_for_incentive_boolean = false;
  if v_qualifies_for_incentive is not null or array_length(v_qualifies_for_incentive,1)!= 0 then
    v_qualifies_for_incentive_boolean = true;
  end if;
  --raise notice 'v_qualifies_for_incentive_boolean %',v_qualifies_for_incentive_boolean;

  select below_the_line_state_rebate_amount, rebates,below_the_line_state_rebate_first_year_cap_amount
  into v_below_the_line_state_rebate_amount,v_below_the_line_state_rebates,v_below_the_line_state_rebate_first_year_cap_amount
  from brs.get_below_the_line_state_rebates(v_version_id, v_state_id,
                                            v_system_size,
                                            (coalesce(v_total_loan_amount, 0) + coalesce(v_down_payment_amount, 0) +
                                             coalesce(v_required_down_payment, 0)));

  --raise notice 'v_below_the_line_state_rebate_amount = %',v_below_the_line_state_rebate_amount;
  --raise notice 'v_below_the_line_state_rebates = %',v_below_the_line_state_rebates;

  if v_below_the_line_state_rebates is not null or v_below_the_line_state_rebates != '{}' then
    v_rebates = coalesce(v_rebates,'{}'::jsonb) || v_below_the_line_state_rebates;
  end if;

  --raise notice 'v_rebates after state below the line rebates %',v_rebates;
  --raise notice 'v_below_the_line_state_rebate_amount %',v_below_the_line_state_rebate_amount;
  --raise notice 'v_below_the_line_state_rebate_first_year_cap_amount %',v_below_the_line_state_rebate_first_year_cap_amount;

  select rebate_amount,
         unit_type_id,
         rebate
  into v_federal_tax_incentive_rate,v_federal_unit_type_id,v_federal_tax_incentive_rebate_name
  from brs.get_proposal_rebates(v_version_id)
  where rebate_type_id = 453;

  if v_federal_tax_incentive_rate is not null and v_federal_unit_type_id = 460 then
    v_federal_tax_incentive_amount = v_federal_tax_incentive_rate * v_system_size * 1000;
  elsif v_federal_tax_incentive_rate is not null and v_federal_unit_type_id = 458 and v_state_id = 47 then

    if coalesce(v_reroof_cost,0) < v_down_payment_amount + v_required_down_payment then
      v_federal_tax_incentive_amount =
        ((v_total_loan_amount + v_down_payment_amount + v_required_down_payment + coalesce(v_deposit_amount, 0) + case when v_version_id > 110 then coalesce(v_above_line_rebate,0) else 0::numeric end)- coalesce(v_reroof_cost,0)) * v_federal_tax_incentive_rate;
    else
    v_federal_tax_incentive_amount =
      ((v_total_loan_amount + coalesce(v_deposit_amount, 0) + case when v_version_id > 110 then coalesce(v_above_line_rebate,0) else 0::numeric end)-((coalesce(v_reroof_cost,0)- v_down_payment_amount - v_required_down_payment)/(1-v_dealer_fee))) * v_federal_tax_incentive_rate;
    end if;
  elsif v_federal_tax_incentive_rate is not null and v_federal_unit_type_id = 458 and v_state_id != 47 then
    v_federal_tax_incentive_amount =
      (v_total_loan_amount  + v_down_payment_amount + v_required_down_payment + coalesce(v_deposit_amount, 0)+ case when v_version_id > 110 then coalesce(v_above_line_rebate,0) - coalesce(v_eto_rebate_amount,0) else 0::numeric end) * v_federal_tax_incentive_rate;
  elsif v_federal_tax_incentive_rate is not null and v_federal_unit_type_id = 459 then
    v_federal_tax_incentive_amount = v_federal_tax_incentive_rate;
  end if;

  if v_federal_tax_incentive_rebate_name is not null then
    v_rebates = coalesce(v_rebates,'{}'::jsonb) || jsonb_build_object(v_federal_tax_incentive_rebate_name, round(v_federal_tax_incentive_amount,2));
  end if;
  if v_rete_incentive_applied is true and coalesce(v_rete_depreciation_incentive_amount,0) > 0 then
    v_rebates = coalesce(v_rebates,'{}'::jsonb) || jsonb_build_object('RETE DEPRECIATION INCENTIVE', round(v_rete_depreciation_incentive_amount,2));
  end if;
  --raise notice 'v_rebates = %',v_rebates;
  --raise notice 'v_federal_tax_incentive_rate = %',v_federal_tax_incentive_rate;
  --raise notice 'v_federal_tax_incentive_amount = %',v_federal_tax_incentive_amount;

  v_below_line_rebate = case when v_rete_incentive_applied is true then coalesce(v_rete_depreciation_incentive_amount,0) else 0::numeric end + coalesce(v_below_the_line_state_rebate_amount,0) + coalesce(v_below_the_line_utility_rebate_amount,0) + coalesce(v_federal_tax_incentive_amount,0) + coalesce(v_virginia_srec_rebate_amount,0);
  v_total_rebate_first_year_cap_amount = coalesce(v_below_the_line_utility_rebate_first_year_cap_amount,0) + coalesce(v_below_the_line_state_rebate_first_year_cap_amount,0) + coalesce(v_federal_tax_incentive_amount,0) + coalesce(v_virginia_srec_rebate_amount,0);

  --raise notice 'v_above_line_rebate = %',v_above_line_rebate;
  --raise notice 'v_below_line_rebate = %',v_below_line_rebate;
  --raise notice 'v_total_rebate_first_year_cap_amount = %',v_total_rebate_first_year_cap_amount;

  v_monthly_solar_payment = coalesce(v_total_loan_amount, 0) * v_initial_payment_factor;
  --raise notice 'v_monthly_solar_payment = %',v_monthly_solar_payment;

  v_total_ee_reduction =
    least(((v_estimated_annual_energy_consumption_kwh *
            case
              when coalesce(v_smart_thermostat,0) > 0 then coalesce(v_energy_efficiency_reduction_thermostat,0)
              else 0 end) +
           (coalesce(v_energy_efficiency_reduction_light_bulbs,0) * coalesce(v_led_light_bulbs,0))),
          coalesce(v_estimated_annual_energy_consumption_kwh,0) * .2);
  --raise notice 'v_total_ee_reduction = %',v_total_ee_reduction;

  v_adjusted_annual_consumption =
      coalesce(v_estimated_annual_energy_consumption_kwh::numeric, 0) - coalesce(v_total_ee_reduction, 0);
  --raise notice 'v_adjusted_annual_consumption = %',v_adjusted_annual_consumption;

  v_remaining_monthly_electric_bill_25_year_average = brs.get_year_avg_remaining_monthly_electric_bill(
    v_current_estimated_cost_per_kwh,
    v_utility_cost_escalator,
    v_adjusted_annual_consumption,
    v_adjusted_annual_production,
    v_panel_degradation_factor,
    25);
  --raise notice 'v_remaining_monthly_electric_bill_25_year_average = %',v_remaining_monthly_electric_bill_25_year_average;

  v_remaining_monthly_electric_bill_30_year_average = brs.get_year_avg_remaining_monthly_electric_bill(
    v_current_estimated_cost_per_kwh,
    v_utility_cost_escalator,
    v_adjusted_annual_consumption,
    v_adjusted_annual_production,
    v_panel_degradation_factor,
    30);
  --raise notice 'v_remaining_monthly_electric_bill_30_year_average = %',v_remaining_monthly_electric_bill_30_year_average;

  v_monthly_cost_25_year_average_without_solar = brs.get_monthly_cost_average_without_solar(
    v_current_estimated_cost_per_kwh::numeric,
    v_utility_cost_escalator,
    v_estimated_annual_energy_consumption_kwh::numeric,
    300,
    25);
  --raise notice 'v_monthly_cost_25_year_average_without_solar = %',v_monthly_cost_25_year_average_without_solar;

  v_monthly_cost_30_year_average_without_solar = brs.get_monthly_cost_average_without_solar(
    v_current_estimated_cost_per_kwh::numeric,
    v_utility_cost_escalator,
    v_estimated_annual_energy_consumption_kwh::numeric,
    360,
    30);
  --raise notice 'v_monthly_cost_30_year_average_without_solar = %',v_monthly_cost_30_year_average_without_solar;
  --todo add up state and utility amounts based on first year cap if first year cap is yes and take the least of the rebate and
  -- the first year cap.
--   if v_product_id = 19424 then -- this is for interest only
--     select *
--     into v_reamortized_monthly_payment_all_credits_to_loan
--     from flow.get_reamortized_monthly_payment((v_apr / 12):: numeric, ((v_loan_term * 12) - 18):: smallint,
--                                               (coalesce(v_total_loan_amount, 0) -
--                                                coalesce(v_below_line_rebate, 0) + coalesce(v_virginia_srec_rebate_amount,0) -
--                                                coalesce(v_state_rebate_amount, 0) -
--                                                coalesce(v_above_line_rebate, 0)):: numeric);
--   else
  v_reamortized_monthly_payment_all_credits_to_loan =
    (coalesce(v_total_loan_amount, 0) - coalesce(v_total_rebate_first_year_cap_amount,0) + coalesce(v_virginia_srec_rebate_amount,0)) * v_reamortization_factor;

  v_reamortized_monthly_payment_for_roi_calcs =     (coalesce(v_total_loan_amount, 0) - (coalesce(v_reroof_cost,0)/(1-v_dealer_fee)) - coalesce(v_storage_cost_with_fees,0) - coalesce(v_federal_tax_incentive_amount,0)) * v_reamortization_factor;
  -- end if;

  v_rete_reamortized_monthly_payment_all_credits_to_loan = (coalesce(v_total_loan_amount, 0) - coalesce(v_total_rebate_first_year_cap_amount,0) - coalesce(v_rete_depreciation_incentive_amount,0) + coalesce(v_virginia_srec_rebate_amount,0)) * v_reamortization_factor;

  --raise notice 'v_reamortized_monthly_payment_all_credits_to_loan = %',v_reamortized_monthly_payment_all_credits_to_loan;
  --raise notice 'v_rete_reamortized_monthly_payment_all_credits_to_loan = %',v_rete_reamortized_monthly_payment_all_credits_to_loan;
  v_cost_of_solar = v_reamortized_monthly_payment_all_credits_to_loan * 12 * v_loan_term;
  --raise notice 'v_cost_of_solar = %',v_cost_of_solar;

  if v_financier_id = 721 then
    v_monthly_cost_25_year_average_with_solar = v_remaining_monthly_electric_bill_25_year_average +
                                                ((v_total_loan_amount - coalesce(v_reroof_cost,0) - v_storage_cost_with_fees - v_federal_tax_incentive_amount) / 300) + ((v_down_payment_amount+coalesce(v_required_down_payment,0)) / 300);

    v_monthly_cost_30_year_average_with_solar = v_remaining_monthly_electric_bill_30_year_average +
                                                ((v_total_loan_amount - coalesce(v_reroof_cost,0) - v_storage_cost_with_fees - v_federal_tax_incentive_amount) / 360)
      + ((v_down_payment_amount+coalesce(v_required_down_payment,0)) / 360);
  else
  v_monthly_cost_25_year_average_with_solar = v_remaining_monthly_electric_bill_25_year_average +
                                              ((v_reamortized_monthly_payment_for_roi_calcs * 12 *
                                                v_loan_term) / 300) + ((v_down_payment_amount+coalesce(v_required_down_payment,0)) / 300);


  v_monthly_cost_30_year_average_with_solar = v_remaining_monthly_electric_bill_30_year_average +
                                              ((v_reamortized_monthly_payment_for_roi_calcs * 12 *
                                                v_loan_term) / 360)
    + ((v_down_payment_amount+coalesce(v_required_down_payment,0)) / 360);

  end if;
  --raise notice 'v_monthly_cost_25_year_average_with_solar = %',v_monthly_cost_25_year_average_with_solar;
  --raise notice 'v_monthly_cost_30_year_average_with_solar = %',v_monthly_cost_30_year_average_with_solar;
  v_total_cost_25_years = brs.get_year_cost_by_years(
    v_current_estimated_cost_per_kwh,
    v_utility_cost_escalator,
    v_estimated_annual_energy_consumption_kwh,
    25);
  --raise notice 'v_total_cost_25_years = %',v_total_cost_25_years;

  v_total_cost_30_years = brs.get_year_cost_by_years(
    v_current_estimated_cost_per_kwh,
    v_utility_cost_escalator,
    v_estimated_annual_energy_consumption_kwh,
    30);
  --raise notice 'v_total_cost_30_years = %',v_total_cost_30_years;

  v_total_savings_25_years = v_total_cost_25_years - (v_monthly_cost_25_year_average_with_solar * 300);
  --raise notice 'v_total_savings_25_years = %',v_total_savings_25_years;

  v_total_savings_30_years = v_total_cost_30_years - (v_monthly_cost_30_year_average_with_solar * 360);
  --raise notice 'v_total_savings_30_years = %',v_total_savings_30_years;

  v_monthly_cost_today_without_solar =
        v_estimated_annual_energy_consumption_kwh * v_current_estimated_cost_per_kwh / 12;
  --raise notice 'v_monthly_cost_today_without_solar = %',v_monthly_cost_today_without_solar;

  if v_state_id = 43 then
    v_estimated_offset = (v_first_year_production_estimate::numeric /
                          (v_estimated_annual_energy_consumption_kwh::numeric))::numeric;
  else
    v_estimated_offset = (v_adjusted_annual_production::numeric /
                          (v_adjusted_annual_consumption))::numeric;
  end if;

  v_first_year_avoided_bill = (v_estimated_annual_energy_consumption_kwh * v_current_estimated_cost_per_kwh * v_estimated_offset);
  --raise notice 'v_first_year_avoided_bill = %',v_first_year_avoided_bill;

  --raise notice 'v_estimated_offset = %',v_estimated_offset;

  v_financed_pv_price_per_watt_to_customer = (v_total_loan_amount - ((v_total_ancillary_costs + coalesce(v_equipment_storage_adder,0)) / (1 - v_dealer_fee)))
    / (v_system_size * 1000);
  --raise notice 'v_financed_pv_price_per_watt_to_customer = %',v_financed_pv_price_per_watt_to_customer;
  v_monthly_cost_today_avg_remaining_electrical_bill = greatest(0.00::numeric, (v_current_estimated_cost_per_kwh *
                                                                                (v_adjusted_annual_consumption -
                                                                                 v_adjusted_annual_production)) /
                                                                               12);
  --raise notice 'v_monthly_cost_today_avg_remaining_electrical_bill = %',v_monthly_cost_today_avg_remaining_electrical_bill;

  if v_product_id = 293 then
    v_initial_monthly_payment_all_credits_to_loan_bpPlus = 0::numeric;
  else
    v_initial_monthly_payment_all_credits_to_loan_bpPlus = v_total_loan_amount * v_initial_payment_factor;
  end if;
  v_initial_monthly_payment_all_credits_to_loan = v_total_loan_amount * v_initial_payment_factor;
  v_intial_monthly_payment_for_solar_only_costs = (v_total_loan_amount - (coalesce(v_reroof_cost,0)/(1-v_dealer_fee)) - v_storage_cost_with_fees)  * v_initial_payment_factor;
  --raise notice 'v_initial_monthly_payment_all_credits_to_loan = %',v_initial_monthly_payment_all_credits_to_loan;

  v_initial_monthly_payment_no_credits_to_loan = v_total_loan_amount * v_initial_payment_factor;
  --raise notice 'v_initial_monthly_payment_no_credits_to_loan = %',v_initial_monthly_payment_no_credits_to_loan;

  v_net_payment_from_customer = v_initial_monthly_payment_all_credits_to_loan - v_check_from_br;
  --raise notice 'v_net_payment_from_customer = %',v_net_payment_from_customer;
  if v_product_id = 19424 then
    select *
    into v_reamortized_monthly_payment_no_credits_to_loan
    from flow.get_reamortized_monthly_payment((v_apr / 12):: numeric, ((v_loan_term * 12) - 18):: smallint,
                                              v_total_loan_amount::numeric);
  else
    v_reamortized_monthly_payment_no_credits_to_loan = v_total_loan_amount * v_reamortization_factor;
  end if;

  --raise notice 'v_reamortized_monthly_payment_no_credits_to_loan = %',v_reamortized_monthly_payment_no_credits_to_loan;

  v_monthly_payment_all_credits_to_loan_after_term = 0.00;

  --raise notice 'v_monthly_payment_all_credits_to_loan_after_term = %',v_monthly_payment_all_credits_to_loan_after_term;
  v_monthly_payment_no_credits_to_loan_after_term = 0.00;

  --raise notice 'v_monthly_payment_no_credits_to_loan_after_term = %',v_monthly_payment_no_credits_to_loan_after_term;

  if v_product_id in (293, 19424) then
    v_monthly_cost_today_with_solar = greatest(0, (v_current_estimated_cost_per_kwh *
                                                   (v_adjusted_annual_consumption -
                                                    v_adjusted_annual_production)) / 12);
  else
    v_monthly_cost_today_with_solar = greatest(0, (v_current_estimated_cost_per_kwh *
                                                   (v_adjusted_annual_consumption -
                                                    v_adjusted_annual_production)) / 12) +
                                      v_intial_monthly_payment_for_solar_only_costs;

  end if;
  --raise notice 'v_monthly_cost_today_with_solar = %',v_monthly_cost_today_with_solar;

  v_net_system_cost =
        coalesce(v_total_loan_amount, 0) + coalesce(v_required_down_payment, 0) +
        coalesce(v_down_payment_amount, 0) -
        coalesce(v_below_line_rebate, 0);
  --raise notice 'v_net_system_cost = %',v_net_system_cost;
  --raise notice 'v_below_line_rebate4444444444444444 = %',v_below_line_rebate;

  v_current_estimated_annual_utility_bill =
      v_estimated_annual_energy_consumption_kwh * v_current_estimated_cost_per_kwh;
  --raise notice 'v_current_estimated_annual_utility_bill = %',v_current_estimated_annual_utility_bill;

  v_system_production_25_year = brs.get_system_production_year(
    v_first_year_production_estimate,
    v_panel_degradation_factor,
    25);
  --raise notice 'v_system_production_25_year = %',v_system_production_25_year;

  --raise notice 'v_led_light_bulbs = %',v_led_light_bulbs;

  --raise notice 'v_smart_thermostat = %',v_smart_thermostat;

  v_secondary_monthly_payment_no_credits_to_loan =
      v_reamortized_monthly_payment_no_credits_to_loan -
      (coalesce(v_reamortized_monthly_payment_all_credits_to_loan, 0) -
       coalesce(v_initial_monthly_payment_all_credits_to_loan, 0));
  --raise notice 'v_secondary_monthly_payment_no_credits_to_loan = %',v_secondary_monthly_payment_no_credits_to_loan;

  v_assumed_payment_by_month_18 =  coalesce(v_total_rebate_first_year_cap_amount,0) - coalesce(v_virginia_srec_rebate_amount,0);
  --raise notice 'v_assumed_payment_by_month_18 = %',v_assumed_payment_by_month_18;

  v_loan_type = concat(v_financier || ' ' || v_loan_term);
  --raise notice 'v_loan_type = %',v_loan_type;

  --   (24 * square root of system size in kWh DC)-(0.0016+(sqrt of system size in kWh DC * 0.00012)) * square footage of house * number of batteries
  v_estimated_backup_days = case
                              when v_system_size is not null then
                                    24 * sqrt(v_system_size) -
                                    (0.0016 + sqrt(v_system_size * 0.00012)) * v_total_square_footage *
                                    v_number_of_batteries end;
  v_solar_rebate_for_hic =
      coalesce(v_total_system_cost, 0) - coalesce(v_down_payment_amount, 0) -
      coalesce(v_required_down_payment, 0) -
      coalesce(v_total_loan_amount, 0);

  v_total_system_cost =
      coalesce(v_total_loan_amount, 0) + coalesce(v_required_down_payment, 0) + coalesce(v_down_payment_amount, 0) +
      coalesce(v_above_line_rebate, 0) + coalesce(v_other_adder_and_discount_amount, 0) + coalesce(v_deposit_amount, 0);

  --raise notice 'v_total_system_cost at the end %',v_total_system_cost;
  v_above_line_rebate_without_odoe = (coalesce(v_above_line_rebate,0) - coalesce(v_odoe_rebate,0) - coalesce(v_eto_rebate_amount,0)- coalesce(v_denver_care_rebate_amount,0)- coalesce(v_denver_care_rebate_battery_amount,0)- coalesce(v_denver_care_rebate_mpu_amount,0));
  v_below_line_rebate = coalesce(v_below_line_rebate,0) - coalesce(v_federal_tax_incentive_amount,0);
  --raise notice 'v_below_line_rebate %',v_below_line_rebate;
  --raise notice 'Carlins new value %',((coalesce(v_total_ancillary_costs,0) - coalesce(v_ancillary_percent_cap_down_payment,0))/(1-v_dealer_fee))/v_total_system_cost;

  --raise notice 'Carlins new value11111111 %',(coalesce(v_total_system_cost,0) - coalesce(v_storage_cost_with_fees,0) - ((coalesce(v_total_ancillary_costs,0) - coalesce(v_ancillary_percent_cap_down_payment,0))/(1-v_dealer_fee)))/(v_system_size*1000);

  if v_non_solar_cap is not null and round(((coalesce(v_total_ancillary_costs, 0) -
                                             coalesce(v_ancillary_percent_cap_down_payment, 0)) /
                                            (1 - v_dealer_fee)) / v_total_loan_amount, 2) >
                                     coalesce(v_non_solar_cap, 0) then
    raise exception 'Ancillary Costs exceed the maximum allowable value.';
  end if;

  --raise notice 'new value %',round(v_total_loan_amount/(v_system_size * 1000),2);

  if v_maximum_dollar_per_watt_for_solar is not null and
     v_financier_id = 722 and
            round((v_total_system_cost -
                   coalesce(v_storage_cost_with_fees, 0) -
                   (coalesce(v_total_ancillary_costs, 0) -
                    coalesce(v_ancillary_percent_cap_down_payment, 0)) /
                   (1 - v_dealer_fee)) / (v_system_size * 1000), 2) >
            coalesce(v_maximum_dollar_per_watt_for_solar, 0) then
    raise exception 'Solar Costs exceed the maximum allowable value.';
  elsif  v_maximum_dollar_per_watt_for_solar is not null and v_financier_id in (24153,19203) and
    round(v_total_loan_amount/(v_system_size * 1000),2) >
      coalesce(v_maximum_dollar_per_watt_for_solar, 0) then
    raise exception 'Solar Costs exceed the maximum allowable value.';
  elsif v_maximum_dollar_per_watt_for_solar is not null and
    round((v_total_loan_amount -
           coalesce(v_storage_cost_with_fees, 0) -
           (coalesce(v_total_ancillary_costs, 0) -
            coalesce(v_ancillary_percent_cap_down_payment, 0)) /
           (1 - v_dealer_fee)) / (v_system_size * 1000), 2) >
      coalesce(v_maximum_dollar_per_watt_for_solar, 0) then
    raise exception 'Solar Costs exceed the maximum allowable value.';
  end if;

  if p_insert_prop_log_history is true then
    v_all_ancillary_costs = null;
    if coalesce(v_main_panel_upgrade_cost, 0)::numeric > 0 then
      v_all_ancillary_costs =
        coalesce(v_all_ancillary_costs, '{}'::jsonb) ||
        jsonb_build_object('Main Panel Upgrade Cost', coalesce(v_main_panel_upgrade_cost, 0)::numeric);
    end if;
    if coalesce(v_structural_upgrade_cost, 0)::numeric > 0 then
      v_all_ancillary_costs =
        coalesce(v_all_ancillary_costs, '{}'::jsonb) ||
        jsonb_build_object('Structural Upgrade Cost', coalesce(v_structural_upgrade_cost, 0)::numeric);
    end if;
    if coalesce(v_reroof_cost, 0)::numeric > 0 then
      v_all_ancillary_costs =
        coalesce(v_all_ancillary_costs, '{}'::jsonb) ||
        jsonb_build_object('Reroof Cost', coalesce(v_reroof_cost, 0)::numeric);
    end if;
    if coalesce(v_tree_trimming_cost, 0)::numeric > 0 then
      v_all_ancillary_costs =
        coalesce(v_all_ancillary_costs, '{}'::jsonb) ||
        jsonb_build_object('Tree Trimming Cost', coalesce(v_tree_trimming_cost, 0)::numeric);
    end if;
    if coalesce(v_trenching_cost, 0)::numeric > 0 then
      v_all_ancillary_costs =
        coalesce(v_all_ancillary_costs, '{}'::jsonb) ||
        jsonb_build_object('Trenching Cost', coalesce(v_trenching_cost, 0)::numeric);
    end if;
    if coalesce(v_ac_unit_relocation_cost, 0)::numeric > 0 then
      v_all_ancillary_costs =
        coalesce(v_all_ancillary_costs, '{}'::jsonb) ||
        jsonb_build_object('AC Unit Relocation Cost', coalesce(v_ac_unit_relocation_cost, 0)::numeric);
    end if;

    insert into brs.proposal_log_history(project_id, fullname, address, city, state, zip, phone,
                                         email,loan_term_id, loan_term, interest_rate, optional_down_payment,
                                         required_down_payment,
                                         number_of_leds, number_of_ecobees, cost_per_kwh_before_solar,
                                         bp_plus_promotion, year_1_kwh_output, panel_number,
                                         panel_wattage, system_size, panel, number_of_inverters, inverter_mfg,
                                         inverter_custom_getting,inverter_brand_id,
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
                                         bp_plus_amount, aurora_design_id,loan_type, filename, financial_option,
                                         site_survey_time_estimate,
                                         site_survey_resource_type_id,
                                         site_survey_resource_type,site_survey_item_ids, site_survey_items, number_of_batteries,
                                         estimated_backup_days,
                                         solar_rebate_for_hic,
                                         full_commission_discount_amount,
                                         closer_commission_forfeiture_amount,
                                         desired_commission_amount,
                                         number_of_promotion_payments,
                                         product_id,
                                         loan_product,
                                         financed_system_cost_with_fees,
                                         financed_ancillary_cost_with_fees,
                                         total_ancillary_cost,
                                         total_promotion_amount,
                                         storage_cost_with_fees,
                                         commission_strategy_id,
                                         prepay_deposit,
                                         storage_brand_id,
                                         storage_brand,
                                         storage_size_kwh,
                                         storage_type_id,
                                         storage_name,
                                         all_rebates,
                                         net_system_cost,
                                         eto_rebate_amount,
                                         virtual_sales_price_adjustment,
                                         virtual_sales_base_price,
                                         system_size_ac,
                                         all_ancillary_costs,
                                         financier_id,
                                         financier,
                                         panel_id,
                                         panel_model,
                                         financed_pv_price_per_watt_to_customer,
                                         first_year_avoided_bill,
                                         battery_workmanship_warranty,
                                         battery_manufacturers_warranty,
                                         rete_incentive_applied,
                                         rete_depreciation_incentive_amount,
                                         rete_reamortized_monthly_payment_all_credits_to_loan,
                                         rete_adder,
                                         setter_lead_cost, digital_lead_cost, lead_cost_adder,grid_tied_battery)
    values (v_project_id,
            v_project_name,
            v_project_street1,
            v_city,
            v_project_state_abbrev,
            v_postal_code,
            v_contact_phone,
            v_contact_email,
            v_loan_term_id,
            v_loan_term,
            v_apr,
            coalesce(round(v_down_payment_amount, 0), 0),
            coalesce(round(v_required_down_payment, 0), 0),
            v_led_light_bulbs,
            v_smart_thermostat,
            v_current_estimated_cost_per_kwh,
            coalesce(round(v_promotion_cost, 0), 0),
            v_first_year_production_estimate,
            v_panel_quantity,
            v_panel_watts,
            v_system_size * 1000,
            v_panel_brand,
            v_panel_quantity,
            v_inverter_brand,
            v_inverter_brand,
            v_inverter_brand_id,
            v_utility_company,
            v_estimated_annual_energy_consumption_kwh,
            v_equipment_panel_adder,
            v_equipment_panel_adder * (v_system_size * 1000),
            case
              when v_dealer is null then
                  coalesce(v_unapproved_zip_code_adder, 0) +
                  coalesce(v_equipment_panel_adder, 0) + coalesce(v_equipment_inverter_adder, 0) +
                  coalesce(v_misc_adders, 0) + coalesce(v_small_system_size_adder_amount, 0) + coalesce(v_redline_utility_adder, 0) +
                  coalesce(v_smart_thermostat_adder, 0) + coalesce(v_led_light_bulbs_adder, 0) +
                  coalesce(v_lead_cost_adder, 0)
              else 0::numeric end +
            v_total_ancillary_costs::numeric +
            coalesce(v_equipment_storage_adder, 0),
            v_adjusted_price_per_watt,
            round(v_total_loan_amount, 0),
            round(v_total_system_cost, 0),
            v_estimated_offset,
            v_dealer_fee,
            v_utility_cost_escalator,
            v_panel_degradation_factor,
            v_production_factor,
            round(v_total_system_cost, 0),
            (v_down_payment_amount + v_above_line_rebate),
            v_referral_promotion,
            v_initial_system_cost,
            round(v_total_loan_amount, 0),
            round(v_federal_tax_incentive_amount, 0),
            round(v_below_the_line_state_rebate_amount, 0),
            round(v_monthly_cost_today_without_solar, 0),
            round(v_monthly_solar_payment, 0),
            round(v_monthly_cost_today_avg_remaining_electrical_bill, 0),
            round(v_monthly_cost_today_with_solar, 0),
            (v_estimated_annual_energy_consumption_kwh / 12),
            (v_estimated_annual_energy_consumption_kwh - v_total_ee_reduction),
            v_total_ee_reduction,
            v_estimated_annual_energy_consumption_kwh,
            (v_estimated_annual_energy_consumption_kwh - v_total_ee_reduction),
            round(v_monthly_cost_25_year_average_without_solar, 0),
            round(v_total_cost_25_years, 0),
            round(v_total_savings_25_years, 0),
            round(v_remaining_monthly_electric_bill_25_year_average, 0),
            round(v_reamortized_monthly_payment_all_credits_to_loan, 0),
            round(v_initial_monthly_payment_all_credits_to_loan, 0),
            round(v_reamortized_monthly_payment_all_credits_to_loan, 0),
            now(),
            coalesce(round(v_promotion_cost, 0), 0),
            now(),
            v_proposal_nbr,
            v_proposal_id,
            coalesce(round(v_promotion_cost, 0), 0),
            v_aurora_design_id,
            v_loan_type,
            v_display_name,
            v_financial_option,
            v_site_survey_time_estimate,
            v_site_survey_resource_type_id,
            v_site_survey_resource_type,
            v_site_survey_item_ids,
            v_site_survey_items,
            v_number_of_batteries,
            v_estimated_backup_days,
            v_solar_rebate_for_hic,
            v_other_adder_and_discount_amount,
            v_other_adder_and_discount_amount * .5,
            v_desired_commission_amount,
            case when v_product_id = 293 then 18 else 0 end,
            v_product_id,
            v_product_name,
            coalesce(round(v_total_loan_amount, 0), 0),
            case when v_total_ancillary_costs::numeric > 0::numeric then
            (v_total_ancillary_costs::numeric - coalesce(v_ancillary_percent_cap_down_payment,0)) / (1 - v_dealer_fee) else 0::numeric end,
            v_total_ancillary_costs::numeric,
            coalesce(v_promotion_cost, 0),
            round(v_storage_cost_with_fees, 0),
            v_commission_strategy_id,
            v_deposit_amount_number,
            v_storage_brand_id::bigint,
            v_storage_brand,
            v_storage_capacity,
            v_storage_id::bigint,
            v_storage_name,
            v_rebates,
            v_net_system_cost,
            v_eto_rebate_amount,
            v_virtual_sales_price_adjustment,
            v_virtual_sales_base_price,
            v_system_size_ac,
            v_all_ancillary_costs,
            v_financier_id,
            v_financier,
            v_panel_brand_id,
            v_panel_model,
            v_financed_pv_price_per_watt_to_customer,
            v_first_year_avoided_bill,
            v_battery_workmanship_warranty,
            v_battery_manufacturers_warranty,
            v_rete_incentive_applied,
            v_rete_depreciation_incentive_amount,
            v_rete_reamortized_monthly_payment_all_credits_to_loan,
            v_rete_adder,
            v_setter_lead_cost,
            v_digital_lead_cost,
            v_lead_cost_adder,
            v_grid_tied_battery
            );
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
           to_char(v_monthly_cost_25_year_average_without_solar, '$FM9,999,999')::varchar,
           to_char(v_monthly_cost_30_year_average_without_solar, '$FM9,999,999')::varchar,
           to_char(v_monthly_cost_25_year_average_with_solar, '$FM9,999,999')::varchar,
           to_char(v_remaining_monthly_electric_bill_25_year_average, '$FM9,999,999')::varchar,
           to_char(v_remaining_monthly_electric_bill_30_year_average, '$FM9,999,999')::varchar,
           to_char(v_total_cost_25_years, '$FM9,999,999')::varchar,
           to_char(v_total_cost_30_years, '$FM9,999,999')::varchar,
           to_char(v_total_savings_25_years, '$FM9,999,999')::varchar,
           to_char(v_total_savings_30_years, '$FM9,999,999')::varchar,
           to_char(v_monthly_solar_payment, '$FM9,999,999')::varchar,
           to_char(v_monthly_cost_today_without_solar, '$FM9,999,999')::varchar,
           to_char(v_monthly_cost_today_with_solar, '$FM9,999,999')::varchar,
           to_char(v_monthly_cost_today_avg_remaining_electrical_bill, '$FM9,999,999')::varchar,
           to_char(v_initial_monthly_payment_all_credits_to_loan, '$FM9,999,999')::varchar,
           to_char(v_initial_monthly_payment_no_credits_to_loan, '$FM9,999,999')::varchar,
           to_char(v_reamortized_monthly_payment_all_credits_to_loan, '$FM9,999,999')::varchar,
           to_char(v_reamortized_monthly_payment_no_credits_to_loan, '$FM9,999,999')::varchar,
           to_char(v_monthly_payment_all_credits_to_loan_after_term, '$FM9,999,999')::varchar,
           to_char(v_monthly_payment_no_credits_to_loan_after_term, '$FM9,999,999')::varchar,
           v_system_size,
           v_system_size_ac,
           v_first_year_production_estimate,
           to_char(v_total_system_cost, '$FM9,999,999')::varchar,
           to_char(v_referral_promotion, '$FM9,999,999')::varchar,
           to_char(v_total_loan_amount, '$FM9,999,999')::varchar,
           to_char(v_federal_tax_incentive_amount, '$FM9,999,999')::varchar,
           round(v_federal_tax_incentive_rate, 0) * 100,
           to_char(v_net_system_cost, '$FM9,999,999')::varchar,
           v_utility_company,
           v_estimated_annual_energy_consumption_kwh,
           to_char(v_current_estimated_annual_utility_bill, '$FM9,999,999')::varchar,
           to_char(v_current_estimated_cost_per_kwh, '$FM9,999,999.99')::varchar,
           round(v_utility_cost_escalator * 100, 2),
           to_char(v_ill_srec_rebate_amount, '$FM9,999,999')::varchar,
           round(v_apr * 100, 2),
           v_loan_term,
           to_char(v_assumed_payment_by_month_18, '$FM9,999,999')::varchar,
           round(v_panel_degradation_factor * 100, 2),
           TO_CHAR(round(v_system_production_25_year, 0), 'FM9,999,999'),--comma not money
           round(round(v_estimated_offset, 2) * 100, 0),
           v_led_light_bulbs,
           v_smart_thermostat,
           round(v_total_ee_reduction, 0),
           to_char(v_down_payment_amount, '$FM9,999,999')::varchar,
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
           round(v_adjusted_price_per_watt, 2),
           round(v_initial_system_cost, 2),
           round(v_promotion_cost, 0),
           round(v_equipment_inverter_adder, 2),
           round(v_equipment_panel_adder, 2),
           round(v_equipment_storage_adder, 2),
           round(v_misc_adders, 2),
           v_panel_brand_id,
           v_panel_watts,
           round(v_above_line_rebate, 0),
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
           to_char(v_monthly_cost_30_year_average_with_solar, '$FM9,999,999')::varchar,
           v_reamortized_payment_factor_without_itc_paydown,
           to_char(v_secondary_monthly_payment_no_credits_to_loan, '$FM9,999,999')::varchar,
           v_panel_brand,
           v_panel_quantity,
           v_inverter_brand_id,
           v_inverter_brand,
           v_aurora_design_id,
           v_product_name,
           v_proposal_nbr,
           v_other_adder_and_discount,
           to_char(v_other_adder_and_discount_amount, '$FM9,999,999')::varchar,
           v_adder,
           round(v_non_solar_cap, 2),
           to_char(v_required_down_payment, '$FM9,999,999')::varchar,
           round(v_required_down_payment_number, 0),
           v_storage_type_id,
           v_storage_type,
           v_financier,
           v_financier_id,
           to_char(v_storage_cost_with_fees, '$FM9,999,999')::varchar,
           to_char(v_equipment_storage_adder, '$FM9,999,999')::varchar,
           round(v_main_panel_upgrade_cost, 2),
           round(v_structural_upgrade_cost, 2),
           round(v_reroof_cost, 2),
           round(v_tree_trimming_cost, 2),
           round(v_trenching_cost, 2),
           round(v_ac_unit_relocation_cost, 2),
           round(v_total_amount_to_be_financed, 2),
           round(v_zone_adder, 2),
           v_loan_type,
           round(v_unapproved_zip_code_adder, 2),
           v_csu_rebate_unit_type_id,
           v_financial_option,
           to_char(v_check_from_br, '$FM9,999,999')::varchar,
           v_site_survey_time_estimate,
           v_site_survey_resource_type_yn,
           v_site_survey_resource_type,
           v_site_survey_items,
           v_number_of_batteries,
           v_estimated_backup_days,
           v_solar_rebate_for_hic,
           v_total_square_footage,
           to_char(v_net_payment_from_customer, '$FM9,999,999')::varchar,
           to_char(v_initial_monthly_payment_all_credits_to_loan_bpPlus, '$FM9,999,999')::varchar,
           to_char(v_below_line_rebate, '$FM9,999,999')::varchar,
           v_below_line_rebate,
           to_char(v_above_line_rebate_without_odoe, '$FM9,999,999')::varchar,
           to_char(v_odoe_rebate, '$FM9,999,999')::varchar,
           v_above_line_rebate_without_odoe::numeric,
           v_odoe_rebate::numeric,
           to_char(coalesce(v_deposit_amount,0),'$FM9,999,999')::varchar,
           coalesce(v_deposit_amount_number,0),
           v_has_critter_guard,
--            case when p_run_details is true then
--                   (SELECT array_to_json(array_agg(row_to_json(proposal_commission_details)))
--                    FROM (
--                           select *
--                           from brs.get_proposal_commission_details(v_product_id::bigint,
--                                                                    v_source_id ,
--                                                                    v_system_size ,
--                                                                    v_unapproved_zip_code_adder ,
--                                                                    v_high_commission_funding_amount_per_watt ,
--                                                                    v_closer_gen_discount ,
--                                                                    v_equipment_panel_adder ,
--                                                                    v_equipment_inverter_adder ,
--                                                                    v_zone_adder ,
--                                                                    v_misc_adders ,
--                                                                    v_small_system_size_adder_amount ,
--                                                                    v_dealer_fee ,
--                                                                    v_initial_payment_factor,
--                                                                    v_above_line_rebate)
--                         ) proposal_commission_details)
--                 else '{}'::json end,
           v_qualifies_for_incentive_boolean,
           to_char(v_above_the_line_utility_rebate_amount, '$FM9,999,999')::varchar,
           to_char(v_below_the_line_utility_rebate_amount, '$FM9,999,999')::varchar,
           v_below_the_line_utility_rebate_amount,
           to_char(v_above_the_line_state_rebate_amount, '$FM9,999,999')::varchar,
           to_char(v_below_the_line_state_rebate_amount, '$FM9,999,999')::varchar,
           v_below_the_line_state_rebate_amount::numeric,
           v_rebates,
           to_char(v_eto_rebate_amount, '$FM9,999,999')::varchar,
           v_eto_rebate_amount,
           to_char(v_virginia_srec_rebate_amount, '$FM9,999,999')::varchar,
           v_virginia_srec_rebate_amount::numeric,
           v_storage_capacity,
           v_nominal_power,
           v_battery_manufacturers_warranty,
           v_battery_workmanship_warranty,
           v_virtual_sales_price_adjustment,
           v_high_commission_funding_amount_per_watt,
           v_closer_gen_discount,
           v_small_system_size_adder_amount,
           to_char(v_denver_care_rebate_amount, '$FM9,999,999')::varchar,
           v_denver_care_rebate_amount_number,
           v_denver_care_rebate_mpu_amount,
           to_char(v_denver_care_rebate_mpu_amount, '$FM9,999,999')::varchar,
           v_denver_care_rebate_battery_amount,
           to_char(v_denver_care_rebate_battery_amount, '$FM9,999,999')::varchar,
           to_char(v_rete_reamortized_monthly_payment_all_credits_to_loan, '$FM9,999,999')::varchar,
           v_rete_incentive_applied,
           v_rete_depreciation_incentive_amount,
           to_char(v_rete_depreciation_incentive_amount, '$FM9,999,999')::varchar,
           to_char(v_rete_adder, '$FM9,999,999')::varchar,
           v_setter_lead_cost,
           v_digital_lead_cost,
           v_lead_cost_adder,
           v_grid_tied_battery,
           v_proposal_template_id;


END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
