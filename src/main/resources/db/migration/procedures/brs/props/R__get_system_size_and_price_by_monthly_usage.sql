drop function if exists brs.get_system_size_and_price_by_monthly_usage(p_state_abbrev text,
                                                                       p_average_monthly_bill numeric,
                                                                       p_utility_id integer,
                                                                       p_number_of_batteries integer);
drop function if exists brs.get_system_size_and_price_by_monthly_usage(p_state_abbrev text,
                                                                       p_average_monthly_bill numeric,
                                                                       p_utility_id integer,
                                                                       p_number_of_batteries integer,
                                                                       p_battery_brand text);
CREATE OR REPLACE FUNCTION brs.get_system_size_and_price_by_monthly_usage(p_state_abbrev text,
                                                                          p_average_monthly_bill numeric,
                                                                          p_utility_id integer,
                                                                          p_number_of_batteries integer,
                                                                          p_battery_brand text)
  returns table
          (
            average_production_factor                          numeric,
            utility_rate                                       numeric,
            monthly_usage_kwh                                  numeric,
            annual_usage_kwh                                   numeric,
            system_size_kw_100_percent_offset                  numeric,
            system_size_kw_85_percent_offset                   numeric,
            system_size_kw_115_percent_offset                  numeric,
            cash_price_for_100_percent_offset                  numeric,
            cash_price_for_100_panel_cost_offset               numeric,
            cash_price_for_85_percent_offset                   numeric,
            cash_price_for_85_panel_cost_offset                numeric,
            cash_price_for_115_percent_offset                  numeric,
            cash_price_for_115_panel_cost_offset               numeric,
            init_pmt_factor_10_year_low_dealer_fee             numeric,
            init_pmt_factor_25_year_low_payment                numeric,
            dealer_fee_10_year_low_dealer_fee                  numeric,
            dealer_fee_25_year_low_payment                     numeric,
            month_pmt_100_offset_low_dealer_fee                numeric,
            month_pmt_85_offset_low_dealer_fee                 numeric,
            month_pmt_115_offset_low_dealer_fee                numeric,
            total_system_cost_100_offset_low_dealer_fee        numeric,
            total_system_cost_100_panel_cost_low_dealer_fee    numeric,
            total_system_cost_85_offset_low_dealer_fee         numeric,
            total_system_cost_85_panel_cost_low_dealer_fee     numeric,
            total_system_cost_115_offset_low_dealer_fee        numeric,
            total_system_cost_115_panel_cost_low_dealer_fee    numeric,
            month_pmt_100_offset_low_monthly_pmt               numeric,
            month_pmt_85_offset_low_monthly_pmt                numeric,
            month_pmt_115_offset_low_monthly_pmt               numeric,
            total_system_cost_100_offset_low_monthly_pmt       numeric,
            total_system_cost_100_panel_cost_low_monthly_pmt   numeric,
            total_system_cost_85_offset_low_monthly_pmt        numeric,
            total_system_cost_85_panel_cost_low_monthly_pmt    numeric,
            total_system_cost_115_offset_low_monthly_pmt       numeric,
            total_system_cost_115_panel_cost_low_monthly_pmt   numeric,
            apr_low_dealer_fee_option                          numeric,
            term_low_dealer_fee_option                         numeric,
            apr_low_monthly_option                             numeric,
            term_low_monthly_option                            numeric,
            utility_cost_escalator                             numeric,
            twenty_five_year_savings_cash_100_offset           numeric,
            twenty_five_year_savings_cash_85_offset            numeric,
            twenty_five_year_savings_cash_115_offset           numeric,
            twenty_five_year_savings_low_dealer_fee_100_offset numeric,
            twenty_five_year_savings_low_dealer_fee_85_offset  numeric,
            twenty_five_year_savings_low_dealer_fee_115_offset numeric,
            twenty_five_year_savings_low_payment_100_offset    numeric,
            twenty_five_year_savings_low_payment_85_offset     numeric,
            twenty_five_year_savings_low_payment_115_offset    numeric,
            net_system_cost_100_offset_low_dealer_fee          numeric,
            net_system_cost_100_panel_cost_low_dealer_fee      numeric,
            net_system_cost_85_offset_low_dealer_fee           numeric,
            net_system_cost_85_panel_cost_low_dealer_fee       numeric,
            net_system_cost_115_offset_low_dealer_fee          numeric,
            net_system_cost_115_panel_cost_low_dealer_fee      numeric,
            net_system_cost_100_offset_low_month_pmt           numeric,
            net_system_cost_100_panel_cost_low_monthly_pmt     numeric,
            net_system_cost_85_offset_low_month_pmt            numeric,
            net_system_cost_85_panel_cost_low_monthly_pmt      numeric,
            net_system_cost_115_offset_low_month_pmt           numeric,
            net_system_cost_115_panel_cost_low_monthly_pmt     numeric,
            net_cash_price_for_100_percent_offset              numeric,
            net_cash_price_for_100_panel_cost_offset           numeric,
            net_cash_price_for_85_percent_offset               numeric,
            net_cash_price_for_85_panel_cost_offset            numeric,
            net_cash_price_for_115_percent_offset              numeric,
            net_cash_price_for_115_panel_cost_offset           numeric,
            battery_price                                      numeric,
            financed_battery_price_low_dealer_fee              numeric,
            financed_battery_price_low_month_pmt               numeric
          )
