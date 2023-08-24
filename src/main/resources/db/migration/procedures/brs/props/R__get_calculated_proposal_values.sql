drop function if exists brs.get_calculated_proposal_values(bigint, boolean, bigint);
drop type if exists brs.calculated_proposal_value cascade;

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
  ill_srec_rebate_amount                           varchar,
  utility_rebate_amount                            varchar, --eto_rebate                                       varchar,
--csu_rebate                                       varchar,
  apr                                              numeric,
  loan_term                                        numeric,
  assumed_payment_by_month_18                      varchar,
  panel_degradation_factor                         numeric,
  system_production_25_year                        text,
  estimated_offset                                 numeric,
  led_light_bulbs                                  bigint,
  smart_thermostat                                 bigint,
  total_ee_reduction                               numeric,
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
  csu_rebate_unit_type_id                          integer,
  financial_option                                 varchar,
  check_from_br                                    varchar,
  site_survey_time_estimate                        integer,
  site_survey_resource_type_yn                     text,
  site_survey_resource_type                        text,
  site_survey_items                                text,
  number_of_batteries                              numeric,
  estimated_backup_days                            numeric,
  solar_rebate_for_hic                             numeric,
  total_square_footage                             numeric,
  net_payment_from_customer                        varchar
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
  csu_rebate_unit_type_id                        integer,
  financial_option                               varchar,
  site_survey_time_estimate                      integer,
  site_survey_resource_type_yn                   text,
  site_survey_resource_type                      text,
  site_survey_items                              text
);

CREATE OR REPLACE FUNCTION brs.get_calculated_proposal_values(
  p_proposal_id bigint,
  p_insert_prop_log_history boolean default false,
  p_run_by_id bigint default 99999999
)

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
  v_financial_option                                 varchar;
  v_check_from_br                                    numeric;
  v_site_survey_time_adders                          bigint[];
  v_site_survey_time_estimate                        integer;
  v_site_survey_resource_type_yn                     text;
  v_site_survey_resource_type                        text;
  v_site_survey_items                                text;
  v_number_of_batteries                              numeric;
  v_estimated_backup_days                            numeric(10, 1);
  v_solar_rebate_for_hic                             numeric;
  v_total_square_footage                             numeric;
  v_net_payment_from_customer                        numeric(10, 2);
  v_proposal_group_uuid_state_rebate                 uuid;
  v_state_rebate_cap_amount                          numeric;
  v_state_rebate_cap_percent_of_total                numeric;
  v_utility_rebate_cap_amount                        numeric;
  v_utility_rebate_amount                            numeric;
  v_unit_type_utility_rebate                         numeric;
  v_utility_rebate_cap_percent_of_total              numeric;
  v_total_system_cost_before_rebates                 numeric;
  v_srec_realization                                 numeric;
  v_il_srec_greater_25                               numeric;
  v_il_srec_less_10                                  numeric;
  v_il_srec_between_10_25                            numeric;
  v_ill_srec_rebate_amount                           numeric;
  v_srec_rebate_cap_percent_of_total                 numeric;
  v_srec_rebate_cap_amount                           numeric;
  v_financial_product_id                             bigint;
  v_production_factor_east_west                      numeric;
  v_production_factor_south                          numeric;
  v_maximum_funding_amount_per_watt                 numeric;
  v_minimum_funding_amount_per_watt                 numeric;
  v_unit_type_id_smart_thermostat                    bigint;
  v_unit_type_id_led                                 bigint;
  v_misc_adders_array bigint[];
  v_panel_unit_type_id   bigint;
  v_panel_adder_amount numeric;
  v_panel_states bigint[];
  v_inverter_unit_type_id   bigint;
  v_inverter_adder_amount numeric;
  v_small_system_size_adder_amount numeric;
  v_small_system_size_adder numeric;
  v_small_system_size_unit_type_id bigint;
  v_small_system_size_value numeric;
  v_rebate_amount numeric;
  v_rebate_cap_amount numeric;
  v_rebate_cap_percentage numeric;
  v_odoe_income_status bigint;
v_battery_rebate_amount numeric;
v_battery_rebate_cap_percent_of_total numeric;
v_battery_rebate_cap_amount numeric;
v_odoe_rebate numeric;
v_system_size_cutoff numeric;
  v_commission_strategy_id bigint;
v_closer_gen_discount numeric;
v_red_line_funding_amount numeric;
v_desired_commission_amount numeric;
v_source_id bigint;
v_adjusted_price_per_watt numeric;
v_lead_source_discount numeric;
v_redline_markup numeric;
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
         (pcfv7.numeric_value) * -1,
         lov6.name,
         pcfv8.int_value,
         lov2.name,
         pcfv10.numeric_value,
         pcfv11.numeric_value,
         pcfv12.numeric_value,
         pcfv13.numeric_value,
         pcfv14.numeric_value,
         pcfv15.numeric_value,
         pcfv16.numeric_value,
         prop.proposal_nbr,
         coalesce(prop.name, 'New Proposal') ||
         case
           when prop.revision_number = 0 then ''
           else ' (' || prop.revision_number::varchar || ')' end
           || ' - ' || prop.proposal_nbr || '.pdf' as display_name,
         pcfv17.int_value,
         pcfv18.int_value,
         pcfv19.numeric_value,
         d.source
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
    v_source_id
  from brs.proposal prop
         inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
         inner join flow.project p on pps.project_id = p.id
         inner join brs.project_details d on d.project_id = p.id
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
         left join brs.list_of_value lov6 on lov6.id = pcfv6.int_value
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
         left join brs.proposal_custom_field_value pcfv16 on prop.id = pcfv16.proposal_id and
                                                             pcfv16.custom_field_group_assignment_id = 389
         left join brs.proposal_custom_field_value pcfv17 on prop.id = pcfv17.proposal_id and
                                                             pcfv17.custom_field_group_assignment_id = 155
         left join brs.proposal_custom_field_value pcfv18 on prop.id = pcfv18.proposal_id and
                                                             pcfv18.custom_field_group_assignment_id = 447
         left join brs.proposal_custom_field_value pcfv19 on prop.id = pcfv19.proposal_id and
                                                             pcfv19.custom_field_group_assignment_id = 454
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
         pd.unapproved_zip_code_adder,
         ppscfv12.int_array_value,
         ppscfv13.int_array_value,
         ppscfv14.int_value
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
    v_unapproved_zip_code_adder,
    v_site_survey_time_adders,
    v_misc_adders_array,
    v_commission_strategy_id
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
         left join flow.project_process_step_custom_field_value ppscfv12
                   on ppscfv12.project_process_step_id = pps.id and
                      ppscfv12.custom_field_group_assignment_id =
                      25023
         left join flow.project_process_step_custom_field_value ppscfv13
                   on ppscfv13.project_process_step_id = pps.id and
                      ppscfv13.custom_field_group_assignment_id =
                      25981
         left join flow.project_process_step_custom_field_value ppscfv14
                   on ppscfv14.project_process_step_id = pps.id and
                      ppscfv14.custom_field_group_assignment_id =
                      26122
  where pps.id = v_project_process_step_id;

  create temp table proposal_value as (with version_values
                                              as (select distinct on ( proposal_group_uuid, custom_field_group_assignment_id ) id,
                                                                                                                               proposal_group_uuid,
                                                                                                                               value,
                                                                                                                               field_id,
                                                                                                                               object_code
                                                  from brs.proposal_version_custom_field_value_vw v
                                                  where v.proposal_version_id <= v_proposal_id
                                                    and proposal_group_uuid not in (select distinct proposal_group_uuid
                                                                                    from brs.proposal_version_custom_field_group
                                                                                    where archived is not null
                                                                                      and proposal_version_id <= v_proposal_id)
                                                  order by proposal_group_uuid, custom_field_group_assignment_id, id desc),
                                            grouped_rows as (select jsonb_build_object('pk', proposal_group_uuid,
                                                                                       'object_code', object_code,
                                                                                       'fields',
                                                                                       array_to_json(array_agg(jsonb_strip_nulls(
                                                                                           jsonb_build_object('fieldId',
                                                                                                              vv.field_id,
                                                                                                              'flowCustomFieldId',
                                                                                                              cf.flow_custom_field_id) ||
                                                                                           vv.value)))
                                                                      ) as row
                                                             from version_values vv
                                                                    inner join brs.custom_field cf on cf.id = vv.field_id
                                                             group by proposal_group_uuid, object_code)
                                       select row ->> 'object_code' as object_code, *
                                       from grouped_rows);
  raise notice 'v_first_year_production_estimate = %',v_first_year_production_estimate;
  raise notice 'v_system_size = %',v_system_size;
  raise notice 'v_estimated_annual_energy_consumption_kwh = %',v_estimated_annual_energy_consumption_kwh;

  --   create index pv_proposal_group_uuid on proposal_value (proposal_group_uuid);
