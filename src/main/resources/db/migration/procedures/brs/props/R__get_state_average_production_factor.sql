drop function if exists brs.get_system_size_and_price_by_monthly_usage(p_state_id bigint,
                                                                       p_average_monthly_bill numeric,
                                                                       p_utility_id integer);
CREATE OR REPLACE FUNCTION brs.get_system_size_and_price_by_monthly_usage(p_state_id bigint,
                                                                          p_average_monthly_bill numeric,
                                                                          p_utility_id integer)
  returns table
          (
            average_production_factor                    numeric,
            utility_rate                                 numeric,
            monthly_usage_kwh                            numeric,
            annual_usage_kwh                             numeric,
            system_size_kw_100_percent_offset            numeric,
            system_size_kw_85_percent_offset             numeric,
            system_size_kw_115_percent_offset            numeric,
            cash_price_for_100_percent_offset            numeric,
            cash_price_for_85_percent_offset             numeric,
            cash_price_for_115_percent_offset            numeric,
            init_pmt_factor_10_year_low_dealer_fee       numeric,
            init_pmt_factor_25_year_low_payment          numeric,
            dealer_fee_10_year_low_dealer_fee            numeric,
            dealer_fee_25_year_low_payment               numeric,
            month_pmt_100_offset_low_dealer_fee          numeric,
            month_pmt_85_offset_low_dealer_fee           numeric,
            month_pmt_115_offset_low_dealer_fee          numeric,
            total_system_cost_100_offset_low_dealer_fee  numeric,
            total_system_cost_85_offset_low_dealer_fee   numeric,
            total_system_cost_115_offset_low_dealer_fee  numeric,
            month_pmt_100_offset_low_monthly_pmt         numeric,
            month_pmt_85_offset_low_monthly_pmt          numeric,
            month_pmt_115_offset_low_monthly_pmt         numeric,
            total_system_cost_100_offset_low_monthly_pmt numeric,
            total_system_cost_85_offset_low_monthly_pmt  numeric,
            total_system_cost_115_offset_low_monthly_pmt numeric
          )
AS
$BODY$
declare
  v_average_production_factor                   numeric;
  v_utility_rate_kwh                            numeric;
  v_monthly_usage_kwh                           numeric;
  v_annual_usage_kwh                            numeric;
  v_system_size_kw_100_percent_offset           numeric;
  v_system_size_kw_85_percent_offset            numeric;
  v_system_size_kw_115_percent_offset           numeric;
  v_cash_price_for_100_percent_offset           numeric;
  v_cash_price_for_85_percent_offset            numeric;
  v_cash_price_for_115_percent_offset           numeric;
  v_init_pmt_factor_10_year_low_dealer_fee      numeric;
  v_init_pmt_factor_25_year_low_payment         numeric;
  v_dealer_fee_10_year_low_dealer_fee           numeric;
  v_dealer_fee_25_year_low_payment              numeric;
  v_month_pmt_100_offset_low_dealer_fee         numeric;
  v_month_pmt_85_offset_low_dealer_fee          numeric;
  v_month_pmt_115_offset_low_dealer_fee         numeric;
  v_total_system_cost_100_offset_low_dealer_fee numeric;
  v_total_system_cost_85_offset_low_dealer_fee  numeric;
  v_total_system_cost_115_offset_low_dealer_fee numeric;
  v_month_pmt_100_offset_low_month_pmt          numeric;
  v_month_pmt_85_offset_low_month_pmt           numeric;
  v_month_pmt_115_offset_low_month_pmt          numeric;
  v_total_system_cost_100_offset_low_month_pmt  numeric;
  v_total_system_cost_85_offset_low_month_pmt   numeric;
  v_total_system_cost_115_offset_low_month_pmt  numeric;