AS
$BODY$
declare
  v_state_id                                            bigint;
  v_average_production_factor                           numeric;
  v_utility_rate_kwh                                    numeric;
  v_monthly_usage_kwh                                   numeric;
  v_annual_usage_kwh                                    numeric;
  v_system_size_kw_100_percent_offset                   numeric;
  v_system_size_kw_85_percent_offset                    numeric;
  v_system_size_kw_115_percent_offset                   numeric;
  v_cash_price_for_100_percent_offset                   numeric;
  v_cash_price_for_85_percent_offset                    numeric;
  v_cash_price_for_115_percent_offset                   numeric;
  v_net_cash_price_for_100_percent_offset               numeric;
  v_net_cash_price_for_85_percent_offset                numeric;
  v_net_cash_price_for_115_percent_offset               numeric;
  v_init_pmt_factor_10_year_low_dealer_fee              numeric;
  v_init_pmt_factor_25_year_low_payment                 numeric;
  v_dealer_fee_10_year_low_dealer_fee                   numeric;
  v_dealer_fee_25_year_low_payment                      numeric;
  v_month_pmt_100_offset_low_dealer_fee                 numeric;
  v_month_pmt_85_offset_low_dealer_fee                  numeric;
  v_month_pmt_115_offset_low_dealer_fee                 numeric;
  v_total_system_cost_100_offset_low_dealer_fee         numeric;
  v_net_system_cost_100_offset_low_dealer_fee           numeric;
  v_total_system_cost_85_offset_low_dealer_fee          numeric;
  v_net_system_cost_85_offset_low_dealer_fee            numeric;
  v_total_system_cost_115_offset_low_dealer_fee         numeric;
  v_net_system_cost_115_offset_low_dealer_fee           numeric;
  v_month_pmt_100_offset_low_month_pmt                  numeric;
  v_month_pmt_85_offset_low_month_pmt                   numeric;
  v_month_pmt_115_offset_low_month_pmt                  numeric;
  v_total_system_cost_100_offset_low_month_pmt          numeric;
  v_net_system_cost_100_offset_low_month_pmt            numeric;
  v_total_system_cost_85_offset_low_month_pmt           numeric;
  v_net_system_cost_85_offset_low_month_pmt             numeric;
  v_total_system_cost_115_offset_low_month_pmt          numeric;
  v_net_system_cost_115_offset_low_month_pmt            numeric;
  v_apr_low_dealer_fee_option                           numeric;
  v_term_low_dealer_fee_option                          numeric;
  v_apr_low_monthly_option                              numeric;
  v_term_low_monthly_option                             numeric;
  v_remaining_mon_electric_bill_25_year_average_100     numeric;
  v_remaining_mon_electric_bill_25_year_average_85      numeric;
  v_remaining_mon_electric_bill_25_year_average_115     numeric;
  v_utility_cost_escalator                              numeric;
  v_twenty_five_year_savings_cash_100_offset            numeric;
  v_twenty_five_year_savings_cash_85_offset             numeric;
  v_twenty_five_year_savings_cash_115_offset            numeric;
  v_total_cost_25_years                                 numeric;
  v_twenty_five_year_savings_low_dealer_fee_100_offset  numeric;
  v_twenty_five_year_savings_low_dealer_fee_85_offset   numeric;
  v_twenty_five_year_savings_low_dealer_fee_115_offset  numeric;
  v_twenty_five_year_savings_low_payment_100_offset     numeric;
  v_twenty_five_year_savings_low_payment_85_offset      numeric;
  v_twenty_five_year_savings_low_payment_115_offset     numeric;
  v_federal_tax_incentive_rate                          numeric;
  v_federal_unit_type_id                                bigint;
  v_federal_tax_incentive_amount_100_cash               numeric;
  v_federal_tax_incentive_amount_85_cash                numeric;
  v_federal_tax_incentive_amount_115_cash               numeric;
  v_federal_tax_incentive_amount_100_low_dealer_fee     numeric;
  v_federal_tax_incentive_amount_85_low_dealer_fee      numeric;
  v_federal_tax_incentive_amount_115_low_dealer_fee     numeric;
  v_federal_tax_incentive_amount_100_low_mon_pay        numeric;
  v_federal_tax_incentive_amount_85_low_mon_pay         numeric;
  v_federal_tax_incentive_amount_115_low_mon_pay        numeric;
  v_battery_price                                       numeric;
  v_version_id                                          bigint;
  v_dealer_redline_price                                numeric;
  v_financed_battery_price_low_dealer_fee               numeric;
  v_financed_battery_price_low_month_pmt                numeric;
  v_battery_federal_tax_incentive_amount_low_dealer_fee numeric;
  v_battery_federal_tax_incentive_amount_low_mon_pay    numeric;
  v_battery_federal_tax_incentive_amount_cash           numeric;