--   create index pv_field_id on proposal_value (field_id);
--   create index pv_field_name on proposal_value (field_name);
--   create index pv_data_type_id on proposal_value (data_type_id);
--   create index pv_value on proposal_value (value);
--   create index pv_int_value on proposal_value (int_value);
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

  v_small_system_size_adder_amount = 0.00::numeric;

  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric as small_system_size_adder,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 132)') ->> 'value')::numeric as small_system_size_value,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as small_system_size_unit_type_id
  into v_small_system_size_adder,v_small_system_size_value,v_small_system_size_unit_type_id
  from proposal_value pv
  where object_code = 'PROPOSAL_SMALL_SYSTEM_ADDERS';


  if v_system_size < v_small_system_size_value then
    select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_SMALL_SYSTEM_ADDERS',
                                       v_small_system_size_adder::numeric, v_small_system_size_unit_type_id::bigint,
                                       0::numeric,
                                       null,
                                       null)
    into v_small_system_size_adder_amount;
  end if;

  raise notice 'v_small_system_size_adder_amount = % ',v_small_system_size_adder_amount;

  with t as (select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 340)') ->> 'value')            as adder_name,
                    (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 340)') ->> 'intValue')::bigint as val
             from proposal_value pv
             where object_code = 'PROPOSAL_SITE_SURVEY'
               and jsonb_path_match(row, 'exists($.fields[*] ? (@.intArrayValue == $field))',
                                    jsonb_build_object('field', v_state_id)))
  select string_agg(t.adder_name, ', ')
  into v_site_survey_items
  from t
  where val = any (v_site_survey_time_adders);

  raise notice 'v_site_survey_items = %',v_site_survey_items;

  select sum(site_survey_duration::bigint)
  into v_site_survey_time_estimate
  from (select coalesce((select jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 339)') ->> 'value')::integer,0)   as site_survey_duration,
               (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 340)') ->> 'intValue')::bigint as adder_value,
               (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 340)') ->> 'intValue')::bigint as val
        from proposal_value pv
        where object_code = 'PROPOSAL_SITE_SURVEY'
          and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.value == $value)', '{
          "targetFieldId": 329,
          "value": true
        }'))
        union
        select *
        from (select coalesce((select jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 339)') ->> 'value')::integer,0)   as site_survey_duration,
                     (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 340)') ->> 'intValue')::bigint as adder_value,
                     (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 340)') ->> 'intValue')::bigint as val
              from proposal_value pv
              where object_code = 'PROPOSAL_SITE_SURVEY'
                and not jsonb_path_match(row, 'exists($.fields[*] ? (@.fieldId == $field))', '{
                "field": 329
              }')) as foo1
        where val = any (v_site_survey_time_adders)) as foo;

  raise notice 'v_site_survey_time_estimate = %',v_site_survey_time_estimate;

  select completed_by_surveyor
  into v_site_survey_resource_type_yn
  from (select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == $targetFieldId)', '{
    "targetFieldId": 338
  }') ->> 'value')                                                                                   completed_by_surveyor,
               (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 340)') ->> 'intValue')::bigint as adder_value
        from proposal_value pv
        where object_code = 'PROPOSAL_SITE_SURVEY'
          and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)', '{
          "targetFieldId": 338,
          "intValue": 1731
        }'))
          and not (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.value == $value)', '{
          "targetFieldId": 329,
          "value": true
        }'))) as foo
  where adder_value = any (v_site_survey_time_adders)
  limit 1;
  raise notice 'v_site_survey_resource_type_yn = %',v_site_survey_resource_type_yn;

  if v_site_survey_resource_type_yn is null then
    select completed_by_surveyor
    into v_site_survey_resource_type_yn
    from (select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == $targetFieldId)', '{
      "targetFieldId": 338
    }') ->> 'value')                                                                                   completed_by_surveyor,
                 (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 340)') ->> 'intValue')::bigint as adder_value
          from proposal_value pv
          where object_code = 'PROPOSAL_SITE_SURVEY'
            and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)', '{
            "targetFieldId": 338,
            "intValue": 1730
          }'))
            and not (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.value == $value)', '{
            "targetFieldId": 329,
            "value": true
          }'))) as foo
    where adder_value = any (v_site_survey_time_adders)
    limit 1;
  end if;


  raise notice 'v_site_survey_resource_type_yn = %',v_site_survey_resource_type_yn;
  if v_site_survey_resource_type_yn is not null and v_site_survey_resource_type_yn = 'No' then
    v_site_survey_resource_type = 'Service Tech or Higher';
  elsif v_site_survey_resource_type_yn is not null and v_site_survey_resource_type_yn = 'Yes' then
    v_site_survey_resource_type = 'Site Surveyor';
  end if;

  raise notice 'v_site_survey_resource_type = %',v_site_survey_resource_type;


  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 111)') ->> 'value')::numeric   as apr,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 320)') ->> 'value')::text      as financial_option,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 148)') ->> 'value')::numeric   as reamortized_payment_factor_without_itc_paydown,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 110)') ->> 'value')::numeric   as loan_term,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 114)') ->> 'value')::numeric   as dealer_fee,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 116)') ->> 'value')::numeric   as reamortization_factor,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 102)') ->> 'intValue')::bigint as financier_id,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 102)') ->> 'value')::text      as financier,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 115)') ->> 'value')::numeric   as initial_payment_factor
  into v_apr,v_financial_option,v_reamortized_payment_factor_without_itc_paydown,v_loan_term,
    v_dealer_fee,v_reamortization_factor,v_financier_id,v_financier,v_initial_payment_factor
  from proposal_value pv
  where object_code = 'PROPOSAL_FINANCE_PRODUCTS'
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.fieldId == $field))', '{
    "field": 128
  }')
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.intValue == $field))',
                         jsonb_build_object('field', v_financial_product_id));

  raise notice 'v_apr = %',v_apr;
  raise notice 'v_financial_option = %',v_financial_option;
  raise notice 'v_reamortized_payment_factor_without_itc_paydown = % ',v_reamortized_payment_factor_without_itc_paydown;
  raise notice 'v_loan_term = % ',v_loan_term;
  raise notice 'v_dealer_fee = %',v_dealer_fee;
  raise notice 'v_reamortization_factor = %',v_reamortization_factor;
  raise notice 'v_financier_id = %',v_financier_id;
  raise notice 'v_financier = %',v_financier;
  raise notice 'v_initial_payment_factor = %',v_initial_payment_factor;


  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 147)') ->> 'value')::numeric as instant_use_assumption,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 92)') ->> 'value')::numeric  as net_metring_rate,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 88)') ->> 'value')::numeric  as production_factor_east_west,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 89)') ->> 'value')::numeric  as production_factor_south,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 90)') ->> 'value')::numeric  as maximum_funding_amount_per_watt,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 91)') ->> 'value')::numeric  as minimum_funding_amount_per_watt,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 87)') ->> 'value')::numeric  as current_estimated_cost_per_kwh,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 94)') ->> 'value')::numeric  as utility_cost_escalator,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 380)') ->> 'value')::numeric  as red_line_funding_amount,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 381)') ->> 'value')::numeric  as closer_gen_discount
  into v_instant_use_assumption,v_net_metring_rate,v_production_factor_east_west,
    v_production_factor_south,v_maximum_funding_amount_per_watt,v_minimum_funding_amount_per_watt,
    v_current_estimated_cost_per_kwh,v_utility_cost_escalator,v_red_line_funding_amount,v_closer_gen_discount
  from proposal_value pv
  where object_code = 'PROPOSAL_PRICING'
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.fieldId == $field))', '{
    "field": 85
  }')
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.intValue == $field))',
                         jsonb_build_object('field', v_utility_company_id));


  raise notice 'v_instant_use_assumption = %',v_instant_use_assumption;
  raise notice 'v_net_metring_rate = %',v_net_metring_rate;
  raise notice 'production_factor_east_west = %',v_production_factor_east_west;
  raise notice 'production_factor_south = %',v_production_factor_south;
  raise notice 'maximum_funding_amount_per_watt = %',v_maximum_funding_amount_per_watt;
  raise notice 'minimum_funding_amount_per_watt = %',v_minimum_funding_amount_per_watt;

  raise notice 'v_current_estimated_cost_per_kwh = %',v_current_estimated_cost_per_kwh;
  raise notice 'v_utility_cost_escaltor = %',v_utility_cost_escalator;

  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 155)') ->> 'value')::numeric as number_of_batteries,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 157)') ->> 'value')::numeric as cash_price_storage
  into v_number_of_batteries,v_cash_price_storage
  from proposal_value pv
  where object_code = 'PROPOSAL_STORAGE_DETAILS'
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.fieldId == $field))', '{
    "field": 160
  }')
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.intValue == $field))',
                         jsonb_build_object('field', v_storage_type_id));

  raise notice 'v_number_of_batteries = %',v_number_of_batteries;
  raise notice 'v_cash_price_storage = %',v_cash_price_storage;


  v_instantly_used = v_first_year_production_estimate * v_instant_use_assumption;
  v_sent_to_grid = v_first_year_production_estimate - coalesce(v_instantly_used, 0);
  v_after_net_metering = v_sent_to_grid * v_net_metring_rate;
  v_adjusted_annual_production = coalesce(v_instantly_used, 0) + coalesce(v_after_net_metering, 0);

  raise notice 'v_instant_use_assumption = % ',v_instant_use_assumption;
  raise notice 'v_net_metring_rate = % ',v_net_metring_rate;
  raise notice 'v_instantly_used = % ',v_instantly_used;
  raise notice 'v_sent_to_grid = % ',v_sent_to_grid;
  raise notice 'v_after_net_metering = % ',v_after_net_metering;
  raise notice 'v_adjusted_annual_production = % ',v_adjusted_annual_production;

  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric   as smart_thermostat_value,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 145)') ->> 'value')::numeric   as energy_efficiency_reduction_thermostat,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::numeric as unit_type_id_smart_thermostat
  into v_smart_thermostat_value,v_energy_efficiency_reduction_thermostat,v_unit_type_id_smart_thermostat
  from proposal_value pv
  where object_code = 'PROPOSAL_EQUIPMENT_ADDERS'
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.fieldId == $field))', '{
    "field": 117
  }')
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.intValue == $intValue))', '{
    "intValue": 536
  }');
  raise notice 'v_smart_thermostat_value = % ',v_smart_thermostat_value;
  raise notice 'v_energy_efficiency_reduction_thermostat = % ',v_energy_efficiency_reduction_thermostat;

  select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_EQUIPMENT_ADDERS',
                                     v_smart_thermostat_value::numeric, v_unit_type_id_smart_thermostat::bigint,
                                     0::numeric,
                                     null,
                                     null)
  into v_smart_thermostat_value;

  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric   as led_light_bulbs_value,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 145)') ->> 'value')::numeric   as energy_efficiency_reduction_light_bulbs,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::numeric as unit_type_id_led
  into v_led_light_bulbs_value,v_energy_efficiency_reduction_light_bulbs,v_unit_type_id_led
  from proposal_value pv
  where object_code = 'PROPOSAL_EQUIPMENT_ADDERS'
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.fieldId == $field))', '{
    "field": 117
  }')
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.intValue == $intValue))', '{
    "intValue": 537
  }');

  select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_EQUIPMENT_ADDERS',
                                     v_led_light_bulbs_value::numeric, v_unit_type_id_led::bigint,
                                     0::numeric,
                                     null,
                                     null)
  into v_led_light_bulbs_value;

  raise notice 'v_led_light_bulbs_value = % ',v_led_light_bulbs_value;
  raise notice 'v_energy_efficiency_reduction_light_bulbs = % ',v_energy_efficiency_reduction_light_bulbs;

  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 136)') ->> 'value')::numeric as panel_degradation_factor,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as unit_type_id,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric as adder_amount,
         ARRAY(SELECT jsonb_array_elements_text((jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 341)') -> 'intArrayValue')))::bigint[] as states

  into v_panel_degradation_factor,v_panel_unit_type_id,v_panel_adder_amount,v_panel_states
  from proposal_value pv
  where object_code = 'PROPOSAL_PANEL_DETAIL'
    and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)',
                           jsonb_build_object('targetFieldId', 138, 'intValue', v_panel_brand_id)))
    and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.value == $value)',
                           jsonb_build_object('targetFieldId', 139, 'value', v_panel_watts)));

  raise notice 'v_panel_degradation_factor = %',v_panel_degradation_factor;
  raise notice 'v_panel_unit_type_id = %',v_panel_unit_type_id;
  raise notice 'v_panel_adder_amount = %',v_panel_adder_amount;
  raise notice 'v_panel_states = %',v_panel_states;

  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 142)') ->> 'value')::numeric as inverter_efficiency,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as unit_type_id,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric as adder_amount
  into v_inverter_efficiency,v_inverter_unit_type_id,v_inverter_adder_amount
  from proposal_value pv
  where object_code = 'PROPOSAL_INVERTER_DETAILS'
    and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)',
                           jsonb_build_object('targetFieldId', 131, 'intValue', v_inverter_brand_id)));

  raise notice 'v_inverter_efficiency = %',v_inverter_efficiency;
  raise notice 'v_inverter_unit_type_id = %',v_inverter_unit_type_id;
  raise notice 'v_inverter_adder_amount = %',v_inverter_adder_amount;

  raise notice 'v_utility_company_id = % ',v_utility_company_id;
