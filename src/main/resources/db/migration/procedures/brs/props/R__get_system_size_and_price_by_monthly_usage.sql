drop function if exists brs.get_system_size_and_price_by_monthly_usage(p_state_abbrev text,
                                                                       p_average_monthly_bill numeric,
                                                                       p_utility_id integer,
                                                                       p_number_of_batteries integer);
CREATE OR REPLACE FUNCTION brs.get_system_size_and_price_by_monthly_usage(p_state_abbrev text,
                                                                          p_average_monthly_bill numeric,
                                                                          p_utility_id integer,
                                                                          p_number_of_batteries integer)
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
            net_system_cost_85_offset_low_dealer_fee           numeric,
            net_system_cost_115_offset_low_dealer_fee          numeric,
            net_system_cost_100_offset_low_month_pmt           numeric,
            net_system_cost_85_offset_low_month_pmt            numeric,
            net_system_cost_115_offset_low_month_pmt           numeric,
            net_cash_price_for_100_percent_offset              numeric,
            net_cash_price_for_85_percent_offset               numeric,
            net_cash_price_for_115_percent_offset              numeric,
            battery_price                                      numeric
          )
AS
$BODY$
declare
  v_state_id                                           bigint;
  v_average_production_factor                          numeric;
  v_utility_rate_kwh                                   numeric;
  v_monthly_usage_kwh                                  numeric;
  v_annual_usage_kwh                                   numeric;
  v_system_size_kw_100_percent_offset                  numeric;
  v_system_size_kw_85_percent_offset                   numeric;
  v_system_size_kw_115_percent_offset                  numeric;
  v_cash_price_for_100_percent_offset                  numeric;
  v_cash_price_for_85_percent_offset                   numeric;
  v_cash_price_for_115_percent_offset                  numeric;
  v_net_cash_price_for_100_percent_offset              numeric;
  v_net_cash_price_for_85_percent_offset               numeric;
  v_net_cash_price_for_115_percent_offset              numeric;
  v_init_pmt_factor_10_year_low_dealer_fee             numeric;
  v_init_pmt_factor_25_year_low_payment                numeric;
  v_dealer_fee_10_year_low_dealer_fee                  numeric;
  v_dealer_fee_25_year_low_payment                     numeric;
  v_month_pmt_100_offset_low_dealer_fee                numeric;
  v_month_pmt_85_offset_low_dealer_fee                 numeric;
  v_month_pmt_115_offset_low_dealer_fee                numeric;
  v_total_system_cost_100_offset_low_dealer_fee        numeric;
  v_net_system_cost_100_offset_low_dealer_fee          numeric;
  v_total_system_cost_85_offset_low_dealer_fee         numeric;
  v_net_system_cost_85_offset_low_dealer_fee           numeric;
  v_total_system_cost_115_offset_low_dealer_fee        numeric;
  v_net_system_cost_115_offset_low_dealer_fee          numeric;
  v_month_pmt_100_offset_low_month_pmt                 numeric;
  v_month_pmt_85_offset_low_month_pmt                  numeric;
  v_month_pmt_115_offset_low_month_pmt                 numeric;
  v_total_system_cost_100_offset_low_month_pmt         numeric;
  v_net_system_cost_100_offset_low_month_pmt           numeric;
  v_total_system_cost_85_offset_low_month_pmt          numeric;
  v_net_system_cost_85_offset_low_month_pmt            numeric;
  v_total_system_cost_115_offset_low_month_pmt         numeric;
  v_net_system_cost_115_offset_low_month_pmt           numeric;
  v_apr_low_dealer_fee_option                          numeric;
  v_term_low_dealer_fee_option                         numeric;
  v_apr_low_monthly_option                             numeric;
  v_term_low_monthly_option                            numeric;
  v_remaining_mon_electric_bill_25_year_average_100    numeric;
  v_remaining_mon_electric_bill_25_year_average_85     numeric;
  v_remaining_mon_electric_bill_25_year_average_115    numeric;
  v_utility_cost_escalator                             numeric;
  v_twenty_five_year_savings_cash_100_offset           numeric;
  v_monthly_cash_payment                               numeric;
  v_twenty_five_year_savings_cash_85_offset            numeric;
  v_twenty_five_year_savings_cash_115_offset           numeric;
  v_total_cost_25_years                                numeric;
  v_twenty_five_year_savings_low_dealer_fee_100_offset numeric;
  v_twenty_five_year_savings_low_dealer_fee_85_offset  numeric;
  v_twenty_five_year_savings_low_dealer_fee_115_offset numeric;
  v_twenty_five_year_savings_low_payment_100_offset    numeric;
  v_twenty_five_year_savings_low_payment_85_offset     numeric;
  v_twenty_five_year_savings_low_payment_115_offset    numeric;
  v_federal_tax_incentive_rate                         numeric;
  v_federal_unit_type_id                               bigint;
  v_federal_tax_incentive_amount_100_cash              numeric;
  v_federal_tax_incentive_amount_85_cash               numeric;
  v_federal_tax_incentive_amount_115_cash              numeric;
  v_federal_tax_incentive_amount_100_low_dealer_fee    numeric;
  v_federal_tax_incentive_amount_85_low_dealer_fee     numeric;
  v_federal_tax_incentive_amount_115_low_dealer_fee    numeric;
  v_federal_tax_incentive_amount_100_low_mon_pay       numeric;
  v_federal_tax_incentive_amount_85_low_mon_pay        numeric;
  v_federal_tax_incentive_amount_115_low_mon_pay       numeric;
  v_battery_price numeric;