BEGIN
  v_battery_price = 0::numeric;
  if p_battery_brand is not null and p_number_of_batteries is not null then

    select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 157)') ->>
            'value')::numeric as cash_price_storage
    into v_battery_price
    from brs.get_proposal_version_value(v_version_id, array [(155, p_number_of_batteries, null, null)::ProposalFieldFilter,
      (412, p_battery_brand, null, null)::ProposalFieldFilter,
      (102, null, 20065, null)::ProposalFieldFilter],
                                        'PROPOSAL_STORAGE_DETAILS');
  end if;
  select sapf.average_production_factor, s.id
  into v_average_production_factor,v_state_id
  from brs.state_average_production_factor sapf
         inner join flow.state s on s.abbreviation = p_state_abbrev
  where sapf.state_id = s.id;

  select max(version::bigint)
  into v_version_id
  from brs.proposal_version p
  where proposal_version_status_id = 2;

  select gp.dealer_redline_price
  into v_dealer_redline_price
  from brs.get_proposal_dealer_redline_pricing(v_version_id, v_state_id, 2035) as gp;

  select gp.current_estimated_cost_per_kwh, gp.utility_cost_escalator
  into v_utility_rate_kwh,v_utility_cost_escalator
  from brs.get_proposal_pricing(v_version_id, p_utility_id) as gp;
  --------

  select gp.apr, loan_term, gp.dealer_fee, gp.initial_payment_factor
  into v_apr_low_dealer_fee_option,v_term_low_dealer_fee_option,v_dealer_fee_10_year_low_dealer_fee,
    v_init_pmt_factor_10_year_low_dealer_fee
  from brs.get_proposal_finance_products(v_version_id, 0, 1918) as gp;

  select gp.apr, gp.loan_term, gp.dealer_fee, gp.initial_payment_factor
  into v_apr_low_monthly_option,v_term_low_monthly_option,
    v_dealer_fee_25_year_low_payment,v_init_pmt_factor_25_year_low_payment
  from brs.get_proposal_finance_products(v_version_id, 0, 1917) as gp;

  v_financed_battery_price_low_dealer_fee = 0::numeric;
  v_financed_battery_price_low_month_pmt = 0::numeric;
  if p_battery_brand is not null and p_number_of_batteries is not null and v_battery_price > 0 then
    v_financed_battery_price_low_dealer_fee = v_battery_price / (1 - v_dealer_fee_10_year_low_dealer_fee);
    v_financed_battery_price_low_month_pmt = v_battery_price / (1 - v_dealer_fee_25_year_low_payment);
  end if;


  select gp.rebate_amount,
         gp.unit_type_id
  into v_federal_tax_incentive_rate,v_federal_unit_type_id
  from brs.get_proposal_rebates(v_version_id) as gp
  where gp.rebate_type_id = 453;

  --   raise notice 'v_cash_price_for_100_percent_offset %',v_cash_price_for_100_percent_offset;