--call first formula


  raise notice 'v_first_year_production_estimate = %',v_first_year_production_estimate;
  raise notice 'v_system_size = %',v_system_size;

  v_production_factor = v_first_year_production_estimate / (v_system_size * 1000);
  raise notice 'v_production_factor = %',v_production_factor;

  v_funding_range = v_maximum_funding_amount_per_watt - v_minimum_funding_amount_per_watt;

  raise notice 'v_funding_range = %',v_funding_range;
  v_production_factor_range = v_production_factor_south - v_production_factor_east_west;

  raise notice 'v_production_factor_range = %',v_production_factor_range;
  v_points_off_south_production_factor = v_production_factor - v_production_factor_south;

  raise notice 'v_points_off_south_production_factor = %',v_points_off_south_production_factor;
  v_price_change_per_production_point = coalesce(v_funding_range, 0) / v_production_factor_range;

  raise notice 'v_price_change_per_production_point = %',v_price_change_per_production_point;

  v_calculated_price_adjustment = v_price_change_per_production_point * v_points_off_south_production_factor;
  raise notice 'v_calculated_price_adjustment = %',v_calculated_price_adjustment;

  v_max_price_adjustment = (select least(greatest((v_funding_range * -1), v_calculated_price_adjustment), 0))::numeric +
                           case
                             when v_friends_and_family is true then .5::numeric
                             else 0::numeric
                             end;
  raise notice 'v_max_price_adjustment = %',v_max_price_adjustment;

  if v_commission_strategy_id = 23610 then

    v_redline_markup = coalesce(v_desired_commission_amount,0) / 0.68;
    v_lead_source_discount = case when  v_source_id = 523 then coalesce(v_closer_gen_discount,0) else 0 end;
    v_adjusted_price_per_watt = coalesce(v_red_line_funding_amount,0) + coalesce(v_redline_markup,0) - coalesce(v_lead_source_discount,0);
    raise notice 'v_redline_markup = %',v_redline_markup;
    raise notice 'v_lead_source_discount = %',v_lead_source_discount;
    raise notice 'v_adjusted_price_per_watt = %',v_adjusted_price_per_watt;
  else
    v_adjusted_price_per_watt =
        v_maximum_funding_amount_per_watt +
        v_max_price_adjustment;
  end if;

  raise notice 'v_commission_strategy_id = %',v_commission_strategy_id;


  raise notice 'v_adjusted_price_per_watt = %',v_adjusted_price_per_watt;

  v_initial_system_cost = v_system_size::numeric * 1000::numeric * v_adjusted_price_per_watt::numeric;
  raise notice 'v_initial_system_cost = %',v_initial_system_cost;

  v_equipment_storage_adder = 0;

  v_cash_price_storage = coalesce(v_cash_price_storage, 0) / (1 - v_dealer_fee);
  v_equipment_storage_adder = coalesce(v_cash_price_storage, 0);
  v_loan_price_storage = v_cash_price_storage;

  raise notice 'v_cash_price_storage = %',v_cash_price_storage;
  raise notice 'v_loan_price_storage = %',v_loan_price_storage;

  raise notice 'v_storage adder based on loan type = %',v_equipment_storage_adder;


  select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_PANEL_DETAIL', v_panel_adder_amount::numeric,
                                     v_panel_unit_type_id::bigint,  0::numeric, v_panel_states, v_state_id)
  into v_equipment_panel_adder;
 -- raise notice 'v_equipment_panel_adder = %',v_equipment_panel_adder;

   select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_INVERTER_DETAILS',v_inverter_adder_amount::numeric,
    v_inverter_unit_type_id::bigint, 0::numeric,null,null)
  into v_equipment_inverter_adder;
 -- raise notice 'v_equipment_inverter_adder = %',v_equipment_inverter_adder;

  v_misc_adders = brs.get_misc_adder_amount(v_system_size,v_misc_adders_array);
  raise notice 'v_misc_adders = %',v_misc_adders;


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

  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric as adder_name
  into v_zone_adder
  from proposal_value pv
  where object_code = 'PROPOSAL_ZONE_ADDERS'
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.intArrayValue == $field))',
                         jsonb_build_object('field', v_postal_code));

  raise notice 'v_zone_adder = %',v_zone_adder;

  v_promotion_cost = 0.00;
  if v_product_id = 293 then
    v_promotion_cost =
        ((coalesce(v_initial_system_cost, 0) + coalesce(v_equipment_storage_adder, 0) +
          coalesce(v_unapproved_zip_code_adder, 0) +
          coalesce(v_equipment_panel_adder, 0) + coalesce(v_equipment_inverter_adder, 0) +
          coalesce(v_zone_adder,0) +
          coalesce(v_misc_adders, 0) + coalesce(v_small_system_size_adder_amount,0) + coalesce(v_smart_thermostat_adder, 0) + coalesce(v_led_light_bulbs_adder, 0) +
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
          coalesce(v_zone_adder,0) +
          coalesce(v_misc_adders, 0) + coalesce(v_small_system_size_adder_amount,0) + coalesce(v_smart_thermostat_adder, 0) + coalesce(v_led_light_bulbs_adder, 0) +
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
                                       coalesce(v_misc_adders, 0) + coalesce(v_small_system_size_adder_amount,0) + coalesce(v_promotion_cost, 0) +
                                       coalesce(v_zone_adder, 0));
  raise notice 'v_total_loan_amount_before_rebate = %',v_total_loan_amount_before_rebate;


  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 98)') ->> 'value')::bigint as referral_promotion
  into v_referral_promotion
  from proposal_value pv
  where object_code = 'PROPOSAL_REBATE'
    and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)', '{
    "targetFieldId": 93,
    "intValue": 535
  }'));

  v_referral_promotion = coalesce(v_referral_promotion, 0);
  raise notice 'v_referral_promotion = %',v_referral_promotion;


  raise notice 'v_proposal_group_uuid_state_rebate***************************** = % ',v_proposal_group_uuid_state_rebate;

  v_state_rebate_amount = 0.00::numeric;

  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 98)') ->> 'value')::numeric   as state_rebate_amount,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as unit_type_state_rebate,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 101)') ->> 'value')::numeric  as state_rebate_cap_amount,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 133)') ->> 'value')::numeric  as state_rebate_cap_percent_of_total
  into v_state_rebate_amount,v_unit_type_state_rebate,v_state_rebate_cap_amount,v_state_rebate_cap_percent_of_total
  from proposal_value pv
  where object_code = 'PROPOSAL_REBATE'
    and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)',
                           jsonb_build_object('targetFieldId', 86, 'intValue', v_state_id)))
    and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)', '{
    "targetFieldId": 96,
    "intValue": 454
  }'));

  v_state_rebate_amount = coalesce(v_state_rebate_amount, 0);
  raise notice 'v_state_rebate_amount***************************** = % ',v_state_rebate_amount;
  raise notice 'v_unit_type_state_rebate***************************** = % ',v_unit_type_state_rebate;
  raise notice 'v_state_rebate_cap_amount***************************** = % ',v_state_rebate_cap_amount;
  raise notice 'v_state_rebate_cap_percent_of_total***************************** = % ',v_state_rebate_cap_percent_of_total;

  v_utility_rebate_amount = 0.00::numeric;
  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 98)') ->> 'value')::numeric   as utility_rebate_amount,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as unit_type_utility_rebate,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 101)') ->> 'value')::numeric  as utility_rebate_cap_amount,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 133)') ->> 'value')::numeric  as utility_rebate_cap_percent_of_total
  into v_utility_rebate_amount,v_unit_type_utility_rebate,v_utility_rebate_cap_amount,v_utility_rebate_cap_percent_of_total
  from proposal_value pv
  where object_code = 'PROPOSAL_REBATE'
    and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)',
                           jsonb_build_object('targetFieldId', 85, 'intValue', v_utility_company_id)))
    and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)', '{
    "targetFieldId": 96,
    "intValue": 455
  }'));

  v_state_rebate_amount = coalesce(v_state_rebate_amount, 0);
  raise notice 'v_utility_rebate_amount***************************** = % ',v_utility_rebate_amount;

  v_utility_rebate_amount = coalesce(v_utility_rebate_amount, 0);
  raise notice 'v_utility_rebate_amount***************************** = % ',v_utility_rebate_amount;
  raise notice 'v_unit_type_utility_rebate***************************** = % ',v_unit_type_utility_rebate;
  raise notice 'v_utility_rebate_cap_amount***************************** = % ',v_utility_rebate_cap_amount;
  raise notice 'v_utility_rebate_cap_percent_of_total***************************** = % ',v_utility_rebate_cap_percent_of_total;
  raise notice 'v_other_adder_and_discount_amount = %',v_other_adder_and_discount_amount;

  v_total_system_cost_before_rebates =
    (coalesce(v_total_loan_amount_before_rebate, 0) + coalesce(v_down_payment_amount, 0) +
     coalesce(v_referral_promotion * -1, 0) + coalesce((v_other_adder_and_discount_amount * -1), 0));
  raise notice 'v_total_system_cost_before_rebates = %',v_total_system_cost_before_rebates;
  raise notice 'v_total_system_cost_before_rebates = %',v_total_system_cost_before_rebates;