BEGIN
  select sapf.average_production_factor, s.id
  into v_average_production_factor,v_state_id
  from brs.state_average_production_factor sapf
         inner join flow.state s on s.abbreviation = p_state_abbrev
  where sapf.state_id = s.id;
  v_battery_price = 0::numeric;
  if p_number_of_batteries > 0 then
    if v_state_id in (12, 44, 47, 33, 37, 6) then
      v_battery_price = case
                        when p_number_of_batteries = 1 then
                          17000::numeric
                        when p_number_of_batteries = 2 then
                          26000::numeric
                        when p_number_of_batteries = 3 then
                          35000::numeric
                        when p_number_of_batteries = 4 then
                          44000::numeric end;
    else
      v_battery_price = case
                        when p_number_of_batteries = 1 then
                          19000::numeric
                        when p_number_of_batteries = 2 then
                          28000::numeric
                        when p_number_of_batteries = 3 then
                          37000::numeric
                        when p_number_of_batteries = 4 then
                          46000::numeric end;

    end if;
  end if;


  create temp table proposal_value_avg on commit drop as
  with version_values as (select distinct on ( proposal_group_uuid, custom_field_group_assignment_id ) id,
                                                                                                       proposal_group_uuid,
                                                                                                       value,
                                                                                                       field_id,
                                                                                                       object_code
                          from brs.proposal_version_custom_field_value_vw v
                                 inner join brs.primary_company_proposal_version pcpv on pcpv.company_id = 3
                          where v.proposal_version_id <= pcpv.proposal_version_id
                            and v.object_code in ('PROPOSAL_PRICING', 'PROPOSAL_FINANCE_PRODUCTS', 'PROPOSAL_REBATE')
                            and proposal_group_uuid not in (select distinct proposal_group_uuid
                                                            from brs.proposal_version_custom_field_group
                                                            where archived is not null
                                                              and proposal_version_id <= pcpv.proposal_version_id)
                          order by proposal_group_uuid, custom_field_group_assignment_id, id desc),
       grouped_rows as (select jsonb_build_object('pk', proposal_group_uuid,
                                                  'object_code', object_code,
                                                  'fields',
                                                  array_to_json(array_agg(jsonb_strip_nulls(
                                                      jsonb_build_object('fieldId', vv.field_id,
                                                                         'flowCustomFieldId',
                                                                         cf.flow_custom_field_id) || vv.value)))
                                 ) as row
                        from version_values vv
                               inner join brs.custom_field cf on cf.id = vv.field_id
                        group by proposal_group_uuid, object_code)
  select row ->> 'object_code' as object_code, *
  from grouped_rows;


  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 87)') ->> 'value')::numeric as v_utility_rate_kwh,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 94)') ->> 'value')::numeric as utility_cost_escalator
  into v_utility_rate_kwh,v_utility_cost_escalator
  from proposal_value_avg pv
  where object_code = 'PROPOSAL_PRICING'
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.fieldId == $field))', '{
    "field": 85
  }')
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.intValue == $field))',
                         jsonb_build_object('field', p_utility_id));

  --------

  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 111)') ->> 'value')::numeric as v_apr_low_dealer_fee_option,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 110)') ->> 'value')::numeric as v_term_low_dealer_fee_option,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 114)') ->> 'value')::numeric as v_dealer_fee_10_year_low_dealer_fee,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 115)') ->> 'value')::numeric as v_init_pmt_factor_10_year_low_dealer_fee
  into v_apr_low_dealer_fee_option,v_term_low_dealer_fee_option,v_dealer_fee_10_year_low_dealer_fee,
    v_init_pmt_factor_10_year_low_dealer_fee
  from proposal_value_avg pv
  where object_code = 'PROPOSAL_FINANCE_PRODUCTS'
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.fieldId == $field))', '{
    "field": 374
  }')
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.intValue == $intValue))', '{
    "intValue": 1918
  }');


  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 111)') ->> 'value')::numeric as v_apr_low_monthly_option,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 110)') ->> 'value')::numeric as v_term_low_monthly_option,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 114)') ->> 'value')::numeric as v_dealer_fee_25_year_low_payment,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 115)') ->> 'value')::numeric as v_init_pmt_factor_25_year_low_payment
  into v_apr_low_monthly_option,v_term_low_monthly_option,
    v_dealer_fee_25_year_low_payment,v_init_pmt_factor_25_year_low_payment
  from proposal_value_avg pv
  where object_code = 'PROPOSAL_FINANCE_PRODUCTS'
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.fieldId == $field))', '{
    "field": 374
  }')
    and jsonb_path_match(row, 'exists($.fields[*] ? (@.intValue == $intValue))', '{
    "intValue": 1917
  }');


  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 98)') ->> 'value')::numeric    as federal_tax_incentive_rate,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::numeric as federal_unit_type_id
  into v_federal_tax_incentive_rate,v_federal_unit_type_id
  from proposal_value_avg pv
  where object_code = 'PROPOSAL_REBATE'
    and (jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId && @.intValue == $intValue)', '{
    "targetFieldId": 96,
    "intValue": 453
  }'));

  --   raise notice 'v_cash_price_for_100_percent_offset %',v_cash_price_for_100_percent_offset;