--   raise notice 'v_federal_tax_incentive_rate %',v_federal_tax_incentive_rate;
--   raise notice 'v_federal_tax_incentive_amount_100_cash %',v_federal_tax_incentive_amount_100_cash;


  v_monthly_usage_kwh = p_average_monthly_bill / v_utility_rate_kwh;
  v_annual_usage_kwh = v_monthly_usage_kwh * 12;
  v_system_size_kw_100_percent_offset = round((v_annual_usage_kwh / v_average_production_factor / 1000), 2);
  v_system_size_kw_85_percent_offset = round(((v_annual_usage_kwh * .85) / v_average_production_factor / 1000), 2);
  v_system_size_kw_115_percent_offset = round(((v_annual_usage_kwh * 1.15) / v_average_production_factor / 1000), 2);
  v_cash_price_for_100_percent_offset =
    v_system_size_kw_100_percent_offset * coalesce(v_dealer_redline_price, 2.52) * 1000;
  v_cash_price_for_85_percent_offset =
    v_system_size_kw_85_percent_offset * coalesce(v_dealer_redline_price, 2.52) * 1000;
  v_cash_price_for_115_percent_offset =
    v_system_size_kw_115_percent_offset * coalesce(v_dealer_redline_price, 2.52) * 1000;
  v_month_pmt_100_offset_low_dealer_fee =
    ((v_cash_price_for_100_percent_offset + v_battery_price) / (1 - v_dealer_fee_10_year_low_dealer_fee)) *
    v_init_pmt_factor_10_year_low_dealer_fee;
  v_month_pmt_85_offset_low_dealer_fee =
    ((v_cash_price_for_85_percent_offset + v_battery_price) / (1 - v_dealer_fee_10_year_low_dealer_fee)) *
    v_init_pmt_factor_10_year_low_dealer_fee;
  v_month_pmt_115_offset_low_dealer_fee =
    ((v_cash_price_for_115_percent_offset + v_battery_price) / (1 - v_dealer_fee_10_year_low_dealer_fee)) *
    v_init_pmt_factor_10_year_low_dealer_fee;
  v_total_system_cost_100_offset_low_dealer_fee =
    (v_cash_price_for_100_percent_offset / (1 - v_dealer_fee_10_year_low_dealer_fee));
  v_total_system_cost_85_offset_low_dealer_fee =
    (v_cash_price_for_85_percent_offset / (1 - v_dealer_fee_10_year_low_dealer_fee));
  v_total_system_cost_115_offset_low_dealer_fee =
    (v_cash_price_for_115_percent_offset / (1 - v_dealer_fee_10_year_low_dealer_fee));
  v_month_pmt_100_offset_low_month_pmt =
    ((v_cash_price_for_100_percent_offset + v_battery_price) / (1 - v_dealer_fee_25_year_low_payment)) *
    v_init_pmt_factor_25_year_low_payment;
  v_month_pmt_85_offset_low_month_pmt =
    ((v_cash_price_for_85_percent_offset + v_battery_price) / (1 - v_dealer_fee_25_year_low_payment)) *
    v_init_pmt_factor_25_year_low_payment;
  v_month_pmt_115_offset_low_month_pmt =
    ((v_cash_price_for_115_percent_offset + v_battery_price) / (1 - v_dealer_fee_25_year_low_payment)) *
    v_init_pmt_factor_25_year_low_payment;
  v_total_system_cost_100_offset_low_month_pmt =
    (v_cash_price_for_100_percent_offset / (1 - v_dealer_fee_25_year_low_payment));
  v_total_system_cost_85_offset_low_month_pmt =
    (v_cash_price_for_85_percent_offset / (1 - v_dealer_fee_25_year_low_payment));
  v_total_system_cost_115_offset_low_month_pmt =
    (v_cash_price_for_115_percent_offset / (1 - v_dealer_fee_25_year_low_payment));


  v_remaining_mon_electric_bill_25_year_average_100 = brs.get_year_avg_remaining_monthly_electric_bill(
    v_utility_rate_kwh,
    v_utility_cost_escalator,
    v_annual_usage_kwh,
    v_annual_usage_kwh * 1,
    .005::numeric,
    25);

  v_remaining_mon_electric_bill_25_year_average_85 = brs.get_year_avg_remaining_monthly_electric_bill(
    v_utility_rate_kwh,
    v_utility_cost_escalator,
    v_annual_usage_kwh,
    v_annual_usage_kwh * .85,
    .005::numeric,
    25);

  v_remaining_mon_electric_bill_25_year_average_115 = brs.get_year_avg_remaining_monthly_electric_bill(
    v_utility_rate_kwh,
    v_utility_cost_escalator,
    v_annual_usage_kwh,
    v_annual_usage_kwh * 1.15,
    .005::numeric,
    25);

  v_total_cost_25_years = brs.get_year_cost_by_years(
    v_utility_rate_kwh,
    v_utility_cost_escalator,
    v_annual_usage_kwh,
    25);


  v_federal_tax_incentive_amount_100_cash = v_cash_price_for_100_percent_offset * v_federal_tax_incentive_rate;
  v_federal_tax_incentive_amount_85_cash = v_cash_price_for_85_percent_offset * v_federal_tax_incentive_rate;
  v_federal_tax_incentive_amount_115_cash = v_cash_price_for_115_percent_offset * v_federal_tax_incentive_rate;

  v_battery_federal_tax_incentive_amount_cash = v_battery_price * v_federal_tax_incentive_rate;
  v_battery_federal_tax_incentive_amount_low_mon_pay =
    v_financed_battery_price_low_month_pmt * v_federal_tax_incentive_rate;
  v_battery_federal_tax_incentive_amount_low_dealer_fee =
    v_financed_battery_price_low_dealer_fee * v_federal_tax_incentive_rate;

  v_federal_tax_incentive_amount_100_low_dealer_fee =
    v_total_system_cost_100_offset_low_dealer_fee * v_federal_tax_incentive_rate;
  v_federal_tax_incentive_amount_85_low_dealer_fee =
    v_total_system_cost_85_offset_low_dealer_fee * v_federal_tax_incentive_rate;
  v_federal_tax_incentive_amount_115_low_dealer_fee =
    v_total_system_cost_115_offset_low_dealer_fee * v_federal_tax_incentive_rate;
  v_federal_tax_incentive_amount_100_low_mon_pay =
    v_total_system_cost_100_offset_low_month_pmt * v_federal_tax_incentive_rate;
  v_federal_tax_incentive_amount_85_low_mon_pay =
    v_total_system_cost_85_offset_low_month_pmt * v_federal_tax_incentive_rate;
  v_federal_tax_incentive_amount_115_low_mon_pay =
    v_total_system_cost_115_offset_low_month_pmt * v_federal_tax_incentive_rate;
  --   raise notice 'v_total_cost_25_years %',v_total_cost_25_years;