--illionios
  if v_state_id = 13 then
    select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 369)') ->> 'value')::numeric as il_srec_less_10,
           (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 370)') ->> 'value')::numeric as il_srec_between_10_25,
           (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 371)') ->> 'value')::numeric as il_srec_greater_25,
           (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 372)') ->> 'value')::numeric as il_srec_greater_25,
           (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 101)') ->> 'value')          as srec_rebate_cap_amount,
           (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 133)') ->> 'value')          as srec_rebate_cap_percent_of_total
    into v_il_srec_less_10,v_il_srec_between_10_25,v_il_srec_greater_25,v_srec_realization,
      v_srec_rebate_cap_amount,v_srec_rebate_cap_percent_of_total
    from proposal_value pv
    where object_code = 'PROPOSAL_REBATE'
      and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)', '{
      "targetFieldId": 86,
      "intValue": 13
    }'))
      and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)', '{
      "targetFieldId": 96,
      "intValue": 1911
    }'))
      and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)', '{
      "targetFieldId": 93,
      "intValue": 1905
    }'));


    raise notice 'v_il_srec_less_10 = %',v_il_srec_less_10;
    raise notice 'v_il_srec_between_10_25 = %',v_il_srec_between_10_25;
    raise notice 'v_il_srec_greater_25 = %',v_il_srec_greater_25;
    raise notice 'v_srec_realization = %',v_srec_realization;
    raise notice 'v_srec_rebate_cap_amount***************************** = % ',v_srec_rebate_cap_amount;
    raise notice 'v_srec_rebate_cap_percent_of_total***************************** = % ',v_srec_rebate_cap_percent_of_total;