BEGIN
  select sapf.average_production_factor
  into v_average_production_factor
  from brs.state_average_production_factor sapf
  where sapf.state_id = p_state_id;

  with utility_group as (select vw.proposal_group_uuid
                         from brs.proposal_version_custom_field_value_vw vw
                                inner join brs.proposal_version pv
                                           on pv.id = vw.proposal_version_id and pv.proposal_version_status_id = 2
                         where object_code = 'PROPOSAL_PRICING'
                           and field_id = 85
                           and (value ->> 'intValue')::integer = p_utility_id)
  select (vw.value ->> 'value')::numeric
  into v_utility_rate_kwh
  from brs.proposal_version_custom_field_value_vw vw
         inner join utility_group ug on ug.proposal_group_uuid = vw.proposal_group_uuid
         inner join brs.proposal_version pv on pv.id = vw.proposal_version_id and pv.proposal_version_status_id = 2
  where vw.field_id = 87
  order by vw.proposal_version_id desc
  limit 1;

  --------

  with low_dealer_fee_initial_payment_factor as (select vw.proposal_group_uuid
                                                 from brs.proposal_version_custom_field_value_vw vw
                                                      -- inner join brs.proposal_version pv on pv.id = vw.proposal_version_id and pv.proposal_version_status_id = 2
                                                 where object_code = 'PROPOSAL_FINANCE_PRODUCTS'
                                                   and field_id = 374
                                                   and (value ->> 'intValue')::integer = 1918)--low dealer fee
  select (vw.value ->> 'value')::numeric
  into v_init_pmt_factor_10_year_low_dealer_fee
  from brs.proposal_version_custom_field_value_vw vw
         inner join low_dealer_fee_initial_payment_factor ug on ug.proposal_group_uuid = vw.proposal_group_uuid
       --  inner join brs.proposal_version pv on pv.id = vw.proposal_version_id and pv.proposal_version_status_id = 2
  where vw.field_id = 115 --Initial Monthly Payment Factor
  order by vw.proposal_version_id desc
  limit 1;

  with low_dealer_fee_low_dealer_fee as (select vw.proposal_group_uuid
                                         from brs.proposal_version_custom_field_value_vw vw
                                              -- inner join brs.proposal_version pv on pv.id = vw.proposal_version_id and pv.proposal_version_status_id = 2
                                         where object_code = 'PROPOSAL_FINANCE_PRODUCTS'
                                           and field_id = 374
                                           and (value ->> 'intValue')::integer = 1918)--low dealer fee
  select (vw.value ->> 'value')::numeric
  into v_dealer_fee_10_year_low_dealer_fee
  from brs.proposal_version_custom_field_value_vw vw
         inner join low_dealer_fee_low_dealer_fee ug on ug.proposal_group_uuid = vw.proposal_group_uuid
       --  inner join brs.proposal_version pv on pv.id = vw.proposal_version_id and pv.proposal_version_status_id = 2
  where vw.field_id = 114 --dealer fee
  order by vw.proposal_version_id desc
  limit 1;


  with low_monthly_payment_inital_payment_factor as (select vw.proposal_group_uuid
                                                     from brs.proposal_version_custom_field_value_vw vw
                                                          -- inner join brs.proposal_version pv on pv.id = vw.proposal_version_id and pv.proposal_version_status_id = 2
                                                     where object_code = 'PROPOSAL_FINANCE_PRODUCTS'
                                                       and field_id = 374
                                                       and (value ->> 'intValue')::integer = 1917) --low monthly payment
  select (vw.value ->> 'value')::numeric
  into v_init_pmt_factor_25_year_low_payment
  from brs.proposal_version_custom_field_value_vw vw
         inner join low_monthly_payment_inital_payment_factor ug on ug.proposal_group_uuid = vw.proposal_group_uuid
       -- inner join brs.proposal_version pv on pv.id = vw.proposal_version_id and pv.proposal_version_status_id = 2
  where vw.field_id = 115 --Initial Monthly Payment Factor
  order by vw.proposal_version_id desc
  limit 1;


  with low_montly_payment_dealer_fee as (select vw.proposal_group_uuid
                                         from brs.proposal_version_custom_field_value_vw vw
                                              -- inner join brs.proposal_version pv on pv.id = vw.proposal_version_id and pv.proposal_version_status_id = 2
                                         where object_code = 'PROPOSAL_FINANCE_PRODUCTS'
                                           and field_id = 374
                                           and (value ->> 'intValue')::integer = 1917) --low monthly payment
  select (vw.value ->> 'value')::numeric
  into v_dealer_fee_25_year_low_payment
  from brs.proposal_version_custom_field_value_vw vw
         inner join low_montly_payment_dealer_fee ug on ug.proposal_group_uuid = vw.proposal_group_uuid
       -- inner join brs.proposal_version pv on pv.id = vw.proposal_version_id and pv.proposal_version_status_id = 2
  where vw.field_id = 114 --dealer fee
  order by vw.proposal_version_id desc
  limit 1;


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

  return query
    select v_average_production_factor,
           v_utility_rate_kwh,
           round(v_monthly_usage_kwh, 2),
           round(v_annual_usage_kwh, 2),
           round(v_system_size_kw_100_percent_offset, 2),
           round(v_system_size_kw_85_percent_offset, 2),
           round(v_system_size_kw_115_percent_offset, 2),
           round(v_cash_price_for_100_percent_offset, 2),
           round(v_cash_price_for_85_percent_offset, 2),
           round(v_cash_price_for_115_percent_offset, 2),
           v_init_pmt_factor_10_year_low_dealer_fee,
           v_init_pmt_factor_25_year_low_payment,
           v_dealer_fee_10_year_low_dealer_fee,
           v_dealer_fee_25_year_low_payment,
           round(v_month_pmt_100_offset_low_dealer_fee, 2),
           round(v_month_pmt_85_offset_low_dealer_fee, 2),
           round(v_month_pmt_115_offset_low_dealer_fee, 2),
           round(v_total_system_cost_100_offset_low_dealer_fee, 2),
           round(v_total_system_cost_85_offset_low_dealer_fee, 2),
           round(v_total_system_cost_115_offset_low_dealer_fee, 2),
           round(v_month_pmt_100_offset_low_month_pmt, 2),
           round(v_month_pmt_85_offset_low_month_pmt, 2),
           round(v_month_pmt_115_offset_low_month_pmt, 2),
           round(v_total_system_cost_100_offset_low_month_pmt, 2),
           round(v_total_system_cost_85_offset_low_month_pmt, 2),
           round(v_total_system_cost_115_offset_low_month_pmt, 2);

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;