--   raise notice 'v_remaining_mon_electric_bill_25_year_average_100 %',v_remaining_mon_electric_bill_25_year_average_100;
--   raise notice 'v_cash_price_for_100_percent_offset %',v_cash_price_for_100_percent_offset;
--   raise notice 'v_federal_tax_incentive_amount_100_cash %',v_federal_tax_incentive_amount_100_cash;


  v_twenty_five_year_savings_cash_100_offset =
    v_total_cost_25_years - ((v_remaining_mon_electric_bill_25_year_average_100 * 12 * 25) +
                             v_cash_price_for_100_percent_offset) + v_federal_tax_incentive_amount_100_cash;

  v_twenty_five_year_savings_cash_85_offset =
    v_total_cost_25_years - ((v_remaining_mon_electric_bill_25_year_average_85 * 12 * 25) +
                             v_cash_price_for_85_percent_offset) + v_federal_tax_incentive_amount_85_cash;

  v_twenty_five_year_savings_cash_115_offset =
    v_total_cost_25_years - ((v_remaining_mon_electric_bill_25_year_average_115 * 12 * 25) +
                             v_cash_price_for_115_percent_offset) + v_federal_tax_incentive_amount_115_cash;

  v_twenty_five_year_savings_low_dealer_fee_100_offset =
    v_total_cost_25_years - ((v_remaining_mon_electric_bill_25_year_average_100 * 12 * 25) +
                             v_total_system_cost_100_offset_low_dealer_fee) +
    v_federal_tax_incentive_amount_100_low_dealer_fee;

  v_twenty_five_year_savings_low_dealer_fee_85_offset =
    v_total_cost_25_years - ((v_remaining_mon_electric_bill_25_year_average_85 * 12 * 25) +
                             v_total_system_cost_85_offset_low_dealer_fee) +
    v_federal_tax_incentive_amount_85_low_dealer_fee;

  v_twenty_five_year_savings_low_dealer_fee_115_offset =
    v_total_cost_25_years - ((v_remaining_mon_electric_bill_25_year_average_115 * 12 * 25) +
                             v_total_system_cost_115_offset_low_dealer_fee) +
    v_federal_tax_incentive_amount_115_low_dealer_fee;

  v_twenty_five_year_savings_low_payment_100_offset =
    v_total_cost_25_years - ((v_remaining_mon_electric_bill_25_year_average_100 * 12 * 25) +
                             v_total_system_cost_100_offset_low_month_pmt) +
    v_federal_tax_incentive_amount_100_low_mon_pay;

  v_twenty_five_year_savings_low_payment_85_offset =
    v_total_cost_25_years - ((v_remaining_mon_electric_bill_25_year_average_85 * 12 * 25) +
                             v_total_system_cost_85_offset_low_month_pmt) +
    v_federal_tax_incentive_amount_85_low_mon_pay;

  v_twenty_five_year_savings_low_payment_115_offset =
    v_total_cost_25_years - ((v_remaining_mon_electric_bill_25_year_average_115 * 12 * 25) +
                             v_total_system_cost_115_offset_low_month_pmt) +
    v_federal_tax_incentive_amount_115_low_mon_pay;


  v_net_system_cost_100_offset_low_dealer_fee =
    v_total_system_cost_100_offset_low_dealer_fee - v_federal_tax_incentive_amount_100_low_dealer_fee;
  v_net_system_cost_85_offset_low_dealer_fee =
    v_total_system_cost_85_offset_low_dealer_fee - v_federal_tax_incentive_amount_85_low_dealer_fee;
  v_net_system_cost_115_offset_low_dealer_fee =
    v_total_system_cost_115_offset_low_dealer_fee - v_federal_tax_incentive_amount_115_low_dealer_fee;

  v_net_system_cost_100_offset_low_month_pmt =
    v_total_system_cost_100_offset_low_month_pmt - v_federal_tax_incentive_amount_100_low_mon_pay;
  v_net_system_cost_85_offset_low_month_pmt =
    v_total_system_cost_85_offset_low_month_pmt - v_federal_tax_incentive_amount_85_low_mon_pay;
  v_net_system_cost_115_offset_low_month_pmt =
    v_total_system_cost_115_offset_low_month_pmt - v_federal_tax_incentive_amount_115_low_mon_pay;


  v_net_cash_price_for_100_percent_offset =
    v_cash_price_for_100_percent_offset - v_federal_tax_incentive_amount_100_cash;
  v_net_cash_price_for_85_percent_offset = v_cash_price_for_85_percent_offset - v_federal_tax_incentive_amount_85_cash;
  v_net_cash_price_for_115_percent_offset =
    v_cash_price_for_115_percent_offset - v_federal_tax_incentive_amount_115_cash;

  raise notice 'v_federal_tax_incentive_amount_100_low_dealer_fee %',v_federal_tax_incentive_amount_100_low_dealer_fee;
  raise notice 'v_net_system_cost_100_offset_low_dealer_fee %',v_net_system_cost_100_offset_low_dealer_fee;
  return query
    select v_average_production_factor,
           v_utility_rate_kwh,
           round(v_monthly_usage_kwh),
           round(v_annual_usage_kwh),
           v_system_size_kw_100_percent_offset,
           v_system_size_kw_85_percent_offset,
           v_system_size_kw_115_percent_offset,
           round(v_cash_price_for_100_percent_offset + v_battery_price),
           round(v_cash_price_for_100_percent_offset),
           round(v_cash_price_for_85_percent_offset + v_battery_price),
           round(v_cash_price_for_85_percent_offset),
           round(v_cash_price_for_115_percent_offset + v_battery_price),
           round(v_cash_price_for_115_percent_offset),
           v_init_pmt_factor_10_year_low_dealer_fee,
           v_init_pmt_factor_25_year_low_payment,
           v_dealer_fee_10_year_low_dealer_fee,
           v_dealer_fee_25_year_low_payment,
           round(v_month_pmt_100_offset_low_dealer_fee),
           round(v_month_pmt_85_offset_low_dealer_fee),
           round(v_month_pmt_115_offset_low_dealer_fee),
           round(v_total_system_cost_100_offset_low_dealer_fee + v_financed_battery_price_low_dealer_fee),
           round(v_total_system_cost_100_offset_low_dealer_fee),
           round(v_total_system_cost_85_offset_low_dealer_fee + v_financed_battery_price_low_dealer_fee),
           round(v_total_system_cost_85_offset_low_dealer_fee),
           round(v_total_system_cost_115_offset_low_dealer_fee + v_financed_battery_price_low_dealer_fee),
           round(v_total_system_cost_115_offset_low_dealer_fee),
           round(v_month_pmt_100_offset_low_month_pmt),
           round(v_month_pmt_85_offset_low_month_pmt),
           round(v_month_pmt_115_offset_low_month_pmt),
           round(v_total_system_cost_100_offset_low_month_pmt + v_financed_battery_price_low_month_pmt),
           round(v_total_system_cost_100_offset_low_month_pmt),
           round(v_total_system_cost_85_offset_low_month_pmt + v_financed_battery_price_low_month_pmt),
           round(v_total_system_cost_85_offset_low_month_pmt),
           round(v_total_system_cost_115_offset_low_month_pmt + v_financed_battery_price_low_month_pmt),
           round(v_total_system_cost_115_offset_low_month_pmt),
           v_apr_low_dealer_fee_option,
           v_term_low_dealer_fee_option,
           v_apr_low_monthly_option,
           v_term_low_monthly_option,
           v_utility_cost_escalator,
           round(v_twenty_five_year_savings_cash_100_offset),
           round(v_twenty_five_year_savings_cash_85_offset),
           round(v_twenty_five_year_savings_cash_115_offset),
           round(v_twenty_five_year_savings_low_dealer_fee_100_offset),
           round(v_twenty_five_year_savings_low_dealer_fee_85_offset),
           round(v_twenty_five_year_savings_low_dealer_fee_115_offset),
           round(v_twenty_five_year_savings_low_payment_100_offset),
           round(v_twenty_five_year_savings_low_payment_85_offset),
           round(v_twenty_five_year_savings_low_payment_115_offset),
           round(v_net_system_cost_100_offset_low_dealer_fee + v_financed_battery_price_low_dealer_fee -
                 v_battery_federal_tax_incentive_amount_low_dealer_fee),
           round(v_net_system_cost_100_offset_low_dealer_fee),
           round(v_net_system_cost_85_offset_low_dealer_fee + v_financed_battery_price_low_dealer_fee -
                 v_battery_federal_tax_incentive_amount_low_dealer_fee),
           round(v_net_system_cost_85_offset_low_dealer_fee),
           round(v_net_system_cost_115_offset_low_dealer_fee + v_financed_battery_price_low_dealer_fee -
                 v_battery_federal_tax_incentive_amount_low_dealer_fee),
           round(v_net_system_cost_115_offset_low_dealer_fee),
           round(v_net_system_cost_100_offset_low_month_pmt + v_financed_battery_price_low_month_pmt -
                 v_battery_federal_tax_incentive_amount_low_mon_pay),
           round(v_net_system_cost_100_offset_low_month_pmt),
           round(v_net_system_cost_85_offset_low_month_pmt + v_financed_battery_price_low_month_pmt -
                 v_battery_federal_tax_incentive_amount_low_mon_pay),
           round(v_net_system_cost_85_offset_low_month_pmt),
           round(v_net_system_cost_115_offset_low_month_pmt + v_financed_battery_price_low_month_pmt -
                 v_battery_federal_tax_incentive_amount_low_mon_pay),
           round(v_net_system_cost_115_offset_low_month_pmt),
           round(v_net_cash_price_for_100_percent_offset + v_battery_price -
                 v_battery_federal_tax_incentive_amount_cash),
           round(v_net_cash_price_for_100_percent_offset),
           round(v_net_cash_price_for_85_percent_offset + v_battery_price -
                 v_battery_federal_tax_incentive_amount_cash),
           round(v_net_cash_price_for_85_percent_offset),
           round(v_net_cash_price_for_115_percent_offset + v_battery_price -
                 v_battery_federal_tax_incentive_amount_cash),
           round(v_net_cash_price_for_115_percent_offset),
           round(v_battery_price),
           round(v_financed_battery_price_low_dealer_fee),
           round(v_financed_battery_price_low_month_pmt);

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;