-- inverter_efficiency
-- ONLY IF THE state is Illinois ((15 year production * inverter_efficiency)/1000) * if system is less then < IL srec 10   else greater then >= 10 and less than 25 else greater than 25 * srec realization
    v_ill_srec_rebate_amount =
        ((brs.get_system_production_year(v_first_year_production_estimate, v_panel_degradation_factor, 15) *
          v_inverter_efficiency) / 1000) * case
                                             when v_system_size < 10::numeric then
                                               v_il_srec_less_10
                                             when v_system_size >= 10::numeric and v_system_size < 25::numeric then
                                               v_il_srec_between_10_25
                                             when v_system_size >= 25 then
                                               v_il_srec_greater_25 end * v_srec_realization;

    if v_srec_rebate_cap_amount is not null then
      v_ill_srec_rebate_amount = least(v_ill_srec_rebate_amount::numeric, v_srec_rebate_cap_amount::numeric);
    elsif v_srec_rebate_cap_percent_of_total is not null then
      v_ill_srec_rebate_amount =
        least(v_ill_srec_rebate_amount, v_srec_rebate_cap_percent_of_total * v_total_system_cost_before_rebates);
    end if;
    raise notice 'v_ill_srec_rebate_amount = %',v_ill_srec_rebate_amount;
  end if;

  select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_REBATE',
                                     v_utility_rebate_amount::numeric, v_unit_type_utility_rebate::bigint,
                                     (coalesce(v_total_system_cost_before_rebates, 0)),
                                     null,
                                     null)
  into v_utility_rebate_amount;

  if v_utility_rebate_cap_amount is not null then
    v_utility_rebate_amount = least(v_utility_rebate_amount::numeric, v_utility_rebate_cap_amount::numeric);
  elsif v_utility_rebate_cap_percent_of_total is not null then
    v_utility_rebate_amount =
      least(v_utility_rebate_amount, v_utility_rebate_cap_percent_of_total * v_total_system_cost_before_rebates);
  end if;

  raise notice 'v_utility_rebate_amount = %',v_utility_rebate_amount;

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

  raise notice 'v_csu_rebate = %',v_csu_rebate;
  raise notice 'v_csu_rebate_unit_type_id = %',v_csu_rebate_unit_type_id;


  -- select *