--   raise notice 'v_federal_tax_incentive_rate %',v_federal_tax_incentive_rate;
--   raise notice 'v_federal_tax_incentive_amount_100_cash %',v_federal_tax_incentive_amount_100_cash;


  v_monthly_usage_kwh = p_average_monthly_bill / v_utility_rate_kwh;
  v_annual_usage_kwh = v_monthly_usage_kwh * 12;
  v_system_size_kw_100_percent_offset = v_annual_usage_kwh / v_average_production_factor / 1000;
  v_system_size_kw_85_percent_offset = (v_annual_usage_kwh * .85) / v_average_production_factor / 1000;
  v_system_size_kw_115_percent_offset = (v_annual_usage_kwh * 1.15) / v_average_production_factor / 1000;
  v_cash_price_for_100_percent_offset = v_system_size_kw_100_percent_offset * 2.60 * 1000;
  v_cash_price_for_85_percent_offset = v_system_size_kw_85_percent_offset * 2.60 * 1000;
  v_cash_price_for_115_percent_offset = v_system_size_kw_115_percent_offset * 2.60 * 1000;
  v_month_pmt_100_offset_low_dealer_fee =
      (v_cash_price_for_100_percent_offset / (1 - v_dealer_fee_10_year_low_dealer_fee)) *
      v_init_pmt_factor_10_year_low_dealer_fee;
  v_month_pmt_85_offset_low_dealer_fee =
      (v_cash_price_for_85_percent_offset / (1 - v_dealer_fee_10_year_low_dealer_fee)) *
      v_init_pmt_factor_10_year_low_dealer_fee;
  v_month_pmt_115_offset_low_dealer_fee =
      (v_cash_price_for_115_percent_offset / (1 - v_dealer_fee_10_year_low_dealer_fee)) *
      v_init_pmt_factor_10_year_low_dealer_fee;
  v_total_system_cost_100_offset_low_dealer_fee =
    (v_cash_price_for_100_percent_offset / (1 - v_dealer_fee_10_year_low_dealer_fee));
  v_total_system_cost_85_offset_low_dealer_fee =
    (v_cash_price_for_85_percent_offset / (1 - v_dealer_fee_10_year_low_dealer_fee));
  v_total_system_cost_115_offset_low_dealer_fee =
    (v_cash_price_for_115_percent_offset / (1 - v_dealer_fee_10_year_low_dealer_fee));
  v_month_pmt_100_offset_low_month_pmt =
      (v_cash_price_for_100_percent_offset / (1 - v_dealer_fee_25_year_low_payment)) *
      v_init_pmt_factor_25_year_low_payment;
  v_month_pmt_85_offset_low_month_pmt = (v_cash_price_for_85_percent_offset / (1 - v_dealer_fee_25_year_low_payment)) *
                                        v_init_pmt_factor_25_year_low_payment;
  v_month_pmt_115_offset_low_month_pmt =
      (v_cash_price_for_115_percent_offset / (1 - v_dealer_fee_25_year_low_payment)) *
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

  return query
    select v_average_production_factor,
           v_utility_rate_kwh,
           round(v_monthly_usage_kwh),
           round(v_annual_usage_kwh),
           round(v_system_size_kw_100_percent_offset, 1),
           round(v_system_size_kw_85_percent_offset, 1),
           round(v_system_size_kw_115_percent_offset, 1),
           round(v_cash_price_for_100_percent_offset + v_battery_price),
           round(v_cash_price_for_100_percent_offset ),
           round(v_cash_price_for_85_percent_offset + v_battery_price),
           round(v_cash_price_for_85_percent_offset ),
           round(v_cash_price_for_115_percent_offset+ v_battery_price),
           round(v_cash_price_for_115_percent_offset),
           v_init_pmt_factor_10_year_low_dealer_fee,
           v_init_pmt_factor_25_year_low_payment,
           v_dealer_fee_10_year_low_dealer_fee,
           v_dealer_fee_25_year_low_payment,
           round(v_month_pmt_100_offset_low_dealer_fee),
           round(v_month_pmt_85_offset_low_dealer_fee),
           round(v_month_pmt_115_offset_low_dealer_fee),
           round(v_total_system_cost_100_offset_low_dealer_fee+ v_battery_price),
           round(v_total_system_cost_100_offset_low_dealer_fee),
           round(v_total_system_cost_85_offset_low_dealer_fee+ v_battery_price),
           round(v_total_system_cost_85_offset_low_dealer_fee),
           round(v_total_system_cost_115_offset_low_dealer_fee+ v_battery_price),
           round(v_total_system_cost_115_offset_low_dealer_fee),
           round(v_month_pmt_100_offset_low_month_pmt),
           round(v_month_pmt_85_offset_low_month_pmt),
           round(v_month_pmt_115_offset_low_month_pmt),
           round(v_total_system_cost_100_offset_low_month_pmt+ v_battery_price),
           round(v_total_system_cost_100_offset_low_month_pmt),
           round(v_total_system_cost_85_offset_low_month_pmt+ v_battery_price),
           round(v_total_system_cost_85_offset_low_month_pmt),
           round(v_total_system_cost_115_offset_low_month_pmt+ v_battery_price),
           round(v_total_system_cost_115_offset_low_month_pmt),
           v_apr_low_dealer_fee_option,
           v_term_low_dealer_fee_option,
           v_apr_low_monthly_option,
           v_term_low_monthly_option,
           v_utility_cost_escalator,
           round(v_twenty_five_year_savings_cash_100_offset, 2),
           round(v_twenty_five_year_savings_cash_85_offset),
           round(v_twenty_five_year_savings_cash_115_offset),
           round(v_twenty_five_year_savings_low_dealer_fee_100_offset),
           round(v_twenty_five_year_savings_low_dealer_fee_85_offset),
           round(v_twenty_five_year_savings_low_dealer_fee_115_offset),
           round(v_twenty_five_year_savings_low_payment_100_offset),
           round(v_twenty_five_year_savings_low_payment_85_offset),
           round(v_twenty_five_year_savings_low_payment_115_offset),
           round(v_net_system_cost_100_offset_low_dealer_fee),
           round(v_net_system_cost_85_offset_low_dealer_fee),
           round(v_net_system_cost_115_offset_low_dealer_fee),
           round(v_net_system_cost_100_offset_low_month_pmt),
           round(v_net_system_cost_85_offset_low_month_pmt),
           round(v_net_system_cost_115_offset_low_month_pmt),
           round(v_net_cash_price_for_100_percent_offset),
           round(v_net_cash_price_for_85_percent_offset),
           round(v_net_cash_price_for_115_percent_offset),
           v_battery_price;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;