-- into v_col_springs_rebate
-- from brs.get_colorado_rebate(v_aurora_design_summary, v_csu_rebate,
--                              v_inverter_efficiency);

--end if;
  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 98)') ->> 'value')::numeric   as rebate_amount,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 101)') ->> 'value')::numeric  as rebate_cap_amount,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 133)') ->> 'value')::numeric  as rebate_cap_percent_of_total,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 382)') ->> 'value')::numeric   as battery_rebate_amount,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 383)') ->> 'value')::numeric  as battery_rebate_cap_amount,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 384)') ->> 'value')::numeric  as battery_rebate_cap_percent_of_total,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 385)') ->> 'value')::numeric  as system_size_cutoff
  into v_rebate_amount,v_rebate_cap_amount,v_rebate_cap_percentage,
    v_battery_rebate_amount,v_battery_rebate_cap_amount,v_battery_rebate_cap_percent_of_total,
    v_system_size_cutoff
  from proposal_value pv
  where object_code = 'PROPOSAL_REBATE'
    and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)', jsonb_build_object('targetFieldId', 93, 'intValue', v_odoe_income_status)));

  raise notice 'v_odoe_income_status % ',v_odoe_income_status;
  raise notice 'v_rebate_amount % ',v_rebate_amount;
  raise notice 'v_rebate_cap_amount % ',v_rebate_cap_amount;
  raise notice 'v_rebate_cap_percentage % ',v_rebate_cap_percentage;
  raise notice 'v_battery_rebate_amount % ',v_battery_rebate_amount;
  raise notice 'v_battery_rebate_cap_amount % ',v_battery_rebate_cap_amount;
  raise notice 'v_battery_rebate_cap_percent_of_total % ',v_battery_rebate_cap_percent_of_total;
  raise notice 'v_system_size_cutoff % ',v_system_size_cutoff;

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
                                              v_cash_price_storage
    );
  raise notice 'v_odoe_rebate % ',v_odoe_rebate;



  raise notice 'v_col_springs_rebate = %',v_col_springs_rebate;
  v_above_line_rebate = coalesce(v_utility_rebate_amount, 0) + coalesce(v_ill_srec_rebate_amount, 0) + coalesce(v_odoe_rebate,0);
  --+ coalesce(v_csu_rebate, 0);  --Judson wanted me to take out this rebate

  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 106)') ->> 'value') asnon_solar_cap
  into v_non_solar_cap
  from proposal_value pv
  where object_code = 'PROPOSAL_FINANCIERS'
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.intValue == $field))',
                         jsonb_build_object('field', v_financier_id));

  raise notice 'v_non_solar_cap = %',v_non_solar_cap;

  v_total_system_cost =
      (((coalesce(v_total_loan_amount_before_rebate, 0) - coalesce(v_above_line_rebate, 0)) / (1 - v_dealer_fee)) +
       coalesce(v_other_adder_and_discount_amount, 0)) + coalesce(v_down_payment_amount, 0) + coalesce(v_above_line_rebate, 0) +
      coalesce(v_referral_promotion, 0) + coalesce((v_other_adder_and_discount_amount * -1), 0);
  raise notice 'v_total_system_cost = %',v_total_system_cost;


  v_required_down_payment =  --judson changed from the lower function to this one right before he left his job.
    greatest((((coalesce(v_other_adder_and_discount_amount, 0) +
                coalesce(v_main_panel_upgrade_cost, 0)::numeric + coalesce(v_unapproved_zip_code_adder, 0) +
                coalesce(v_structural_upgrade_cost, 0)::numeric + coalesce(v_reroof_cost, 0)::numeric +
                coalesce(v_tree_trimming_cost, 0)::numeric + coalesce(v_trenching_cost, 0)::numeric +
                coalesce(v_ac_unit_relocation_cost, 0)::numeric) -
               ((v_total_system_cost * (1-v_dealer_fee)) * v_non_solar_cap)) /
              (1-v_non_solar_cap)),0);

--   v_required_down_payment =
--     greatest(((coalesce(v_other_adder_and_discount_amount, 0) +
--                coalesce(v_main_panel_upgrade_cost, 0)::numeric + coalesce(v_unapproved_zip_code_adder, 0) +
--                coalesce(v_structural_upgrade_cost, 0)::numeric + coalesce(v_reroof_cost, 0)::numeric +
--                coalesce(v_tree_trimming_cost, 0)::numeric + coalesce(v_trenching_cost, 0)::numeric +
--                coalesce(v_ac_unit_relocation_cost, 0)::numeric)/(1-v_dealer_fee)) - (v_total_system_cost * v_non_solar_cap), 0);
   raise notice 'v_required_down_payment = %',v_required_down_payment;

  v_total_loan_amount =
      ((coalesce(v_total_loan_amount_before_rebate, 0) - coalesce(v_above_line_rebate, 0)) / (1 - v_dealer_fee)) +
      coalesce(v_other_adder_and_discount_amount, 0) - coalesce(v_required_down_payment,0) - coalesce(v_down_payment_amount,0);
  raise notice 'v_total_loan_amount = %',v_total_loan_amount;

  v_check_from_br = 0.00::numeric;
  if v_product_id in (293, 19424) then
    v_check_from_br = round((v_total_loan_amount * v_initial_payment_factor)::numeric, 2);
  end if;

  raise notice 'v_check_from_br = %',v_check_from_br;

  select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_REBATE',
                                     v_state_rebate_amount::numeric, v_unit_type_state_rebate::bigint,
                                     (coalesce(v_total_system_cost_before_rebates, 0)),
                                     null,
                                     null)
  into v_state_rebate_amount;

  if v_state_rebate_cap_amount is not null then
    v_state_rebate_amount = least(v_state_rebate_amount::numeric, v_state_rebate_cap_amount::numeric);
  elsif v_state_rebate_cap_percent_of_total is not null then
    v_state_rebate_amount =
      least(v_state_rebate_amount, v_state_rebate_cap_percent_of_total * v_total_system_cost_before_rebates);
  end if;

  raise notice 'v_state_rebate_amount = % ',v_state_rebate_amount;
  raise notice 'v_unit_type_state_rebate = % ',v_unit_type_state_rebate;


  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 98)') ->> 'value')::numeric    as federal_tax_incentive_rate,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::numeric as federal_unit_type_id
  into v_federal_tax_incentive_rate,v_federal_unit_type_id
  from proposal_value pv
  where object_code = 'PROPOSAL_REBATE'
    and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)', '{
    "targetFieldId": 96,
    "intValue": 453
  }'));


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


  v_total_ee_reduction =
    least(((v_estimated_annual_energy_consumption_kwh *
            case
              when v_smart_thermostat > 0 then v_energy_efficiency_reduction_thermostat
              else 0 end) + ---Judson said this should be the least
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

  if v_product_id = 19424 then -- this is for interest only
    select *
    into v_reamortized_monthly_payment_all_credits_to_loan
    from flow.get_reamortized_monthly_payment((v_apr / 12):: numeric, ((v_loan_term * 12) - 18):: smallint,
                                              (coalesce(v_total_loan_amount, 0) -
                                               coalesce(v_federal_tax_incentive_amount, 0) -
                                               coalesce(v_state_rebate_amount, 0) -
                                               coalesce(v_above_line_rebate, 0)):: numeric);
  else  --TODO judson check to see if we need to subtract the rebates
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


  v_initial_monthly_payment_all_credits_to_loan = v_total_loan_amount * v_initial_payment_factor;
  raise notice 'v_initial_monthly_payment_all_credits_to_loan = %',v_initial_monthly_payment_all_credits_to_loan;

  v_initial_monthly_payment_no_credits_to_loan = v_total_loan_amount * v_initial_payment_factor;
  raise notice 'v_initial_monthly_payment_no_credits_to_loan = %',v_initial_monthly_payment_no_credits_to_loan;

  v_net_payment_from_customer = v_initial_monthly_payment_all_credits_to_loan - v_check_from_br;
  raise notice 'v_net_payment_from_customer = %',v_net_payment_from_customer;
  if v_product_id = 19424 then
    select *
    into v_reamortized_monthly_payment_no_credits_to_loan
    from flow.get_reamortized_monthly_payment((v_apr / 12):: numeric, ((v_loan_term * 12) - 18):: smallint,
                                              v_total_loan_amount::numeric);
  else
    v_reamortized_monthly_payment_no_credits_to_loan = v_total_loan_amount * v_reamortization_factor;
  end if;


  raise notice 'v_reamortized_monthly_payment_no_credits_to_loan = %',v_reamortized_monthly_payment_no_credits_to_loan;

  v_monthly_payment_all_credits_to_loan_after_term = 0.00;

  raise notice 'v_monthly_payment_all_credits_to_loan_after_term = %',v_monthly_payment_all_credits_to_loan_after_term;
  v_monthly_payment_no_credits_to_loan_after_term = 0.00;

  raise notice 'v_monthly_payment_no_credits_to_loan_after_term = %',v_monthly_payment_no_credits_to_loan_after_term;

  if v_product_id in (293,19424) then
    v_monthly_cost_today_with_solar = greatest(0, (v_current_estimated_cost_per_kwh *
                                                   (v_adjusted_annual_consumption -
                                                    v_adjusted_annual_production)) / 12);
  else
    v_monthly_cost_today_with_solar = greatest(0, (v_current_estimated_cost_per_kwh *
                                                   (v_adjusted_annual_consumption -
                                                    v_adjusted_annual_production)) / 12) +
                                         v_initial_monthly_payment_all_credits_to_loan;

  end if;
  raise notice 'v_monthly_cost_today_with_solar = %',v_monthly_cost_today_with_solar;

  v_net_system_cost =
          v_total_system_cost - coalesce(v_referral_promotion, 0) - coalesce(v_federal_tax_incentive_amount, 0) -
          coalesce(v_above_line_rebate, 0) + coalesce(v_other_adder_and_discount_amount, 0) -
          coalesce(v_state_rebate_amount, 0);
  raise notice 'v_net_system_cost = %',v_net_system_cost;

  v_current_estimated_annual_utility_bill =
      v_estimated_annual_energy_consumption_kwh * v_current_estimated_cost_per_kwh;
  raise notice 'v_current_estimated_annual_utility_bill = %',v_current_estimated_annual_utility_bill;

  v_system_production_25_year = brs.get_system_production_year(
    v_first_year_production_estimate,
    v_panel_degradation_factor,
    25);
  raise notice 'v_system_production_25_year = %',v_system_production_25_year;

  raise notice 'v_led_light_bulbs = %',v_led_light_bulbs;

  raise notice 'v_smart_thermostat = %',v_smart_thermostat;

  v_secondary_monthly_payment_no_credits_to_loan =   --TODO  find out what this is Michael!!!!
      v_reamortized_monthly_payment_no_credits_to_loan -
      (coalesce(v_reamortized_monthly_payment_all_credits_to_loan, 0) -
       coalesce(v_initial_monthly_payment_all_credits_to_loan, 0));
  raise notice 'v_secondary_monthly_payment_no_credits_to_loan = %',v_secondary_monthly_payment_no_credits_to_loan;

  v_assumed_payment_by_month_18 = v_federal_tax_incentive_amount;
  raise notice 'v_assumed_payment_by_month_18 = %',v_assumed_payment_by_month_18;

  v_loan_type = concat(v_financier || ' ' || v_loan_term);
  raise notice 'v_loan_type = %',v_loan_type;

--   (24 * square root of system size in kWh DC)-(0.0016+(sqrt of system size in kWh DC * 0.00012)) * square footage of house * number of batteries
  v_estimated_backup_days = case --todo michael
                              when v_system_size is not null then
                                    24 * sqrt(v_system_size) -
                                    (0.0016 + sqrt(v_system_size * 0.00012)) * v_total_square_footage *
                                    v_number_of_batteries end;
  v_solar_rebate_for_hic =  --todo take out required down payment other discounts and adders Michael
      v_total_system_cost - coalesce(v_referral_promotion, 0) - coalesce(v_down_payment_amount, 0) -
      coalesce(v_total_loan_amount, 0);

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
                                         bp_plus_amount, aurora_design_id, loan_type, filename, financial_option,
                                         site_survey_time_estimate,
                                         site_survey_resource_type, site_survey_items, number_of_batteries,
                                         estimated_backup_days,
                                         solar_rebate_for_hic)
    values (v_project_id,
            v_project_name,
            v_project_street1,
            v_city,
            v_project_state_abbrev,
            v_postal_code,
            v_contact_phone,
            v_contact_email,
            v_loan_term,
            v_apr,
            v_down_payment_amount,
            v_led_light_bulbs,
            v_smart_thermostat,
            v_current_estimated_cost_per_kwh,
            v_promotion_cost,
            v_first_year_production_estimate,
            v_panel_quantity,
            v_panel_watts,
            v_system_size,
            v_panel_brand,
            v_panel_quantity,
            v_inverter_brand,
            v_inverter_brand,
            v_utility_company,
            v_estimated_annual_energy_consumption_kwh,
            v_equipment_panel_adder,
            v_equipment_panel_adder * (v_system_size * 1000),
            (coalesce(v_equipment_storage_adder, 0) + coalesce(v_unapproved_zip_code_adder, 0) +
             coalesce(v_equipment_panel_adder, 0) + coalesce(v_equipment_inverter_adder, 0) +
             coalesce(v_misc_adders, 0) + coalesce(v_small_system_size_adder_amount,0) + coalesce(v_smart_thermostat_adder, 0) + coalesce(v_led_light_bulbs_adder, 0) +
             coalesce(v_main_panel_upgrade_cost, 0)::numeric +
             coalesce(v_structural_upgrade_cost, 0)::numeric + coalesce(v_reroof_cost, 0)::numeric +
             coalesce(v_tree_trimming_cost, 0)::numeric + coalesce(v_trenching_cost, 0)::numeric +
             coalesce(v_ac_unit_relocation_cost, 0)::numeric),
            v_adjusted_price_per_watt,
            v_total_loan_amount,
            v_total_system_cost,
            v_estimated_offset,
            v_dealer_fee,
            v_utility_cost_escalator,
            v_panel_degradation_factor,
            v_production_factor,
            v_total_system_cost,
            (v_down_payment_amount + v_above_line_rebate),
            v_referral_promotion,
            v_initial_system_cost,
            v_total_loan_amount,
            v_federal_tax_incentive_amount,
            v_state_rebate_amount,
            v_monthly_cost_today_without_solar,
            v_monthly_solar_payment,
            v_monthly_cost_today_avg_remaining_electrical_bill,
            v_monthly_cost_today_with_solar,
            (v_estimated_annual_energy_consumption_kwh / 12),
            (v_estimated_annual_energy_consumption_kwh - v_total_ee_reduction),
            v_total_ee_reduction,
            v_estimated_annual_energy_consumption_kwh,
            (v_estimated_annual_energy_consumption_kwh - v_total_ee_reduction),
            v_monthly_cost_25_year_average_without_solar,
            v_total_cost_25_years,
            v_total_savings_25_years,
            v_remaining_monthly_electric_bill_25_year_average,
            v_reamortized_monthly_payment_all_credits_to_loan,
            v_initial_monthly_payment_all_credits_to_loan,
            v_reamortized_monthly_payment_all_credits_to_loan,
            now(),
            v_promotion_cost,
            now(),
            v_proposal_nbr,
            v_proposal_id,
            v_promotion_cost,
            v_aurora_design_id,
            v_loan_type,
            v_display_name,
            v_financial_option,
            v_site_survey_time_estimate,
            v_site_survey_resource_type,
            v_site_survey_items,
            v_number_of_batteries,
            v_estimated_backup_days,
            v_solar_rebate_for_hic);
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
           cast(round(v_ill_srec_rebate_amount, 2) as money)::varchar,
           cast(round(v_utility_rebate_amount, 2) as money)::varchar,
           --cast(round(v_eto_rebate, 2) as money)::varchar,
           -- cast(round(v_csu_rebate, 2) as money)::varchar,
           round(v_apr * 100, 2),
           v_loan_term,
           cast(round(v_assumed_payment_by_month_18, 2) as money)::varchar,
           round(v_panel_degradation_factor * 100, 2),
           TO_CHAR(round(v_system_production_25_year, 0), 'FM9,999,999'),--comma not money
           round(round(v_estimated_offset, 2) * 100, 0),
           v_led_light_bulbs,
           v_smart_thermostat,
           round(v_total_ee_reduction, 0),
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
           round(v_adjusted_price_per_watt, 2),
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
           v_csu_rebate_unit_type_id,
           v_financial_option,
           cast(v_check_from_br as money)::varchar,
           v_site_survey_time_estimate,
           v_site_survey_resource_type_yn,
           v_site_survey_resource_type,
           v_site_survey_items,
           v_number_of_batteries,
           v_estimated_backup_days,
           v_solar_rebate_for_hic,
           v_total_square_footage,
           cast(round(v_net_payment_from_customer, 2) as money)::varchar;

  drop table proposal_value;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
